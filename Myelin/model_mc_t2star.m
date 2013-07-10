function S = model_mc_t2star(X, TE)
% Full T2star decay from model parameters

% Parameter vector organization:
% [oes rho_1 rho_2 T2_1 T2_2]

% Odd and even echo times (ms)
TE_even = TE(2:2:end);
TE_odd  = TE(1:2:end);

% Unpack parameters
oes    = X(1); % Odd-even echo scale factor (apply to even echo train)
rho_1  = X(2);
rho_2  = X(3);
rho_3  = X(4);
T2_1   = X(5);
T2_2   = X(6);
T2_3   = X(7);

% Odd and even echo signals
S_odd  = rho_1*exp(-TE_odd/T2_1) + rho_2*exp(-TE_odd/T2_2) + rho_3*exp(-TE_odd/T2_3);
S_even = rho_1*exp(-TE_even/T2_1) + rho_2*exp(-TE_even/T2_2) + rho_3*exp(-TE_even/T2_3);
S_even = S_even * oes;

% Full decay (column vector)
S = [S_odd(:)'; S_even(:)'];
S = S(:);