function [Rsum,dec,azc] = shsum(r,de,az,sepcalc)
% [Rsum,dec,azc] = shsum(r,de,az,sepcalc)
%
% Return the sum of the spherical harmonics with complex coefficients r[]
%
% ARGS :
% r  = Ylm coefficients [Y(0,0) Y(1,-1) Y(1,0) Y(1,1) Y(2,-2) ...]
% de = declination angles matrix (radians)
% az = azimuthal angles matrix (radians)
% sepcalc = 'sep' or 'full' see help sh.m
%
% RETURNS :
% R       = radius sum
% dec,azc = angular coordinate meshs ('sep' calculation only)
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 12/17/2001 Implement from literature
%          12/21/2001 Correct spherical coordinate system
%                     Restrict to real values of Ylm
%          01/07/2002 Explicit anglular variable names
%          01/08/2002 Convert to complex coefficients
%          01/23/2002 Add support for mesh SH calculation
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

% Flatten and count coefficients
r = r(:);
Ncoeff = length(r);

% Determine Lmax from Ncoeff = Sum{0,Lmax}(2 * L + 1) = (1 + Lmax)^2
Lmax = fix(sqrt(Ncoeff) - 1);

switch sepcalc
  
case 'sep'
    
  %----------------------------------------------------------
  % Separable calculation of angular and azimuthal functions
  %----------------------------------------------------------

  % Flatten angular arguments and count samples
  de = de(:);
  az = az(:);
  
  % Count angular samples in each dimension
  Nde = length(de);
  Naz = length(az);

  % Initialize radius sum
  Rsum = zeros(Nde,Naz);
  
  % Construct radius sum
  for L = 0:Lmax
    
    % Generate complex Ylm for this value of L and -L <= M <= L
    [Ylm,dec,azc] = sh(L,de,az,sepcalc);
    
    % Extract the coefficients for this value of L
    roffset = L^2;
    nr = 2*L + 1;
    rL = r(roffset + (1:nr));
    
    % Add all harmonics for this value of L
    for rc = 1:nr
      Rsum = Rsum + rL(rc) * squeeze(Ylm(rc,:,:));
    end
    
  end
  
otherwise
  
  %---------------------------------------------------------
  % Full calculation of angular and azimuthal harmonics
  %---------------------------------------------------------
  
  % Record size of angular matrix - we can't assume it's 2D
  sizede = size(de);
  
  % Flatten angular matrices for calculation
  de = de(:);
  az = az(:);
  
  % Initialize radius sum
  Rsum = zeros(size(de));
  
  % Construct radius sum
  for L = 0:Lmax
    
    % Generate complex Ylm for this value of L and -L <= M <= L
    [Ylm,dec,azc] = sh(L,de,az,sepcalc);
    
    % Extract the coefficients for this value of L
    roffset = L^2;
    nr = 2*L + 1;
    rL = r(roffset + (1:nr));
    
    % Add all harmonics for this value of L
    for rc = 1:nr
      Rsum = Rsum + rL(rc) * reshape(Ylm(rc,:), size(de));
    end
    
  end
  
  % Reshape return arguments back to original mesh size
  Rsum = reshape(Rsum, sizede);
  dec = reshape(dec, sizede);
  azc = reshape(azc, sizede);
  
end
