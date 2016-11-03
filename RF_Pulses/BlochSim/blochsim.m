function [mxy, mz, mxyc] = blochsim(t, B1, f)
% [mxy, mz, mxyc] = blochsim(t, B1, f)
%
% Bloch simulation function using spinor/quaternion
% representation of B1 and gradient/chemshift rotations.
% Simulation area is twice the design FOV in k-space to
% show aliasing effects.
%
% ARGS:
% t  = time vector in seconds (1 x nt)
% B1 = RF field vector in G   (1 x nt)
% f  = isochromat frequency vector in Hz (1 x nf)
%
% REFS  : Formalism in Pauly et al. IEEE TMI 1991;10:53
%
% AUTHOR: Mike Tyszka, Ph.D.
% PLACE : Caltech BIC and City of Hope, Duarte CA
% DATES : 08/03/2000 Port from mrisgi C source
%         01/17/2002 Port to Caltech Matlab environment
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

% Convert frequency vector to rad/s
w = f * 2 * pi;

% Assume constant ticks
dt = t(2)-t(1);

% NMR constants
gamma_1H = 4258 * 2 * pi; % rad/s/G
gamma_dt = gamma_1H * dt;

nt = length(t);
nw = length(w);

% Make space for the magentization results 
mxy  = zeros(size(w));
mz   = zeros(size(w));
mxyc = zeros(size(w));

for wc = 1:nw
   
   ww = w(wc);
   
   % fprintf('w(%d) : %g\n', wc, ww);
   
   % Initialize the state-space representation of the spin-domain rotations
   % ab = [alpha_j; beta_j]
   
   ab = [1; 0];
   
   for tc = 1:nt
      
      B1j = B1(tc);
      
      % Effective rotating frame B field in G
      Beff = [real(B1j) imag(B1j) ww/gamma_1H];
      
      % Rotation angle in radians for this time step due to Beff
      phij = -gamma_dt * norm(Beff); % rad
      
      % Trap zero rotation
      if phij == 0.0
         
         aj = 1.0;
         bj = 0.0;
         
      else
         
         % Rotation axis for this time step
         nj = gamma_dt / abs(phij) * Beff;
         
         % Trig functions of half rotation angle
         sinphij2 = sin(phij/2.0);
         cosphij2 = cos(phij/2.0);
         
         % Cayley-Klein parameters for this timestep
         aj = cosphij2 - i * nj(3) * sinphij2;
         bj = (nj(2) - i * nj(1)) * sinphij2;
         
      end
      
      Qj = [aj -conj(bj); bj conj(aj)];
      
      % Apply the quaternion to the state-space
      ab = Qj * ab;
      
   end
   
   % Extract magnetization vector
   alpha = ab(1);
   beta = ab(2);
   
   % Tranverse magnetization : M+_xy = 2 alpha* beta
   mxy(wc) = 2 * conj(alpha) * beta;
   
   % Longitudinal magnetization : Mz = alpha alpha* - beta beta*
   mz(wc) = alpha * conj(alpha) - beta * conj(beta); 
   
   % Crushed spin-echo signal : M+_xyc = i beta^2
   mxyc(wc) = i * beta * beta;
   
end
