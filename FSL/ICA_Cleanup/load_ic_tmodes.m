function IC_tmodes = load_ic_tmodes(ICA_dir)
% Load IC temporal modes from a Melodic output directory
%
% USAGE: 
% IC_tmodes = load_ic_tmodes(ICA_dir)
%
% ARGS:
% ICA_dir = Melodic .ica directory containing IC results [pwd]
%
% RETURNS:
% IC_tmodes = matrix of IC temporal modes
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

% All temporal modes are in the report subdirectory
IC_tmode_dir = fullfile(ICA_dir, 'report');

if ~exist(IC_tmode_dir,'dir');
  fprintf('*** Report directory not found - returning\n');
  IC_tmodes = [];
  return
end

% Get list of IC timecourse text files
IC_tmode_files = dir(fullfile(IC_tmode_dir, 't*.txt'));

% Load IC timecourses
n_ICs = length(IC_tmode_files);

% Loop over all ICs
for ic = 1:n_ICs

  % Current IC temporal mode filename
  this_file = IC_tmode_files(ic).name;
  
  % Load single IC timecourse
  ICt = load(fullfile(IC_tmode_dir, this_file));
  
  % Make space for IC temporal modes on first pass
  if ic == 1
    n_TRs = length(ICt);
    IC_tmodes = zeros(n_TRs, n_ICs);
  end
  
  % Determine actual IC index from filename
  % Filename is of the form t<number>.txt
  actual_ic = str2double(this_file(2:(end-4)));
  
  % Store temporal mode for this IC
  IC_tmodes(:,actual_ic) = ICt;

end
