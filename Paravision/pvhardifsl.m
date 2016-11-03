function pvhardifsl(study_dir,hardi_scans,gaussfr,samp_type)
% Convert a Paravision HARDI exam to FSL/Fdt format
%
% USAGE: status = pvhardifsl(pvdir,dwinos,gaussfr,samp_type)
%
% ARGS:
% study_dir   = paravision study directory containing scans
% hardi_scans = scan numbers of all ref and DWI scans
% gaussfr     = gauss spatial filter radius (voxels) [0.5] 
% samp_type   = 'rodent_brain'
%               'primate_brain'
%               'rodent_head'
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech CBIC
% DATES  : 10/04/2007 JMT Adapt from pvdsifsl v1.1
%                         - Eliminate all but gauss filter
%                         - Eliminate Analyze intermediates
%          10/06/2007 JMT Correct vsize error and dtifit order
%          2015-03-26 JMT Update for latest data
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

version = 1.2;
mat_arch = 'R2015a';

% Eddy current correction flag
do_eddy = false;

% Splash text
fprintf('\n');
fprintf('PVHARDIFSL DWI Reconstruction Utility\n');
fprintf('-----------------------------------\n');
fprintf('VERSION  : %0.1f\n',version);
fprintf('PLATFORM : %s\n',mat_arch);
fprintf('AUTHOR   : Mike Tyszka, Ph.D.\n');
fprintf('Copyright 2015 California Insitute of Technology\n');
fprintf('All rights reserved\n');
fprintf('For non-commercial research use only.\n\n');

% Default args
if nargin < 1; study_dir = pwd; end
if nargin < 2

  % List all studies in the directory
  parxls(study_dir);

  % Ask user to enter vector (eg 1:10) for S0 and DWI scans
  hardi_scans = input('HARDI scan list: ');

end
if nargin < 3; gaussfr = 0.5; end
if nargin < 4; samp_type = 'unknown'; end

% Convert to numeric values (for standalone command line)
if ischar(hardi_scans)
  hardi_scans = str2double(hardi_scans);
end
if ischar(gaussfr)
  gaussfr = str2double(gaussfr);
end

% Report arguments
fprintf('ARGUMENTS:\n');
fprintf('Study directory : %s\n',study_dir);
fprintf('HARDI scans     : %d to %d\n', min(hardi_scans), max(hardi_scans));
fprintf('Gaussian radius : %0.2f\n', gaussfr);
fprintf('Sample type     : %s\n', samp_type);

% Count total number of DWIs
nhardi = length(hardi_scans);

% Orientation flip vector
% Used to flip each bvector component independently if necessary
% So far [1 1 1] works for primate brains from 9.4T with radiological convention
% output from nii_save.m
flip = [1 1 1]';

% Spatial filtering
filt_type = 'gauss';
fr = gaussfr;
fw = 0.0;

% Open the log file in the study directory
logname = fullfile(study_dir,'pvhardifsl.log');
fd_log = fopen(logname,'w');
if fd_log < 0
  fprintf('Could not open log file - aborting\n');
  return
end

fprintf(fd_log,'**********\n');
fprintf(fd_log,'Recon started : %s\n',datestr(now));

%% Reconstruction loop

bvals = zeros(nhardi,1);
bvecs = zeros(nhardi,3);

for dc = 1:nhardi

  % HARDI scan directory name
  hardi_no = hardi_scans(dc);
  hardi_fname = fullfile(study_dir,num2str(hardi_no));

  fprintf(fd_log,'**********\n');
  fprintf(fd_log,'Reconstructing HARDI %d (Scan %d)\n',dc, hardi_no);
  fprintf('Reconstructing HARDI %d (Scan %d)\n',dc, hardi_no);

  % Load DWI k-space
  [k, info] = parxloadfid(hardi_fname);
  if isequal(info.name,'Unknown')
    fprintf('Problem loading DWI %d (scan %d)\n', dc, hardi_no);
    return
  end
  
  %--------------------------------------------------------
  % b-values and vectors
  % Use sequence simulation if supported
  %--------------------------------------------------------
  
  % Get ideal diffusion encoding info from header
  bval_ideal = sum(info.bfactor);
  bvec_ideal = info.diffdir .* flip;
  
  switch upper(info.method)
    
    case {'BIC_DWSE','JMT_DWSE','JMT_DDR','JMT_DR'}
      
      fprintf(fd_log,'Using simulated b-matrix\n');
      
      % Create options structure from sequence details
      psqoptions = psqmkopts(hardi_fname);
      
      % Generate waveforms
      switch upper(info.method)
        case {'BIC_DWSE','JMT_DWSE'}
          [t,B1t,Gx,Gy,Gz,kinv] = DW_SE(psqoptions);
        case 'JMT_DDR'
          [t,B1t,Gx,Gy,Gz,kinv] = JMT_DDR(psqoptions);
        case 'JMT_DR'
          [t,B1t,Gx,Gy,Gz,kinv] = JMT_DR(psqoptions);
      end

      % Calculate b-matrix in s/mm^2
      b_matrix = psqbmatrix(t,Gx,Gy,Gz,kinv,psqoptions.echoloc);
      
      % Total b-value is the trace of the b-matrix
      bval_sim = trace(b_matrix);
      
      % Extract encoding vector from b-matrix (as row vector)
      g = sqrt(diag(b_matrix/bval_sim));

      % Get g vector signs from ideal vectors
      bvec_sim = g .* sign(bvec_ideal) .* flip;
      
      % Store bval and encoding vector
      bvals(dc) = bval_sim;
      bvecs(dc,:) = bvec_sim;
      
    otherwise

      % Extract ideal b-values and encoding vectors
      fprintf(fd_log,'Using ideal b-matrix\n');
      bvals(dc) = bval_ideal;
      bvecs(dc,:) = bvec_ideal;
      
  end
  
  fprintf(fd_log,'b = %0.1fs/mm^2\n',bvals(dc));
  fprintf(fd_log,'v = (%0.3f, %0.3f, %0.3f)\n',info.diffdir(1),info.diffdir(2),info.diffdir(3));
  
  % Apply phase rolls from geometry prescription to each dimension
  fprintf(fd_log,'Applying k-space phase roll\n');
  k = pvmphaseroll(k,info);
  
  % k-space spatial filtering
  fprintf(fd_log,'Spatial filtering: %s fr=%0.2f fw=%0.2f\n',filt_type,fr,fw);
  echopos = [info.echopos 50.0 50.0]; % In percent of k-space width
  k = pvmspatfilt(k,filt_type,fr,fw,echopos);
  
  % Forward FFT of k-space
  fprintf(fd_log,'Foward FFTing\n');
  s = abs(fftn(fftshift(k)));
  
  % Add to 4D data volume
  fprintf(fd_log,'Adding to 4D data\n');
  if dc == 1
    s_4d = zeros([size(s) nhardi]);
  end
  s_4d(:,:,:,dc) = s;

