function parxplotmrs(imnddir, ppmrange, srange)
% parxplotmrs(imnddir, ppmrange, srange)
%
% Pretty plot the phased spectrum in this directory
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 08/08/2001 From scratch
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

if nargin < 1; imnddir = '.'; end

[s,ppm,info] = parxloadmrs(imnddir);

if nargin < 2 || isempty(ppmrange)
  ppmrange = [min(ppm) max(ppm)];
end

if nargin < 3; srange = []; end

% Extract the real channel
sr = real(s);

% Normalize the spectral noise
% [srn, sd_n] = noisenorm(sr);
% fprintf('Noise sd estimate : %g\n', sd_n);
srn = sr;

figure(1); clf;

plot(ppm, srn, 'k');

set(gca, 'XDir','reverse','XLim',ppmrange);

if ~isempty(srange)
  set(gca,'YLim',srange);
end

xlabel('Chemical Shift (ppm)');

% Remove underscores in id and method
info.id(info.id == '_') = '-';
info.method(info.method == '_') = '-';
