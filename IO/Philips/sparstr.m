function s = sparstr(fd)
% Extract a string field from a Philips .spar file
%
% s = sparstr(fd)
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : ETH Zuerich
% DATES  : 08/01/2003 JMT From scratch
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

% Default return
s = [];

tline = fgetl(fd);

while tline(1) == '!'; tline = fgetl(fd); end

ss = strread(tline,'%s','delimiter',':');
r = ss{2};

% Catch empty field string
if length(r) < 2; return; end

% Remove leading space if present
if isequal(r(1),' ')
  r = r(2:length(r));
end

% Remove double quotes
r(findstr(r,'"')) = [];

% Remove square braces
r(findstr(r,'[')) = [];
r(findstr(r,']')) = [];

s = r;
