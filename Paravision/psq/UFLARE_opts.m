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
% DATES  : 12/30/2001 From scratch

opts.esp        = 5e-3;      % Echo spacing (s)
opts.etl        = 8;         % Echo train length
opts.alpha      = 60.0;      % Refocussing flip angle (degs)
opts.t_excite   = 512e-6;    % Excitation pulse time (s)
opts.t_ref      = 512e-6;    % Refocussing pulse time (s)
opts.t_ramp     = 100e-6;    % Gradient ramp time (s)
opts.t_spoil    = 750e-6;    % Homospoil time (s)
opts.FOV        = 0.02;      % Field of view (m)
opts.Nx         = 128;       % Readout samples
opts.ReadBW     = 100e3;     % Readout bandwidth (Hz)
opts.SliceThick = 20e-3;     % Slice thickness (m)
opts.TB         = 6;         % Time-bandwidth product of RF pulses (s Hz)
opts.G_spoil    = 0.2;       % Homospoil gradient amplitude (T/m)

% Dependent parameters
opts.TE = opts.esp * fix(opts.etl/2);
