function dwufl
% dwufl
%
% Bloch equation simulation of various artifacts in DW-UFLARE
% Simulate MG and non-MG components during UFLARE train with Hennig
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 03/28/2002 From scratch
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

% Sample properties
N = 128;    % Isochromats
V = 0;      % cm/s
T1 = 0.8;   % s
T2 = 0.15;  % s
D = 2.2e-5; % cm^2/s

% Imaging parameters
FOV = 2;   % cm
Gd = 25;   % G/cm
Td = 5e-3; % s

% Setup isochromats
IC = InitIC([0 0 1],N,FOV,V,T1,T2,D);

% Excite with a given phase
IC = RF(IC,90,0);

% Precess in a diffusion gradient, Gd, for time, Td
IC = Precess(IC,Td,Gd);

% Refocus with a 180y
IC = RF(IC,180,90);

% Precess in a diffusion gradient
IC = Precess(IC,Td,Gd);
