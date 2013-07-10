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

% Header
fprintf('%-3s %8s %8s %6s %2s %4s %4s %4s %6s %6s %6s\n',...
  '#','Method','TR ms','TE ms','NA','nx','ny','nz','vx','vy','vz');

% Second pass: list paravision information for each scan
for sc = 1:length(scanlist)
  
  % Load the scan information
  [info, status] = parxloadinfo(fullfile(studydir,num2str(scanlist(sc))));
    
  if status == 1
      
    fprintf('%-3d %8s %8.1f %6.1f %2d %4d %4d %4d %6.1f %6.1f %6.1f\n',...
      scanlist(sc), info.method, info.tr, info.te(1),...
      info.navs,...
      info.recodim(1), info.recodim(2), info.recodim(3),...
      info.vsize(1), info.vsize(2), info.vsize(3));
            
  end
  
end
