function dchardifsl(dcdir)
% Convert a directory containing only a DICOM HARDI dataset for FSL/FDT
%
% SYNTAX: dchardifsl(dcdir)
%
% - Handles both single and mosaic images
% - extracts bval and bvec from DICOM header
% - matched to Siemens data only at this point
% - generates idwi and brain masks
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 02/10/2006 JMT From scratch
%          02/28/2006 JMT Add b-file and nodif output
%          03/01/2006 JMT Add idwi output
%          09/12/2006 JMT Check for FSL output type (freesurfer)
% REFS   :
% http://wiki.na-mic.org/Wiki/index.php/NAMIC_Wiki:DTI:DICOM_for_DWI_and_DTI#Private_vendor:_Siemens
%
% Copyright 2006-2007 California Institute of Technology.
% All rights reserved.

% Default arguments
if nargin < 1; dcdir = pwd; end

% Software version
hardiver = 0.3;

% Splash text
fprintf('\n');
fprintf('Siemens DICOM HARDI to FSL FDT Preprocessing\n');
fprintf('------------------------------------------\n');
fprintf('Version       : %0.1f\n', hardiver);
fprintf('Copyright     : 2006 California Institute of Technology\n');
fprintf('Code & Design : Mike Tyszka, Ph.D.\n');
fprintf('\n');

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

% Orientation flip vector
% Used to flip each bvector component independently
flip = [1 -1 1];
fprintf('b-vector orientation flips : [%d %d %d]\n',flip(1),flip(2),flip(3));

% Bedpost flag
do_bedpost = 0;

% Remove existing FSL directory and recreate
parentdir = fullfile(dcdir,'..');
fsldir = fullfile(parentdir,'FSL');
if exist(fsldir,'dir')
  fprintf('Removing existing FSL directory\n');
  rmdir(fsldir,'s');
end
mkdir(parentdir,'FSL');

% Get DICOM directory list
d = dir(dcdir);

% Identify all dicom files in directory by extension only
fprintf('Compiling DICOM file list\n');
ndc = 0;
dcnames = '';
for dc = 1:length(d)
  ddcname = d(dc).name;
  if strfind(ddcname,'.dcm') % Use strfind to eliminate '.' and '..'
    ndc = ndc + 1;
    dcnames(ndc,:) = fullfile(dcdir,ddcname);
  end
end

if ndc < 1
  fprintf('No DICOM files found in DICOM directory\n');
  return
end

% Load DICOM headers
fprintf('Loading DICOM headers\n');
hdr = spm_dicom_headers(dcnames);

% Change PWD to the FSL directory
fprintf('Moving to FSL directory\n');
oldpwd = pwd;
cd(fsldir);

% Check for standard or mosaic images
if hdr{1}.CSAImageHeaderInfo(21).nitems > 0

  % Convert DICOM mosaics to Nifti-1 hdr/img pairs
  fprintf('Converting mosaic DICOM to Nifti-1\n');
  spm_dicom_convert(hdr,'mosaic');
  prefix = 'f';
  nvols = length(hdr);
  
else

  % Convert DICOM singles to Nifti-1 hdr/img pairs
  fprintf('Converting DICOM to Nifti-1\n');
  spm_dicom_convert(hdr,'standard');
  prefix = 's';
  
  % Sort hdr cell array into volumes
  % Function borrowed from spm_dicom_convert
  hdrv = spm_sort_into_volumes(hdr);
  nvols = length(hdrv);
  
  % Reduce cell array of headers for first image in each volume
  hdr = {};
  for hc = 1:nvols
    hdr{hc} = hdrv{hc}{1};
  end
  
end

%-----------------------------------------------
% Parse DICOM header for DWI information
%-----------------------------------------------

% DWI counter
nDWI = 0;

for vc = 1:nvols
  
  % Extract DWI information from CSA image header
  bval_item = hdr{vc}.CSAImageHeaderInfo(7).item;
  bvec_item = hdr{vc}.CSAImageHeaderInfo(22).item;

  % Check for diffusion weighting
  if ~isempty(bval_item)
        
    % Must be diffusion weighted
    nDWI = nDWI + 1;
        
    % Extract b-value from Siemens DICOM header
    b = str2double(bval_item(1).val);
        
    % Save b-value
    bvals(nDWI) = b;

    if isempty(bvec_item)
          
      % Must be an unweighted T2 image
      bvecs(nDWI,:) = [0 0 0];
          
    else
          
      % Must be a DWI, so extract encoding vector
      bvec1 = str2double(bvec_item(1).val);
      bvec2 = str2double(bvec_item(2).val);
      bvec3 = str2double(bvec_item(3).val);
      
      % Apply reorientation flips
      bv = [bvec1 bvec2 bvec3] .* flip;
          
      % Save b-vector
      bvecs(nDWI,:) = bv;

    end
        
  end
     
