function [s,info,errmsg] = parxrecon(sdir,options)
% [s,info,errmsg] = parxrecon(sdir,options)
%
% Reconstruct a 2D or 3D paravision dataset from the FID data
% - handle split-echo recon (eg for UFLARE)
% - FID breakthrough filter (one-sided fermi filter in read direction)
%
% ARGS:
% sdir    = scan directory containing fid to recon
% options = recon options
% .filttype  = 'none', 'hamming', 'gauss' or 'fermi' ['fermi']
% .fr        = filter radius [0.47]. For Gauss filter, spatial HWHM in
%              voxels
% .fw        = filter width (Fermi only) [0.03]
% .zpad      = zero padding factor [1]
% .fidw      = FID filter width [0.0 -> no filter applied]. 0.05 works.
% .imtype    = returned image type 'm' (magnitude) or 'c' (complex) ['m']
% .zip       = zipper plane to correct [x y z]. Use -1 for no correction.
% .nifti     = write Nifti image to FSL subdirectory [true]
%
% RETURNS:
% s      = reconstructed magnitude dataset
% info   = study information structure
% errmsg = error messages. Empty if all ok.
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 05/08/2002 JMT From scratch
%          02/03/2003 JMT Add support for PvM DWI-BIC_RARE method
%          11/26/2003 JMT Generalize for all paravision datasets
%          02/28/2004 JMT Add options
%          03/22/2004 JMT Add FID filter
%          01/17/2006 JMT M-Lint corrections
%          2015-04-06 JMT Add optional Nifti output
%
% The MIT License (MIT)
%
% Copyright (c) 2016 Mike Tyszka
%
%   Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
%   documentation files (the "Software"), to deal in the Software without restriction, including without limitation the
%   rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
%   permit persons to whom the Software is furnished to do so, subject to the following conditions:
%
%   The above copyright notice and this permission notice shall be included in all copies or substantial portions of the
%   Software.
%
%   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
%   WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
%   COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
%   OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

% Internal flags
verbose = true;

% Initialize the options structure if absent
if nargin < 2; options.filttype = 'none'; end

% Tidy up options structure
if ~isfield(options,'filttype'); options.filttype = 'none'; end
if ~isfield(options,'fr');       options.fr = 0.5;          end
if ~isfield(options,'fw');       options.fw = 0.01;         end
if ~isfield(options,'zpad');     options.zpad = 1;          end
if ~isfield(options,'fidw');     options.fidw = 0;          end
if ~isfield(options,'imtype');   options.imtype = 'm';      end
if ~isfield(options,'zip');      options.zip = [-1 -1 -1];  end
if ~isfield(options,'nifti');    options.nifti = 'true';    end

if verbose; fprintf('START PARXRECON\n'); end

% Initialize return matrix
s = [];
info = [];

% Determine acquisition method type
if verbose; fprintf('  Checking acquisition type: '); end
acqmeth = parxacqmeth(sdir);

% Load FID data
switch acqmeth
  case 'imnd'
    if verbose; fprintf('imnd\n'); end
    [k, info, errmsg] = parxloadfid(sdir);
  case 'pvm'
    if verbose; fprintf('pvm\n'); end
    [k, info, errmsg] = pvmloadfid(sdir);    
  otherwise
    if verbose; fprintf('unknown\n'); end
    errmsg = 'Unknown acquisition type';
    return
end

% Check for load problems
if ~isempty(errmsg)
  return
end

% Grab k-space dimensions
[nx,ny,nz] = size(k);
info.dim = [nx ny nz]';
nDim = info.ndim;

