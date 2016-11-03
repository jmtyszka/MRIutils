function [x,w,mxy] = SStest
% Test Bloch Equation simulation of a pulse
% 1ms 3-lobe sinc has BW = 6000Hz
% 1G/cm = 4200 Hz/cm
% Slice width = 6000/4200 = 1.4cm
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

PW = 1e-3;
dt = 8e-6;
t = (0:dt:(PW-dt))-PW/2;   % 1ms pulse in 8us increments
w = 3.0*2*pi/PW;           % 3-lobe sinc
phi = w*t;
B1t = sin(phi)./(phi);
B1t(isnan(B1t)) = 1.0;

B1t = B1t / 1e6; % Scale B1 into low flip angle regime

Gt = 1.0e-2*ones(size(B1t)); % 1 G/cm gradient

[x,w,mxy] = SSBlochSim(t,Gt,B1t);

surfl(w,x,abs(mxy)); shading interp;
