function tp = threeplanemont(s,clims)
% Create a three-plane montage from a 3D dataset.
%
% tp = threeplanemont(s,clims)
%
% Allow specification of intensity limits and colormap.
%
% ARGS :
% s     = 3D dataset
% clims = colormap limits
% sp    = subplot parameters [nx ny Axloc Sagloc Corloc] eg [2 2 1 2 3]
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : City of Hope, Duarte CA
% DATES  : 09/07/2001 JMT Adapt from montagegray
%          06/20/2002 JMT Add colormap argument
%          01/17/2006 JMT M-Lint corrections
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

% Defaults if arguments aren't passed
if nargin < 1
  help threeplane
  return
end

if nargin < 2; clims = []; end
if isempty(clims); clims = [min(s(:)) max(s(:))]; end

% Catch equal limits
if diff(clims) == 0
  clims = [min(s(:)) max(s(:))];
end

% Get new dimensions
[nx,ny,nz] = size(s);
hx = round(nx/2);
hy = round(ny/2);
hz = round(nz/2);

% Clamp s[] to these limits
s(s < clims(1)) = clims(1);
s(s > clims(2)) = clims(2);

% Extract axial, sagittal and coronal midline sections
Ax  = squeeze(s(:,:,hz))';
Sag = flipdim(squeeze(s(hx,:,:))',2);
Cor = squeeze(s(:,hy,:))';

% Determine maximum vertical dimension
dims = [size(Ax); size(Sag); size(Cor)];

% Find maximum dimensions of any orthogonal slice
newdims = max(dims);

Ax  = impad(Ax,newdims);
Sag = impad(Sag,newdims);
Cor = impad(Cor,newdims);

% Montage the three planes
tp = [Ax Sag Cor];
