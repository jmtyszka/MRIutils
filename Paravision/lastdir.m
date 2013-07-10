function d = lastdir(p)
% d = lastdir(p)
%
% Returns the last directory in the path, p
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 03/01/2001 JMT From scratch
%          01/17/2006 JMT M-Lint corrections
%          02/27/2006 JMT Use filesep
%
% Copyright 2001-2006 California Institute of Technology.
% All rights reserved.

% Split pathname using fileseparator as delimiter
s = strread(p,'%s','delimiter',filesep);

% Last member of cell array is the final directory
d = s{length(s)};