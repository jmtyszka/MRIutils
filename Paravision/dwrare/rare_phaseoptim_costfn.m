function c = rare_phaseoptim_costfn(x,pars)
% Optimization cost function
% Based on residual image-space signal outside of mask defined by reference
% image

% Apply correction to complex k-space
k_corr = rare_apply_echo_corr(x,pars);

% Reconstruct corrected image space
s_corr = abs(fftshift(fftn(fftshift(k_corr))));

% Extract ghost + noise signal (automatically flattened)
c = s_corr(pars.outside);