function clamp_nii(fname)
% Allow user to manually clamp intensity range of an SPM5 Nifti image
%
% clamp_nii(fname)
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

% Display intensity histogram
figure(1); clf
hist(S(:),200);

% User selects clamp limits from histogram
pnts = ginput(2)
irng = pnts(:,1);
imin = min(irng);
imax = max(irng);

fprintf('Clamping image to range [%0.0f,%0.0f]\n',imin,imax);

% Apply intensity clamp
Sclamp = S;
Sclamp(S > imax) = imax;
Sclamp(S < imin) = imin;

% Display result
threeplane(Sclamp);

% Adjust volume info for clamped image
Vclamp = V;
Vclamp.descrip = 'Clamped';

% Remove private fields
if isfield(Vclamp,'private'); rmfield(Vclamp,'private'); end

% Add '_clamp' suffix
[pth,fnm,ext] = fileparts(Vclamp.fname);
Vclamp.fname = fullfile(pth,[fnm '_clamp' ext]);

fprintf('Writing clamped image to %s\n', Vclamp.fname);
spm_write_vol(Vclamp,Sclamp);


