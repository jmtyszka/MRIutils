function idxfile = parxstudyreport(studydir,reportdir)
% idxfile = parxstudyreport(studydir)
%
% Generate HTML report pages and an index for
% all scans within the supplied Paravision directory. The report
% is created within the supplied report directory.
%
% ARGS :
% studydir  = directory containing Paravision exams,studies and series
% reportdir = destination directory for HTML reports and indices
% 
% RETURNS:
% idxfile   = index file path for report
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 01/10/2002 Adapt from parxindex.m (JMT)
%          01/17/2006 JMT M-Lint corrections
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

% Default args
if nargin < 1; studydir = pwd; end
if nargin < 2; reportdir = fullfile(studydir,'report'); end

% Default returns
idxfile = [];

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
idxfile = sprintf('%s_%04d.htm',info.name,info.studyno);
idxpath = fullfile(reportdir,idxfile);
fd = fopen(idxpath,'w');
if fd < 0
  fprintf('Could not create report/index.htm\n');
  return
end

% Write HTML header
fprintf(fd,'<html>\n');
fprintf(fd,'<body>\n');

% Start outer table
fprintf(fd,'<table width=100%% border=1 cellpad=5>\n');

% Sort numerically
snum = sort(snum);

% Loop over all scans
for sc = 1:n
  
  fname = num2str(snum(sc));
  
  % Create HTML report directory for this series in the exam/study/series directory tree
  [reportname,info,thumbname] = parxscanreport(fullfile(studydir,fname),reportdir);
  
  if sc == 1
    % Create subject information line
    fprintf(fd,'<tr bgcolor=#333333><td colspan="5"><font face="arial" color=#ffffff>%s %s %s</td>\n',...
      studydir,info.name,info.time);
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
