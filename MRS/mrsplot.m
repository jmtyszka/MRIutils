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
% Copyright 2002-2006 California Institute of Technology.
% All rights reserved.
%
% This file is part of MRutils.
%
% MRutils is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% MRutils is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with MRutils; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

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

