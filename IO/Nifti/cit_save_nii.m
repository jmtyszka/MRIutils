function cit_save_nii(fname, img, vsize)
% Save nD (n = 2,3) matrix as a Nifti image
% Wrapper for Jimmy Shen's Nifti Tools package (Matlab Central)
%
% AUTHOR : Mike Tyszka
% PLACE  : Caltech
% DATES  : 2015-04-06 JMT From scratch
%
% DEPENDENCIES : http://www.mathworks.com/matlabcentral/fileexchange/8797-tools-for-nifti-and-analyze-image

% Set coordinate origin to center of voxel space (spatial dimensions only)
dims = size(img);
origin = fix(dims(1:3)/2.0);

% Create Nifti object
nii = make_nii(img, vsize, origin);

% Set the L-R orientation correctly and set sform code for compatibility
% Modify the nii.hdr.hist fields
nii.hdr.hist.sform_code = 1; % Method 3 - use sform matrix
nii.hdr.hist.srow_x = [-vsize(1) 0 0 0]; % Correct L-R flip
nii.hdr.hist.srow_y = [0  vsize(2) 0 0];
nii.hdr.hist.srow_z = [0 0  vsize(3) 0];

% Save to file
save_nii(nii, fname);