switch info.uflare_echopath

  case 'AddedCoherently'
    
    %------------------------------------------------
    % Coherent echo recon
    %------------------------------------------------

    % Apply phase rolls from geometry prescription to each dimension
    if verbose; fprintf('  Applying k-space phase roll\n'); end
    k = pvmphaseroll(k,info);
    
    %----------------------------------------------------------
    % Spatial filter
    %----------------------------------------------------------
  
    if verbose; fprintf('  Spatial filtering: '); end
    switch options.filttype
      
      case 'hamming'
        if verbose; fprintf('Hamming [%f]\n',options.fr); end
        switch nDim
          case 2
            Hfilt = hamming2([nx ny], options.fr, info.echopos/100);
            Hfilt = repmat(Hfilt,[1 1 nz]);
          case 3
            Hfilt = hamming3([nx ny nz], options.fr, info.echopos/100);
        end
        
        % Apply filter
        k = k .* Hfilt;
              
      case 'gauss'
        gauss_fwhm = options.fr * 2;
        if verbose; fprintf('Radial Gauss [FWHM %f voxels]\n',gauss_fwhm); end
        switch nDim
          case 2
            Hfilt = gauss2([nx ny], gauss_fwhm, info.echopos/100);
            Hfilt = repmat(Hfilt,[1 1 nz]);
          case 3
            Hfilt = gauss3([nx ny nz], gauss_fwhm, info.echopos/100);
        end
        
        % Apply filter
        k = k .* Hfilt;
        
      case 'fermi'
        if verbose; fprintf('Fermi [%f %f]\n',options.fr, options.fw); end
        switch nDim
          case 2
            Hfilt = fermi2([nx ny], options.fr, options.fw, info.echopos/100);
          case 3
            Hfilt = fermi3([nx ny nz], options.fr, options.fw, info.echopos/100);
        end

        % Apply filter
        k = k .* Hfilt;
        
      otherwise
        if verbose; fprintf('None\n'); end
        
    end
    
    %----------------------------------------------------------
    % Optional FID filter
    %----------------------------------------------------------
    if options.fidw > 0.0

      if verbose; fprintf('  FID filtering: width %f\n', options.fidw); end
    
      % Construct FID filter for read dimension only
      % Fermi filter is asymmetric. Radius set empirically
      Hfid = fermi(nx, 0.5-options.fidw*5, options.fidw);
      Hfid = flip(Hfid,1);
      Hfid = repmat(Hfid(:), [1 ny nz]);

      % Apply filter
      k = k .* Hfid;
      
    end

    %----------------------------------------------------------
    % Optional zero padding
    %----------------------------------------------------------

    if options.zpad > 1

      if verbose; fprintf('  Zero padding x%d\n', options.zpad); end

      paddims = [nx ny nz] * options.zpad;
      padshift = fix((paddims - [nx ny nz])/2);
      
      % Make space for padded k-space
      kpad = zeros(paddims);
      
      % Assume minimum 2D k-space
      xsrc = 1:nx;
      xdest = (1:nx) + padshift(1);
      
      ysrc = 1:ny;
      ydest = (1:ny) + padshift(2);

      if nDim == 3
        
        % 3D case
        zsrc = 1:nz;
        zdest = (1:nz) + padshift(3);
        
        kpad(xdest,ydest,zdest) = k(xsrc,ysrc,zsrc);
      
      else

        % 2D case
        kpad(xdest,ydest) = k(xsrc,ysrc);
        
      end
      
      % Transfer padded k-space
      k = kpad;
      
      % Clean up memory
      clear kpad;
      
    end
    
    %----------------------------------------------------------
    % FFT k-space
    %----------------------------------------------------------

    if verbose; fprintf('  FFTing k-space\n'); end
    switch nDim
      case 2
        k = fftshift(fftshift(k,1),2);
        s = fft(fft(k,[],1),[],2);
      case 3
        s = fftn(fftshift(k));
    end
    
    % Adjust center shift in the 2nd and 3rd PE dimension
    switch lower(info.method)
      case {'bic_rare','bic_mike','bic_uflare3d'}
        s = fftshift(fftshift(s,2),3);
      otherwise
        % Do nothing
    end
    
    % Adjust return type of image
    switch options.imtype
      case 'm'
        s = abs(s);
      case 'c'
        % Do nothing
    end
    
    % Apply zipper correction
    zipx = options.zip(1);
    zipy = options.zip(2);
    zipz = options.zip(3);
    if zipx > 0
      fprintf('  Correcting x zipper at plane %d\n', zipx);
      sA = s(zipx-2,:,:);
      sB = s(zipx+2,:,:);
      s((zipx-1):(zipx+1),:,:) = cat(1, sA * 0.75 + sB * 0.25, sA * 0.5 + sB * 0.5, sA * 0.25 + sB * 0.75);
    end
    if zipy > 0
      fprintf('  Correcting y zipper at plane %d\n', zipy);
      s(:,zipy,:) = (s(:,zipy-1,:) + s(:,zipy+1,:))/2;
    end
    if zipz > 0
      fprintf('  Correcting z zipper at plane %d\n', zipz);
      s(:,:,zipz) = (s(:,:,zipz-1) + s(:,:,zipz+1))/2;
    end
    
  case 'Displaced'

    %------------------------------------------------
    % Split echo recon
    %------------------------------------------------

    if verbose; fprintf('  Displaced/Split echo recon\n'); end
    
    % Half x dim
    hx = fix(nx/2);
    
    % First dimension is split echo readout so split into early and late halves
    kA = k(1:hx,:,:);
    kB = k((1:hx)+hx,:,:);
    
    % Apply phase rolls from geometry prescription to each dimension
    if verbose; fprintf('  Applying phase roll\n'); end
    kA = pvmphaseroll(kA,info);
    kB = pvmphaseroll(kB,info);
    
    % FFT first and second echoes
    if verbose; fprintf('  FFTing k-space\n'); end
    sA = abs(fftn(fftshift(kA)));
    sB = abs(fftn(fftshift(kB)));
    
    % Combine modulus echo images
    if verbose; fprintf('  Combining echoes\n'); end
    s = sA + sB;
    
end

% Final voxel dimensions
info.vsize = info.fov(1:3) ./ [nx ny nz]';

% Handle interleaved slices in 2D - use ACQ_objorder field
% Do this prior to multiecho handling. At this point s
% is of the form (X,Y,Z*TE) and objorder has Z*TE elements.
if info.ndim == 2
  s(:,:,info.objorder+1) = s(:,:,:);
end

% Handle multislice multiecho
if info.nechoes > 1 && info.ndim == 2
  % Initial data order is (X,Y,Z*TE) with echo inner loop
  % in the 3rd dimension
  s = reshape(s,[nx,ny,info.nechoes,nz/info.nechoes]);
  % Place echoes in last dimension (X,Y,Z,TE)
  s = permute(s,[1 2 4 3]);
end

% Optional Nifti output
if options.nifti
  
  % Parse paravision directory name
  [dcontain, dname, ~] = fileparts(sdir);
  
  % Create output directory if necessary
  outdir = fullfile(dcontain, 'FSL');
  warning('off','MATLAB:MKDIR:DirectoryExists');
  mkdir(outdir);
  warning('on','MATLAB:MKDIR:DirectoryExists');
    
  % Output Nifti filename
  fname = fullfile(outdir, [dname '.nii.gz']);
  
  % Write Nifti file
  if verbose; fprintf('  Saving image to %s\n', fname); end
  cit_save_nii(fname, s, info.vsize);
  
  % Save full recon options structure
  if verbose; fprintf('  Saving recon options to %s\n', fname); end
  matfile = fullfile(outdir, [dname '_recon.mat']);
  save(matfile, 'options');
  
end

if verbose; fprintf('END PARXRECON\n'); end
