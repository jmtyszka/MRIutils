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
% Copyright 2001-2006 California Institute of Technology.
% All rights reserved.

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