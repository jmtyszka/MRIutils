function NR = NoiseRatio
% NR = NoiseRatio
% Sample to Coil noise ratio at various sample or coil sizes and field strengths
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : City of Hope, Duarte CA
% DATES  : 06/06/2000 From scratch
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

% B0 on a log grid
logB = -2:0.1:1.2;
B = 10.^logB;  % Tesla

% Sample or coil size on a log grid
logR = -3:0.1:0;
R = 10.^logR; % m

% Coordinate grids for size (R) and B0 (B)
[allR, allB] = meshgrid(R,B);

% Larmor frequencies for each B0 in Hz
allf = 4.2e6 * allB;

% Noise voltages in sample and coil
VS = allf.* allR.^1.5;
VC = allf.^0.25;

% Noise ratio
NR = VS./VC;

% Normalize all ratios to value for 25cm sample/coil (Human Head) at 1.5 Tesla
A = interp2(allR, allB, NR, 0.25, 1.5, 'cubic');

% Normalize head at 1.5 to a ratio of 10 -> log10(R) = 1
NR = NR / A * 10;

clf

% Set an appropriate colormap
colormap(jet);

[c,h] = contourf(allB,allR,log10(NR)); colorbar;
xlabel('Field Strength (Tesla)','FontSize',[14]);
ylabel('Sample or Coil Size (m)','FontSize',[14]);
title('log_{10}(Sample Noise / Coil Noise)','FontSize',[14]);
set(gca,'XScale','log','YScale','log');

% Label some interesting points
text(1.5, 0.25, '\bulletHead(1.5T)','FontSize',[14],'FontWeight','bold');
text(0.1, 0.25, '\bulletHead(0.1T)','FontSize',[14],'FontWeight','bold');
text(9.7,0.02,'Rat(9.7T)\bullet','HorizontalAlignment','right','FontSize',[14],'FontWeight','bold');
text(11.7,0.01,'Mouse(11.7T)\bullet','HorizontalAlignment','right','FontSize',[14],'FontWeight','bold');

