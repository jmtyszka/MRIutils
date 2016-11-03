function [is_motion, r, p] = find_motion_ics(IC_tmodes, moco_pars, alpha)
% Identify motion-correlated ICs using motion regressors
%
% USAGE: [is_motion, r, p] = find_motion_ics(IC_tmodes, moco_pars, alpha)
%
% ARGS:
% ica_dir   = Melodic .ica directory
% moco_pars = 
% alpha     = threshold significance. p(r) < alpha indicates motion IC
%
% RETURNS:
% motion_ics = logical vector identifying motion ICs (true)
%
% This script looks for significant correlations between
% motion regressors (and their derivatives) and timeseries of
% independent components (ICs) extracted derived from FSL's MELODIC.  It
% outputs a structure indicating which ICs significantly correlate (p(r) < alpha)
% with these regressors.
%
% AUTHOR : Dan Kennedy and Mike Tyszka
% PLACE  : Caltech
% DATES  : 08/21/2008 DK  From scratch
%          08/21/2008 JMT Portability and speedup, output plots
%          08/22/2008 DK  Corrected file order bug, added significance
%                         matrix
%          08/22/2008 JMT Combined figures, added IC selector
%          05/22/2012 JMT Generalize for FEAT directory with ICA explore
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

% Output flags
do_figure = 1;

% Default args
if nargin < 1
  fprintf('USAGE: [is_motion, r, p] = find_motion_ics(IC_tmodes, moco_pars, alpha)');
  return
end

% Number of MOCO pars and ICs
num_MCs = size(moco_pars,2);
num_ICs = size(IC_tmodes,2);

% Define structure field names
motion_names = {'pitch','roll','yaw','x','y','z'};
motion_names_accl = {'pitch_rate','roll_rate','yaw_rate','x_rate','y_rate','z_rate'};

%% look for significant correlations between each regressor and all ICs

% Allocate space for correlation coeffs and associated probabilities
r        = zeros(num_MCs,num_ICs);
pstat    = zeros(num_MCs,num_ICs);
r_dt     = zeros(num_MCs,num_ICs);
pstat_dt = zeros(num_MCs,num_ICs);

list_bad_ICs = [];

% Correlate IC timecourses with first temporal derivatives of motion regressors
for ii = 1:num_MCs
  [r(ii,:),pstat(ii,:)] = corr(moco_pars(:,ii), IC_tmodes);
  list_bad_ICs.(motion_names{ii}) = find(pstat(ii,:) <= alpha);
end

% Correlate IC timecourses with first temporal derivatives of motion regressors
for ii = 1:num_MCs
  [r_dt(ii,:),pstat_dt(ii,:)] = corr(diff(moco_pars(:,ii)),IC_tmodes(2:end,:));
  list_bad_ICs.(motion_names_accl{ii}) = find(pstat_dt(ii,:) <= alpha);
end

%% Create binary correlation significance matrices for 0th and 1st motion derivatives
significant = pstat <= alpha;
significant_dt = pstat_dt <= alpha;

% Collapse over motion components
sig_sum_IC    = sum(significant,1);
sig_dt_sum_IC = sum(significant_dt,1);

% Identify likely motion ICs
is_motion = sig_sum_IC > 1 | sig_dt_sum_IC > 1;

%% create a field .all which lists all bad ICs
count = 1;
field_names = fieldnames(list_bad_ICs);
for index=1:num_ICs,
  for ii = 1:length(field_names)
    if find(list_bad_ICs.(field_names{ii}) == index) > 0
      list_bad_ICs.all(1,count) = index;
      count = count + 1;
      break
    end
  end
end

%% Display correlation matrices for zeroth and first temporal derivatives

if do_figure
  
  figure(21); clf;
  
  subplot(321), colormap(gray); imagesc([pstat <= alpha],[0 1]);
  axis equal xy tight; xlabel('IC #'); ylabel('Motion Regressor'); title('Significant Corr with MR');
  
  subplot(322), imagesc([pstat_dt <= alpha],[0 1]);
  axis equal xy tight; xlabel('IC #'); ylabel('dMotion Regressor/dt'); title('Significant Corr with MR''');
  
  subplot(323), bar(sig_sum_IC); xlabel('IC #'); ylabel('Num Sign Motion Correlations');
  axis tight
  
  subplot(324), bar(sig_dt_sum_IC); xlabel('IC #'); ylabel('Num Sign Motion Deriv Correlations');
  axis tight
  
  subplot(325), plot(sort(max(r,[],1))); xlabel('Sorted IC #'); ylabel('Maximum r');
  axis tight
    
  subplot(326), plot(sort(max(r_dt,[],1))); xlabel('Sorted IC #'); ylabel('Maximum r');
  axis tight
  
end
