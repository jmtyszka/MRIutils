function [t,B1t,Gx,Gy,Gz,kinv] = JMT_HYPER(opts)
% [t,B1t,Gx,Gy,Gz,kinv] = JMT_HYPER(opts)
%
% Generate waveforms for the STE, ISE and DSE pathways in HyperDWI
% The returned gradient and inversion vectors are N x 3 matrices, with
% the pathways assigned to rows (row 1 = STE, 2 = ISE, 3 = DSE)
%
% ARGS :
% opts  = options structure :
%   .TE         = echo time (s)
%   .t_90       = excitation pulse width (s)
%   .t_180      = excitation pulse width (s)
%   .t_ramp     = gradient ramp time (s)
%   .t_hspoil   = homospoil duration (s)
%   .FOV        = FOV (m)
%   .Nx         = readout samples
%   .ReadBW     = readout bandwidth (Hz)
%   .SliceThick = slice thickness (mm)
%   .RFwave     = RF waveform name
%   .TB         = time-bandwidth product of RF pulses (s Hz)
%   .G_homo     = homospoiler amplitude (T/m)
%   .delta1     = diffusion pulse duration (attack start to decay start)
%   .delta2     = diffusion pulse duration (attack start to decay start)
%   .DELTA1     = diffusion pulse interval (attack start to attack start)
%   .DELTA2     = diffusion pulse interval (attack start to attack start)
%   .G_diff       = diffusion encoding gradient amp (T/m)
%   .diff_vec     = diffusion encoding direction vector [x y z]
%
% RETURNS :
% t        = time vector (s)
% B1t      = RF transmit waveform (T)
% Gx,Gy,Gz = gradient waveforms, pathways in rows (T)
% kinv     = location of k-space inversion points
%            due to 180 refocusing pulses, pathways in rows (s)
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 04/06/2004 JMT Adapt from SpinEcho.m
%          06/27/2008 JMT Adapt for jmt_hyper
%
% The MIT License (MIT)
%
% Copyright (c) 2016 Mike Tyszka
%
%   Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
%   documentation files (the "Software"), to deal in the Software without restriction, including without limitation the
%   rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
%   permit persons to whom the Software is furnished to do so, subject to the following conditions:
%
%   The above copyright notice and this permission notice shall be included in all copies or substantial portions of the
%   Software.
%
%   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
%   WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
%   COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
%   OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

% Flag to include imaging gradients
inc_imgrads = 1;

% Utility variables
tramp = opts.t_ramp;
tpad = opts.rfpad;
thspoil = opts.t_hspoil;
Gh = opts.G_hspoil;

%-------------------------------------------------------------
% Precalculate sequence parameters
%-------------------------------------------------------------

t_acq = opts.Nx / opts.ReadBW; 
SliceBW = opts.TB / opts.t_90;

%-------------------------------------------------------------
% Calculate read gradient time before echo
%-------------------------------------------------------------

% Read on during phase encoding
t_acq_wait = thspoil - tramp;

%-------------------------------------------------------------
% Estimate total time range of sequence and construct time vector
%-------------------------------------------------------------

% Temporal sampling interval (4us)
dt = 4e-6;
Ttot = opts.t_90/2 + opts.TE + opts.TM + t_acq * (1-opts.echopos/100) + tramp + thspoil;

% Extend sampling interval by 10%
t = (-Ttot * 0.1):dt:(Ttot * 1.1);
nt = length(t);

%-------------------------------------------------------------
% Initialize waveform vectors
%-------------------------------------------------------------

B1t  = zeros(1,nt);
Gx   = B1t;
Gy   = B1t;
Gz   = B1t;
kinv = {};

%-------------------------------------------------------------
% Gradients in T/m
%-------------------------------------------------------------

gam = GAMMA_1H / (2 * pi);
G_read = opts.ReadBW / (gam * opts.FOV);
G_slice = SliceBW / (gam * opts.SliceThick);
G_readdeph = -(G_read * (tramp/2 + t_acq_wait + t_acq * opts.echopos/100)) / (thspoil - tramp);

% Slice refocusing gradient moment
M_slref = G_slice * (opts.t_90 + tramp)/2;

% Excite slice refocus + homospoil
G_slrefocus = (Gh * (thspoil - tramp) - M_slref) / (thspoil - tramp);

if ~inc_imgrads

  % Switch off imaging gradients
  G_read = 0.0;
  G_slice = 0.0;
  G_readdeph = 0.0;
  G_slrefocus = 0.0;
  Gh = 0.0;
  
