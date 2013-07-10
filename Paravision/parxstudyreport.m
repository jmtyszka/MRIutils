function [scanindexpage,subjectinfo] = parxstudyreport(studydir,reportdir,studyindexpage)
% [scanindexpage,subjectinfo] = parxstudyreport(studydir,reportdir,studyindexpage)
%
% Generate HTML report pages and an index for
% all scans within the supplied Paravision directory. The report
% is created within the supplied report directory.
%
% ARGS :
% studydir  = directory containing Paravision exams,studies and series
% reportdir = destination directory for HTML reports and indices
% studyindexpage = index HTML page for all studies
% 
% RETURNS:
% scanindexpage = index HTML page for scans within this study
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 01/10/2002 Adapt from parxindex.m (JMT)
%          01/17/2006 JMT M-Lint corrections
%
% Copyright 2002-2006 California Institute of Technology.
% All rights reserved.

% Default args
if nargin < 1; studydir = pwd; end
if nargin < 2; reportdir = fullfile(studydir,'report'); end

% Default returns
scanindexpage = [];
subjectinfo = [];

% Make the report directory if necessary
if ~exist(reportdir,'dir')
  fprintf('Creating %s\n', reportdir);
  [status,msg] = mkdir(reportdir);
  if status == 0
    fprintf('%s\n',msg);
    return
  end
end

% Load study directory entries
d = dir(studydir);

% Extract valid scan number directory names
n = 0;
snum = [];
for sc = 1:length(d)
  sn = str2double(d(sc).name);
  if ~isempty(sn) && sn > 0
    n = n + 1;
    snum(n) = sn;
  end
end

if isempty(snum)
  fprintf('*** No Paravision scans found in %s\n',studydir);
  fprintf('*** Exiting\n');
  return
end

%---------------------------------------------------
% Start generating study report
%---------------------------------------------------

fprintf('Generating report for %s\n',studydir);

% Load info for first valid scan and use subject info
info = parxloadinfo(fullfile(studydir,num2str(snum(1))));
if isempty(info) || isequal(info.name,'Unknown')
  fprintf('Problem loading subject info\n');
  return
end

% Create index file for this study
scanindexpage = sprintf('%s_%04d.htm',info.name,info.studyno);
scanindexpath = fullfile(reportdir,scanindexpage);

fd = fopen(scanindexpath,'w');
if fd < 0
  fprintf('Could not create study index file: %s\n', scanindexpath);
  return
end

% Write HTML header
fprintf(fd,'<html>\n');
fprintf(fd,'<body>\n');

% Insert return link
fprintf(fd,'<h2><a href="%s">Return to Study Index</a></h2>\n',studyindexpage);

% Study info
fprintf(fd,'<table border=0 cellpadding=5>\n');
fprintf(fd,'<tr><td><b>Study Directory</b><td>%s</tr>\n', studydir);
fprintf(fd,'<tr><td><b>Exam Name</b><td>%s</tr>\n',info.name);
fprintf(fd,'<tr><td><b>Study Number</b><td>%d</tr>\n',info.studyno);
fprintf(fd,'<tr><td><b>Exam Time</b><td>%s</tr>\n',info.time);
fprintf(fd,'</table><hr><br>\n');
    
% Start outer table
fprintf(fd,'<table width=100%% border=0 cellpad=1>\n');

% Sort numerically
snum = sort(snum);

% Loop over all scans in this study
for sc = 1:n

  fname = num2str(snum(sc));
  
  % Create HTML report directory for this series in the exam/study/series directory tree
  [reportname,info,thumbname] = parxscanreport(fullfile(studydir,fname),reportdir,scanindexpage);
  
  % Save first scan information for subject parameters
  if sc == 1
    subjectinfo = info;
  end

  if ~isempty(reportname)
    fprintf('  Creating page for %s\n', fname);
    if mod(sc,5) == 1
      fprintf(fd,'<tr>\n');
    end
    fprintf(fd,'<td width=200 height=64>\n');
    fprintf(fd,'<a href="%s">\n',reportname);
    fprintf(fd,'<img src="%s" align="middle" border="0">\n',thumbname); 
    fprintf(fd,'%s %s</a>\n',fname,info.method);
    fprintf(fd,'</td>\n');
  end

end

% End outer table
fprintf(fd,'<table>\n');

% Write HTML footer
fprintf(fd,'</body>\n');
fprintf(fd,'</html\n>\n');

% Close index file
fclose(fd);