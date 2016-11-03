function [Ylm,dec,azc] = sh(L,de,az,sepcalc)
% [Ylm,dec,azc] = sh(L,de,az,sepcalc)
%
% Complex orthonormal spherical harmonic (SH) function, Ylm(de,az)
% Returns matrix of values for -L <= M <= L where M is the azimuthal
% quantum number.
%
% If spepcalc is 'sep' then the spherical harmonic is calculated as
% the outer product of the angular and azimuthal functions.
% Otherwise the spherical harmonic is calculated (slowly) for each coordinate.
%
% ARGS :
% L  = degree of harmonic (angular quantum number)
% de = declination angles (radians) (N x 1)
% az = aximuthal angles (radians) (N x 1)
% sepcalc = 'sep' or 'full' - flag for separable function calculation
%           'sep' generates the SH on a rectilinear sampling grid defined
%           by de and az vectors
%
% RETURNS :
% Ylm     = matrix of complex Ylm values for -L <= m <= +L
% dec,azc = angular coordinate meshs ('sep' calculation only)
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 12/17/2001 Implement from literature
%          12/21/2001 Correct spherical coordinate system
%                     Restrict to real componets
%          01/07/2002 Explicit naming of angular variables
%          01/08/2002 Correct polar orientation of function
%          01/16/2002 Switch to 1D flattened de and az
%          01/23/2002 Add separable funcion flag
% REFS   : Goldberg-Zimring, D et al. MRM 2001;46:756-766.
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

% Initialize return arguments
Ylm = [];
dec = [];
azc = [];

% Check calling syntax
if nargin < 3
  fprintf('USAGE: Ylm = sh(L,de,az)\n');
  return
end

% Flatten angles to a column vector
de = de(:);
az = az(:);
nde = length(de);
naz = length(az);
  
% Calculate full or seperable functions
switch sepcalc

case 'sep'
  
  %----------------------------------------------------------
  % Separable calculation of angular and azimuthal functions
  %----------------------------------------------------------
  
  % Make space for the harmonic functions
  Ylm = zeros([2*L+1 nde naz]);
  Plm = zeros([L+1 nde]);
  philm = zeros([L+1 naz]);
  
  % Generate the associated Legendre polynomial (angular function) for M = 0..L
  % Plm is (Lmax+1) x nde
  Plm = legendre(L,cos(de));
  
  % Reshape as a row vector if L = 0
  if L == 0
    Plm = reshape(Plm,[1 nde]);
  end

  % Calculate the azimuthal functions for M = 0..L
  for M = 0:L
    
    % Calculate the scaling constant for this SH order and number
    A = sqrt((2*L+1) / (4*pi) * factorial(L-M) / factorial(L+M));
    
    % Calculate the azimuthal function philm
    philm(M+1,:) = A * exp(i * M * az');

  end
  
  % Generate the full spherical harmonics using outer products
  % of the angular and azimuthal functions
  % (nde x 1) * (1 x naz) = (nde x naz)
  
  for M = 0:L
    
    % Extract angular and azimuthal functions
    ang_lm = Plm(M+1,:)';  % Column vector
    azi_lm = philm(M+1,:); % Row vector
    
    % Insert outer product into spherical harmonic matrix
    Ylm(M+L+1,:,:) = ang_lm * azi_lm;
    
  end
  
  % Construct rows for -L <= M <= -1 from rows for M > 0
  for M = 1:L
    Ylm(L+1-M,:,:) = (-1)^(M) * conj(Ylm(L+M+1,:,:));
  end
  
  % Construct angular coordinate mesh
  [dec,azc] = ndgrid(de,az);
  
otherwise
  
  %---------------------------------------------------------
  % Full calculation of angular and azimuthal harmonics
  %---------------------------------------------------------

  % Check angular argument sizes
  if nde ~= naz
    fprintf('de and az must be the same length\n');
    return
  end
  
  N = nde;
  
  % Generate the associated Legendre polynomial
  Plm = legendre(L,cos(de));
  
  if L == 0
    Plm = reshape(Plm,[1 N]);
  end
  
  % Initialize the returned Ylm matrix
  Ylm = zeros([2*L+1 N]);
  
  for M = 0:L
    
    % Calculate the scaling constant for this SH order and number
    A = sqrt((2*L+1) / (4*pi) * factorial(L-M) / factorial(L+M));
    
    % Calculate the full complex SH
    % M = 0:L occupy rows (L+1):(2L+1)
    theta = squeeze(Plm(M+1,:))';
    phi   = exp(i * M * az);
    Ylm(L+M+1,:,:) = A .* theta .* phi;
    
  end
  
  % Construct rows for -L <= M <= -1 from rows for M > 0
  for M = 1:L
    Ylm(L+1-M,:) = (-1)^(M) * conj(Ylm(L+M+1,:));
  end
  
  % Recompose coordinate mesh - same as original
  dec = de;
  azc = az;
  
end

