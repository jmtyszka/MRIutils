function IC = RF(IC,alpha,phi)
% IC = RF(IC,alpha,phi)
%
% Apply an RF pulse with a given flip, alpha, and phase, phi
%
% ARGS :
% IC    = isochromate structure
% alpha = flip angle in degrees
% phi   = RF phase angle in degrees
%
% RETURNS :
% IC    = updated isochromat structure
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 03/29/2002 From scratch

% Precessional phase angle varies with position
alpha = alpha * pi / 180;
phi = phi * pi/180;

% Trig functions
ca = cos(alpha);
sa = sin(alpha);
cp = cos(phi);
sp = sin(phi);

% Rotation matrices
Rz = [cp -sp 0; sp cp 0; 0 0 1];
Rx = [1 0 0; 0 cp -sp; 0 sp cp];

% Apply rotation to all isochromats - M is a 3 x N matrix
IC.M = Rx * Rz * IC.M;