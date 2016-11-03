function [dphi_echo_est, dphi_y_est, dphi_y] = rare_echo_phase_est(dphi, ky_order)
% [dphi_echo_est,dphi_y_est,dphi_y] = rare_echo_phase_est(dphi,ky_order)
%
% ARGS:
% dphi = phase difference between DWI and S(0) k-spaces
% ky_order = nshot x etl matrix of original ky line index ordering
%
% RETURNS:
% dphi_echo_est = estimated phase offset for each RARE echo (1 x etl)
% dphi_y_est = raw phase estimate onto ky axis (1 x ny)
% dphi_y = median phase projection onto ky axis (1 x ny)
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

% Extract number of echoes and shots from ky_order
[~, etl] = size(ky_order);

% Check data dimensions - should be 2 or 3
nd = ndims(dphi);

switch nd
  
  case 2
    
    % 2D phase unwrap dphi
    dphi_uw = unwrap2d(dphi,ones(size(dphi)),0.0);
    
    % Collapse unwrapped phase to 2nd dimension using median
    dphi_y = squeeze(median(median(dphi_uw,1),3));

  case 3

    % 3D phase unwrap dphi
    dphi_uw = unwrap3d(dphi,ones(size(dphi)),0.0);
    
    % Collapse unwrapped phase to 2nd dimension using median
    dphi_y = squeeze(median(median(dphi_uw,1),3));
    
  otherwise
    
    fprintf('Unsupported data dimensions (%d) for phase unwrapping\n', ndims);
    return
    
end

% Adjust phase offset to lowest 2 pi interval
dphi_y = dphi_y - fix(median(dphi_y)/(2*pi))*2*pi;

% Allocate phase correction vectors
dphi_echo_est = zeros(1,etl);
dphi_y_est = zeros(size(dphi_y));

% Loop over all echoes
% NB: each column of ky_order contains the ky line indices filled by
% a given echo in the CPMG train

for ec = 1:etl
  
  % Median phase error for this echo
  dphi_echo_est(ec) = median(median(dphi_y(ky_order(:,ec))));
  
  % Phase correction is the median of the phase difference for this echo
  dphi_y_est(ky_order(:,ec)) = dphi_echo_est(ec); 
  
end
