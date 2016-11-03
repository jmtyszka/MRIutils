function [mxy, mz, mxyc] = blochrfsim(t, B1, f, alpha)
% [mxy, mz, mxyc] = blochrfsim(t, B1, f, alpha)
%
% Bloch simulation function using spinor/quaternion
% representation of B1 and gradient/chemshift rotations.
% Simulation area is twice the design FOV in k-space to
% show aliasing effects.
%
% ARGS:
% t  = time vector in seconds (1 x nt)
% B1 = RF field waveform vector (arbitrary scaling) (1 x nt)
% f  = isochromat frequency vector in Hz (1 x nf) [-5k..5k]
% alpha = desired calibrated flip angle (degrees) [90]
%
% REFS  : Formalism in Pauly et al. IEEE TMI 1991;10:53
%
% AUTHOR: Mike Tyszka, Ph.D.
% PLACE : Caltech, Pasadena CA
% DATES : 01/17/2002 JMT Port to Caltech Matlab environment
%         11/20/2006 JMT Tidy up for release
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

%% Initialize simulation

% Default arguments
if nargin < 3; f = linspace(-5000,5000,256); end
if nargin < 4; alpha = 90; end

% Convert frequency vector to rad/s
w = f * 2 * pi;

% Assume constant ticks
dt = t(2)-t(1);

% NMR constants
gamma_1H = 42.58e6 * 2 * pi; % rad/s/T
gamma_dt = gamma_1H * dt;

% Determine lengths of time and isochromat frequency vectors
nt = length(t);
nw = length(w);

% Make space for the magentization results
mxy  = zeros(size(w));
mz   = zeros(size(w));
mxyc = zeros(size(w));

% Calibrate pulse amplitude scaling in T
alpha_raw = gamma_dt * sum(B1);
B1 = B1 * alpha * pi/180 / alpha_raw;

%% Main simulation loops

for wc = 1:nw

  % Extract isochromat frequency (rad/s)
  ww = w(wc);

  % Initialize state-space
  ab = [1; 0];

  for tc = 1:nt

    % Extract current B1 value for this time point
    B1j = B1(tc);

    % Effective rotating frame B field in G
    Beff = [real(B1j) imag(B1j) ww/gamma_1H];

    % Rotation angle in radians for this time step due to Beff
    phij = -gamma_dt * norm(Beff); % rad

    % Trap zero rotation
    if phij == 0.0

      % Initialize C-K parameters
      aj = 1.0;
      bj = 0.0;

    else

      % Rotation axis for this time step
      nj = gamma_dt / abs(phij) * Beff;

      % Trig functions of half rotation angle
      sinphij2 = sin(phij/2.0);
      cosphij2 = cos(phij/2.0);

      % Cayley-Klein parameters for this timestep
      aj = cosphij2 - 1i * nj(3) * sinphij2;
      bj = (nj(2) - 1i * nj(1)) * sinphij2;

    end

    % Construct unitary complex rotation matrix
    Qj = [aj -conj(bj); bj conj(aj)];

    % Apply the quaternion to the state-space
    ab = Qj * ab;

  end

  % Extract quaternion complex magnetization vector
  alpha = ab(1);
  beta = ab(2);

  % Tranverse magnetization : M+_xy = 2 alpha* beta
  mxy(wc) = 2 * conj(alpha) * beta;

  % Longitudinal magnetization : Mz = alpha alpha* - beta beta*
  mz(wc) = alpha * conj(alpha) - beta * conj(beta);

  % Crushed spin-echo signal : M+_xyc = i beta^2
  mxyc(wc) = 1i * beta * beta;

end

%% Plot magnetization figures

figure(1); clf

subplot(131), plot(t * 1e3,B1 * 1e6);
title('B_1(t)');
xlabel('Time (ms)');
ylabel('B_1 (uT)');
axis tight;
grid on

subplot(232), plot(f,real(mxy),f,imag(mxy));
title('M_{xy} Response');
xlabel('Frequency (Hz)');
ylabel('Normalized M_{xy}');
legend('M_x','M_y');
set(gca,'YLim',[-1.1 1.1]);
grid on

subplot(233), plot(f,abs(mxy));
title('|M_{xy}| Response');
xlabel('Frequency (Hz)');
ylabel('Normalized M_{xy}');
set(gca,'YLim',[-1.1 1.1]);
grid on

subplot(235), plot(f,real(mxyc),f,imag(mxyc));
title('Crushed Spin Echo M_{xy} Response');
xlabel('Frequency (Hz)');
ylabel('Normalized M_{xy}');
legend('M_x','M_y');
set(gca,'YLim',[-1.1 1.1]);
grid on

subplot(236), plot(f,mz);
title('Longitudinal M_{z} Response');
xlabel('Frequency (Hz)');
ylabel('Normalized M_{z}');
set(gca,'YLim',[-1.1 1.1]);
grid on

