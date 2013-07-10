function crop_nii(fname)
% Allow user to manually crop an SPM5 Nifti image
%
% crop_nii(fname)
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 03/16/2006 JMT From scratch
%
% Copyright 2006 California Institute of Technology
% All rights reserved.

[fname,dname] = uigetfile({'*.img;*.nii','Nifti-1 images (*.img,*.nii)'},'Select Nifti-1 image');
if isequal(fname,0) | isequal(dname,0)
  return
end

% Construct image filename
P = fullfile(dname,fname);

% Load volume information
V = spm_vol(P);

% Load image data
fprintf('Loading %s\n',fname);
S = spm_read_vols(V);

% Allow user to crop volume
[xcrop,ycrop,zcrop] = crop3d(S);

% Apply crop limits
Scrop = S(xcrop,ycrop,zcrop);

% Adjust volume info for cropped image
Vcrop = V;
Vcrop.dim = size(Scrop);
Vcrop.descrip = 'Cropped';

% Remove private fields
if isfield(Vcrop,'private'); rmfield(Vcrop,'private'); end

% Add '_crop' suffix
[pth,fnm,ext] = fileparts(Vcrop.fname);
Vcrop.fname = fullfile(pth,[fnm '_crop' ext]);

fprintf('Writing cropped image to %s\n', Vcrop.fname);
spm_write_vol(Vcrop,Scrop);


