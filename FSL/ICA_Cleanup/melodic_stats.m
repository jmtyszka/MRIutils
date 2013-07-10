function stats = melodic_stats(ica_dir)
% Load IC stats (explained variance, etc) from a Melodic output directory
%
% USAGE: 
% stats = melodic_stats(ica_dir)
%
% ARGS:
% ica_dir = Melodic .ica directory containing IC results [pwd]
%
% RETURNS:
% stats = stats structure for all ICs
% .exp_var = explained variance
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech
% DATES  : 03/19/2012 JMT From scratch
%
% Copyright 2012 California Institute of Technology.
% All rights reserved.

if nargin < 1; ica_dir = pwd; end

% Stats file in Melodic output directory
stats_file = fullfile(ica_dir,'melodic_ICstats');

% Read stats file contents into a matrix
try
 raw_stats = dlmread(stats_file);
catch
  fprintf('Problem loading stats file information\n');
  stats.exp_var = -1;
  stats.tot_var = -1;
end

% Parse stats matrix into named vectors
stats.exp_var = raw_stats(:,1);
stats.tot_var = raw_stats(:,2);