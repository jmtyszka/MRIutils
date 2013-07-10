function opts = JMT_HYPER_opts(scandir)
% opts = JMT_HYPER_opts
%
% Setup default options for JMT_HYPER
%
% RETURNS :
% opts = opts structure for this sequence
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 01/09/2008 JMT Adapt from DW_SE_opts.m
%          06/27/2008 JMT Extract opts code from psqmkopts.m
%
% Copyright 2008 California Institute of Technology.
% All rights reserved.

% Read sequence information
info = parxloadinfo(scandir);

% Fill opts structure
opts.TE         = info.t_TE/1000;          % Stimulated echo time (s)
opts.TM         = info.t_TM/1000;          % Mixing time (s)
opts.t_90       = info.excpulse.pw/1000;   % 90 deg pulse time (s)
opts.t_180      = info.refpulse.pw/1000;   % 180 deg pulse time (s)
opts.t_alpha    = info.alphapulse.pw/1000; % 180 deg pulse time (s)
opts.t_ramp     = info.t_ramp / 1000;      % Gradient ramp time (s)
opts.FOV        = info.fov(1) / 1000;      % Field of view (m)
opts.Nx         = info.sampdim(1);         % Readout samples
opts.ReadBW     = info.bw;                 % Readout bandwidth (Hz)
opts.SliceThick = info.slthick * 1e-3;     % Slice thickness (m)
opts.TB         = info.excpulse.tb / 1000; % Time-bandwidth product of RF pulses (s Hz)
opts.rfpad      = info.delays(4);          % RF padding delay (s) D[3]
opts.echopad    = info.delays(2);          % Echo padding delay (s) D[1]
opts.tmpad      = info.delays(15);         % TM padding delay (s) D[14]

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
opts.delta1 = info.t_delta1 / 1000; % STE delta1 - DW pulse width (s)
opts.delta2 = info.t_delta2 / 1000; % HE delta2 - DW pulse width (s)
opts.DELTA1 = info.t_DELTA1 / 1000; % STE DELTA1 - DW pulse width (s)
opts.DELTA2 = info.t_DELTA2 / 1000; % HE DELTA2 - DW pulse width (s)
opts.G_diff_ste = info.G_diff_ste / 100;      % STE diffusion gradient amplitude (T/m)
opts.G_diff_hyper = info.G_diff_hyper / 100;  % HYPER diffusion gradient amplitude (T/m)
opts.diff_vec_ste = info.diff_dir_ste;        % STE diffusion gradient direction
opts.diff_vec_hyper = info.diff_dir_hyper;    % HYPER diffusion gradient direction

% Spoilers
opts.t_hspoil   = info.t_hspoil / 1000;                % Full homospoiler time (s)
opts.G_hspoil   = info.G_hspoil * info.maxgrad * 1e-4; % Homospoiler amplitude (T/m) 1T/m = 100G/cm

% True echo time and percent position within acquire window
opts.echoloc = opts.TE + opts.TM;
opts.echopos = info.echopos;

% Verbosity
opts.verbose = 0;