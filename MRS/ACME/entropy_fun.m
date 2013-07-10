function f = entropy_fun(x,s)
% function f = entropy_fun(x,s)
% written by Chen Li 
% input:   x - PHC0 and PHC1
%         s - NMR Spectral data
% output   f - entropy value (Using the first derivative)
%
% Modifications: Mike Tyszka, Ph.D, Caltech BIC

% Derivative order for entropy calculation
dn = 1;

% Dephase
[N,L] = size(s);
phc0 = x(1);
phc1 = x(2);

s0 = dephase_fun(s,phc0,phc1);
s = real(s0);
maxs = max(s);

% Absolute Nth order derivative
ds_n = abs(diff(s,dn));

% Normalized derivative
p_n = ds_n ./ sum(ds_n);

% Eliminate zeros (ln(1) = 0)
p_n(p_n == 0) = 1;

% Entropy measure
H_n  = sum(-p_n .* log(p_n));

% Calculation of penalty
Pfun	= 0.0;
as      = s - abs(s);
sumas   = sum(sum(as));
if (sumas < 0)
  Pfun = Pfun + sum(sum((as./2).^2));
end

% Penalty function to ensure positive bands
P = 1000 * Pfun;

% The value of objective function
f = H_n + P;

