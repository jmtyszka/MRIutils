function [s_corr,bval,bvec, s] = jmt_dr_recon(scan_dir)
% Reconstruct a single scan acquired using the jmt_dr DW-RARE
% sequence. Apply a blind optimized per-echo phase correction.
%
% This function can be used to correct any residual ghosting in the
% unweighted images of a DW-RARE HARDI dataset.
%
% SYNTAX : jmt_dr_recon(scan_dir)
%
% ARGS:
% study_dir = Paravision study directory
%
% RETURNS:
% s_corr = corrected image
% bval = calcualted b-value
% bvec = calculated b-vector
% s = uncorrected image
%
% AUTHOR : Mike Tyszka, Ph.D.
% DATES  : 02/26/2008 JMT Retool for single volume blind correction
%          05/08/2009 JMT Correct all lint warnings
%
% Copyright 2008,2009 California Institute of Technology.
% All rights reserved.

% Internal flags
debug = false; % Lots of internal logging, figure generation, etc

% Echo correction type: 'phase' or 'complex'
corr_type = 'phase';

% Number of correction passes
corr_passes = 3;

% Empirical bvec flip
flip = [1 1 -1]';

% Default args
if nargin < 1; scan_dir = pwd; end

% Load k-space
fprintf('Loading k-space\n');
[k, info, errmsg] = pvmloadfid(scan_dir);
if ~isempty(errmsg)
  fprintf(errmsg);
  return
end

if ~isequal(info.method,'jmt_dr')
  fprintf('Sequence is not jmt_dr (%s)\n', info.method);
  return
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

%---------------------------------------------
% Numerical calculation of b-matrix
%---------------------------------------------

fprintf('Calculating b-matrix from sequence details\n');

bval_ideal = info.bfactor;
bvec_ideal = info.diffdir;

% Create options structure for this scan
psqoptions = psqmkopts(scan_dir);

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
bval = bval_sim;
bvec = bvec_sim;

fprintf('  Sequence b-factor   : %0.1f s/mm^2\n', bval_ideal);
fprintf('  Calculated b-factor : %0.1f s/mm^2\n', bval_sim);

% Reorder ky dimension of DWI k-space
k(:,ky_order(:),:) = k;

% Reconstruct uncorrected image with phase rolling
fprintf('Reconstructing uncorrected image\n');
k_raw = pvmphaseroll(k,info);
s = abs(fftn(fftshift(k_raw)));

%--------------------------------------------
% RARE phase correction
% At this stage, ky has not been reordered and is in shot, echo order
% ie e1s1, e1s2, e1s3, ... e2s1, ...
% This is standard for Bruker at this point, which means that
% phase optimization can operate on echo blocks regardless of actual
% phase encode ordering (centric, linear, etc).
%--------------------------------------------

fprintf('Echo correction optimization\n');
k_corr = k;
for pc = 1:corr_passes
  [k_corr, x_optim, optres] = rare_phaseoptim2(k_corr,ky_order,corr_type);
end

disp(x_optim)

% Apply phase rolls from geometry prescription to each dimension
fprintf('Applying phase roll to corrected k-space\n');
k_corr = pvmphaseroll(k_corr,info);

% Forward FFT of k-space
fprintf('Foward FFTing\n');
s_corr = abs(fftn(fftshift(k_corr)));

%---------------------------------------------
% Debug output for phase optimization
%---------------------------------------------

if debug

  % Get k-space dimensions
  [nx,ny,nz] = size(k);

  % Reconstruct uncorrected volume
  k_uncorr = pvmphaseroll(k,info);
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

end

% Close the optimization log file if debugging
if debug && isequal(method,'optimized')
  fclose(fd_log);
end
