function lns = parxtextread(fname)
% lns = parxtextread(fname)
%
% Load lines from text file into cell elements
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 12/10/2001 From scratch
%          01/17/2006 JMT M-Lint corrections
%
% Copyright 2001-2006 California Institute of Technology.
% All rights reserved.

lns = {};

fd = fopen(fname);

if fd < 0
  return
end

count = 1;

while 1
  tline = fgetl(fd);
  if ~ischar(tline)
    break
  end
  lns{count} = tline;
  count = count + 1;
end

fclose(fd);