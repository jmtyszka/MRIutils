function opts = SpinEcho_opts
% opts = SpinEcho_opts
%
% Setup default options for SpinEcho
%
% RETURNS :
% B1t,Mxy    = RF transmit waveform
% Gx,Gy,Gz = gradient waveforms
% ksgn     = sign vector for k(t) calculations 
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 02/25/2002 From scratch

opts.TE         = 15e-3;     % Echo time (s)
opts.t_excite   = 0.5e-3;    % Excitation pulse time (s)
opts.t_ref      = 0.5e-3;    % Refocussing pulse time (s)
opts.t_ramp     = 80e-6;     % Gradient ramp time (s)
opts.t_spoil    = 2e-3;      % Homospoil time (s)
opts.FOV        = 2e-3;      % Field of view (m)
opts.Nx         = 32;       % Readout samples
opts.ReadBW     = 25e3;     % Readout bandwidth (Hz)
opts.SliceThick = Inf;       % Slice thickness (m)
opts.TB         = 6;         % Time-bandwidth product of RF pulses (s Hz)
opts.G_spoil    = 0.5;      % Homospoil gradient amplitude (T/m) 1T/m = 100G/cm