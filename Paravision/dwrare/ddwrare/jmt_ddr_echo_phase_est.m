function [dphi_echo_est,dphi_y_est,dphi_y] = jmt_ddr_echo_phase_est(dphi,nshots,etl,debug)
% [dphi_echo_est,dphi_y_est,dphi_y] = jmt_ddr_echo_phase_est(dphi,nshots,etl,debug)
%
% RETURNS:
% dphi_echo_est = estimated phase offset for each RARE echo (1 x etl)
% dphi_y_est = raw phase estimate onto ky axis (1 x ny)
% dphi_y = median unwrapped phase projection onto ky axis (1 x ny)
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech
% DATES  : 09/19/2007 JMT From scratch
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

% Phase unwrap
dphi_uw = unwrap3d(dphi,ones(size(dphi)),0.0);
    
% Collapse unwrapped phase to 2nd dimension using median
dphi_y = squeeze(median(median(dphi_uw,1),3));
dphi_y_wrap = squeeze(median(median(dphi,1),3));

% Adjust phase offset to lowest 2 pi interval
dphi_y = dphi_y - fix(median(dphi_y)/(2*pi))*2*pi;
dphi_y_wrap = dphi_y_wrap - fix(median(dphi_y_wrap)/(2*pi))*2*pi;

% Reshape dphi_y to nshots x etl then take column median across shots
% Result is a 1 x etl vector of phases
dphi_echo_est = median(reshape(dphi_y,[nshots etl]),1);

% Replicate estimated echo phase to fill ky dimension (for return arg only)
dphi_y_est = repmat(dphi_echo_est,[nshots 1]);

% Reshape into a row vector - reshape works through dimensions in
% order, ie rows (1st) then columns (2nd), then 3rd, etc
% Following this, phi_corr is a 1 x ny vector
dphi_y_est = dphi_y_est(:)';

if debug
  
  figure(20); clf;
  colormap(gray);
  
  [nx,ny,nz] = size(dphi);
  hz = fix(nz/2);

  dphi_xy = dphi(:,:,hz);
  dphi_uw_xy = dphi_uw(:,:,hz);
  
  subplot(221), imagesc(dphi_xy,[-pi pi]);
  axis image xy tight off;
  
  subplot(222), imagesc(dphi_uw_xy,[-pi pi]);
  axis image xy tight off;
  
  subplot(223), plot(1:ny,dphi_y_wrap);
  set(gca,'XLim',[1 ny],'YLim',[-pi pi]);

  subplot(224), plot(1:ny,dphi_y,1:ny,dphi_y_est);
  set(gca,'XLim',[1 ny],'YLim',[-pi pi]);
  
  fprintf('Saving figure\n');
  saveas(gcf,'phase_figure.fig');
  
end
