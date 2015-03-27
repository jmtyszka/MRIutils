function theta_total, axis_total = total_rotation(theta_x, theta_y, theta_z)
% Total rotation and axis for a three-axis gimble rotation
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech
% DATES  : 2012-10-02 JMT From scratch
%          2014-12-18 JMT Add total rotation axis calculation
%
% Copyright 2014 California Institute of Technology
% All rights reserved.

theta_x = theta_x(:);
theta_y = theta_y(:);
theta_z = theta_z(:);

n = length(theta_x);

% Init return arrays
theta_total = zeros(n,1);
axis_total = zeros(n,3);

for ac = 1:length(theta_x)
  
  % Construct total rotation matrix
  ctx = cos(theta_x(ac));
  stx = sin(theta_x(ac));
  Rx = [1 0 0; 0 ctx -stx; 0 stx ctx];
  
  cty = cos(theta_y(ac));
  sty = sin(theta_y(ac));
  Ry = [cty 0 -sty; 0 1 0; sty 0 cty];
  
  ctz = cos(theta_z(ac));
  stz = sin(theta_z(ac));
  Rz = [ctz -stz 0; stz ctz 0; 0 0 1];
  
  % Total rotation matrix
  Rtot = Rz * Ry * Rx;
  
  % Total rotation angle (radians)
  theta_total(ac) = acos((trace(Rtot)-1)/2);
  
  % Total rotation axis
  ax = 
  
end