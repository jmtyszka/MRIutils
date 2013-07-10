function [options, all_ok] = ica_cleanup_options(mode, options_tocheck)
% Fill or check options structure for ica_cleanup
% - if mode = 'default', returns default options structure
% - if mode = 'check', checks contents of options_tocheck
%
% ARGS:
% mode            = 'default' or 'check'
% options_tocheck = options structure if mode = 'check'
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech
% DATES  : 04/03/2013 JMT From scratch
%
% Copyright 2013 California Institute of Technology.
% All rights reserved.

if nargin < 1; mode = 'default'; end

% Force lower case
mode = lower(mode);

if nargin < 2 && (isequal(mode,'check') || isequal(mode,'dump'))
  fprintf('No options structure to check or dump\n');
  return
end

switch mode
  
  case 'default'
    
    options.TR = 2.0;
    options.freq_cutoff = 0.1;
    options.pspec_frac = 0.33;
    options.corr_thresh = 0.4;
    options.score_thresh = 1;
    options.outside_thresh = 0.5;
    options.overwrite_ica = false;
    options.ica_dim = 50;
    
  case 'check'
    
    all_ok = true;
    
    % Check whether fields exist
    if ~isfield(options_tocheck,'TR')
      fprintf('TR missing\n');
      all_ok = false;
    end
    
    if ~isfield(options_tocheck,'freq_cutoff')
      fprintf('freq_cutoff missing\n');
      all_ok = false;
    end
    
    if ~isfield(options_tocheck,'pspec_frac')
      fprintf('pspec_frac missing\n');
      all_ok = false;
    end
    
    if ~isfield(options_tocheck,'corr_thresh')
      fprintf('corr_thresh missing\n');
      all_ok = false;
    else
      
      % Check limits
      ct = options_tocheck.corr_thresh;
      if ct >= 1 || ct <= 0
        fprintf('corr_thresh out of bounds [0,1] : %0.3f\n', ct);
        all_ok = false;
      end
      
    end
    
    if ~isfield(options_tocheck,'outside_thresh')
      fprintf('outside_thresh missing\n');
      all_ok = false;
    else
      
      % Check limits
      ot = options_tocheck.outside_thresh;
      if ot >= 1 || ot <= 0
        fprintf('outside_thresh out of bounds [0,1] : %0.3f\n', ot);
        all_ok = false;
      end
      
    end
    
    if ~isfield(options_tocheck,'overwrite_ica')
      fprintf('overwrite_ica missing\n');
      all_ok = false;
    end
    
    if ~isfield(options_tocheck,'ica_dim')
      fprintf('ica_dim missing\n');
      all_ok = false;
    end
    
    if all_ok
      fprintf('ICA cleanup options structure checks out\n');
      options = options_tocheck;
    else
      fprintf('One or more required fields are bad or missing - please correct and recheck\n');
    end
    
  case 'dump'
    
    [options, all_ok] = ica_cleanup_options('check',options_tocheck);
    
    % Only dump options if structure passes check
    if all_ok
    
      fprintf('ICA cleanup options\n');
      fprintf('  TR             : %0.3f s\n', options.TR);
      fprintf('  Freq Cutoff    : %0.3f Hz\n', options.freq_cutoff);
      fprintf('  Pspec Fraction : %0.3f\n', options.pspec_frac);
      fprintf('  Corr Thresh    : %0.3f\n', options.corr_thresh);
      fprintf('  Score Thresh   : %0.3f\n', options.score_thresh);
      fprintf('  Outside Thresh : %0.3f\n', options.outside_thresh);
      fprintf('  Overwrite ICA  : %d\n', options.overwrite_ica);
      fprintf('  ICA Dim        : %d\n', options.ica_dim);
      
    end
    
  otherwise
    
    fprintf('Unknown mode %s - exiting\n', mode)
    
end

