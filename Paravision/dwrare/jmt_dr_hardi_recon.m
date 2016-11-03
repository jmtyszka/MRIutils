function jmt_dr_hardi_recon(study_dir, hardi_scans, samp_type, method)
% Reconstruct a complete HARDI dataset acquired using the jmt_dr DW-RARE
% sequence. Apply an optimizaed phase correction to all scans.
%
% USAGE : jmt_dr_hardi_recon(study_dir, hardi_scans, samp_type, method)
%
% ARGS:
% study_dir = Paravision study directory (string)
% hardi_scans = scan numbers of HARDI scans (vector of doubles)
% samp_type = 'rodent_head' or 'other' ['other']
% method = phase correction method:
%   'none'
%   'estimated'
%   'optimized' [default]
%
% AUTHOR : Mike Tyszka, Ph.D.
% DATES  : 09/13/2007 JMT From scratch
%          02/26/2008 JMT Rename for HARDI recon
%          2015-03-27 JMT Update for latest jmt_dr results
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

% Default args
if nargin < 1; study_dir = pwd; end

if nargin < 2

  % List all studies in the directory
  parxls(study_dir);

  % Ask user to enter vector (eg 1:10) for S0 and DWI scans
  hardi_scans = input('HARDI scan list: ');

end

if nargin < 3; samp_type = 'other'; end
if nargin < 4; method = 'estimated'; end

% Internal flags
% Lots of internal logging, figure generation, etc if true
debug = true;

% Eddy current correction flag
do_eddy = false;

% Echo correction type: 'phase' or 'complex'
corr_type = 'phase';

% Empirical bvec flip
flip = [1 1 -1]';

% Spatial filtering
filt_type = 'gauss';
fr = 2.0; % For Gauss filter, this is the FWHM of the PSF in voxels
fw = 0.0; % Unused

% Count number of HARDI scans
nhardi = length(hardi_scans);

%% Find DWIs in HARDI list

fprintf('Finding S(0) images in list\n');

ns0 = 0;
s0_scans = zeros(1,nhardi);

% Loop over all scans and construct list of S(0) images
for hc = 1:nhardi

  hardi_no = hardi_scans(hc);
  hardi_fname = fullfile(study_dir,num2str(hardi_no));

  % Get info for this study
  info = parxloadinfo(hardi_fname);

  if isequal(info.name,'Unknown')
    fprintf('Scan not found\n');
    return
  end

  if isequal(info.method,'jmt_dr') && info.bfactor == 0.0
    ns0 = ns0 + 1;
    s0_scans(ns0) = hardi_no;
  end

end

% Remove empty elements and sort DWI list
s0_scans = sort(s0_scans(1:ns0));

fprintf('Found %d S(0) images in %d HARDI scans\n', ns0, nhardi);

for dc = 1:ns0

  s0_no = s0_scans(dc);
  s0_fname = fullfile(study_dir,num2str(s0_no));

  fprintf('Loading S(0) k-space from scan %d\n', s0_no);

  % Load DWI k-space
  [k, info, errmsg] = pvmloadfid(s0_fname);
  if ~isempty(errmsg)
    fprintf('\nError for %s\n', s0_fname);
    fprintf(errmsg);
    return
  end

  % Make space for all S(0) k-spaces
  if dc == 1
    kdims = info.sampdim(1:3)';
    k_s0 = zeros([kdims ns0]);
  end

  % Add to main k-space store
  k_s0(:,:,:,dc) = k;

end

%% Phase ordering of ky dimension

% Reshape the ky encoding step vector to have ETL rows
% EncSteps1 maps the echo acquisition order to k-space line index running
% from -ny/2 to ny/2+1. Add ny/2+1 for Matlab indexing
ky_order = info.EncSteps1 + info.sampdim(2)/2 + 1;
ky_order = reshape(ky_order,info.etl,[]);

% Transpose and flatten to put ky indexes in echo, shot order
% Each column of ky_order now represents the ky indices for a given echo
ky_order = ky_order';

%% Generate phase reference for correction

% Average all S(0) volumes if necessary
nd = size(k_s0,4);
if nd > 1
  fprintf('Averaging S(0) k-spaces\n');
  k_s0 = mean(k_s0,4);
end

