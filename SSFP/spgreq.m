function s = spgreq(TR,TE,alpha,T1,T2s,M0)
% s = spgreq(TR,TE,alpha,T1,T2s,M0)
%
% Signal magnitude at the echo time for a perfectly spoiled
% SPGR sequence.
%
% ARGS :
% TR    = repetition time vector (ms) (N x 1)
% TE    = echo time vector (ms) (N x 1)
% alpha = flip angle vector (degrees) (N x 1)
% T1    = T1 relaxation time (ms)
% T2s   = T2* relaxation time (ms)
% M0    = equilibrium magnetization (AU)
%
% RETURNS :
% s      = signal vector at (TR,TE,alpha) (AU) (N x 1)
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 2/14/2002 From Mathematica working in SSFP.nb

alpha = alpha * pi / 180;
E1  = exp(-TR/T1);
E2s = exp(-TE/T2s);

% Full ideal SPGR equation
s = M0 .* (1 - E1) .* sin(alpha) ./ (1 - E1 .* cos(alpha)) .* E2s;