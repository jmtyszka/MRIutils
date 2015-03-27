function c = jmt_ddr_costfn(x,pars)
% Optimization cost function
% Based on residual image-space signal outside of mask defined by reference
% image

% x is a vector of phases corresponding to each CPMG echo
% Expand to cover k-space

[nx,ny,nz] = size(pars.k);

phi_corr = repmat(x,[pars.nshots 1]);
phi_corr = phi_corr(:)';
phi_corr = repmat(phi_corr,[nx 1 nz]);

k_corr = pars.k .* exp(-i * phi_corr);

% Reconstruct image space
s_corr = abs(fftshift(fftn(k_corr)));

% Extract ghost + noise signal
c = s_corr(pars.outside);