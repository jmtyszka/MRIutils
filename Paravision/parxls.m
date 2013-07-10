function parxls(examdir)
% parxls(examdir)
%
% Create a summary list of all PARX series in an exam directory
%
% ARGS:
% examdir = root directory of exam
%
% RETURNS:
% serlist = structure array containing info about each series in exam 
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 04/26/2001 From scratch
%          01/17/2006 JMT M-Lint corrections
%
% Copyright 2000-2006 California Institute of Technology.
% All rights reserved.

% Defaults
if nargin < 1; examdir = pwd; end

% Get the exam directory list
dirlist = dir(examdir);

% Loop over all entries
for d = 1:length(dirlist)

  % Extract the
  this_dir = dirlist(d).name;
  this_path = [examdir '\' this_dir];
  
  % Only look at subdirectories
  if ~strcmp(this_dir, '.') && ...
      ~strcmp(this_dir, '..') && ...
      dirlist(d).isdir

    % Load the series information
    [info, status] = parxloadinfo(this_path);
    
    if status == 1
      
      % Print a formated line for this series
      parxdump(info);
      
    end
   
  end
    
end