%% Reorder ky for S(0) k-spaces
fprintf('Reordering ky for S(0) k-space\n');
k_s0(:,ky_order(:),:,:) = k_s0;

%% Reconstruction loop
% Loop over all S(0) and DWI scans

bvals = zeros(nhardi,1);
bvecs = zeros(nhardi,3);

if debug && isequal(method, 'optimized')
  log_file = fullfile(study_dir, 'optimlog.txt');
  fd_log = fopen(log_file,'w');
  if fd_log < 0
    fprintf('Could not open log file to write\n');
    return
  end
  fprintf(fd_log, '%6s %12s %12s %6s %8s %8s %8s\n',...
    '#','RawRes','EstRes','EstIt','Gx','Gy','Gz');
end

% Loop includes S(0) scans
for dc = 1:nhardi

  % HARDI scan directory name
  hardi_no = hardi_scans(dc);
  hardi_fname = fullfile(study_dir,num2str(hardi_no));

  % Load DWI k-space
  [k, info] = parxloadfid(hardi_fname);
  if isequal(info.name,'Unknown')
    fprintf('Problem loading DWI %d (scan %d)\n', dc, hardi_no);
    return
  end

  fprintf('Reconstructing HARDI %d (Scan %d): v = (%0.3f, %0.3f, %0.3f)\n',...
    dc, hardi_no,info.diffdir(1),info.diffdir(2),info.diffdir(3));

  %---------------------------------------------
  % Numerical calculation of b-matrix
  %---------------------------------------------
  
  bval_ideal = info.bfactor;
  bvec_ideal = info.diffdir;
  
  % Create options structure from sequence details
  psqoptions = psqmkopts(hardi_fname);
      
  % Generate waveforms
  [t,B1t,Gx,Gy,Gz,kinv] = JMT_DR(psqoptions);

  % Calculate b-matrix in s/mm^2
  [b_matrix,kx,ky,kz] = psqbmatrix(t,Gx,Gy,Gz,kinv,psqoptions.echoloc);
      
  % Plot the sequence waveforms
  psqplotwaveforms(t,B1t,Gx,Gy,Gz,kx,ky,kz);
  
  % Total b-value is the trace of the b-matrix
  bval_sim = trace(b_matrix);
      
  % Extract encoding vector from b-matrix (as row vector)
  g = sqrt(diag(b_matrix/bval_sim));

  % Get g vector signs from ideal vectors
  bvec_sim = g .* sign(bvec_ideal) .* flip;
      
  % Store bval and encoding vector
  bvals(dc) = bval_sim;
  bvecs(dc,:) = bvec_sim;
  
  fprintf('  Sequence b-factor   : %0.1f s/mm^2\n', bval_ideal);
  fprintf('  Calculated b-factor : %0.1f s/mm^2\n', bval_sim);
  
  % Reorder ky dimension of DWI k-space
  k(:,ky_order(:),:) = k; 
  
  %--------------------------------------------
  % RARE phase correction
  % Applied to DWIs only
  % At this stage, ky has not been reordered and is in shot, echo order
  % ie e1s1, e1s2, e1s3, ... e2s1, ...
  % This is standard for Bruker at this point, which means that
  % phase optimization can operate on echo blocks regardless of actual
  % phase encode ordering (centric, linear, etc).
  %--------------------------------------------

  if info.bfactor > 0.0
    switch lower(method)
      case 'estimated'
        [k_corr, optres] = rare_phaseoptim(k_s0, k, ky_order);
      case 'optimized'
        [k_corr, ~, optres] = rare_phaseoptim2(k, ky_order, corr_type);
      otherwise
        % Do nothing
        k_corr = k;
    end
  else
    k_corr = k;
  end
  
  % Apply phase rolls from geometry prescription to each dimension
  k_corr = pvmphaseroll(k_corr,info);

  % k-space spatial filtering
  fprintf('Spatial filtering: %s fr=%0.2f fw=%0.2f\n',filt_type,fr,fw);
  echopos = [info.echopos 50 50]; % k-space center location in percent
  k_corr = pvmspatfilt(k_corr,filt_type,fr,fw,echopos);

  % Forward FFT of k-space
  fprintf('Foward FFTing\n');
  s_corr = abs(fftn(fftshift(k_corr)));

  % Add to 4D data volume
  fprintf('Adding to 4D data\n');
  if dc == 1
    % Using kdims accounts for singlet 3D dimension
    s_4d = zeros([kdims nhardi]);
  end
  s_4d(:,:,:,dc) = s_corr;

  %---------------------------------------------
  % Debug output for DWIs
  %---------------------------------------------

  if debug && info.bfactor > 0.0 && isequal(method,'optimized')

    % Save optimization results in log file
    fprintf(fd_log, '%6d %12.5g %12.5g %6d %8.3f %8.3f %8.3f\n', ...
      dc, optres.resnorm_raw, optres.resnorm_est, optres.iters_est, ...
      info.diffdir(1),info.diffdir(2),info.diffdir(3));

    % Reconstruct uncorrected volume
    k_uncorr = pvmphaseroll(k,info);
    k_uncorr = pvmspatfilt(k_uncorr, filt_type, fr, fw, echopos);
    s_uncorr = abs(fftn(fftshift(k_uncorr)));

    % Construct figure
    figure(100); colormap(gray);
    set(gcf,'Position',[360 60 560 800]);

    set(gcf, 'numbertitle', 'off', 'name', ...
      sprintf('DWI %d : (%0.3f,%0.3f,%0.3f)',...
      dc,info.diffdir(1),info.diffdir(2),info.diffdir(3)));

    % Slice and intensity limits
    hz = fix(size(k,3)/2);
    normlims = robustrange(s_uncorr(:),[5, 99],1000);
    ghostlims = normlims / 10;
    
    % Draw subplots
    subplot(221), imagesc(s_uncorr(:,:,hz),normlims);
    axis image xy off;
    title('Uncorrected');

    subplot(222), imagesc(s_corr(:,:,hz),normlims);
    axis image xy off;
    title(['Correction : ' method]);

    subplot(223), imagesc(s_uncorr(:,:,hz),ghostlims);
    axis image xy off;
    title('Uncorrected');

    subplot(224), imagesc(s_corr(:,:,hz),ghostlims);
    axis image xy off;
    title(['Correction : ' method]);

    % Print figure to PNG image in the figures subdirectory
    fig_dir = fullfile(study_dir,'figures');
    if ~exist(fig_dir,'dir')
      fprintf('Creating figure directory\n');
      mkdir(fig_dir);
    end

    [spath,sname] = fileparts(study_dir);
    fig_name = fullfile(fig_dir,sprintf('%s_%d_pc.png',sname,dc));
    orient tall;
    fprintf('Printing figure\n');
    print(fig_name,'-dpng','-r300');

  end

