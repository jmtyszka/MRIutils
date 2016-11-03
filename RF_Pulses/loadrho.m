function [t, B1] = loadrho(rhoname, flipangle, duration)
%
% [t, B1] = loadrho(rhoname, flipangle, duration)
%
% Load an RF waveform from a GEMS .rho file
%
% AUTHOR: Mike Tyszka, Ph.D.
% PLACE : City of Hope, Duarte CA
% DATES : 08/03/2000 From scratch
%         11/27/2000 Modify for .rho files
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

% Gyromagnetic ratio for 1H nucleus
GAMMA_1H = 4258; % Hz/G

% Open the .rho file
fd = fopen(rhoname, 'r', 'ieee-be');
if fd < 0
   return;
end

% Read in the waveform
w = double(fread(fd, Inf, 'int16'));

% Close the file
fclose(fd);

% Strip the footer (4 points) and header (32 points)
n = length(w);
w((-3:0) + n) = [];
w(1:32) = [];

% Calibrate B1 in Gauss for 1H
w_tot = mean(w) * duration;
B1 = w / w_tot / GAMMA_1H * flipangle / 360;

% Create a time vector
t = (0:(length(B1)-1)) * duration / n;
