function [options, all_ok] = ica_cleanup_options(mode, options_tocheck, fid)
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
%          01/17/2014 JMT Automatic PCA dimensionality
%                         Add artifact type flags
%
% Copyright 2013 California Institute of Technology.
% All rights reserved.

if nargin < 1; mode = 'default'; end

% Output to command window if no FID provided
if nargin < 3; fid = 1; end

% Force lower case
mode = lower(mode);

if nargin < 2 && (isequal(mode,'check') || isequal(mode,'dump'))
  fprintf(fid,'No options structure to check or dump\n');
  return
end

switch mode
  
  case 'default'
    
    options.TR = 2.0;
    options.overwrite_ica = false;
    options.do_glm = true;
    options.highfreq_cutoff = 0.1;
    options.highfreq_frac = 1.0;
    options.nyquist_corr_thresh = 0.4;
    options.nyquist_score_thresh = 1;
    options.slicebg_score_thresh = Inf;
    
  case 'check'
    
    % Check whether fields exist
    all_ok = true;
    
    if ~isfield(options_tocheck,'TR')
      fprintf(fid,'TR missing\n');
      all_ok = false;
    end
    
    if ~isfield(options_tocheck,'overwrite_ica')
      fprintf(fid,'overwrite_ica missing\n');
      all_ok = false;
    end
    
    if ~isfield(options_tocheck,'do_glm')
      fprintf(fid,'do_glm missing\n');
      all_ok = false;
    end
    
    % High frequency IC filtering
    if ~isfield(options_tocheck,'highfreq_cutoff')
      fprintf(fid,'highfreq_cutoff missing\n');
      all_ok = false;
    end
    
    if ~isfield(options_tocheck,'highfreq_frac')
      fprintf(fid,'highfreq_frac missing\n');
      all_ok = false;
    end
    
    % Nyquist IC filtering
    if ~isfield(options_tocheck,'nyquist_corr_thresh')
      fprintf(fid,'nyquist_corr_thresh missing\n');
      all_ok = false;
    else
      
      % Check limits
      ct = options_tocheck.nyquist_corr_thresh;
      if ct < 0 || ct > 1
        fprintf(fid,'nyquist_corr_thresh out of bounds [0,1] : %0.3f\n', ct);
        all_ok = false;
      end
      
    end
    
    if ~isfield(options_tocheck,'nyquist_score_thresh')
      fprintf(fid,'nyquist_score_thresh missing\n');
      all_ok = false;
    else
      
      % Check limits
      st = options_tocheck.nyquist_score_thresh;
      if st < 0
        fprintf(fid,'nyquist_score_thresh out of bounds [0,Inf] : %0.3f\n', st);
        all_ok = false;
      end
      
    end
    
    % Slice background IC filtering
    if ~isfield(options_tocheck,'slicebg_score_thresh')
      fprintf(fid,'slicebg_score_thresh missing\n');
      all_ok = false;
    else
      
      % Check limits
      st = options_tocheck.slicebg_score_thresh;
      if st < 0
        fprintf(fid,'slicebg_score_thresh out of bounds [0,Inf] : %0.3f\n', st);
        all_ok = false;
      end
      
    end
    
    if all_ok
      options = options_tocheck;
    else
      fprintf(fid,'One or more required fields are bad or missing - please correct and recheck\n');
    end
    
  case 'dump'
    
    [options, all_ok] = ica_cleanup_options('check', options_tocheck);
    
    % Only dump options if structure passes check
    if all_ok
      
      fprintf(fid,'\n');
      fprintf(fid,'ICA cleanup options\n');
      fprintf(fid,'-------------------\n');
      fprintf(fid,'  TR                     : %0.3f s\n',  options.TR);
      fprintf(fid,'  Overwrite ICA          : %d\n',       options.overwrite_ica);
      fprintf(fid,'  Do GLM regression      : %d\n',       options.do_glm);
      
      if options.highfreq_frac >= 1.0
        fprintf(fid,'  Highfreq IC Filtering  : OFF\n');
      else
        fprintf(fid,'  Highfreq Cutoff        : %0.3f Hz\n', options.highfreq_cutoff);
        fprintf(fid,'  Highfreq Fraction      : %0.3f\n',    options.highfreq_frac);
      end
      
      if isinf(options.nyquist_score_thresh)
        fprintf(fid,'  Nyquist IC Filtering   : OFF\n');
      else
        fprintf(fid,'  Nyquist Corr Thresh    : %0.3f\n',    options.nyquist_corr_thresh);
        fprintf(fid,'  Nyquist Score Thresh   : %0.3f\n',    options.nyquist_score_thresh);
      end
      
      if isinf(options.slicebg_score_thresh)
        fprintf(fid,'  Slice BG IC Filtering  : OFF\n');
      else
        fprintf(fid,'  Slice BG Score Thresh  : %0.3f\n',    options.slicebg_score_thresh);
      end
      
      fprintf(fid,'\n');
      
    end
    
  otherwise
    
    fprintf(fid,'Unknown mode %s - exiting\n', mode);
    
end

