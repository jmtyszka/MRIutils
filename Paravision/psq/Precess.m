function IC = Precess(IC,t,G)
% IC = Precess(IC,t,G)
%
% Precess the isochromats for time, t, in a gradient G
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 03/29/2002 From scratch

% Precessional phase angle varies with position
phi = IC.gam * G * IC.x;

% Trig functions
cp = cos(phi);
sp = sin(phi);

% Rotation matrix
Rz = [cp -sp 0; sp cp 0; 0 0 1];

% Apply rotation to all isochromats - M is a 3 x N matrix
IC.M = Rz * IC.M;