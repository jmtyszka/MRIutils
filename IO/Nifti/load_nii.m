function [s,nii] = load_nii(nii_name)
% Load a Nifti-1 format image file
%
% SYNTAX: [s,nii] = load_nii(fname)
%
% ARGS:
% fname = file stub of Nifti image (eg /data/mydata -> /data/mydata.nii)
%
% RETURNS:
% s   = N-D image data
% nii = Nifti-1 image object
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 03/01/2006 JMT From scratch
%          05/12/2006 JMT Switch to niftilib
%          09/12/2006 JMT Add support for extension types (.nii and
%          .nii.gz)
%
% Copyright 2006 California Institute of Technology.
% All rights reserved.

% Default returns
s = [];
nii = [];

% Default argyments
if nargin < 1; return; end

if ~exist(nii_name,'file')
  fprintf('Image file does not exist\n');
  return
end

% Detect file extension
[f_path,f_name,f_ext] = fileparts(nii_name);
[gz_path,gz_name,gz_ext] = fileparts(fullfile(f_path,f_name));

% Catch exceptions
if ~isequal(gz_ext,'.nii') && ~isequal(f_ext,'.nii')
  fprintf('Unkown file type : %s\n',[f_name f_ext]);
  return
end

% Gzipped flag
gzipped = isequal(f_ext,'.gz');

% Uncompress .nii.gz file if necessary
if gzipped
  
  % Adjust nii name and record .nii.gz name
  nii_gz_name = nii_name;
  nii_name = fullfile(f_path, f_name);
  
  % gunzip .nii.gz file to create .nii file
  % gunzip does not remove the .nii.gz file
  gunzip(nii_gz_name);

end

% Open Nifti-1 object
nii = nifti(nii_name);

% Pull in the data
% Cast to double required for overloaded nii object
% This approach loads the imaging data from the file
% Direct assignment would pass the data field of the
% nii object, not the image data.
s = double(nii.dat);

% Remove uncompressed .nii file if original was compressed
if gzipped
  delete(nii_name)
end
