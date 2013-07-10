function fsldtifit(fsldir)

%-----------------------------------------------------
% Start FSL preprocessing
% - 3D to 4D merge
% - eddy current correction
% - tensor fit
% - bedpost
%-----------------------------------------------------

% Change to FSL directory to run make
oldpwd = pwd;
cd(fsldir);

% Merge 3D volumes into 4D volume
% Delete old Analyze 7.5 hdr/img pairs on completion
% FSL function using shell escape
fprintf('Merging 3D to 4D\n');
!make dwi4d.nii.gz

% Eddy current correction to genereate data.nii.gz volume
% FSL function using shell escape
fprintf('Eddy current correction\n');
!make data.nii.gz

%-----------------------------------------------------
% nodif (mean S0) and iDWI
%-----------------------------------------------------

% Load eddy corrected 4D volume (data.nii.gz)
fprintf('Loading 4D volume\n');
Snii = load_niigz('data');
S = Snii.img;

% Create nodif volume from mean S0
fprintf('Writing nodif\n');
s0inds = (bvals < max(bvals)/10);
fprintf('  Average of %d volumes\n', sum(s0inds));
nodif = sum(S(:,:,:,s0inds),4) / sum(s0inds);
save_niigz('nodif',nodif,hdr.vsize,nii_datatype);

% Create idwi volume
fprintf('Writing idwi\n');
dwiinds = ~s0inds;
fprintf('  Average of %d volumes\n', sum(dwiinds));
idwi = sum(S(:,:,:,dwiinds),4) / sum(dwiinds);
save_niigz('idwi',idwi,hdr.vsize,nii_datatype);

fprintf('Creating nodif_brain_mask\n');
  
% iDWI threshold
idwin = idwi / max(idwi(:));
idwi_th = graythresh(idwin);
  
% S0 threshold
nodifn = nodif / max(nodif(:));
nodif_th = graythresh(nodifn);

% Logical OR masks
mask = (idwin > idwi_th) | (nodifn > nodif_th) ;

niiname = 'nodif_brain_mask';
fname = fullfile(fsldir,niiname);
fprintf('Writing %s.nii.gz\n',niiname);
save_niigz(fname, mask, hdr.vsize, nii_datatype);

%-----------------------------------------------------
% Diffusion tensor fitting
%-----------------------------------------------------

fprintf('Tensor fitting\n');
!make dtifit

% Return to original PWD
cd(oldpwd);

% Closing text
fprintf('Completed at %s\n',datestr(now));