function xray(s, projmeth)
% Display three-plane projections through a 3D dataset
%
% xray(s, projmeth)
%
% ARGS :
% s = 3D scalar image
% projment = 'xray' or 'mip'
%
% RETURNS :
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 07/25/2002 JMT From scratch
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

if nargin < 2; projmeth = 'mip'; end

switch projmeth
case 'mip'
  sx = squeeze(max(s,[],1))';
  sy = squeeze(max(s,[],2))';
  sz = squeeze(max(s,[],3));
otherwise
  sx = squeeze(mean(s,1))';
  sy = squeeze(mean(s,2))';
  sz = squeeze(mean(s,3));
end

subplot(221), imagesc(sx);
title('Coronal','Color','w');
axis equal xy;
set(gca,'XColor','w','YColor','w');

subplot(223), imagesc(sy);
title('Sagittal','Color','w');
axis equal xy;
set(gca,'XColor','w','YColor','w');

subplot(224), imagesc(sz);
title('Axial','Color','w');
axis equal xy;
set(gca,'XColor','w','YColor','w');
