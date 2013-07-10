function [h,m,s] = parxacqtime(acqstr)
% t = parxacqtime(acqstr)
%
% Parse acqtime string (%dh%dm%ds%dms) into hours, minutes and seconds
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 09/28/2004 JMT From scratch
%          01/17/2006 JMT M-Lint corrections
%
% Copyright 2004-2006 California Institute of Technology.
% All rights reserved.

% Split input string into integers separated by h,m,s or ms
n = strread(acqstr,'%d','delimiter','hms');

% Parse cell array of integers
h = n(1);
m = n(2);
s = n(3);
ms = n(4);

if isempty(h);  h = 0;  end
if isempty(m);  m = 0;  end
if isempty(s);  s = 0;  end
if isempty(ms); ms = 0; end

% Combine ms in seconds return value
s = s + ms / 1000;

