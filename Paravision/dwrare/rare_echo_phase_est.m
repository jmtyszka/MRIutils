function [dphi_echo_est,dphi_y_est,dphi_y] = rare_echo_phase_est(dphi,ky_order)
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
% Copyright 2007 California Institute of Technology.
% All rights reserved.

% Extract number of echoes and shots from ky_order
[nshots,etl] = size(ky_order);

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