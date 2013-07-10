function opts = DW_STE_opts
% opts = DW_STE_opts
%
% Setup default options for DW-STE
%
% RETURNS :
% B1t,Mxy    = RF transmit waveform
% Gx,Gy,Gz = gradient waveforms
% ksgn     = sign vector for k(t) calculations 
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 02/25/2002 From scratch

opts.TE         = 4.9e-3;    % Echo time (s)
opts.TM         = 72.5e-3;   % Mixing time (s)
opts.t_90       = 0.5e-3;    % 90 deg pulse time (s)
opts.t_ramp     = 80e-6;     % Gradient ramp time (s)
opts.FOV        = 2e-3;      % Field of view (m)
opts.Nx         = 32;        % Readout samples
opts.ReadBW     = 40e3;      % Readout bandwidth (Hz)
opts.SliceThick = Inf;       % Slice thickness (m)
opts.TB         = 6;         % Time-bandwidth product of RF pulses (s Hz)

% Diffusion weighting
opts.little_delta = 0.75e-3;         % Little delta - DW pulse width (s)
opts.big_delta    = 75e-3;           % Big delta - DW pulse interval (s)
opts.G_diff       = 0.80;            % Diffusion gradient amplitude (T/m)
opts.diff_vec     = [-0.526 0 0.851]; % Diffusion gradient direction

% Spoilers
opts.t_hspoil   = 0.5e-3;    % Homospoil time (s)
opts.t_tmspoil  = 5.0e-3;    % Homospoil time (s)
opts.G_hspoil   = 0;         % Homospoiler amplitude (T/m) 1T/m = 100G/cm
opts.G_tmspoil  = 0.30;      % TM spoiler amplitude (T/m) 1T/m = 100G/cm

% True echo location
opts.echoloc = opts.TE + opts.TM;

% Verbosity
opts.verbose = 0;