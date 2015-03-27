function jmt_dr_hardi_recon(study_dir,hardi_scans,samp_type,method)
% Reconstruct a complete HARDI dataset acquired using the jmt_dr DW-RARE
% sequence. Apply an optimizaed phase correction to all scans.
%
% SYNTAX : jmt_dr_hardi_recon(study_dir,hardi_scans,samp_type,method)
%
% ARGS:
% study_dir = Paravision study directory
% hardi_scans = scan numbers of HARDI scans
% samp_type = 'rodent_head' or 'other' ['other']
% method = phase correction method:
%   'none'
%   'simple'
%   'reduced'
%   'unwrapped'
%   'unwrapped_center'
%   'optimized' [default]
%
% AUTHOR : Mike Tyszka, Ph.D.
% DATES  : 09/13/2007 JMT From scratch
%          02/26/2008 JMT Rename for HARDI recon
%
% Copyright 2007-2008 California Institute of Technology.
% All rights reserved.

% Internal flags
debug = 0; % Lots of internal logging, figure generation, etc

% Echo correction type: 'phase' or 'complex'
corr_type = 'phase';

% Empirical bvec flip
flip = [1 1 -1]';

% Spatial filtering
filt_type = 'gauss';
fr = 0.5;
fw = 0.0;

% Default args
if nargin < 1; study_dir = pwd; end

if nargin < 2

  % List all studies in the directory
  parxls(study_dir);

  % Ask user to enter vector (eg 1:10) for S0 and DWI scans
  hardi_scans = input('HARDI scan list: ');

end

if nargin < 3; samp_type = 'other'; end
if nargin < 4; method = 'optimized'; end

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

%% Blind phase correction of S(0) k-space
fprintf('Blind phase correction of S(0) k-space\n');
k_s0 = rare_phaseoptim2(k_s0, ky_order, corr_type);

% Reference phase
phi_0 = angle(k_s0);

%% Reconstruction loop
% Loop over all S(0) and DWI scans

bvals = zeros(nhardi,1);
bvecs = zeros(nhardi,3);

if debug && isequal(method,'optimized')
  log_file = fullfile(study_dir,'optimlog.txt');
  fd_log = fopen(log_file,'w');
  if fd_log < 0
    fprintf('Could not open log file to write\n');
    return
  end
  fprintf('%6s %12s %12s %12s %6s %6s %8s %8s %8s\n',...
    '#','RawRes','RndRes','EstRes','RndIt','EstIt','Gx','Gy','Gz');
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
      case 'optimized'
        [k_corr, x_optim, optres] = rare_phaseoptim(k_s0,k,ky_order,corr_type);
      otherwise
        k_corr = jmt_ddr_phasecorr(k, method, info, phi_0, debug);
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
    fprintf('%6d %12.5g %12.5g %12.5g %6d %6d %8.3f %8.3f %8.3f\n',...
      dc, optres.resnorm_raw, optres.resnorm_rand, optres.resnorm_est,...
      optres.iters_rand, optres.iters_est,...
      info.diffdir(1),info.diffdir(2),info.diffdir(3));

    [nx,ny,nz] = size(k);

    % Reconstruct uncorrected volume
    k_uncorr = pvmphaseroll(k,info);
    k_uncorr = pvmspatfilt(k_uncorr,filt_type,fr,fw,echopos);
    s_uncorr = abs(fftn(fftshift(k_uncorr)));

    % Reconstruct using median estimated phase only
    dphi_est = repmat(dphi_y_est,[nx 1 nz]);
    k_est = k .* exp(-1i * dphi_est);
    k_est = pvmphaseroll(k_est,info);
    k_est = pvmspatfilt(k_est,filt_type,fr,fw,echopos);
    s_est = abs(fftn(fftshift(k_est)));

    figure(1); colormap(gray);
    set(gcf,'Position',[360 60 560 800]);

    hz = fix(nz/2);
    ky = 1:ny;

    subplot(311), plot(ky,dphi_y,ky,dphi_y_est,ky,dphi_y_optim);
    legend('Raw Projection','Estimate','Optimized','Location','Best');
    xlabel('ky');
    ylabel('\Delta\phi(ky) (radians)');
    title(sprintf('DWI %d : (%0.3f,%0.3f,%0.3f)',...
      dc,info.diffdir(1),info.diffdir(2),info.diffdir(3)));

    normlims = [min(s_uncorr(:)) max(s_uncorr(:))];
    ghostlims = normlims / 10;

    subplot(334), imagesc(s_uncorr(:,:,hz),normlims);
    axis image xy off;
    title('Uncorrected');

    subplot(335), imagesc(s_est(:,:,hz),normlims);
    axis image xy off;
    title('Median estimated');

    subplot(336), imagesc(s_corr(:,:,hz),normlims);
    axis image xy off;
    title(['Correction : ' method]);

    subplot(337), imagesc(s_uncorr(:,:,hz),ghostlims);
    axis image xy off;
    title('Uncorrected');

    subplot(338), imagesc(s_est(:,:,hz),ghostlims);
    axis image xy off;
    title('Median estimated');

    subplot(339), imagesc(s_corr(:,:,hz),ghostlims);
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

