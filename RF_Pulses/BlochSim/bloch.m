function [Mx,My,Mz] = bloch(t,B1,Gx,Gy,Gz,xm,ym,zm,Mx0,My0,Mz0)
% [Mx,My,Mz] = bloch(t,B1,Gx,Gy,Gz,xm,ym,zm,Mx0,My0,Mz0)
%
% Bloch simulation of 3D isochromat array during RF and gradient waveforms
%
% ARGS :
% t  = time vector (s)
% B1 = RF waveform vector (T)
% Gx = x gradient wavefor (T/m)
% Gy = y gradient wavefor (T/m)
% Gz = z gradient wavefor (T/m)
% xm = isochromat x coordinate mesh (m)
% ym = isochromat y coordinate mesh (m)
% zm = isochromat z coordinate mesh (m)
% Mx0 = initial isochromat Mxs
% My0 = initial isochromat Mys
% Mz0 = initial isochromat Mzs
%
% AUTHOR: Mike Tyszka, Ph.D.
% PLACE : Caltech BIC and City of Hope
% DATES : 02/20/2002 From scratch for use with psq.m
%         04/10/2002 Rewrite as a MEX executable

% Call MEX routine
[Mx,My,Mz] = bloch_mex(t,B1,Gx,Gy,Gz,xm,ym,zm,Mx0,My0,Mz0);
