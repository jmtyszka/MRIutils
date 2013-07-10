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
% .fr        = filter radius [0.47]
% .fw        = filter width (Fermi only) [0.03]
% .zpad      = zero padding factor [1]
% .fidw      = FID filter width [0.05] 0.0 -> no filter applied
% .imtype    = returned image type 'm' (magnitude) or 'c' (complex) ['m']
% .bline     = k-space baseline correction 0 = off, 1 = on [0]
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
%          06/20/2011 JMT Add baseline correction option
%
% Copyright 2000-2011 California Institute of Technology.
% All rights reserved.

% Internal flags
verbose = 1;

if verbose; fprintf('Entering PARXRECON\n'); end

% Initialize the options structure if absent
if nargin < 2; options.filttype = 'none'; end

% Tidy up options structure
if ~isfield(options,'filttype'); options.filttype = 'none'; end
if ~isfield(options,'fr');       options.fr = 0.45;         end
if ~isfield(options,'fw');       options.fw = 0.01;         end
if ~isfield(options,'zpad');     options.zpad = 1;          end
if ~isfield(options,'fidw');     options.fidw = 0;          end
if ~isfield(options,'imtype');   options.imtype = 'm';      end
if ~isfield(options,'bline');    options.bline = 0;         end

% Initialize return matrix
s = [];
info = [];

% Determine acquisition method type
if verbose; fprintf('  Checking acquisition type: '); end
acqmeth = parxacqmeth(sdir);

%% Load FID data

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

% Grab k-space dimensions including multiple echo images
[nx,ny,nz,ni] = size(k);
info.dim = [nx ny nz ni]';
nDim = info.ndim;

fprintf('From data  : (nx,ny,nz,ni) = (%d,%d,%d,%d)\n', nx, ny, nz, ni);
fprintf('From header: (nx,ny,nz,ni) = (%d,%d,%d,%d)\n', ...
  info.sampdim(1), info.sampdim(2), info.sampdim(3), info.nechoes);

%% Baseline correction

if verbose; fprintf('  Baseline correction: '); end
switch options.bline
  
  case 1
    if verbose; fprintf('Spine baseline estimation\n'); end
    k = pvmkspacebline(k);
    
  otherwise
    if verbose; fprintf('None\n'); end

end

%% Center FOV using phase rolls

if verbose; fprintf('  Applying k-space phase roll\n'); end
k = pvmphaseroll(k,info);

%% Spatial filter

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
    if verbose; fprintf('Gauss [%f voxels]\n',options.fr); end
    switch nDim
      case 2
        Hfilt = gauss2([nx ny], options.fr, info.echopos/100);
        Hfilt = repmat(Hfilt,[1 1 nz]);
      case 3
        Hfilt = gauss3([nx ny nz], options.fr, info.echopos/100);
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

%% Optional FID filter

if options.fidw > 0.0
  
  if verbose; fprintf('  FID filtering: width %f\n', options.fidw); end
  
  % Construct FID filter for read dimension only
  % Fermi filter is asymmetric and has a radius = (1-fidw)/2
  Hfid = fermi(nx, 0.5-options.fidw*5, options.fidw, 'lower');
  Hfid = repmat(Hfid(:), [1 ny nz]);
  
  % Apply filter
  k = k .* Hfid;
  
end

%% Optional zero padding

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

%% FFT k-space

if verbose; fprintf('  FFTing k-space\n'); end
switch nDim
  
  case 2
    
    k = fftshift(fftshift(k,1),2);
    s = fft(fft(k,[],1),[],2);
    
  case 3
    
    % Allocate space for real-space image
    s = zeros(nx,ny,nz,ni);
    
    % Loop over all echo images
    for ic = 1:ni
      s(:,:,:,ic) = fftn(fftshift(k(:,:,:,ic)));
    end
    
    % Remove singlet dimensions
    s = squeeze(s);
    
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

%% Final tidy up

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

if verbose; fprintf('Leaving PARXRECON\n'); end