function IC = InitIC(M0,N,FOVx,Vx,T1,T2,D)
% IC = InitIC(M0,N,FOVx,Vx,T1,T2,D)
%
% Initialize an isochromat structure
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 03/29/2002 From scratch

% 1H gyromagnetic ratio
IC.gam = 4200; % Hz/G

% Initialize magnetization vector for each isochromat
IC.M = repmat(M0(:),N);

% Setup a linear coverage of the field of view
IC.x = linspace(-BW/2,FOV/2,N);

% Fill structure with global parameters
IC.Vx = Vx;
IC.T1 = T1;
IC.T2 = T2;
