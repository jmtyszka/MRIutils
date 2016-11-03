function [B1,t,Gt,B1t,kwt,kxt] = SSpulse(Gmax, Smax, Deltax, Deltaf, dt, PW)
% [B1,t,Gt,B1t,kwt,kxt] = SSpulse(Gmax, Smax, Deltax, Deltaf, dt, PW)
%
% Simple spectral spatial pulse design using FT small flip approx
% and cosinusoidal gradient waveform
%
% INPUT PARAMETERS:
% Gmax   : Maxmimum gradient amplitude (T/m)
% Smax   : Maximum slew rate (T/m/s)
% Deltax : Slice thickness (m)
% Deltaf : Spectral passband width (Hz)
% dt     : Temporal sampling rate (s)
% PW     : Pulse width (s)
%
% OUTPUT PARAMETERS:
% B1     : B1(k) (Tesla)
% t      : Time samples for pulse (seconds)
% Gt     : Gradient waveform corresponding to t (T/m)
% B1t    : B1 waveform corresponding to t (Tesla)
% kwt    : kw waveform
% kxt    : kx waveform
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : City of Hope, Duarte, CA
% DATES  : 09/10/98  First working version
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

% Constants
GAMMA = 2 * pi * 4.2e7; % rad/s/T

% Summarize all the parameters
fprintf('\nINDEPENDENT PARAMETERS\n');
fprintf('Maxmimum gradient amplitude : %0.2f G/cm\n', Gmax*1.0e2);
fprintf('Maximum slew rate           : %0.1f T/m/s\n', Smax);
fprintf('Pulse duration              : %0.2f ms\n', PW*1e3);
fprintf('Slice thickness             : %0.2f mm\n', Deltax*1e3);
fprintf('Spectral passband           : %0.1f Hz\n', Deltaf);
fprintf('Temporal sampling interval  : %0.1f us\n', dt*1e6);

% Matrix dimensions of x-w sample space
nx = 64;
nw = 128;

% Calculate dependent variables
wf = Smax / Gmax;          % rad/s

% Adjust Gmax down to give an integer number of cycles in PW
w0 = 2.0 * pi / PW;
N = ceil(wf / w0);
Gmax = Smax / (N * w0);    % T/m
wf = Smax/Gmax;

fprintf('Adjusted max gradient amp   : %0.2f G/cm\n', Gmax*1.0e2);

kxmax = GAMMA * Gmax / wf; % rad/m

% x-f space sample grid
FOVx = 10.0e-2;    % 10cm
FOVw = 2*wf;       % 2 x Oscillation freq

dx = FOVx/nx;     % m
dw = FOVw/nw;     % rad/s

FOVkx = 2*pi/dx;  % rad/m
FOVkw = 2*pi/dw;  % s

dkx = FOVkx / nx; % rad/m
dkw = FOVkw / nw; % s

% Summarize dependent parameters
fprintf('\nDEPENDENT PARAMETERS\n');
fprintf('Gradient frequency : %f Hz\n', wf/(2*pi));
fprintf('FOV x              : %f cm\n', FOVx*100);
fprintf('FOV w              : %f Hz\n', FOVw/(2*pi));
fprintf('FOV kx             : %f rad/m\n', FOVkx);
fprintf('FOV kw             : %f ms\n', FOVkw);
fprintf('dkx                : %f rad/m\n', dkx);
fprintf('dkw                : %f ms\n', dkw*1000);
fprintf('dx                 : %f mm\n', dx*1000);
fprintf('dw                 : %f Hz\n', dw/(2*pi));

% Time sample array
t = 0.0:dt:(PW-dt);

x = -FOVx/2:dx:(FOVx/2-dx);
w = -FOVw/2:dw:(FOVw/2-dw);

fprintf('\nGenerating ideal response\n');

% x-w space ideal response
mxybar = SSresponse(x, w, Deltax, Deltaf*2*pi);

% kxf coordinates
kx = -FOVkx/2:dkx:(FOVkx/2-dkx);
kw = -FOVkw/2:dkw:(FOVkw/2-dkw);

% FFT the grid -> excitation k-space (kx-kw = kx-t)
M = fftshift(ifft2(fftshift(mxybar)));
[nx,nw] = size(M);

fprintf('Generated ideal kxw excitation response\n');
fprintf('  kxw space is %d x %d samples in size\n', nx, nw);

% Calculate B1(k) from M(k) and W(k)
fprintf('Weighting ideal response\n');
W = SSRadialHamming(M);
B1 = M .* W;

% Lit surface for mxybar and B1
clf;
colormap(gray);

subplot(1,2,1), surfl(w/(2*pi),x,mxybar); shading interp;
xlabel('w (Hz)');
ylabel('x (m)');

subplot(1,2,2), surfl(kw,kx,real(B1)); shading interp;
xlabel('kw (s)');
ylabel('kx (rad/m)');

% Generate gradient waveform
Gt = SSgradient(t, Gmax, wf);

% Generate kw(t) and kx(t)
% Note that kwt is the remaining time to the end of the pulse
kwt = (PW/2-dt):-dt:-PW/2;
kxt = SSktraj(Gt, dt);

% Sample B1 along the trajectory
% This must be run as a loop since interp2 will expand kxt and kwt
% vectors into a 2D grid of coordinates

fprintf('\nSampling B1(k) along trajectory : %d points\n', length(kxt));

[kxall,kwall] = meshgrid(kx,kw);
B1t = zeros(1,length(kxt));

fprintf('Progress : ');
previous = -10;

% Separate B1 into real and imag parts due to bug in interp2
rB1 = real(B1);
iB1 = imag(B1);

for tick = 1:length(kxt)
   
   progress = floor(tick/length(kxt)*10);
   if (progress ~= previous)
      fprintf('%d%%-',progress*10);
      previous = progress;
   end
   
   this_kxt = kxt(tick);
   this_kwt = kwt(tick);
   B1t(tick) = interp2(kxall, kwall, rB1', this_kxt, this_kwt,'*cubic') + ...
   i * interp2(kxall, kwall, iB1', this_kxt, this_kwt,'*cubic');
    
end

% Density correct B1(t)
% Use |k(n) - k(n-1)| as the weighting function 
dkxt = diff(kxt);
dkwt = diff(kwt);
A = sqrt(dkxt.*dkxt + dkwt.*dkwt); % A is k velocity
A(length(A)+1) = A(length(A));     % Extend A by one element
A = A / max(A);
B1t = B1t .* A;

fprintf('done\n');

% Catch any NaNs generated by out-of-bounds interpolation
B1t(isnan(B1t)) = 0.0;

% Overlay imag(B1t) on surface plot
hold on;
plot3(kwt,kxt,real(B1t));
hold off;
