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
