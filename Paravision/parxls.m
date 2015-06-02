function parxls(studydir)
% parxls(studydir)
%
% Create a summary list of all Paravision scans in an study directory
%
% ARGS:
% studydir = study directory containing numbered scan directories
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 04/26/2001 JMT From scratch
%          01/17/2006 JMT M-Lint corrections
%          08/03/2006 JMT Sort scan numbers in listing
%
% Copyright 2000-2006 California Institute of Technology.
% All rights reserved.

% Defaults
if nargin < 1; studydir = pwd; end

% Get the exam directory list
dirlist = dir(studydir);

% First pass: find numbered scan directories
scanlist = [];
count = 0;
for dc = 1:length(dirlist)

  sno = str2double(dirlist(dc).name);
  if ~isempty(sno)
    count = count + 1;
    scanlist(count) = sno;
  end
    
end

% Sort scanlist ascending
scanlist = sort(scanlist,'ascend');

% Second pass: list paravision information for each scan
for sc = 1:length(scanlist)
  
  % Load the scan information
  [info, status] = parxloadinfo(fullfile(studydir,num2str(scanlist(sc))));
    
  if status == 1
      
    % Print a formated line for this scan
    parxdump(info);
      
  end  
  
end
