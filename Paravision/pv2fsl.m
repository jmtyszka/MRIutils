function nii_names = pv2fsl(studydir,scans)
% Convert one or more Paravision scans to Nifti-1 volumes in outdir
%
% nii_names = pv2fsl(studydir,scans)
%
% ARGS:
% studydir = paravision study directory containing numbered scan dirs
% scans = vector of integer scan numbers to reconstruct
%
% RETURNS:
% nii_names = cell array of full paths to converted images
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech CBIC
% DATES  : 01/29/2008 JMT Adapt from pvhardifsl.m (JMT)
%          04/16/2009 JMT Add batch capabilities
%          2015-03-26 JMT Update to R2014b
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

version = 1.3;
mat_arch = 'R2015a';

if nargin < 1; studydir = pwd; end
if nargin < 2; scans = 1; end

% Splash text
fprintf('\n');
fprintf('PV2FSL Conversion Utility\n');
fprintf('-------------------------\n');
fprintf('VERSION  : %0.1f\n',version);
fprintf('PLATFORM : %s\n',mat_arch);
fprintf('AUTHOR   : Mike Tyszka, Ph.D.\n');
fprintf('Copyright 2008 California Insitute of Technology\n');
fprintf('All rights reserved\n');
fprintf('For non-commercial research use only.\n\n');

outdir = fullfile(studydir,'FSL');

if exist(outdir,'dir')
  fprintf('Removing previous output directory\n')
  rmdir(outdir,'s');
end

fprintf('Creating output directory\n');
mkdir(outdir);

nscans = length(scans);

nii_names = cell(1,nscans);

for sc = 1:nscans
  
  fprintf('Processing scan %d in study %s\n', scans(sc), studydir);
  
  scandir = fullfile(studydir,num2str(scans(sc)));
  
  % Reconstruct image
  fprintf('Loading Pv images\n');
  [s, info] = parxload2dseq(scandir);
  
  if isequal(info.name,'Unknown')
  
      fprintf('Problem loading Pv scan\n');
  
  else
  
      % Grab 4D data dimensions (handles time-series or multi-echo datasets)
      [nx,ny,nz,nt] = size(s);
      
      fprintf('(nx,ny,nz,nt) = (%d,%d,%d,%d) from data\n',nx,ny,nz,nt);
      fprintf('(nx,ny,nz,nt) = (%d,%d,%d,%d) from header\n',info.recodim(1),info.recodim(2),info.recodim(3),info.nims);
      
      %% Data output
      
      % Voxel dimensions
      vsize = info.vsize(1:3)/1000.0; % um -> mm for Nifti-1
      
      % Flip sign of A11 element of matrices
      % This forces radiological convention for non-oblique datasets
      % nii_mat(1,1) = -nii_mat(1,1);
      % nii_mat0(1,1) = -nii_mat0(1,1);
      
      % Construct Nifti volume name
      t_string = datestr(info.time,30);
      nii_name = sprintf('%s_%03d_%s.nii.gz',info.method,info.scanno,t_string);
      nii_path = fullfile(outdir,nii_name);
      
      % Save compressed Nifti-1 image volume
      fprintf('Saving %s\n', nii_name);
      nii = make_nii(s, vsize);
      save_nii(nii, nii_path);
      
      % Add output file name to list
      nii_names{sc} = nii_path;
      
  end
  
end
