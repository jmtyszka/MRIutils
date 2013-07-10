function err = spgr_err(x,S,TR,TE,alpha)
% err = spgr_err(x,S,TR,TE,alpha)
%
% Error vector for SPGR signal equation fitting
%
% ARGS :
% x     = fit parameters [T1 T2* M0]
% S     = vector of signal values [1 x N]
% TR    = vector of TR values (ms) for S[]
% TE    = vector of TE values (ms) for S[]
% alpha = vector of flip angles (degrees) for S[]
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 2/14/2002 From scratch

% Extract results
T1  = x(1);
T2s = x(2);
M0  = x(3);

% Calculate and return error vector
err = S - spgreq(TR,TE,alpha,T1,T2s,M0);