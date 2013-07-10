function [Tms, FOVfHz, Slicexmm] = ReadSSPars(dirname, name)
%
% SpSp            1
% NPnts        3600
% FlipDeg        90
% Tms          14.4
% Tsubms        1.2
% Nsub           12
% BWfHz         220
% FOVfHz        440
% Slicexmm        5
% FOVxmm    82.7679
% de1%            5
% de2%            1
% dtus            4
% SmaxTms        77
% GmaxGcm         2

% Read essential parameters
parfile = sprintf('%s/%s.par', dirname, name);
fd = fopen(parfile,'r');
dummy = fscanf(fd, '%s',1); SpSp     = fscanf(fd, '%d', 1);
dummy = fscanf(fd, '%s',1); Npnts    = fscanf(fd, '%d', 1);
dummy = fscanf(fd, '%s',1); FlipDeg  = fscanf(fd, '%f', 1);
dummy = fscanf(fd, '%s',1); Tms      = fscanf(fd, '%f', 1);
dummy = fscanf(fd, '%s',1); Tsubms   = fscanf(fd, '%f', 1);
dummy = fscanf(fd, '%s',1); Nsub     = fscanf(fd, '%d', 1);
dummy = fscanf(fd, '%s',1); BWfHz    = fscanf(fd, '%d', 1);
dummy = fscanf(fd, '%s',1); FOVfHz   = fscanf(fd, '%d', 1);
dummy = fscanf(fd, '%s',1); Slicexmm = fscanf(fd, '%d', 1);
dummy = fscanf(fd, '%s',1); FOVxmm   = fscanf(fd, '%f', 1);
dummy = fscanf(fd, '%s',1); de1perc  = fscanf(fd, '%f', 1);
dummy = fscanf(fd, '%s',1); de2perc  = fscanf(fd, '%f', 1);
dummy = fscanf(fd, '%s',1); dtus     = fscanf(fd, '%d', 1);
dummy = fscanf(fd, '%s',1); SmaxTms  = fscanf(fd, '%d', 1);
dummy = fscanf(fd, '%s',1); GmaxGcm  = fscanf(fd, '%d', 1);
fclose(fd);
