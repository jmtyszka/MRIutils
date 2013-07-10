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

% Create index file for all studies in basedir
studyindexpage = 'index.htm';
studyindexpath = fullfile(reportdir,studyindexpage);
fprintf('Creating base index page: %s\n',studyindexpage);
fd = fopen(studyindexpath,'w');
if fd < 0
  fprintf('Could not create study index file\n');
  return
end

% Write HTML header
fprintf(fd,'<html>\n');
fprintf(fd,'<body>\n');

% Locate Paravision studies within this directory
fprintf('Locating Paravision studies in %s\n', basedir);
studylist = parxfindstudies(basedir);

ns = length(studylist);
fprintf('Found %d studies in %s\n',ns,basedir);

% Bail out if no studies found
if ns < 1
  fprintf('Exiting\n');
  return
end

% Print banner
fprintf(fd,'<h1><font face="arial">Study Index</font></h1>\n');
fprintf(fd,'<table border=0 cellpadding=5>\n');
fprintf(fd,'<tr><td><b>Base Directory</b><td>%s</tr>\n', basedir);
fprintf(fd,'<tr><td><b>Report Generated</b><td>%s by parxreport.m</tr>\n',datestr(now()));
fprintf(fd,'</table><hr><br>\n');

% Start new table for study index entries
fprintf(fd,'<table border=0 cellpadding=5>\n');
fprintf(fd,'<tr><td><b>Study ID<td><b>Name<td><b>Time</tr>');

% Create entries for each study
for sc = 1:length(studylist)
  
  % parxstudyreport returns the filename of the scan index HTML page
  [scanindexpage,sinfo] = parxstudyreport(studylist{sc},reportdir,studyindexpage);
  
  if isempty(scanindexpage) || isempty(sinfo)
    
    fprintf('Empty index page or subject information\n');
    
  else
    
    fprintf(fd,'<tr>\n');
  
    % First column links to scan index for each study
    fprintf(fd,'<td><a href="%s">%s</a><br>\n',scanindexpage,sinfo.id);
    
    fprintf(fd,'<td>%s<td>%s\n',sinfo.name,sinfo.time);
    
  end
  
end

% Close out table
fprintf(fd,'</table>\n');

% Write HTML footer
fprintf(fd,'</body>\n');
fprintf(fd,'</html\n>\n');

% Close index file
fclose(fd);

% Display the index page in Matlab's browser
web(['file:///' studyindexpath]);