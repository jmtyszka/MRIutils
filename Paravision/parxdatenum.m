function mdn = parxdatenum(pds)
% mdn = parxdatenum(pds)
%
% Convert from PARX data format to a Matlab date number
%
% PARX Date: <hh:mm:ss Day Month Year>
%
% ARGS:
% pds = PARX date string
%
% RETURNS:
% mdn = Matlab date number

% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 03/01/2001 From scratch
%          01/17/2006 JMT M-Lint corrections
%
% Copyright 2001-2006 California Institute of Technology.
% All rights reserved.

% Convert the Matlab date string to a date number
mdn = datenum(parxdatestr(pds));