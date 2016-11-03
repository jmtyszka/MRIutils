function [f, Vm, Vmex] = voigtcmp
% Compare results of M and MEX versions of voigt
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 05/24/00 Start from scratch
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

nsamp = 256;
maxdV = zeros(1,nsamp);
mindV = zeros(1,nsamp);

for c = 1:nsamp
   f = -1.0:0.001:1;
   I = rand(1,1) * 10;
   f0 = rand(1,1) - 0.5;
   gL = rand(1,1);
   gD = rand(1,1);
   phi = pi*(rand(1,1)-0.5);
   
   Vm = voigt(f,I,f0,gL,gD,phi);
   Vmex = voigt_mex(f,I,f0,gL,gD,phi);
   dV = Vm - Vmex;
   
   maxdV(c) = max(dV);
   mindV(c) = min(dV);
end

fprintf('E(max,min dV) = [%g, %g]\n', mean(maxdV), mean(mindV));
fprintf('sd(max,min dV) = [%g, %g]\n', std(maxdV), std(mindV));
