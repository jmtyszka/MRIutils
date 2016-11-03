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
