function [t,B1t,Gx,Gy,Gz,kinv] = UFLARE(opts)
% [t,B1t,Gx,Gy,Gz,kinv] = UFLARE(opts)
%
% Generate waveforms for UFLARE sequence
%
% ARGS :
% opts  = UFLARE options structure :
%   .esp   = echo spacing (s)
%   .etl   = echo train length
%   .alpha = refocusing flip angle (deg);
%   .t_excite   = 512e-6;    % s
%   .t_ref      = 512e-6;    % s
%   .t_ramp     = 100e-6;    % s
%   .t_spoil    = 750e-6;    % s
%   .FOV        = 0.02;      % m
%   .Nx         = 128;       % Readout samples
%   .ReadBW     = 100e3;     % Hz
%   .SliceThick = 20e-3;     % m
%   .TB         = 6;         % Time-bandwidth product of RF pulses (s Hz)
%   .G_spoil    = 0.1;       % T/m
%
% RETURNS :
% t        = time vector (s)
% B1t      = RF transmit waveform (T)
% Gx,Gy,Gz = gradient waveforms (T)
% kinv     = k inversion time points (s) 
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 12/30/2001 From scratch
%          02/27/2002 Change ksgn to kinv
%                     Calculate t-vector

% Pulse sequence parameters

% Precalculate dependent sequence parameters where possible
t_acq       = opts.Nx / opts.ReadBW; 
SliceBW     = opts.TB / opts.t_excite;
G_read      = opts.ReadBW / (GAMMA_1H * opts.FOV);
G_readdeph  = (G_read * (opts.t_ramp + t_acq)/2) / (opts.t_spoil + opts.t_ramp);
G_pe        = 0.5 * opts.Nx / (GAMMA_1H * opts.FOV * (opts.t_spoil + opts.t_ramp));
G_slice     = SliceBW / (GAMMA_1H * opts.SliceThick);
t0_excite   = -opts.t_excite/2 - opts.t_ramp;
t0_ref      = opts.esp/2 - opts.t_ref/2 - opts.t_ramp;
t0_prespoil = t0_ref - opts.t_spoil - opts.t_ramp;

% Slice refocusing moment
M_slref = G_slice * (opts.t_excite + opts.t_ramp)/2;

% Estimate total time range of sequence and construct time vector
dt = 4e-6;
Ttot = opts.t_ramp + opts.esp * (opts.etl + 1);
t = (-Ttot * 0.1):dt:(Ttot * 1.1);

% Initialize return vectors
B1t = zeros(size(t));
Gx = B1t;
Gy = B1t;
Gz = B1t;

%---------------------------------------------------------
% Sequence start
%---------------------------------------------------------

% Excite slice select gradient
Gz = GradTrap(t,Gz,G_slice,t0_excite,opts.t_ramp,opts.t_excite);

% RF Excite pulse
B1t = RFWave(t,B1t,'hsinc',90.0,t0_excite+opts.t_ramp,opts.t_excite);

% Adjust pre-RF refocus homospoil moment for slice refocusing
G_prespoil = (opts.G_spoil * (opts.t_spoil + opts.t_ramp) - M_slref) / ...
  (opts.t_spoil + opts.t_ramp);

% Pre-RF refocus homospoil and slice refocus
Gz = GradTrap(t,Gz,G_prespoil,t0_prespoil,opts.t_ramp,opts.t_spoil);

% Read dephase
Gx = GradTrap(t,Gx,G_readdeph,t0_prespoil,opts.t_ramp,opts.t_spoil);

%---------------------------------------------------------
% Echo loop
%---------------------------------------------------------

for ec = 1:opts.etl
  
  % Calculate timing positions for this echo
  toff = opts.esp * (ec-1);
  t0_ref = toff + opts.esp/2 - opts.t_ref/2 - opts.t_ramp;
  t0_postspoil = t0_ref + opts.t_ramp + opts.t_ref;
  t0_read = toff + opts.esp - t_acq/2 - opts.t_ramp;
  t0_prespoil = t0_ref - opts.t_spoil - opts.t_ramp + opts.esp;

  % RF Refocus pulse
  B1t = RFWave(t,B1t,'hsinc',opts.alpha,t0_ref + opts.t_ramp,opts.t_ref);

  % Refocus slice select gradient
  Gz = GradTrap(t,Gz,G_slice,t0_ref,opts.t_ramp,opts.t_ref);

  % Post-RF refocus homospoil
  Gz = GradTrap(t,Gz,opts.G_spoil,t0_postspoil,opts.t_ramp,opts.t_spoil);

  % Read gradient
  Gx = GradTrap(t,Gx,G_read,t0_read,opts.t_ramp,t_acq);

  % Phase encode (assume square FOV and matrix)
  PEscale = 1 - 2 * (ec-1) / opts.etl;
  Gy = GradTrap(t,Gy,G_pe,t0_postspoil,opts.t_ramp,opts.t_spoil,PEscale);

  % Dephase encode
  Gy = GradTrap(t,Gy,-G_pe,t0_prespoil,opts.t_ramp,opts.t_spoil,PEscale);

  % Pre-RF refocus homospoil for next echo
  Gz = GradTrap(t,Gz,opts.G_spoil,t0_prespoil,opts.t_ramp,opts.t_spoil);

end
  
%--------------------------------------------------------------------
% Create vector of time points at which k is inverted by an RF pulse
%--------------------------------------------------------------------

kinv = ((1:opts.etl)-0.5) * opts.esp;
