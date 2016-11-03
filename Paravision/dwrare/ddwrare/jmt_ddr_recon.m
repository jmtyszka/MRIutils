function jmt_ddr_recon(study_dir,hardi_scans,method)
% RARE phase correction algorithms for jmt_ddr data
%
% SYNTAX : jmt_ddr_recon(study_dir,hardi_scans,method)
%
% ARGS:
% study_dir = Paravision study directory
% hardi_scans = scan numbers of HARDI scans
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

% Internal flags
debug = 1;       % Lots of internal logging, figure generation, etc
dofsloutput = 1; % Flag for FSL output, eddy correction and DTI fitting
docorrect = 1;   % Flag for RARE phase corrections

% Empirical bvec flip
flip = [1 1 -1]';

% Spatial filtering
filt_type = 'gauss';
fr = 1.0;
fw = 0.0;

% Default args
if nargin < 1; study_dir = pwd; end
if nargin < 2

  % List all studies in the directory
  parxls(study_dir);

  % Ask user to enter vector (eg 1:10) for S0 and DWI scans
  hardi_scans = input('HARDI scan list: ');

end
if nargin < 3; method = 'optimized'; end

nhardi = length(hardi_scans);

%% Find DWIs in HARDI list

fprintf('Finding S(0) images in list\n');

ns0 = 0;
s0_scans = zeros(1,nhardi);

for hc = 1:nhardi

  hardi_no = hardi_scans(hc);
  hardi_fname = fullfile(study_dir,num2str(hardi_no));

  % Get info for this study
  info = parxloadinfo(hardi_fname);

  if isequal(info.name,'Unknown')
    fprintf('Scan not found\n');
    return
  end

  if isequal(info.method,'jmt_ddr') && info.bfactor == 0.0
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
    k_s0 = zeros([size(k) ns0]);
  end

  % Add to main k-space store
  k_s0(:,:,:,dc) = k;

end

%% Generate phase reference for correction

% Average all S(0) volumes if necessary
nd = size(k_s0,4);
if nd > 1
  fprintf('Averaging S(0) k-spaces\n');
  k_s0 = mean(k_s0,4);
end

% Reference phase
phi_0 = angle(k_s0);

%% Reconstruction loop

bvals = zeros(nhardi,1);
bvecs = zeros(nhardi,3);

if debug && isequal(method,'optimized')
  log_file = fullfile(study_dir,'optimlog.txt');
  fd_log = fopen(log_file,'w');
  if fd_log < 0
    fprintf('Could not open log file to write\n');
    return
  end
  [spath,sname] = fileparts(study_dir);
  fprintf(fd_log,'Sample    : %s\n',sname);
  fprintf(fd_log,'Timestamp : %s\n',datestr(now()));
  fprintf(fd_log,'%6s %12s %12s %12s %12s %12s %6s %6s %8s %8s %8s\n',...
    '#','RawRes','RndRes0','EstRes0','RndRes','EstRes','RndIt','EstIt','Gx','Gy','Gz');
