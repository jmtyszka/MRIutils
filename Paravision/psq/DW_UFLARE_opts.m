function opts = UFLARE_opts
% opts = UFLARE_opts
%
% Setup default options for UFLARE
%
%
% RETURNS :
% B1t,Mxy    = RF transmit waveform
% Gx,Gy,Gz = gradient waveforms
% ksgn     = sign vector for k(t) calculations 
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 02/27/2002 From scratch

opts.esp          = 4e-3;      % Echo spacing (s)
opts.etl          = 8;         % Echo train length
opts.alpha        = 180.0;     % Refocussing flip angle (degs)
opts.t_excite     = 512e-6;    % Excitation pulse time (s)
opts.t_refocus    = 512e-6;    % Refocussing pulse time (s)
opts.t_ramp       = 100e-6;    % Gradient ramp time (s)
opts.t_unblank    = 25e-6;     % RF unblank time (s)
opts.t_spoil      = 250e-6;    % Homospoil time (s)
opts.t_pgse_spoil = 1e-3;      % PGSE homospoil time (s)
opts.FOV          = 2e-2;      % Field of view (m)
opts.Nx           = 128;       % Readout samples
opts.ReadBW       = 125e3;     % Readout bandwidth (Hz)
opts.SliceThick   = 2e-2;      % Slice thickness (m)
opts.TB           = 6;         % Time-bandwidth product of RF pulses (s Hz)
opts.G_spoil      = 0.25;      % Homospoil gradient amplitude (T/m) 100 G/cm = 1 T/m
opts.littledelta  = 5e-3;      % Small delta (s)
opts.bigdelta     = 10e-3;     % Small delta (s)

opts.G_diff       = [0.30 -0.20 0.0]; % Diffusion gradient vector (T/m)

% Dependent parameters
opts.TE = opts.esp * fix(opts.etl/2);
