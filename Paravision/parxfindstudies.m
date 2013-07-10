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
% Copyright 2000-2006 California Institute of Technology. All rights
% reserved.

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