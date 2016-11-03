function rf = pvmextractrfpulse(info, tag)
% rf = pvmextractrfpulse(info, tag)
%
% Extract all members of a PvM RF pulse structure
% from a method file cell array read by pvmloadinfo.m
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 04/04/2004 JMT From scratch
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

% Default return is empty matrix
rf = [];

% Search the cell array for the tag
loc = strmatch(tag, info);

% If field not present return default value
if isempty(loc); return; end

% Only use the first occurance of the tag
if length(loc) > 1
  loc = loc(1);
end

% Assume RF pulse covers three lines - concatenate
r = strcat(info{loc},info{loc+1},info{loc+2});

% Parse RF pulse string deliminting with '(,) '
ss = strread(r,'%s','delimiter','(,) ');
rf.pw = str2double(ss(2));
rf.bw = str2double(ss(3));
rf.flip = str2double(ss(4));
rf.atten = str2double(ss(5));
rf.trim1 = str2double(ss(6));
rf.trim2 = str2double(ss(7));
rf.trim3 = str2double(ss(8));
rf.lib = ss{9};
rf.shape = ss{10};
rf.tb = str2double(ss(11));
rf.refpw = str2double(ss(12));
rf.refatten = str2double(ss(13));
rf.minpw = str2double(ss(14));
rf.type = ss{15};



