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