function [F,J] = lsq_srcontrast(x, TR)
%
% lsqcurvefit function for SR contrast
%
% x = [A T1]
%
% F = A * (1 - exp(-TR/T1)) + C
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 11/09/2000 JMT From scratch
%          09/11/2003 JMT Update with DC component

A  = x(1);
T1 = x(2);
C  = x(3);

Q = exp(-TR/T1);
R = 1-Q;

F = A * R + C;

% Jacobian J(i,j) = d(F(i))/d(X(j))

n = length(F);
J = zeros(n,2);

J(:,1) = R;
J(:,2) = -A * TR/(T1*T1) .* Q;
J(:,3) = 1;
