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
