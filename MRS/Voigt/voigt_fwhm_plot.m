function [gL,gD,fwhm] = voigt_fwhm_plot(n)
% VOIGT_FWHM_PLOT Contour plot of results with labels
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

gmax = 0.1;

dn = gmax/n;

gL = dn:dn:gmax;
gD = dn:dn:gmax;

fwhm = zeros(n,n);

for ll = 1:n
   for dd = 1:n
      
      fwhm(ll,dd) = voigt_fwhm(gL(ll),gD(dd));
      
   end
end

% Contour plot of results with labels
[c,h] = contour(gL,gD,fwhm);
clabel(c,h)
xlabel('gD'); ylabel('gL');
