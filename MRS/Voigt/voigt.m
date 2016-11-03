function V = voigt(f, I0, f0, gL, gD, phi)
% V = voigt(f, I0, f0, gL, gD, phi)
%
% Generate a complex Voigt lineshape
%
% f   = Frequency vector
% I0  = Amplitude
% f0  = Central frequency
% gL  = Lorentzian width
% gD  = Doppler (Gaussian) width 
% phi = Phase in radians
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 4/28/00 Start from memory
% REFS   : Armstrong BH J Quant Spectrosc Radiat Transfer 1967; 7:61-88
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

% Numerical scale for x and y
A = sqrt(log(2)) / gD;

x = (f-f0) * A;
y = gL * A;

% humlicek() returns an approximation to w(z), the Voigt/Fadeeva function
% The complex conjugate of w(z) gives the correct phase for NMR spectra
[V, V0] = humlicek_mex(x,y);

% Normalize V to 1.0 then scale by I0 exp(i phi)
V = I0 * exp(i * phi) * conj(V) / V0; 