end

%-------------------------------------------------------------
% RF pulse start times
%-------------------------------------------------------------

t90 = opts.t_90 + 2*tpad;
talpha = opts.t_alpha + 2*tpad;
t180 = opts.t_180 + 2*tpad;

t0_90 = -t90/2;
t0_alpha1 = opts.TE/2 - talpha/2;
t0_180 = (opts.TE + opts.TM)/2 - t180/2;
t0_alpha2 = t0_alpha1 + opts.TM;

% Gradient spoiler start times
t0_alpha1_prespoil = t0_alpha1 - thspoil;
t0_alpha1_postspoil = t0_alpha1 + t180;
t0_180_prespoil = t0_180 - thspoil;
t0_180_postspoil = t0_180 + t180;
t0_alpha2_prespoil = t0_alpha2 - thspoil;
t0_alpha2_postspoil = t0_alpha2 + t180;

t0_read = opts.echoloc - (t_acq * opts.echopos/100) - t_acq_wait - tramp;

% No transverse spoiler in jmt_hyper (as of 7/21/2008)
% t0_transpoil = t0_read + tramp + t_acq_wait + t_acq + tramp;

% Diffusion gradient pulse start times
t0_gdiff_ste_A = t90/2 + tramp + opts.echopad;
t0_gdiff_ste_B = t0_gdiff_ste_A + opts.DELTA1;
t0_gdiff_he_A = t0_alpha1 + talpha + thspoil + opts.tmpad;
t0_gdiff_he_B = t0_gdiff_he_A + opts.DELTA2;

% RF pulse midpoints
tmid_alpha1 = t0_alpha1 + talpha/2;
tmid_alpha2 = t0_alpha2 + talpha/2;
tmid_180 = t0_180 + t180/2;

%-------------------------------------------------------------
% Summary
%-------------------------------------------------------------

if opts.verbose

  fprintf('\n');
  fprintf('JMT_HYPER Pulse Sequence\n');
  fprintf('------------------------\n');
  fprintf('TIMINGS:\n');
  fprintf('  TE        : %0.3f ms\n', opts.TE * 1e3);
  fprintf('  TM        : %0.3f ms\n', opts.TM * 1e3);
  fprintf('  Acq Time  : %0.3f ms\n', t_acq * 1e3);
  fprintf('  Read BW   : %0.1f kHz\n', opts.ReadBW / 1e3);
  fprintf('  Slice BW  : %0.1f kHz\n', SliceBW / 1e3);
  fprintf('  Ramp      : %0.3f ms\n', tramp);
  fprintf('  RF pad    : %0.3f ms\n', tpad);
  fprintf('DIFFUSION:\n');
  fprintf('  delta1    : %0.3f ms\n', opts.delta1 * 1e3);
  fprintf('  DELTA1    : %0.3f ms\n', opts.DELTA1 * 1e3);
  fprintf('  delta2    : %0.3f ms\n', opts.delta2 * 1e3);
  fprintf('  DELTA2    : %0.3f ms\n', opts.DELTA2 * 1e3);
  fprintf('\n');
  
end

%-------------------------------------------------------------
% Diffusion-weighted stimulated echo pulse sequence
%-------------------------------------------------------------

% 90 excitation RF pulse
B1t = RFWave(t,B1t,opts.RFwave,90.0,0.0,t0_90+tramp,t90);

% Alpha1 RF pulse
B1t = RFWave(t,B1t,opts.RFwave,90.0,0.0,t0_alpha1,talpha);

% 180 refocus RF pulse
B1t = RFWave(t,B1t,opts.RFwave,180.0,0.0,t0_180,t180);

% Alpha2 RF pulse
B1t = RFWave(t,B1t,opts.RFwave,90.0,0.0,t0_alpha2,talpha);

% RF excite slice select gradient
Gz = GradTrap(t,Gz,G_slice,t0_90-tramp,tramp,t90);

% Alpha1 prespoil and excite slice select refocus
Gz = GradTrap(t,Gz,G_slrefocus,t0_alpha1_prespoil,tramp,thspoil-2*tramp);

% Alpha1 slice select
Gz = GradTrap(t,Gz,G_slice,t0_alpha1-tramp,tramp,t180);

% Alpha1 postspoil
Gz = GradTrap(t,Gz,Gh,t0_alpha1_postspoil,tramp,thspoil-2*tramp);

