function S = CoilNoiseRatio
% Calculate sample noise to coil noise ratio for ranges of B0 and sample radius
%
% USAGE : S = CoilNoiseRatio
%
% AUTHOR : Mike Tyszka
% PLACE  : Caltech BIC
% DATES  : 06/17/2002 From scratch
%          03/20/2014 Update comments
% REFS   : Mansfield and Morris
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

% log range of B0 to consider
logB = -2:0.2:1;

% B0 range in Tesla
B = 10.^logB;

% Corresponding 1H frequency range in Hz
f = 4.2e6 * B;

% log object radius range to consider
logR = -3:0.1:1;

% Radius range in meters
R = 10.^logR;

% Create coordinate grid
[allf, allR] = meshgrid(R,f);

% Calculate sample noise / coil noise ratio
S = allf.^2 .* allR.^2 ./ sqrt(allf.^2 * allR.^3 + A * f.^0.5);

% Contour plot of SNR 
contour(allf,allR,S);
