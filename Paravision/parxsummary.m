function parxsummary(rootdir)
% parxsummary(rootdir)
%
% Create a summary of the study information within
% a given directory containing one or more paravision studies.
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 08/17/2005 JMT Adapt from parxindex.m (JMT)
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

% Splash text
fprintf('\n');
fprintf('Paravision Summary\n');
fprintf('------------------\n');

% Defaults
if nargin < 1; rootdir = pwd; end
if nargin < 2; summaryfile = fullfile(rootdir,'summary.txt'); end

fd = fopen(summaryfile,'w');
if fd < 1
  return
end

d = dir(rootdir);

for sc = 1:length(d)

  dirname = d(sc).name;

  if ~isequal(dirname,'.') && ~isequal(dirname,'..')

    fullname = fullfile(rootdir,dirname);

    if exist(fullname,'dir')

      subjfile = fullfile(fullname,'subject');

      if exist(subjfile,'file')

        info = parxloadinfo(fullfile(fullname,'1'));
        
        if ~isequal(info.name,'Unknown')
          
          fprintf('Summarizing %s\n', dirname);

          fprintf(fd,'Directory ID : %s\n', dirname);
          fprintf(fd,'Subject Name : %s\n', info.name);
          fprintf(fd,'Study Name   : %s\n', info.studyname);
          fprintf(fd,'Study Number : %d\n', info.studyno);
          fprintf(fd,'Start time   : %s\n', info.time);
          fprintf(fd,'Purpose :\n');
          fprintf(fd,'  %s\n', info.purpose);
          fprintf(fd,'Remarks :\n');
          fprintf(fd,'  %s\n', info.remarks);
          fprintf(fd,'------------------------------------------------\n');
          fprintf(fd,'\n');
          
        end

      end

    end

  end
  
end

% Close the index file
fclose(fd);
