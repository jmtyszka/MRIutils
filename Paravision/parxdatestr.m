function mds = parxdatestr(pds)
% mds = parxdatestr(pds)
%
% Convert from PARX data format to Matlab date string
%
% PARX Date: hh:mm:ss dd MMM YYYY
% MAT Date : Day-Month-Year hh:mm:ss
%
% ARGS:
% pds = PARX date string
%
% RETURNS:
% mds = Matlab date string

% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 03/01/2001 From scratch
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

if length(pds) ~= 20
  mds = datestr(0);
  return;
end

% Parse the PARX date string
tt = pds(1:8);
dd = str2double(pds(10:11));
mm = pds(13:15);
yyyy = str2double(pds(17:20));

% Reconstruct the Matlab date string
mds = sprintf('%02d-%s-%04d %s', dd, mm, yyyy, tt);
