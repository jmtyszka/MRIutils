function M_bssfp = bssfp_contrast_WM(f_F, f_S, T1_F, T1_S, T2_F, T2_S, k_FS, k_SF, rho, TR, alpha_deg)
% bSSFP contrast equation for white matter
%
% Treat WM as a two-compartment (fast, slow relaxing) tissue
%
% ARGS:
% f_F, f_S   : fast and slow compartment volume fractions [0..1]
% T1_F, T1_S : fast and slow compartment T1s (ms)
% T2_F, T2_S : fast and slow compartment T2s (ms)
% k_FS, k_SF : fast and slow compartment reciprocal residencies (ms^-1)
% rho        : Equilibrium magnetization (AU)
% TR         : Repetition time (ms)
% alpha_deg  : Flip angle (degrees)
%
% RETURNS:
% M_bssfp    : steady-state magnetization vector [Mx_F Mx_S My_F My_S Mz_F Mz_S]'
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech
% DATES  : 02/23/2012 JMT Implement bSSFP contrast equation from Deoni 2008
%
% Copyright 2012 California Institute of Technology.
% All rights reserved.

% Flip angle rotation matrix (about x')
alpha_rad = alpha_deg * pi/180;
ca = cos(alpha_rad); sa = sin(alpha_rad);
R_alpha = [1 0 0; 0 ca -sa; 0 sa ca];

% Two-compartment T1 proton density vector
% Equation 7 from Deoni 2008
C = rho * [0 0 0 0 f_F/T1_F f_S/T1_S];

% Two-compartment (fast, slow) bSSFP relaxation-exchange matrix
% Equation 6 from Deoni 2008
A_bssfp = [ ...
  -1/T2_F-k_FS, k_SF        , dw_F        , 0           , 0           , 0            ; ...
  k_FS        , -1/T2_S-k_SF, 0           , dw_S        , 0           , 0            ; ...
  -dw_F       , 0           , -1/T2_F-k_FS, k_SF        , 0           , 0            ; ...
  0           , -dw_S       , k_FS        , -1/T2_S-k_SF, 0           , 0            ; ...
  0           , 0           , 0           , 0           , -1/T1_F-k_FS, k_SF         ; ...
  0           , 0           , 0           , 0           , k_FS        , -1/T1_S-k_SF ];

% Full two-compartment magnetization vector in steady state
% Equation 4 from Deoni 2008
% Note use of Matlab forms: a\b = inv(a) * b and a/b = a * inv(b)
M_bssfp = ((exp(A_bssfp * TR) - eye(6)) * (A_bssfp\C)) / (eye(6) - exp(A_bssfp * TR) * R_alpha);