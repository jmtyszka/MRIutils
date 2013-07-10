function ica_cleanup(epi_file, options)
% Remove high frequency and Nyquist ghost ICs from 4D EPI data
%
% SYNTAX : ica_cleanup(epi_file, options)
%
% ARGS:
% epi_file = 4D compressed Nifti-1 (.nii.gz) file containing EPI timeseries
% options  = options structure for cleanup - see help ica_cleanup_options
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech
% DATES  : 08/25/2011 JMT From scratch
%          03/09/2012 JMT Reality checks - modify to scan sessions
%                         automatically
%          10/04/2012 JMT Spin off into deghosting function
%          01/24/2013 JMT Switch to using spatial correlation with Nyq mask
%          04/04/2013 JMT Merge low pass and Nyquist cleanup - add options structure
%          07/08/2013 JMT Add detection of ICs outside brain
%
% Copyright 2011-2013 California Institute of Technology.
% All rights reserved.

% Default args
if nargin < 1; help ica_cleanup; return; end
if nargin < 2; options = ica_cleanup_options('default'); end

% Check options structure
[options, all_ok] = ica_cleanup_options('check', options);
if ~all_ok
  fprintf('Problem with options structure - exiting\n');
  return
end

% Extract options fields
TR             = options.TR;
freq_cutoff    = options.freq_cutoff;
pspec_frac     = options.pspec_frac;
corr_thresh    = options.corr_thresh;
score_thresh   = options.score_thresh;
outside_thresh = options.outside_thresh;
overwrite_ica  = options.overwrite_ica;
ica_dim        = options.ica_dim;

% FSL environment
FSL_DIR = getenv('FSL_DIR');
if isempty(FSL_DIR); FSL_DIR = '/usr/local/fsl'; end
melodic_cmd = fullfile(FSL_DIR,'bin','melodic');
regfilt_cmd = fullfile(FSL_DIR,'bin','fsl_regfilt');

%% Run melodic on 4D EPI data

% Parent directory of EPI file
[epi_dir, epi_stub, epi_ext] = fileparts(epi_file);

% Fix .nii.gz extension
if isequal(epi_stub((-3:0)+end),'.nii')
  epi_stub = epi_stub(1:(end-4));
  epi_ext = '.nii.gz';
end

% Fill in containing path if absent
if isempty(epi_dir)
  epi_dir = pwd;
end

% Reconstruct full path to EPI file
epi_file = fullfile(epi_dir, [epi_stub epi_ext]);

% Create log file in same directory as EPI file
log_file = fullfile(epi_dir,'ica_deghost.log');
logfd = fopen(log_file,'w');
if logfd < 0
  fprintf('*** Problem opening %s to write\n', log_file);
  return
end

% Header splash
fprintf('-------------------------------\n');
fprintf('ICA cleanup\n');
fprintf('-------------------------------\n');
fprintf('Date                   : %s\n', datestr(now));
fprintf('EPI file               : %s\n', epi_file);
fprintf('TR                     : %0.3f s\n', TR);
fprintf('(Hifreq) Freq Cutoff   : %0.3f\n', freq_cutoff);
fprintf('(Hifreq) Pspec Frac    : %0.3f\n', pspec_frac);
fprintf('(Nyquist) Corr Thresh  : %0.3f\n', nyquist_corr_thresh);
fprintf('(Nyquist) Score Thresh : %d\n', nyqsuit_score_thresh);
fprintf('(Outside) Frac Thresh  : %d\n', outside_frac_thresh);
fprintf('(Outside) Score Thresh : %d\n', outside_score_thresh);
fprintf('Overwrite ICA          : %d\n', overwrite_ica);
fprintf('ICA Dimensions         : %d\n', ica_dim);
fprintf('\n');

% Init log file with header
fprintf(logfd, '-------------------------------\n');
fprintf(logfd, 'ICA cleanup\n');
fprintf(logfd, '-------------------------------\n');
fprintf(logfd, 'Date                   : %s\n', datestr(now));
fprintf(logfd, 'EPI file               : %s\n', epi_file);
fprintf(logfd, 'TR                     : %0.3f s\n', TR);
fprintf(logfd, '(Hifreq) Freq Cutoff   : %0.3f\n', freq_cutoff);
fprintf(logfd, '(Hifreq) Pspec Frac    : %0.3f\n', pspec_frac);
fprintf(logfd, '(Nyquist) Corr Thresh  : %0.3f\n', nyquist_corr_thresh);
fprintf(logfd, '(Nyquist) Score Thresh : %d\n', nyquist_score_thresh);
fprintf(logfd, '(Outside) Frac Thresh  : %0.3f\n', outside_frac_thresh);
fprintf(logfd, '(Outside) Score Thresh : %d\n', outside_score_thresh);
fprintf(logfd, 'Overwrite ICA          : %d\n', overwrite_ica);
fprintf(logfd, 'ICA Dimensions         : %d\n', ica_dim);
fprintf(logfd, '\n');

% Key .feat subdirectories
% Assumes ICA was run during FEAT preprocessing, not independently
ica_dir = fullfile(epi_dir, [epi_stub '.ica']);

if exist(ica_dir,'dir')

  if overwrite_ica
    fprintf('Overwriting previous ICA results\n');
  else
    fprintf('Using previous ICA results\n');
  end

end

