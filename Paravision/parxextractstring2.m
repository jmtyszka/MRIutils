function s = parxextractstring2(info, tag)
% s = parxextractstring2(info, tag)
%
% Extract a string from the line following the tag
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 10/05/2000 From scratch
%          01/17/2006 JMT M-Lint corrections
%
% Copyright 2000-2006 California Institute of Technology.
% All rights reserved.

% Default is empty matrix
s = 'NULL';

% Search the cell array for the tag
loc = strmatch(tag, info);

% Return if tag not found
if isempty(loc); return; end

if length(loc) > 1
  fprintf('%s: More than one occurance, using first\n', tag);
  loc = loc(1);
end

% The string is in the next cell
% If final character is '\' ie continuation, keep adding the next line
% until complete

s = [];
keep_going = 1;

while keep_going
  s = [s info{loc+1}];
  if isequal(s(length(s)),'\')
    s(length(s)) = ' ';
    loc = loc + 1;
    keep_going = 1;
  else
    keep_going = 0;
  end
end

% Strip angle brackets if present
if isequal(s(1),'<'); s(1) = []; end
if isequal(s(length(s)),'>'); s(length(s)) = []; end