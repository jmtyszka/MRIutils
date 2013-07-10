function fslext = fslgetextension

% Read FSL output type from environment
fslouttype = getenv('FSLOUTPUTTYPE');
if isempty(fslouttype)
  fslouttype = 'NIFTI_GZ';
end
fprintf('FSL output type : %s\n', fslouttype);
switch fslouttype
  case 'NIFTI_GZ'
    fslext = '.nii.gz';
  case 'NIFTI'
    fslext = '.nii';
  otherwise
    fprintf('Unsupported image type : %s\n',fslouttype);
    return
end