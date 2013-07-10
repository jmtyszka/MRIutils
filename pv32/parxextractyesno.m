function yn = parxextractyesno(info, tag)
% yn = parxextractyesno(info, tag)
%
% Extract a YesNo following the tag
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 10/05/2000 JMT From scratch
%          01/17/2006 JMT M-Lint corrections
%
% Copyright 2000-2006 California Institute of Technology.
% All rights reserved.

% Default is empty matrix
yn = false;

% Search the cell array for the tag
loc = strmatch(tag, info);

% Return if tag not found
if isempty(loc); return; end

if length(loc) > 1
  loc = loc(1);
end

% The answer follows the '=' on this line
s = info{loc};
yn = isempty(findstr('No', s));
