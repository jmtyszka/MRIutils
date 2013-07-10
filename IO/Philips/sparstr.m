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
% Copyright 2003-2006 California Institute of Technology.
% All rights reserved.
%
% This file is part of MRutils.
%
% MRutils is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% MRutils is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with MRutils; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

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