fprintf('Writing HARDI data to FSL directory\n');

fsl_dir = fullfile(study_dir,'FSL');
if ~exist(fsl_dir,'dir');
  fprintf('Creating FSL directory\n');
  mkdir(fsl_dir);
end

% Write bvals and bvecs text files to FSL directory
fslb(fsl_dir,bvals,bvecs);

% Setup Nifti rotation matrices with voxel size on diagonal
% Use FOV and sampled matrix size to calculate reconstructed vsize
vsize = ones(1,4);
vsize(1:3) = info.fov(1:3) ./ info.sampdim(1:3); % in mm for Nifti-1
nii_mat = diag(vsize);
nii_mat0 = nii_mat;

% Flip sign of A11 element of matrices
% This forces radiological convention for non-oblique datasets
nii_mat(1,1) = -nii_mat(1,1);
nii_mat0(1,1) = -nii_mat0(1,1);

% Save DWI image volume
save_nii(fullfile(fsl_dir,'hardi.nii.gz'),s_4d,'FLOAT32-LE',nii_mat,nii_mat0);

% Change to FSL directory
cwd = pwd;
cd(fsl_dir);

% FSL FDT eddy current distortion correction
fprintf('FSL eddy current correction\n');
!eddy_correct hardi data 0

% Reload eddy corrected data
fprintf('Reload DWIs\n');
s_4d = load_nii(fullfile(fsl_dir,'data.nii.gz'));

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
    [nodif_brain,nodif_brain_mask] = skullstrip(idwi);
  otherwise
    nodif_brain_mask = mrimask(idwi);
end

% Save auxilliary volumes
fprintf('Writing iDWI\n');
save_nii(fullfile(fsl_dir,'idwi.nii.gz'),idwi,'FLOAT32-LE',nii_mat,nii_mat0);
fprintf('Writing nodif\n');
save_nii(fullfile(fsl_dir,'nodif.nii.gz'),nodif,'FLOAT32-LE',nii_mat,nii_mat0);
fprintf('Writing nodif_brain_mask\n');
save_nii(fullfile(fsl_dir,'nodif_brain_mask.nii.gz'),nodif_brain_mask,'FLOAT32-LE',nii_mat,nii_mat0);

% FSL FDT tensor fitting
fprintf('FSL dtifit\n');
!dtifit --data=data --out=dti --mask=nodif_brain_mask --bvecs=bvecs --bvals=bvals

% Return to current directory
cd(cwd);

fprintf('**********\n');
fprintf('Recon completed : %s\n',datestr(now));
fprintf('**********\n');
