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
