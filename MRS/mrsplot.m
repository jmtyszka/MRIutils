function mrsplot(ppm, s, ppmrange, srange, info)
% Pretty plot the phased real channel of a complex spectrum
%
% mrsplot(ppm, s, ppmrange, srange)
%
% ARGS :
% s   = complex 1H spectrum vector
% ppm = chemical shift vector in ppm
% ppmrange = range of ppm values to display
% srange   = range of signal values to display
%
% RETURNS :
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 07/17/2002 JMT Adapt from SpecPlot.m and parxplotmrs.m
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

% Adjust ppm and signal ranges if required
if nargin < 3 || isempty(ppmrange)
  ppmrange = [min(ppm) max(ppm)];
end

% Extract the real channel
sr = real(s);

if nargin < 4 || isempty(srange)
  srange = [min(sr) max(sr)];
end

if nargin < 5
  info = [];
end

% Normalize the spectral noise
%[srn, sd_n] = noisenorm(sr);
%fprintf('Noise sd estimate : %g\n', sd_n);
srn = sr;

% Plot the spectrum
plot(ppm, srn, 'k');
set(gca, 'XDir','reverse','XLim',ppmrange);
set(gca,'YLim',srange);
xlabel('Chemical Shift (ppm)');

% Display optional title using information structure
if ~isempty(info)

  % Remove underscores in id and method
  info.id(info.id == '_') = '-';
  info.method(info.method == '_') = '-';

  % Construct title string
  tstring = sprintf('%s %d:%d %s %d/%d', info.id, info.studyno, info.serno, info.method, info.tr, info.te);
  title(tstring);
end

