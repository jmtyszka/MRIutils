function c = rare_phaseoptim2_costfn(x,pars)
% RARE blind per-echo correction cost function.
%
% x is a vector of phases corresponding to each RARE echo
% Replicate across ky axis using ky_order matrix, then replicate
% across kx and kz axes.

% Apply correction to complex k-space
k_corr = rare_apply_echo_corr(x,pars);

% Reconstruct corrected image space
s_corr = abs(fftshift(fftn(fftshift(k_corr))));

% Extract ghost + noise signal (automatically flattened)
c = s_corr(pars.outside);