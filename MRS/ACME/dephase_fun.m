function sp_dp = dephase_fun(sp_ft,phc0,phc1)
% function sp_dp = dephase_fun(sp_ft,phc0,phc1)
% written by Chen Li 
% input:   sp_ft - complex data after fourier transform
%         phc0  - the zero order phase correction
%         phc1  - the first order phase correction
% output:  sp_dp - spectral data after phase correction
%
% Modified by Mike Tyszka, Caltech BIC

phc0 = phc0 * pi/180;              % convert degree to radian
phc1 = phc1 * pi/180;              % convert degree to radian

% m complex spectra (rows) with n samples (cols)
[m,n]=size(sp_ft);

% Normalized index vector
a_num = linspace(0,1,n);

% Calculate a(i,j)
a = phc0 + a_num * phc1;
a = repmat(a,[m 1]);

% Apply phase function
sp_dp = sp_ft .* exp(i * a);