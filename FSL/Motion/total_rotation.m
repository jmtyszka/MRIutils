function theta_total = total_rotation(theta_x, theta_y, theta_z)
% Total rotation for a three-axis gimble rotation
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech
% DATES  : 02/10/2012 From scratch

theta_x = theta_x(:);
theta_y = theta_y(:);
theta_z = theta_z(:);

n = length(theta_x);

theta_total = zeros(n,1);

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
  
end