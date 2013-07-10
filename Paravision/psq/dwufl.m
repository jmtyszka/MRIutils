function dwufl
% dwufl
%
% Bloch equation simulation of various artifacts in DW-UFLARE
% Simulate MG and non-MG components during UFLARE train with Hennig
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 03/28/2002 From scratch

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
