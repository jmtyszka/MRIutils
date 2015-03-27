function k_corr = rare_apply_echo_corr(x, pars)
% Generate complex echo correction vector from optimization parameter
% vector. Always returns a complex value for each echo.

switch pars.corr_type
  case 'phase'
    phi = x;
    amp = ones(1,pars.etl);
  case 'complex'
    phi = x(1:pars.etl);
    amp = x((1:pars.etl)+pars.etl);
end

per_echo_corr = amp .* exp(i * phi);

% Allocate phase correction volume
echo_corr = zeros(size(pars.k));

% Replicate current per-echo correction across whole k-space volume
% Use ky_order to handle phase encoding order
for ec = 1:pars.etl
  echo_corr(:,pars.ky_order(:,ec),:) = per_echo_corr(ec);
end

% Apply correction
k_corr = pars.k .* echo_corr;