end

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
  [t,B1t,Gx,Gy,Gz,kinv] = JMT_DDR(psqoptions);

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
  
  fprintf('  Sequence b-factor   : %0.1f s/mm^2\n', bval_ideal);
  fprintf('  Calculated b-factor : %0.1f s/mm^2\n', bval_sim);
  
  %--------------------------------------------
  % RARE phase correction
  % - applied to DWIs only
  %--------------------------------------------

  if info.bfactor > 0.0
    switch lower(method)
      case 'optimized'
        [k_corr, dphi_y, dphi_y_est, dphi_y_optim, optres] = jmt_ddr_phaseoptim(k_s0,k,info,debug);
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
  echopos1 = (-info.EncStart1/2.0 * info.etl - 0.5) / info.etl * 100.0;
  echopos2 = -info.EncStart2/2.0 * 100.0;
  echopos = [info.echopos echopos1 echopos2];
  k_corr = pvmspatfilt(k_corr,filt_type,fr,fw,echopos);

  % Forward FFT of k-space
  fprintf('Foward FFTing\n');
  s_corr = abs(fftn(fftshift(k_corr)));

  % Add to 4D data volume
  fprintf('Adding to 4D data\n');
  if dc == 1
    s_4d = zeros([size(s_corr) nhardi]);
  end
  s_4d(:,:,:,dc) = s_corr;

  %---------------------------------------------
  % Debug output for DWIs
  %---------------------------------------------

  if debug && info.bfactor > 0.0 && isequal(method,'optimized')

    % Get k-space dimensions
    [nx,ny,nz] = size(k);

    % Reconstruct uncorrected volume
    k_uncorr = pvmphaseroll(k,info);
    k_uncorr = pvmspatfilt(k_uncorr,filt_type,fr,fw,echopos);
    s_uncorr = abs(fftn(fftshift(k_uncorr)));

    % Reconstruct using median estimated phase only
    dphi_est = repmat(dphi_y_est,[nx 1 nz]);
    k_est = k .* exp(-i * dphi_est);
    k_est = pvmphaseroll(k_est,info);
    k_est = pvmspatfilt(k_est,filt_type,fr,fw,echopos);
    s_est = abs(fftn(fftshift(k_est)));

    % Save optimization results in log file
    fprintf(fd_log,'%6d %12.5g %12.5g %12.5g %12.5g %12.5g %6d %6d %8.3f %8.3f %8.3f\n',...
      dc, ...
      optres.resnorm_raw, optres.resnorm_rand_0, optres.resnorm_est_0, ...
      optres.resnorm_randoptim, optres.resnorm_estoptim,...
      optres.iters_randoptim, optres.iters_estoptim,...
      info.diffdir(1),info.diffdir(2),info.diffdir(3));
    
    % Draw figures
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
    
    % Force figure painting
    drawnow;

    % Save Matlab figure in figures directory
    fig_dir = fullfile(study_dir,'figures');
    if ~exist(fig_dir,'dir')
      fprintf('Creating figure directory\n');
      mkdir(fig_dir);
    end

    [spath,sname] = fileparts(study_dir);
    fig_name = fullfile(fig_dir,sprintf('%s_%d_pc.fig',sname,dc));
    fprintf('Saving figure\n');
    saveas(gcf,fig_name,'fig');
    
    % Commands for PNG printing
    %    orient tall;
    %    fprintf('Printing figure\n');
    %    print(fig_name,'-dpng','-r300');

  end

end

% Close the optimization log file if debugging
if debug && isequal(method,'optimized')
  fclose(fd_log);
end

if dofsloutput
  
  % Normalize intensity of 4D HARDI volume
  fprintf('Normalizing HARDI intensity\n');
  s_4d = s_4d / max(s_4d(:));

  %% Data output

  fsl_dir = fullfile(study_dir,['FSL.' lower(method)]);
  if ~exist(fsl_dir,'dir');
    fprintf('Creating %s\n',fsl_dir);
    mkdir(fsl_dir);
  end

  fprintf('Writing data to %s\n',fsl_dir);

  % Write bvals and bvecs text files to FSL directory
  fslb(fsl_dir,bvals,bvecs);

  % Setup Nifti rotation matrices with voxel size on diagonal
  vsize = ones(1,4);
  vsize(1:3) = info.vsize(1:3)/1000.0; % um -> mm for Nifti-1
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

  % Create index masks for S(0) and DWI images
  % Assume S(0) volumes have b < bmax/10
  fprintf('Identifying S(0) and DWI volumes\n');
  bmax = max(bvals(:));
  s0_inds = (bvals < bmax * 0.1);
  dwi_inds = ~s0_inds;

  fprintf('Calculating mean DWI and S(0) volumes\n');
  idwi = mean(s_4d(:,:,:,dwi_inds),4);
  nodif = mean(s_4d(:,:,:,s0_inds),4);

  % Use sample-specific mask generation
  % Use iDWI - better identification of restricted diffusion areas
  % mrimask is more conservative than Otsu. Can always erode the mask
  fprintf('Generating brain mask using noise threshold of iDWI\n');
  nodif_brain_mask = mrimask(idwi);

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

else
  
  fprintf('Skipping FSL output, eddy correct and DTI fitting\n');
  
end

fprintf('**********\n');
fprintf('Recon completed : %s\n',datestr(now));
fprintf('**********\n');
