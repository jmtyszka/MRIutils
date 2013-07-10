function d = parxextractdouble(info, tag)
% d = parxextractdouble(info, tag)
%
% Extract a double from the end of the line containing the tag
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 11/02/2000 Clone from parxextractstring.m
%          01/17/2006 JMT M-Lint corrections
%
% Copyright 2000-2006 California Institute of Technology.
% All rights reserved.

% Default is NaN value
d = nan;

% Search the cell array for the tag
loc = strmatch(tag, info);

% Return if tag not found
if isempty(loc); return; end

if length(loc) > 1
  fprintf('%s: More than one occurance, using first\n', tag);
  loc = loc(1);
end

% The string follows the '=' in this line
ss = strread(info{loc},'%s','delimiter','=');
s = ss{2};

% Extract double number using space as a delimiter to remove units, etc
% following the value
ss = strread(s,'%f','delimiter',' ');
d = ss(1);