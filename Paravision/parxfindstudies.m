function studylist = parxfindstudies(basedir, subdir, studylist)
% studylist = parxfindstudies(basedir, subdir, studylist)
%
% Return a structure array of the all Paravision studies within basedir.
% The tree is searched recursively using this function.
%
% ARGS:
% basedir = base directory to work from
% subdir  = subdirectory name
% studylist = updating cell array of detected studies
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 12/08/2005 JMT Add support for PvM methods
%          01/17/2006 JMT M-lint corrections
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

% Initialize lists if first call
if nargin < 1; basedir = pwd; end
if nargin < 2; subdir = []; end
if nargin < 3; studylist = {}; end

% Pointer to the last element of the list of PC data dirs
ptr = length(studylist);

% Construct current search directory path
if isempty(subdir)
  curdir = basedir;
else
  curdir = fullfile(basedir,subdir);
end

% List of all entries in the current directory
d = dir(curdir);
nd = length(d);

% Fill arrays of names and directory flags
dname = cell(1,nd);
dflag = zeros(1,nd);
for dc = 1:nd
  dname{dc} = d(dc).name;
  dflag(dc) = d(dc).isdir;
end

% Remove '.' and '..' entries
dots = strmatch('.',dname);
dname(dots) = [];
dflag(dots) = [];
nd = length(dname);

% Search for 'subject' file in cell array
sinds = strmatch('subject',dname);

if ~isempty(sinds)
  ptr = ptr + 1;
  studylist{ptr} = curdir;
  return
end

% If no subdirectories, bail out of recursion
if isempty(find(dflag,1))
  return
end

% Continue search into remaining subdirectories
for dc = 1:nd
    
  if dflag(dc)

    if isempty(subdir)
      nextdir = dname{dc};
    else
      nextdir = fullfile(subdir,dname{dc});
    end

    % Recursion on parxfindstudies
    studylist = parxfindstudies(basedir, nextdir, studylist);

  end

end
