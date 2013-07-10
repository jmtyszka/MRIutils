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
% Copyright 2012 California Institute of Technology.
% All rights reserved.

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