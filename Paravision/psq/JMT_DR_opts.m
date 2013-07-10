function opts = JMT_DR_opts(scandir)
% opts = JMT_DR_opts
%
% Setup default options for JMT_DDR
%
% RETURNS :
% opts = opts structure for this sequence
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 02/18/2008 JMT Adapt from JMT_DDR_opts.m
%          06/27/2008 JMT Extract opts code from psqmkopts.m
%
% Copyright 2008 California Institute of Technology.
% All rights reserved.

% Read sequence information
info = parxloadinfo(scandir);

% Fill opts structure
opts.TE         = info.TE_DW/1000;         % Single echo time for DW prep (s)
opts.t_90       = info.excpulse.pw/1000;   % 90 deg pulse time (s)
opts.t_180      = info.refpulse.pw/1000;   % 180 deg pulse time (s)
opts.t_ramp     = info.t_ramp / 1000;      % Gradient ramp time (s)
opts.FOV        = info.fov(1) / 1000;      % Field of view (m)
opts.Nx         = info.sampdim(1);         % Readout samples
opts.ReadBW     = info.bw;                 % Readout bandwidth (Hz)
opts.SliceThick = Inf;                     % Slice thickness (m)
opts.TB         = info.excpulse.tb / 1000; % Time-bandwidth product of RF pulses (s Hz)
opts.rfpad      = info.delays(4);          % RF padding delay (s)

% RF waveform
switch info.excpulse.shape
  case {'<bp32.exc>','<bp.exc>'}
    opts.RFwave     = 'rect';
  case {'<hermite.exc>'}
    opts.RFwave = 'hsinc';
  otherwise
    opts.RFwave = 'hsinc';
end

% Diffusion weighting
opts.delta1 = info.delta1 / 1000; % delta1 - DW pulse width (s)
opts.delta4 = info.delta4 / 1000; % delta4 - DW pulse width (s)
opts.G_diff = info.Gdiff / 100;   % Diffusion gradient amplitude (T/m)
opts.diff_vec = info.diffdir;     % Diffusion gradient direction

% Spoilers
opts.t_hspoil   = info.t_hspoil / 1000;                % Full homospoiler time (s)
opts.G_hspoil   = info.G_hspoil * info.maxgrad * 1e-4; % Homospoiler amplitude (T/m) 1T/m = 100G/cm

% True echo time and percent position within acquire window
opts.echoloc = opts.TE;
opts.echopos = info.echopos;

% Verbosity
opts.verbose = 1;