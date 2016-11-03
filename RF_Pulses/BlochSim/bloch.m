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

% Call MEX routine
[Mx,My,Mz] = bloch_mex(t,B1,Gx,Gy,Gz,xm,ym,zm,Mx0,My0,Mz0);
