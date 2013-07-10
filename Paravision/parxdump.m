function parxdump(info)
% parxdump(info)
%
% Print out single line series information summary
%
% ARGS:
% info = information structure
%
% RETURNS:
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 04/26/2001 From scratch
%          01/17/2006 JMT M-Lint corrections
%
% Copyright 2001-2006 California Institute of Technology.
% All rights reserved.

% Defaults
if nargin < 1
  return
end

% Basic info
fprintf('%d,', info.scanno);
fprintf('%s,', info.method);

% Timing and averages
fprintf('%0.1f,%0.1f,%d,',...
  info.tr, info.te, info.navs);

if isfield(info,'dim')
  ndim = length(info.dim);
else
  ndim = 0;
end

% Matrix size
for d = 1:3
  fprintf('%d,', info.sampdim(d));
end

% FOV size
for d = 1:3
  fprintf('%0.1f,', info.fov(d));
end

% Slice thickness
fprintf('%0.2f,', info.slthick);

% b factor is present
if isfield(info,'bfactor')
  fprintf('%0.1f',info.bfactor);
end

fprintf('\n');