end

% Close the optimization log file if debugging
if debug && isequal(method,'optimized')
  fclose(fd_log);
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

%% Skull strip rodent head images

switch lower(samp_type)
  
  case 'rodent_head'

    % Generate first pass iDWI
    idwi_0 = mean(s_4d(:,:,:,dwi_inds),4);

    % Use sample-specific mask generation
    % Use iDWI - better identification of restricted diffusion areas
    fprintf('Generating brain mask for %s\n', samp_type);
    [brain_0,brain_mask_0] = skullstrip(idwi_0);

    % Mask all images
    fprintf('Skull stripping all data\n');
    s_4d = s_4d .* repmat(brain_mask_0, [1 1 1 nhardi]);
    
  otherwise
    
    % Do nothing
    
end

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

fprintf('Calculating mean DWI and S(0) volumes\n');
idwi = mean(s_4d(:,:,:,dwi_inds),4);
nodif = mean(s_4d(:,:,:,s0_inds),4);

% Use sample-specific mask generation
% Use iDWI - better identification of restricted diffusion areas
fprintf('Generating brain mask for %s\n', samp_type);
switch samp_type
  case 'rodent_head'
    [~, nodif_brain_mask] = skullstrip(idwi);
  otherwise
    nodif_brain_mask = mrimask(idwi);
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
cit_save_nii(nodif_brain_mask_name, nodif_brain_mask, vsize);

% FSL FDT tensor fitting
fprintf('FSL dtifit\n');
!dtifit -k data -o dti -m nodif_brain_mask.nii.gz -r bvecs -b bvals -V

% Return to current directory
cd(cwd);

fprintf('**********\n');
fprintf('Recon completed : %s\n',datestr(now));
fprintf('**********\n');

