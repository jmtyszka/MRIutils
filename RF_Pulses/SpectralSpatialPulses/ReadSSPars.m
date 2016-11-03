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
