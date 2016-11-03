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
%          2016-08-24 JMT Added voxel dimensions
%
% Copyright 2001-2006 California Institute of Technology.
% All rights reserved.

% Defaults
if nargin < 1
  return
end

fprintf('%-4d', info.scanno);
fprintf('%-24s', info.name);
fprintf('%-12s', info.method);
fprintf('%5.0f/%-5.0f ', info.tr, info.te);

if isfield(info,'dim')
  ndim = length(info.dim);
else
  ndim = 0;
end

% Matrix size
switch ndim
case 0
case 1
  fprintf('%d | ', info.dim(1));
otherwise
  for d = 1:(ndim-1)
    fprintf('%dx', info.dim(d));
  end
  fprintf('%d | ', info.dim(ndim));
end

% FOV size
switch ndim
case 0
case 1
  fprintf('%0.1f | ', info.fov(1));
otherwise
  for d = 1:(ndim-1)
    fprintf('%0.1fx', info.fov(d));
  end
  fprintf('%0.1f | ', info.fov(ndim));
end

% Voxel size
switch ndim
case 0
case 1
  fprintf('%0.1f | ', info.fov(1) / info.dim(1));
otherwise
  for d = 1:(ndim-1)
    fprintf('%0.1fx', info.fov(d) / info.dim(d));
  end
  fprintf('%0.1f | ', info.fov(ndim) / info.dim(ndim));
end

% b factor is present
if isfield(info,'bfactor')
  fprintf('%0.1f ',info.bfactor);
  fprintf('(%0.1f)',sum(info.bfactor));
end

fprintf('\n');