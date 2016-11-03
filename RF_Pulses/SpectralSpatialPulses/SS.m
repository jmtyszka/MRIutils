function [t, Gt, B1t, x, w, mxy] = SS
% [t, Gt, B1t, mxy] = SS
% Make a spectral spatial pulse
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

Gmax = 20.0e-3;      % T/m
Smax = 100.0;        % T/m/s
Deltax = 10.0e-3;    % m
Deltaf = 100.0;      % Hz
dt = 16.0e-6;        % s
PW = 64.0e-3;        % s

[B1,t,Gt,B1t,kwt,kxt] = SSpulse(Gmax, Smax, Deltax, Deltaf, dt, PW);

% Plot gradient and kxf-space trajectory
subplot(2,2,1), plot(t, Gt);
set(gca,'XLim',[min(t) max(t)], 'YLim', 1.1 * [min(Gt) max(Gt)]);
title('Gradient Waveform');
xlabel('Time (s)');
ylabel('Gradient (T/m)');

% Plot B1(t)
subplot(2,2,2), plot(t, real(B1t), t, imag(B1t));
set(gca,'XLim',[min(t) max(t)]);
title('RF Waveform');
xlabel('Time (s)');
ylabel('B1(t) (T)');

drawnow;

% Now calculate Bloch equation response of complex B1 pulse and gradient waveform
[x,w,mxy] = SSBlochSim(t,Gt,4.0*B1t);

% Draw the absolute response
subplot(2,1,2), surfl(w/(2*pi),x*1000,abs(mxy));
xlabel('Frequency (Hz)');
ylabel('Distance (mm)');
zlabel('|mxy|');
title('Spectral-Spatial Magnitude Response');
