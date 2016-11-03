function [g,b1,x,f,mx,my,mz] = SSPlot(name)
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

clf;

nx = 64;
nf = 80;

path = 'D:/Projects/SS Pulses';
dirname = sprintf('%s/%s', path, name);

fprintf('Loading pulse from directory %s\n', dirname);

% Read pulse parameters
[Tms, FOVfHz, Slicexmm] = ReadSSPars(dirname, name);

% Read Mxy array

% Setup data filenames
b1file = sprintf('%s/%s.b1', dirname, name);
gfile = sprintf('%s/%s.g', dirname, name);

% Read in rms mxy interals in f and x
[f, x, rmsf, rmsx] = ReadSSrms(dirname, name, nf, nx);

subplot(2,1,1), plot(x, rmsx, 'k');
set(gca, 'YScale', 'log');
title('RMS magnetization integrated spectrally');
xlabel('Distance (mm)');
ylabel('rms(Mxy)');

subplot(2,1,2), plot(f, rmsf, 'k');
set(gca, 'YScale', 'log');
title('RMS magnetization integrated spatially');
xlabel('Frequency (Hz)');
ylabel('rms(Mxy)');

pause;

clf;

% Read in magnetization components
[mx,my,mz] = ReadSSmxy(dirname, name, nf, nx);

magmxy = abs(mx + i * my);

colormap(gray);
surfl(x,f,magmxy); shading interp;
ylabel('Frequency (Hz)');
xlabel('Distance (mm)');
zlabel('|Mxy|');

pause;

% Read in gradient and RF waveforms
fd = fopen(gfile,'r');
g = fscanf(fd, '%f', Inf);
fclose(fd);

fd = fopen(b1file,'r');
b1 = fscanf(fd, '%f', [2,Inf]);
fclose(fd);

b1 = b1(1,:);

Tms

nt = length(g);
dt = Tms /(nt-1);
t = 0:dt:Tms;

subplot(2,1,1), plot(t, g*100,'k');
xlabel('Time (ms)');
ylabel('Gradient (mT/m)');
set(gca,'XLim',[min(t), max(t)], 'YLim', [min(g*100)*1.1 max(g*100)*1.1]);

subplot(2,1,2), plot(t, b1*1e6,'k');
xlabel('Time (ms)');
ylabel('B1 (uT)');
set(gca,'XLim',[min(t), max(t)]);
