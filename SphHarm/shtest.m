function shtest
% shtest
%
% Plot spherical harmonic functions in polar coordinates
% for orders n = 0 to 5 and numbers m = 0 to n
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 12/20/2001 From scratch
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

% Select figure 1 and clear
figure(1); clf; colormap gray;

% Maximum L to plot
Lmax = 4;

% Size of subplot array
nrows = Lmax+1;
ncols = 2 * Lmax + 1;

% Note use of general math convention
de_v = 0:(pi/30):pi;     % Declination from z axis
az_v = 0:(pi/30):(2*pi); % Azimuthal angle within xy plane

% Loop over SH orders
for L = 0:Lmax
    
  % Calculate Ylm(theta,phi) on an angular mesh
  [Ylm,de_m,az_m] = sh(L,de_v,az_v,'sep');
  
  % Calculate elevation for Matlab functions
  el_m = pi/2 - de_m;
  
  for M = -L:L

    % Extract Ylm for current value of M
    Y = squeeze(Ylm(M+L+1,:,:));
    
    % Take |Y|^2 for surface plots
    aY2 = Y .* conj(Y);
    
    % Convert spherical harmonic to cartesian coordinates
    % Note that Matlab uses azimuth and elevation
    [x,y,z] = sph2cart(az_m,el_m,aY2);
    
    % Locate the plot in the array
    sp = L * ncols + L + M + 1 + (Lmax - L);
    
    % Plot the SH in 3D
    subplot(nrows,ncols,sp), h = surf(x,y,z);

    % Adjust plot
    set(h,'EdgeColor','k');
    axis tight equal off;
    shading interp
    lighting phong
    title(sprintf('|Y(%d,%d)|^2]',L,M));
    
  end
  
end
