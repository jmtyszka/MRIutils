% NIFTI
%
% Files
%   bipolar       - returns an M-by-3 matrix containing a blue-red colormap, in
%   clamp_nii     - Allow user to manually clamp intensity range of an SPM5 Nifti image
%   crop_nii      - Allow user to manually crop an SPM5 Nifti image
%   extra_nii_hdr - Decode extra NIFTI header information into hdr.extra
%   get_nii_frame - Return time frame of a NIFTI dataset. Support both *.nii and 
%   load_nii      - Load a Nifti-1 format image file
%   load_nii_hdr  - Load NIFTI dataset header. Support both *.nii and *.hdr/*.img file
%   load_nii_img  - Load NIFTI dataset body after its header is loaded using load_nii_hdr.
%   make_nii      - Make nii structure specified by 3D matrix [x y z]. It also takes
%   rri_file_menu - Imbed a file menu to any figure. If file menu exist, it will append
%   rri_orient    - Convert image of different orientations to standard Analyze orientation
%   rri_orient_ui - Return orientation of the current image:
%   rri_xhair     - rri_xhair: create a pair of full_cross_hair at point [x y] in
%   rri_zoom_menu - Imbed a zoom menu to any figure.
%   save_nii      - Save image file in Nifti-1 single file format (.nii)
%   save_nii_hdr  - Save NIFTI dataset header. Support both *.nii and *.hdr/*.img file


%   xform_nii     - Perform a subset of NIFTI sform/qform transform. Transforms like
