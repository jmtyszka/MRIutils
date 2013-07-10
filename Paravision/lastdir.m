function d = lastdir(p)
% d = lastdir(p)
%
% Returns the last directory in the path, p
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 03/01/2001 From scratch
%          01/17/2006 JMT M-Lint corrections
%
% Copyright 2001-2006 California Institute of Technology.
% All rights reserved.

% Split pathname using '\' delimiter
s = strread(p,'%s','delimiter','\\');

% Last member of cell array is the final directory
d = s{length(s)};