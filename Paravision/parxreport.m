function parxreport(basedir)
% parxreport(basedir)
%
% Scan through a directory tree creating reports for any Paravision studies
% discovered. The report index page is placed in basedir.
%
% ARGS :
% studydir   = directory containing Paravision exams,studies and series
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 12/08/2005 Adapt from parxstudyreport.m (JMT)
%          01/17/2006 JMT M-Lint corrections
%
% Copyright 2005-2006 California Institute of Technology.
% All rights reserved.

% Function version
fver = 0.2;

% Defaults
if nargin < 1; basedir = pwd; end

% Splash text
fprintf('\n');
fprintf('Paravision Study Reports\n');
fprintf('------------------------\n');
fprintf('Version       : %0.1f\n', fver);
fprintf('Copyright     : 2005 California Institute of Technology\n');
fprintf('Author        : Mike Tyszka, Ph.D.\n');
fprintf('\n');

% Make the report directory if necessary
reportdir = fullfile(basedir,'report');
if ~exist(reportdir,'dir')
  fprintf('Creating %s\n', reportdir);
  [status,msg] = mkdir(reportdir);
  if status == 0
    fprintf('%s\n',msg);
    return
  end
end

% Create index file for this study
idxfile = fullfile(reportdir,'report.htm');
fd = fopen(idxfile,'w');
if fd < 0
  fprintf('Could not create report.htm\n');
  return
end

% Write HTML header
fprintf(fd,'<html>\n');
fprintf(fd,'<body>\n');

% Locate Paravision studies within this directory
studylist = parxfindstudies(basedir);

ns = length(studylist);
fprintf('Found %d studies in %s\n',ns,basedir);

% Create entries for each study
for sc = 1:length(studylist)

  idxfile = parxstudyreport(studylist{sc},reportdir);
  fprintf(fd,'<a href="%s">%s</a><br>\n',idxfile,idxfile);
  
end

% Write HTML footer
fprintf(fd,'</body>\n');
fprintf(fd,'</html\n>\n');

% Close index file
fclose(fd);

% Display the index page in Matlab's browser
web(['file:///' idxfile]);