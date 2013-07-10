function parxlsepi(studydir)
% parxlsepi(studydir)
%
% Summarize paravision EPI parameters for all scans in a directory
%
% ARGS:
% studydir = study directory containing numbered scan directories [pwd]
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 10/24/2010 JMT Adapt from parxls.m
%
% Copyright 2010 California Institute of Technology.
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
fprintf('%-3s %8s %6s %2s %2s %4s %4s %4s %6s %6s %6s\n',...
  '#','TR ms','TE ms','NA','NS','nx','ny','nz','vx','vy','vz');

% Second pass: list paravision information for each scan
for sc = 1:length(scanlist)
  
  % Load the scan information
  [info, status] = parxloadinfo(fullfile(studydir,num2str(scanlist(sc))));
    
  if status == 1 && isequal(info.method,'EPI');
      
    fprintf('%-3d %8.1f %6.1f %2d %2d %4d %4d %4d %6.1f %6.1f %6.1f\n',...
      sc, info.tr, info.te,...
      info.navs, info.nshots,...
      info.sampdim(1), info.sampdim(2), info.sampdim(3),...
      info.vsize(1), info.vsize(2), info.vsize(3));
            
  end
  
end
