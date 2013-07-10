function m = parxextractmatrix(info, tag)
% m = parxextractmatrix(info, tag)
%
% Extract a matrix of values from the cell array 'info'
% and return in m. Searches for the parameter tag and
% parses the following line for values.
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 10/05/2000 JMT From scratch
%          04/14/2003 JMT Add support for multiple slice packages
%          01/17/2006 JMT M-Lint corrections
%
% Copyright 2000-2006 California Institute of Technology.
% All rights reserved.

% Default value is empty matrix
m = [];

% Search the cell array for the tag
loc = strmatch(tag, info);

% If field not present return default value
if isempty(loc); return; end

% Only use the first occurance of the tag
if length(loc) > 1
  loc = loc(1);
end

% Get the number of matrix elements
tagline = info{loc};

% Find start and end of matrix elements count
c0 = find(tagline == '(');
c1 = find(tagline == ')');

% Return is elements count not found
if isempty(c0) || isempty(c1); return; end

% Extract elements count
% This may be a 2D matrix if more than one slice pack was acquired
nels = fliplr(str2num(tagline((c0+1):(c1-1))));

% Return if elements count is zero
if isequal(nels,0); return; end

% Initialize pointers, flags, etc
keep_going = 1;
count = 0;
ptr = loc+1;
m = [];

while keep_going && count < prod(nels)

  % The matrix values are in the next cell
  ms = info{ptr};

  % Convert this row of ASCII reals to column vector
  this_m = sscanf(ms, '%f');
  
  % Escape clause
  if isempty(this_m); keep_going = 0; end
  
  % Concatenate new values onto current column vector
  m = [m; this_m];
  
  % Increment counter and pointer into cell array
  count = count + length(this_m);
  ptr = ptr + 1;
  
end

% Reshape matrix if necessary
if length(nels) > 1
  m = reshape(m,nels);
end