end

% Display 3D plot of encoding vectors
figure(1); clf;
plot3(bvecs(:,1),bvecs(:,2),bvecs(:,3),'.');
axis vis3d

%-----------------------------------------------------
% Adjust the bvectors for image slice orientation
% relative to gradient/diffusion axes
%-----------------------------------------------------

% Determine slice angle - assumes single oblique about
% the X (RL) axis. Slice angle is relative to the z axis,
% so exact axial is 0 degrees, exact coronal is 90 degrees.
% An AxCor oblique slice oriented anterior-superior to
% posterior-inferior has a negative angle.

item = hdr{1}.CSAImageHeaderInfo(24).item;
snx = str2double(item(1).val);
sny = str2double(item(2).val);
snz = str2double(item(3).val);
theta = -atan2(sny,snz);
fprintf('Detected slice angulation of %0.1f degrees\n',theta * 180/pi);

% Construct a rotation matrix to apply to the bvectors to correct for
% slice angulation.
ct = cos(theta); st = sin(theta);
Rx = [1 0 0; 0 ct -st; 0 st ct];
bvecs = (Rx * bvecs')';
  
% Write bvecs and bvals text files for FDT
fprintf('Writing bvals and bvecs files\n');
fslb(fsldir,bvals,bvecs);

%-----------------------------------------------------
% Create makefile for FSL commands
%-----------------------------------------------------

fd = fopen(fullfile(fsldir,'Makefile'),'w');
if fd < 0
  fprintf('Could not open Makefile\n');
  return
end

% Preamble and top-level targets
fprintf(fd,'# Makefile generated automatically by dchardifls.m\n');
fprintf(fd,'all      : dtifit\n');
fprintf(fd,'merge    : hardi%s\n',fslext);
fprintf(fd,'eddycorr : data%s\n',fslext);

% Merge 3D volumes into 4D volume
% Delete spm hdr/img pairs on completion
fprintf(fd,'hardi%s :\n',fslext);
fprintf(fd,'\tfslmerge -a hardi %s*.img\n',prefix);
fprintf(fd,'\trm -rf %s*.hdr %s*.img\n',prefix,prefix);

% Eddy current correction
fprintf(fd,'data%s : hardi%s\n',fslext,fslext);
fprintf(fd,'\teddy_correct hardi data 0\n');

% Brain extraction (use idwi, not nodif)
fprintf(fd,'nodif_brain_mask%s :\n',fslext);
fprintf(fd,'\tbet idwi nodif_brain -m\n');

% Fit tensor model
fprintf(fd,'dtifit : data%s nodif_brain_mask%s\n',fslext,fslext);
fprintf(fd,'\tdtifit --data=data --out=dti --mask=nodif_brain_mask --bvecs=bvecs --bvals=bvals\n');

% Add bedpost target - must be called explicitly by 'make bedpost'
fprintf(fd,'bedpost : data%s\n',fslext);
fprintf(fd,'\tbedpost .\n');

fclose(fd);

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
!make merge

% Eddy current correction to genereate data.nii volume
% FSL function using shell escape
fprintf('Eddy current correction\n');
!make eddycorr

%-----------------------------------------------------
% nodif (mean S0) and iDWI
%-----------------------------------------------------

% Load eddy corrected 4D volume (data.nii)
% NOTE : image is loaded in neurological (RAS) convention
fprintf('Loading 4D volume\n');
[s,nii] = load_nii(['data' fslext]);

% Create nodif volume from mean S0
% Image is written in neurological convention
fprintf('Writing nodif\n');
s0inds = (bvals < max(bvals)/10);
nodif = sum(s(:,:,:,s0inds),4) / sum(s0inds);
save_nii(['nodif' fslext],nodif,nii.dat.dtype,nii.mat,nii.mat0);

% Create idwi volume
% Image is written in neurological convention
fprintf('Writing idwi\n');
dwiinds = ~s0inds;
idwi = sum(s(:,:,:,dwiinds),4) / sum(dwiinds);
save_nii(['idwi' fslext],idwi,nii.dat.dtype,nii.mat,nii.mat0);

%-----------------------------------------------------
% Diffusion tensor fitting
%-----------------------------------------------------

fprintf('Tensor fitting\n');
!make dtifit

%-----------------------------------------------------
% Bedpost
%-----------------------------------------------------

fprintf('Bedpost\n');
if do_bedpost
!make bedpost
end

% Return to original PWD
cd(oldpwd);

% Closing text
fprintf('Completed at %s\n',datestr(now));
