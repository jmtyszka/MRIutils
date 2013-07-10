function opts = DW_SE_opts
% opts = DW_SE_opts
%
% Setup default options for DW-SE
%
% RETURNS :
% B1t,Mxy    = RF transmit waveform
% Gx,Gy,Gz = gradient waveforms
% ksgn     = sign vector for k(t) calculations 
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 04/14/2004 JMT From scratch
%
% Copyright 2004 California Institute of Technology.
% All rights reserved.

opts.TE         = 14.15e-3;  % Echo time (s)
opts.t_90       = 50e-6;     % 90 deg pulse time (s)
opts.t_180      = 50e-6;     % 180 deg pulse time (s)
opts.t_ramp     = 80e-6;     % Gradient ramp time (s)
opts.FOV        = 2.56e-3;   % Field of view (m)
opts.Nx         = 64;        % Readout samples
opts.ReadBW     = 25e3;      % Readout bandwidth (Hz)
opts.SliceThick = Inf;       % Slice thickness (m)
opts.RFwave     = 'rect';    % Rectangular pulse
opts.TB         = 1.28;      % Time-bandwidth product of RF pulses (s Hz)

% Diffusion weighting
opts.little_delta = 1.25e-3;          % Little delta - DW pulse width (s)
opts.big_delta    = 10e-3;            % Big delta - DW pulse interval (s)
opts.G_diff       = 0.75;             % Diffusion gradient amplitude (T/m)
opts.diff_vec     = [0 1 0]; % Diffusion gradient direction

% Spoilers
opts.t_hspoil   = 0.75e-3;    % Homospoil time (s)
opts.G_hspoil   = 0.21;       % Homospoiler amplitude (T/m) 1T/m = 100G/cm

% True echo time and percent position within acquire window
opts.echoloc = opts.TE;
opts.echopos = 25;

% Verbosity
opts.verbose = 1;