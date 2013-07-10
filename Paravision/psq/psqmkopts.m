function opts = psqmkopts(scandir)
% opts = psqmakeopts(scandir)
%
% Create the simulation options structure for psq from a Paravision scan
% directory. This reduces the chance of parameter misentry by reading scan
% parameters directly from the sequence information files (method, imnd,
% acqp, reco, etc)
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 04/14/2004 JMT From scratch
%
% Copyright 2004 California Institute of Technology.
% All rights reserved.

% Get PV info from scandir
info = parxloadinfo(scandir);

% Construct options structure based on method name
switch upper(info.method)
  
  case {'JMT_DDR'} % Double echo DW-RARE
    
    opts = JMT_DDR_opts(scandir);
    
  case {'JMT_DR'} % Single echo DW-RARE
    
    opts = JMT_DR_opts(scandir);
    
  case {'JMT_HYPER'} % HyperCOPS
    
    opts = JMT_HYPER_opts(scandir);

  case {'BIC_DWSE','JMT_DWSE'} % Diffusion-weighted spin echo
    
    opts.TE         = info.te / 1000;          % Echo time (s)
    opts.t_90       = info.excpulse.pw / 1000; % 90 deg pulse time (s)
    opts.t_180      = info.refpulse.pw / 1000; % 180 deg pulse time (s)
    opts.t_ramp     = info.t_ramp / 1000;      % Gradient ramp time (s)
    opts.FOV        = info.fov(1) / 1000;      % Field of view (m)
    opts.Nx         = info.sampdim(1);         % Readout samples
    opts.ReadBW     = info.bw;                 % Readout bandwidth (Hz)
    opts.SliceThick = Inf;                     % Slice thickness (m)
    opts.TB         = info.excpulse.tb / 1000; % Time-bandwidth product of RF pulses (s Hz)

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
    opts.little_delta = info.little_delta / 1000; % Little delta - DW pulse width (s)
    opts.big_delta    = info.big_delta / 1000;    % Big delta - DW pulse interval (s)
    opts.G_diff       = info.Gdiff / 100;         % Diffusion gradient amplitude (T/m)
    opts.diff_vec     = info.diffdir;             % Diffusion gradient direction
    
    % Spoilers
    opts.t_hspoil   = info.t_hspoil / 1000;                % Homospoiler time (s)
    opts.G_hspoil   = info.G_hspoil * info.maxgrad * 1e-4; % Homospoiler amplitude (T/m) 1T/m = 100G/cm
    
    % True echo time and percent position within acquire window
    opts.echoloc = opts.TE;
    opts.echopos = info.echopos;
    
    % Verbosity
    opts.verbose = 0;
    
  case 'BIC_DWSTE' % Diffusion-weighted stimulated echo
    
    opts.TE         = info.te / 1000;          % Echo time (s)
    opts.TM         = info.tm / 1000;          % Mixing time (s)
    opts.t_90       = info.excpulse.pw / 1000; % 90 deg pulse time (s)
    opts.t_ramp     = info.t_ramp / 1000;      % Gradient ramp time (s)
    opts.FOV        = info.fov(1) / 1000;      % Field of view (m)
    opts.Nx         = info.sampdim(1);         % Readout samples
    opts.ReadBW     = info.bw;                 % Readout bandwidth (Hz)
    opts.SliceThick = Inf;                     % Slice thickness (m)
    opts.TB         = info.excpulse.tb / 1000; % Time-bandwidth product of RF pulses (s Hz)
    
    % Diffusion weighting
    opts.little_delta = info.little_delta / 1000; % Little delta - DW pulse width (s)
    opts.big_delta    = info.big_delta / 1000;    % Big delta - DW pulse interval (s)
    opts.G_diff       = info.Gdiff / 100;         % Diffusion gradient amplitude (T/m)
    opts.diff_vec     = info.diffdir;             % Diffusion gradient direction
    
    % Spoilers
    opts.t_hspoil   = info.t_hspoil / 1000;                 % Homospoiler time (s)
    opts.G_hspoil   = info.G_hspoil * info.maxgrad * 1e-4;  % Homospoiler amplitude (T/m) 1T/m = 100G/cm
    opts.t_tmspoil   = info.t_hspoil / 1000;                % TM spoiler time (s)
    opts.G_tmspoil   = info.G_hspoil * info.maxgrad * 1e-4; % TM spoiler amplitude (T/m) 1T/m = 100G/cm
    
    % True echo time and percent position within acquire window
    opts.echoloc = opts.TE + opts.TM;
    opts.echopos = info.echopos;
    
    % Verbosity
    opts.verbose = 0;
    
  otherwise
    
    fprintf('Cannot process method %s\n', info.method);
    return
    
end