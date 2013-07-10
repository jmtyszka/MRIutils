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
% Copyright 2001-2006 California Institute of Technology.
% All rights reserved.

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