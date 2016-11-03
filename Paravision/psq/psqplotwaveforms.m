function psqplotwaveforms(t,B1t,Gx,Gy,Gz,kx,ky,kz)
% psqplotwaveforms(t,B1t,Gx,Gy,Gz,kx,ky,kz)
%
% ARGS:
% t        = time vector
% B1t      = RF waveform vector
% Gx,Gy,Gz = Gradient waveform vectors
% kx,ky,kz = k-space trajectory vectors [optional]
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 04/27/2004 JMT Extract from psq.m
%          2015-04-05 JMT Update figure titling
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

if nargin < 5
  help psqplotwaveforms
  return
end

% Adjust number of plots displayed depending on input waveforms
nrows = nargin - 1;
if nrows < 1
  fprintf('No waveforms supplied for plotting\n');
  return
end

% Setup the results figure window
figure(10); clf;
set(gcf, 'Color', 'w');
set(gcf, 'NumberTitle', 'off');

% Convert from s to ms and T/m to G/cm
t_ms = t * 1e3;
Gx_gcm = Gx * 100;
Gy_gcm = Gy * 100;
Gz_gcm = Gz * 100;

% Find limits
Gall = [Gx_gcm(:) Gy_gcm(:) Gz_gcm(:)];
Gmin = min(Gall(:));
Gmax = max(Gall(:));
aGmax = max(abs([Gmin Gmax]));
Glims = [-aGmax aGmax + eps] * 1.1;
xlims = [min(t_ms) max(t_ms) + eps];

subplot(nrows,1,1), h = plot(t_ms, real(B1t), t_ms, imag(B1t));
set(h,'LineWidth',1);
set(gca,'XLim',xlims,'Box','off','XGrid','on','XTickLabel',[]);
ylabel('RF TX');
axis tight;

if nrows > 1
  subplot(nrows,1,2), h = plot(t_ms, Gx_gcm);
  set(h,'LineWidth',1);
  set(gca,'XLim',xlims,'YLim',Glims,'Box','off','XGrid','on','XTickLabel',[]);
  ylabel('Read (G/cm)');
end

if nrows > 2
  subplot(nrows,1,3), h = plot(t_ms, Gy_gcm);
  set(h,'LineWidth',1);
  set(gca,'XLim',xlims,'YLim',Glims,'Box','off','XGrid','on','XTickLabel',[]);
  ylabel('Phase (G/cm)');
end

if nrows > 3
  subplot(nrows,1,4), h = plot(t_ms, Gz_gcm);
  set(h,'LineWidth',1);
  set(gca,'XLim',xlims,'YLim',Glims,'Box','off','XGrid','on','XTickLabel',[]);
  ylabel('Slice (G/cm)');
end

%---------------------------------------
% Draw zero-order moments - gamma k(t)
%---------------------------------------

if nrows > 4
  
  kall = [kx(:) ky(:) kz(:)];
  kmin = min(kall(:));
  kmax = max(kall(:));
  akmax = max(abs([kmin kmax]));
  klims = [-akmax akmax+eps] * 1.1;

  subplot(nrows,1,5), h = plot(t_ms, kx);
  ylabel('k_x (cycles/m)');
  set(gca,'XLim',xlims,'YLim',klims,'Box','off','XGrid','on','YGrid','on','XTickLabel',[]);

  subplot(nrows,1,6), h = plot(t_ms, ky);
  ylabel('k_y (cycles/m)');
  set(gca,'XLim',xlims,'YLim',klims,'Box','off','XGrid','on','YGrid','on','XTickLabel',[]);

  subplot(nrows,1,7), h = plot(t_ms, kz);
  xlabel('Time (ms)');
  ylabel('k_z (cycles/m)');
  set(gca,'XLim',xlims,'YLim',klims,'Box','off','XGrid','on','YGrid','on');
end

drawnow;
