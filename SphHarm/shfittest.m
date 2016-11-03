function shfittest
% shfittest
%
% Test fitting of spherical harmonics over a non-uniformly sampled
% arbitrary surface (Ylm + noise)
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 1/7/2001 Adapt from shtest.m
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
Lmax   = 5;            % Maximum L to fit
Ncoeff = (Lmax + 1)^2; % Total number of basis functions for this Lmax
Nsamps = 1000;         % Number of surface sample points

%--------------------------------------------------------------
% Generate a non-uniformly sampled unit sphere with a lump
%--------------------------------------------------------------
az_samp = rand(1,Nsamps) * 2 * pi;
de_samp = rand(1,Nsamps) * pi;
el_samp = pi/2 - de_samp;

% Unit sphere
R_samp = ones(size(az_samp));

% Add a lump
inds = find(az_samp > pi/4 & az_samp < pi/2 & de_samp > pi/4 & de_samp < pi/2);
R_samp(inds) = R_samp(inds) + 0.25;

% Convert surface points to cartesian coordinates
% Note conversion from math to physics spherical coordinates for
% Correct use of sph2cart()
[x_samp,y_samp,z_samp] = sph2cart(az_samp,el_samp,R_samp);

% Scale x-axis
x_samp = x_samp * 2;

% Fit complex Ylm basis to arbitrary surface
[r_fit,CofM,de_samp,az_samp,R_fit,R_err,Ylm] = shfit(x_samp,y_samp,z_samp,Lmax);

% Create uniformly sampled cartesian SH sum
[x_fit,y_fit,z_fit] = shcart(r_fit,CofM);

% Take real part of fitted coordinates
x_fit = real(x_fit);
y_fit = real(y_fit);
z_fit = real(z_fit);

% Draw sample points and fitted surface
colormap(gray);
subplot(121), plot3(x_samp, y_samp, z_samp, '.');
hold on;
surfl(x_fit, y_fit, z_fit);
lighting phong
camlight('headlight');
axis equal vis3d
xlabel('x'); ylabel('y'); zlabel('z');
hold off;

% Report fit residual stats
fprintf('Spherical Harmonic Fit Results\n');
fprintf('------------------------------\n');
fprintf('N samples      : %d\n', Nsamps);
fprintf('Lmax           : %d\n', Lmax);
fprintf('Mean(residual) : %0.3f\n', mean(R_err));
fprintf('SD(residual)   : %0.3f\n', std(R_err));
fprintf('CofM           : (%0.3f,%0.3f,%0.3f)\n', CofM(1), CofM(2), CofM(3));

subplot(122), plot(real(r_fit)); title('Re[r_{lm}]');