end

% Normalize intensity of 4D HARDI volume
fprintf('Normalizing HARDI intensity\n');
s_4d = s_4d / max(s_4d(:));

% Create index masks for S(0) and DWI images
% Assume S(0) volumes have b < bmax/10
fprintf('Identifying S(0) and DWI volumes\n');
bmax = max(bvals(:));
s0_inds = (bvals < bmax * 0.1);
dwi_inds = ~s0_inds;

%% Data output

fprintf('Writing HARDI data to directory\n');

hardi_dir = fullfile(study_dir,'HARDI');
if ~exist(hardi_dir,'dir');
  fprintf('Creating HARDI directory\n');
  mkdir(hardi_dir);
end

% Write bvals and bvecs text files to HARDI directory
fprintf('Writing b values and vectors to HARDI directory\n');
fslb(hardi_dir,bvals,bvecs);

% Use FOV and sampled matrix size to calculate reconstructed vsize
vsize = info.fov(1:3) ./ info.sampdim(1:3); % in mm for Nifti-1

% Save DWI image volume
fprintf('Saving enormous 4D HARDI image\n');
hardi_name = fullfile(hardi_dir,'hardi.nii.gz');
cit_save_nii(hardi_name, s_4d, vsize);
fprintf('Finished\n');

% Change to FSL directory
cwd = pwd;
cd(hardi_dir);

% FSL FDT eddy current distortion correction
if do_eddy
  
  fprintf('Starting FSL eddy current correction\n');
  !eddy_correct hardi data 0
  
  % Reload eddy corrected data
  fprintf('Reload DWIs\n');
  data_name = fullfile(hardi_dir,'data.nii.gz');
  nii = load_nii(data_name);
  s_4d = nii.img;

else
  
  fprintf('Skipping eddy current correction\n');
  !imcp hardi data

end

%% Auxilliary volumes
% Ouput idwi, nodif and nodif_brain_mask

fprintf(fd_log,'Extracting S(0) and DWI volumes\n');
idwi = mean(s_4d(:,:,:,dwi_inds),4);
nodif = mean(s_4d(:,:,:,s0_inds),4);

% Use sample-specific mask generation
% Use iDWI - better identification of restricted diffusion areas

fprintf(fd_log,'Generating brain mask\n');

switch lower(samp_type)
  
  case {'rodent_brain','primate_brain'}
    fprintf(fd_log,'  Using noise threshold\n');
    nodif_brain_mask = mrimask(idwi);
  
  case {'rodent_head'}
    fprintf(fd_log,'  Using morphological mask\n');
    [~, nodif_brain_mask] = skullstrip(idwi);
  
  otherwise
    fprintf(fd_log,'  Using Otsu mask\n');
    idwin = idwi / max(idwi(:));
    th = graythresh(idwin);
    nodif_brain_mask = idwin > th;

end

% Save auxilliary volumes
fprintf('Writing iDWI\n');
idwi_name = fullfile(hardi_dir,'idwi.nii.gz');
cit_save_nii(idwi_name, idwi, vsize);

fprintf('Writing nodif\n');
nodif_name = fullfile(hardi_dir,'nodif.nii.gz');
cit_save_nii(nodif_name, nodif, vsize);

fprintf('Writing nodif_brain_mask\n');
nodif_brain_mask_name = fullfile(hardi_dir,'nodif_brain_mask.nii.gz');
cit_save_nii(nodif_brain_mask_name, uint8(nodif_brain_mask), vsize);

% FSL FDT tensor fitting
fprintf('FSL dtifit\n');
!dtifit -k data -o dti -m nodif_brain_mask.nii.gz -r bvecs -b bvals -V

% Return to current directory
cd(cwd);

fprintf('**********\n');
fprintf('Recon completed : %s\n',datestr(now));
fprintf('**********\n');