% Pre-180 homospoil (bridged to 180 slice select)
Gz = GradTrap(t,Gz,Gh,t0_180_prespoil,tramp,thspoil-2*tramp);

% 180 slice select
Gz = GradTrap(t,Gz,G_slice,t0_180-tramp,tramp,t180);

% Post-180 homospoil (bridged to refocus slice select)
Gz = GradTrap(t,Gz,Gh,t0_180_postspoil,tramp,thspoil-2*tramp);

% Alpha2 prespoil and excite slice select refocus
Gz = GradTrap(t,Gz,Gh,t0_alpha2_prespoil,tramp,thspoil-2*tramp);

% Alpha2 slice select
Gz = GradTrap(t,Gz,G_slice,t0_alpha2-tramp,tramp,t180);

% Alpha2 postspoil
Gz = GradTrap(t,Gz,Gh,t0_alpha2_postspoil,tramp,thspoil-2*tramp);

% Read gradient
Gx = GradTrap(t,Gx,G_read,t0_read,tramp,t_acq_wait+t_acq);

% Read dephase
Gx = GradTrap(t,Gx,G_readdeph,t0_alpha2_postspoil,tramp,thspoil-2*tramp);

% Transverse spoiler same amp and duration as homospoil
% Applied to both Gx and Gz - not present in jmt_hyper
% Gx = GradTrap(t,Gx,Gh,t0_transpoil,tramp,thspoil-2*tramp);
% Gz = GradTrap(t,Gz,Gh,t0_transpoil,tramp,thspoil-2*tramp);

%--------------------------------------------------------------------
% Outer/STE Diffusion Pulses
%--------------------------------------------------------------------

Gd_ste = opts.G_diff_ste * opts.diff_vec_ste;

Gx = GradTrap(t,Gx,Gd_ste(1),t0_gdiff_ste_A,tramp,opts.delta1-tramp);
Gy = GradTrap(t,Gy,Gd_ste(2),t0_gdiff_ste_A,tramp,opts.delta1-tramp);
Gz = GradTrap(t,Gz,Gd_ste(3),t0_gdiff_ste_A,tramp,opts.delta1-tramp);

Gx = GradTrap(t,Gx,Gd_ste(1),t0_gdiff_ste_B,tramp,opts.delta1-tramp);
Gy = GradTrap(t,Gy,Gd_ste(2),t0_gdiff_ste_B,tramp,opts.delta1-tramp);
Gz = GradTrap(t,Gz,Gd_ste(3),t0_gdiff_ste_B,tramp,opts.delta1-tramp);

%--------------------------------------------------------------------
% Inner/HE Diffusion Pulses
%--------------------------------------------------------------------

Gd_he = opts.G_diff_hyper * opts.diff_vec_hyper;

Gx = GradTrap(t,Gx,Gd_he(1),t0_gdiff_he_A,tramp,opts.delta2-tramp);
Gy = GradTrap(t,Gy,Gd_he(2),t0_gdiff_he_A,tramp,opts.delta2-tramp);
Gz = GradTrap(t,Gz,Gd_he(3),t0_gdiff_he_A,tramp,opts.delta2-tramp);

Gx = GradTrap(t,Gx,Gd_he(1),t0_gdiff_he_B,tramp,opts.delta2-tramp);
Gy = GradTrap(t,Gy,Gd_he(2),t0_gdiff_he_B,tramp,opts.delta2-tramp);
Gz = GradTrap(t,Gz,Gd_he(3),t0_gdiff_he_B,tramp,opts.delta2-tramp);

%--------------------------------------------------------------------
% Split gradients into three pathways
% Stimulated echo pathway zeros gradients between alpha pulses
% Spin echo pathways have complete waveform
%--------------------------------------------------------------------

Gx = repmat(Gx,3,1);
Gy = repmat(Gy,3,1);
Gz = repmat(Gz,3,1);

TM_inds = find(t > tmid_alpha1 & t < tmid_alpha2);
Gx(1,TM_inds) = 0;
Gy(1,TM_inds) = 0;
Gz(1,TM_inds) = 0;

%--------------------------------------------------------------------
% k-space inversion points
%--------------------------------------------------------------------

kinv{1} = tmid_180; % Stimulated echo pathway (STE)
kinv{2} = tmid_180; % Indirect spin echo pathway (ISE)
kinv{3} = [tmid_alpha1 tmid_180 tmid_alpha2]; % Direct spin echo pathway (DSE)
