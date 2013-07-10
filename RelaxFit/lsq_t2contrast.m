function [F,J] = lsq_t2contrast(x, TE)
%
% T2 contrast function with DC offset
%
% x = [A T2 C]
%
% F = A * exp(-TE/T2) + C
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 09/06/2001 JMT From scratch

A  = x(1);
T2 = x(2);
C  = x(3);

Q = exp(-TE/T2);

F = A * Q + C;

% Jacobian J(i,j) = d(F(i))/d(X(j))

n = length(F);
J = zeros(n,3);

J(:,1) = Q;
J(:,2) = A * TE/(T2*T2) .* Q;
J(:,3) = 1;