% Rerun melodic if overwrite flag is true
if overwrite_ica
  
  if exist(ica_dir,'dir')
    rmdir(ica_dir,'s');
    mkdir(ica_dir);
  end

  % Construct melodic command
  cmd = sprintf('%s -i %s -o %s --nobet --bgthreshold=1 --tr=%0.3f --dim=%d --report', melodic_cmd, epi_file, ica_dir, TR, ica_dim);
  fprintf('Running : %s\n', cmd);

  % Run melodic command in shell
  try
    system(cmd);
  catch MELODIC
    fprintf('*** Problem running melodic command - exiting\n');
    fclose(logfd);
    return
  end
  
end

%% Load IC results

% IC spatial modes
fprintf('Loading spatial modes\n');
ic_smodes = load_ic_smodes(ica_dir);

if isempty(ic_smodes)
  fprintf('*** No IC smodes found - returning\n');
  return
end

% IC temporal modes
fprintf('Loading temporal modes\n');
ic_tmodes = load_ic_tmodes(ica_dir);

if isempty(ic_tmodes)
  fprintf('*** No IC tmodes found - returning\n');
  return
end

%% Create Nyquist mask

% Load mean image from ICA directory
mean_image = fullfile(ica_dir,'mean.nii.gz');
s = load_nii(mean_image);

% Normalize intensity
s = s/max(s(:));

% Otsu threshold to create head mask
th = graythresh(s(:));
mask = s > th;

% Shift by FOV/2 to create Nyquist mask
ny = size(mask,2);
nyquist_mask = circshift(mask,[0 fix(ny/2) 0]);

%% Search for each class of nuisance ICs

% Identify broadband IC temporal modes (physiological ICs in rsBOLD)
[is_hifreq, hifreq_frac] = find_hifreq_ics(ic_tmodes, TR, freq_cutoff, pspec_frac);

% Identify IC spatial modes strongly correlated with Nyquist pattern
[is_nyquist, nyquist_score] = find_nyquist_ics(ic_smodes, nyquist_mask, corr_thresh, score_thresh);

% Find IC spatial modes
[is_outside, outside_frac] = find_outside_ics(ic_smodes, mask, outside_thresh);

% Number of ICs
nics = length(is_hifreq);

% Merge bad IC indices
is_bad = is_hifreq | is_nyquist | is_outside ;

% Bad ICs index lists
hifreq_ics  = find(is_hifreq);
nyquist_ics = find(is_nyquist);
outside_ics = find(is_outside);
bad_ics     = find(is_bad);

% Bad ICs list as a string
bad_ics_list = sprintf('%d ', bad_ics);

%% Write Nyquist IC list to ICA directory

% Open bad ICs file
bad_ic_file = fullfile(ica_dir,'bad_ics.txt');
badfd = fopen(bad_ic_file,'w');
if badfd < 0
  fprintf('Could not open bad ICs file to write\n');
  fclose(logfd);
  return
end

% Write all bad IC indices to single line
fprintf(badfd, '%s', bad_ics_list);

% Close bad ICs file
fclose(badfd);

%% Nuisance IC stats

% Write hifreq and nyquist info for each IC
fprintf(logfd, '%6s %16s %16s %16s\n', 'IC', 'High Freq Frac','Nyquist Score','Nuisance');
for ic = 1:nics
  fprintf(logfd, '%6d %16.3f %16.3g %16.3g %16d\n', ic, hifreq_frac(ic), nyquist_score(ic), outside_frac(ic), is_bad(ic));
end

% Count ICs in each group
n_ics         = length(is_bad);
n_hifreq_ics  = length(hifreq_ics);
n_nyquist_ics = length(nyquist_ics);
n_outside_ics = length(outside_ics);
n_bad_ics     = length(bad_ics);

% Total variance explained by bad ICs
all_stats = melodic_stats(ica_dir);
total_bad_variance = sum(all_stats.exp_var(is_bad));

% Write results summary to log file
fprintf(logfd, '\n');
fprintf(logfd, 'Number of ICs            : %d\n', n_ics);
fprintf(logfd, 'Number of hifreq ICs     : %d\n', n_hifreq_ics);
fprintf(logfd, 'Number of nyquist ICs    : %d\n', n_nyquist_ics);
fprintf(logfd, 'Number of outside ICs    : %d\n', n_outside_ics);
fprintf(logfd, 'Number of bad ICs        : %d\n', n_bad_ics);
fprintf(logfd, 'Bad IC exp var           : %0.1f%%\n', total_bad_variance);
fprintf(logfd, '\n');
fprintf(logfd, 'Hifreq ICs:\n');
fprintf(logfd, ' %d', hifreq_ics);
fprintf(logfd, '\n\n');
fprintf(logfd, 'Nyqyust ICs:\n');
fprintf(logfd, ' %d', nyquist_ics);
fprintf(logfd, '\n\n');
fprintf(logfd, 'Outside ICs:\n');
fprintf(logfd, ' %d', outside_ics);
fprintf(logfd, '\n\n');
fprintf(logfd, 'Neural ICs:\n');
fprintf(logfd, ' %d', find(~is_bad));
fprintf(logfd, '\n');

% Close log file
fclose(logfd);

%% Regress out nuisance ICs

% Melodic mixing matrix
mix_mat = fullfile(ica_dir, 'melodic_mix');

% Output clean EPI filename
clean_epi_file = fullfile(epi_dir, [epi_stub '_clean' epi_ext]);

% Construct FSL regression filter command
cmd = sprintf('%s -i %s -d %s -o %s -f "%s" -a', ...
  regfilt_cmd, epi_file, mix_mat, clean_epi_file, bad_ics_list);

% Run regression filter in a shell
fprintf('Running : %s\n', cmd);
try
  system(cmd);
catch REGFILT
  fprintf('*** Problem running regfilt command - exiting\n');
  return
end
