function [r_fit,CofM,de,az,R_fit,R_err,Ylm] = shfit(x,y,z,Lmax)
% [r_fit,CofM,de,az,R_fit,R_err,Ylm] = shfit(x,y,z,Lmax)
%
% Linear least-squares decomposition of surface to spherical harmonics
%
% ARGS:
% x,y,z = vectors of points on surface (N x 1)
% Lmax  = maximum order of SH to fit
%
% RETURNS:
% r_fit = spherical harmonic coefficients
% CofM  = center of mass vector in same units as x,y,z
% de    = declination angles for each sample point (radians) (N x 1)
% az    = azimuth angles for each sample point (radians) (N x 1)
% R_fit = fitted surface radius Rfit(de,az) (N x 1)
% R_err = radial fit residual Rerr(de,az) (N x 1)
% Ylm   = spherical harmonic bases for use with r_fit[]
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 12/21/2001 From scratch
%          01/07/2002 Complete linear solver code
%          01/16/2002 Adjust return arguments for use with egg.m
%                     Change to 1D position vectors x,y,z
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

% Flatten x,y and z
x = x(:);
y = y(:);
z = z(:);

% Find center of mass
a = mean(x);
b = mean(y);
c = mean(z);
CofM = [a b c];

% Move surface to center of mass frame
x = x - a;
y = y - b;
z = z - c;

% Convert sample points to spherical coordinates
[az,el,R_samp] = cart2sph(x,y,z);

% Generate declination angle used by spherical harmonic functions
de = pi/2 - el;

nsamp = length(de);

% R   = r x Ylm = surface radius estimate vector (1 x N)
% r   = vector of SH coefficients (1 x ncoeff)
% Ylm = matrix of SH values over the spherical coordinate mesh (ncoeff x N)

% (Lmax + 1)^2 coefficients (2*L+1 per L value)
ncoeff = (Lmax + 1)^2;

% Initialize the basis function matrix
Ylm = zeros(ncoeff,nsamp);

% Construct the complex basis function matrix
count = 1;
for L = 0:Lmax
  
  % Generate complex spherical harmonic basis functions for -L <= M <= L
  Y = sh(L,de,az,'full');
  
  % Loop over all values of M
  for M = -L:L
    
    % Insert complex spherical harmonic Y into basis matrix Ylm
    Ylm(count,:) = Y(M+L+1,:);
    
    % Increment basis function counter
    count = count + 1;
    
  end
  
end

% Use linear solver for r
%
% X = A\B is the solution to A*X = B in the least squares sense
% B is a M x 1 column vector and A is an M x N matrix (M ~= N).
%
% In this case :
%   X = column vector of Ylm coefficients (ncoeff x 1) = r_fit
%   A = matrix of Ylm values at the angular location of each sample (nsamp x ncoeff)
%   B = column vector of sample radii (nsamp x 1)

A = Ylm';
B = R_samp(:);

% Fire up linear solver
r_fit = A\B;

% Construct best fit surface on sampling grid
R_fit = shsum(r_fit,de,az,'full');

% Calculate radial residual
R_err = R_samp - R_fit;
