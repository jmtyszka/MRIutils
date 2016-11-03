function [cn, c0] = Humlicek(x,y)
%HUMLICEK [cn,c0] = humlicek(x,y)
%
% [cn,c0] = humlicek(x,y)
%
% Optimized Humlicek approximation due to Schreier for the 
% Voigt/Fadeeva function w(z) = exp(-z^2) * erfc(-iz)
% where z = x + i y
%
% x = sqrt(ln(2)) / gD * (f-f0) = vector
% y = sqrt(ln(2)) / gD * gL     = scalar
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 04/28/2000 Start from web page Fortran code
%          05/09/2000 Vectorize for Matlab 
%          01/17/2006 JMT M-Lint corrections
%
% REFS   : Humlicek J, JQSRT 1982; 27:437
%          Schreier F JQSRT 1992; 48:743-762
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


% Add 0 to the x vector
x = [0 x];

T = y - i * x;

if (y >= 15)
   
   U = T .* T;
 
   % Region 1
   c = cerf1(T, U);
   
elseif (y < 15 && y >= 5.5)
   
   % Calculate intermediate values as needed
   AX = abs(x);
   S = AX + y;
   U = T .* T;
   
   % Define regions 1 and 2 based on the value of S
   R1 = find(S >= 15);
   R2 = find(S < 15);
   
   c(R1) = cerf1(T(R1), U(R1));
   c(R2) = cerf2(T(R2), U(R2));

elseif (y < 5.5 && y >= 0.75)
   
   % Calculate intermediate values as needed
   AX = abs(x);
   S = AX + y;
   U = T .* T;
   
   % Define regions 1, 2 and 3 based on the value of S
   R1 = find(S >= 15);
   R2 = find(S >= 5.5 & S < 15);
   R3 = find(S < 5.5);
   
   c(R1) = cerf1(T(R1), U(R1));
   c(R2) = cerf2(T(R2), U(R2));
   c(R3) = cerf3(T(R3));

else
   
   % Calculate intermediate values as needed
   AX = abs(x);
   S = AX + y;
   U = T .* T;
   
   yc = 0.195 * AX - 0.176;
   
   R1 = find(S >= 15);
   R2 = find(S >= 5.5 & S < 15);
   R3 = find(S < 5.5 & y >= yc);
   R4 = find(S < 5.5 & y < yc);
   
   c(R1) = cerf1(T(R1), U(R1));
   c(R2) = cerf2(T(R2), U(R2));
   c(R3) = cerf3(T(R3));
   c(R4) = exp(U(R4)) - cerf4(T(R4),U(R4));
   
end

% Handle case where y = 0
if (y == 0)
   c = exp(-x.^2) + i * imag(c);
end

c0 = c(1);
cn = c(2:length(c));
