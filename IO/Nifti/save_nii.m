function save_nii(nii_name, s, datatype, mat, mat0)
% Save image file in Nifti-1 single file format (.nii)
%
% SYNTAX: save_nii(nii_name, s, datatype, mat, mat0)
%
% ARGS:
% nii_name = filename with extension eg 'abcd.nii.gz' (required)
% s        = N-D image data (required)
% datatype = NIFTI data type string ['FLOAT32-LE']
%   
% mat      = Scaling displacement transform [eye(4)]
% mat0     = Full sform transform [eye(4)]
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 07/11/2006 JMT Adapt from save_niigz
%
% Copyright 2006 California Institute of Technology.
% All rights reserved.

if nargin < 2; return; end
if nargin < 3; datatype = 'FLOAT32-LE'; end
if nargin < 4; mat = eye(4); end
if nargin < 5; mat0 = eye(4); end

% Cast data to doubles (handles masks, etc)
s = double(s);

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

if gzipped
  nii_name = fullfile(f_path,f_name);
end

% Create file array for 
dat        = file_array;
dat.fname  = nii_name;
dat.dim    = size(s);
dat.dtype  = datatype;
dat.offset  = ceil(348/8)*8;

% Create the Nifti tensor image object
nii = nifti;

% Fill Nifti fields
nii.dat = dat;
nii.mat = mat;
nii.mat_intent = 'Scanner'; % sform intent
nii.mat0 = mat0;
nii.mat0_intent = 'Scanner'; % qform intent
nii.descrip = 'Created by save_nii.m';

% Set scale limits
nii.cal = [min(s(:)) max(s(:))];

% Create the Nifti-1 header
create(nii);

% Finally write data to nii_name
dat(:,:,:,:) = s;

% Compress if necessary
if gzipped
  gzip_name = [nii_name '.gz'];
  if exist(gzip_name,'file')
    fprintf('Removing previous gzipped file\n');
    eval(['!rm -f ' gzip_name]);
  end
  eval(['!gzip ' nii_name]);
  eval(['!rm -f ' nii_name]);
end