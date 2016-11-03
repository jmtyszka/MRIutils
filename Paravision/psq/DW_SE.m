function [t,B1t,Gx,Gy,Gz,kinv] = DW_SE(opts)
% [t,B1t,Gx,Gy,Gz,kinv] = DW_SE(opts)
%
% Generate waveforms for diffusion-weighted spin echo sequence (eg
% BIC_DWSE)
%
% ARGS :
% opts  = DWSE options structure :
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
%   .little_delta = diffusion pulse duration (attack start to decay start)
%   .big_delta    = diffusion pulse interval (attack start to attack start)
%   .G_diff       = diffusion encoding gradient amp (T/m)
%   .diff_vec     = diffusion encoding direction vector [x y z]
%
% RETURNS :
% t        = time vector (s)
% B1t      = RF transmit waveform (T)
% Gx,Gy,Gz = gradient waveforms (T)
% kinv     = location of k-space inversion points
%            due to 180 refocusing pulses (s)
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 04/06/2004 JMT Adapt from SpinEcho.m
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

% Old/New version of 2004 PPG. Old version used before 4/2/2004
oldversion = 0;

% Utility variables
tramp = opts.t_ramp;

%-------------------------------------------------------------
% Precalculate sequence parameters
%-------------------------------------------------------------

t_acq = opts.Nx / opts.ReadBW; 
SliceBW = opts.TB / opts.t_90;

%-------------------------------------------------------------
% Calculate read gradient time before echo
%-------------------------------------------------------------

if oldversion
  % Read on during phase encoding
  t_acq_wait = opts.t_hspoil - tramp;
else
  % Read off during phase encoding
  t_acq_wait = 0.0;
end

%-------------------------------------------------------------
% Estimate total time range of sequence and construct time vector
%-------------------------------------------------------------

% Temporal sampling interval (4us)
dt = 4e-6;
Ttot = opts.t_90/2 + opts.TE + t_acq * (1-opts.echopos/100) + tramp + opts.t_hspoil;

% Extend sampling interval by 10%
t = (-Ttot * 0.1):dt:(Ttot * 1.1);

%-------------------------------------------------------------
% Initialize return vectors
%-------------------------------------------------------------

B1t = zeros(size(t));
Gx = B1t;
Gy = B1t;
Gz = B1t;
kinv = B1t;

%-------------------------------------------------------------
% Gradients in T/m
%-------------------------------------------------------------

gam = GAMMA_1H / (2 * pi);
G_read = opts.ReadBW / (gam * opts.FOV);
G_slice = SliceBW / (gam * opts.SliceThick);
G_readdeph = (G_read * (tramp/2 + t_acq_wait + t_acq * opts.echopos/100)) / (opts.t_hspoil - tramp);
G_pe = 0.5 * opts.Nx / (gam * opts.FOV * (opts.t_hspoil - tramp));

M_slref = G_slice * (opts.t_90 + tramp)/2;

t0_90 = -opts.t_90/2 - tramp;
t0_180 = t0_90 + opts.TE/2;
t0_prespoil = t0_180 - opts.t_hspoil;
t0_postspoil = t0_180 + tramp + opts.t_180;
t0_read = opts.echoloc - (t_acq * opts.echopos/100) - t_acq_wait - tramp;
t0_depe = t0_read + 2 * tramp + t_acq;
t0_transpoil = t0_read + tramp + t_acq + tramp;

t0_gdiff_A = opts.TE/2 - opts.big_delta/2 - (opts.little_delta + tramp)/2;
t0_gdiff_B = opts.TE/2 + opts.big_delta/2 - (opts.little_delta + tramp)/2;;

% Adjust pre-180 homospoil moment for slice refocusing
G_prespoil = (opts.G_hspoil * (opts.t_hspoil - tramp) - M_slref) / (opts.t_hspoil - tramp);

%-------------------------------------------------------------
% Summary
%-------------------------------------------------------------

if opts.verbose

  fprintf('\n');
  fprintf('DW-SE Pulse Sequence\n');
  fprintf('------------------------\n');
  fprintf('TIMINGS:\n');
  fprintf('  TE        : %0.3f ms\n', opts.TE * 1e3);
  fprintf('  Acq Time  : %0.3f ms\n', t_acq * 1e3);
  fprintf('  Read BW   : %0.1f kHz\n', opts.ReadBW / 1e3);
  fprintf('  Slice BW  : %0.1f kHz\n', SliceBW / 1e3);
  fprintf('GRADIENTS:\n');
  fprintf('  Read      : %0.3f G/cm\n', G_read * 100);
  fprintf('  Read Deph : %0.3f G/cm\n', G_readdeph * 100);
  fprintf('\n');
  
end

%-------------------------------------------------------------
% Diffusion-weighted stimulated echo pulse sequence
%-------------------------------------------------------------

% 90 excitation RF pulse
B1t = RFWave(t,B1t,opts.RFwave,90.0,0.0,t0_90+tramp,opts.t_90);

% 180 refocus RF pulse
B1t = RFWave(t,B1t,opts.RFwave,180.0,0.0,t0_180+tramp,opts.t_180);

% RF slice select gradient
Gz = GradTrap(t,Gz,G_slice,t0_90,tramp,opts.t_90);

% Pre-180 homospoil (bridged to refocus slice select)
Gz = GradTrap(t,Gz,G_prespoil,t0_prespoil,tramp,opts.t_hspoil-2*tramp);

% Post-180 homospoil (bridged to refocus slice select)
Gz = GradTrap(t,Gz,opts.G_hspoil,t0_postspoil,tramp,opts.t_hspoil-2*tramp);

% Read gradient
Gx = GradTrap(t,Gx,G_read,t0_read,tramp,t_acq_wait+t_acq);

% Read dephase
Gx = GradTrap(t,Gx,G_readdeph,t0_prespoil,tramp,opts.t_hspoil-2*tramp);

% Transverse spoiler same amp and duration as homospoil
% Applied to both Gx and Gz
Gx = GradTrap(t,Gx,opts.G_hspoil,t0_transpoil,tramp,opts.t_hspoil-2*tramp);
Gz = GradTrap(t,Gz,opts.G_hspoil,t0_transpoil,tramp,opts.t_hspoil-2*tramp);

%--------------------------------------------------------------------
% Diffusion weighting pulses
%--------------------------------------------------------------------

Gd = opts.G_diff * opts.diff_vec;

Gx = GradTrap(t,Gx,Gd(1),t0_gdiff_A,tramp,opts.little_delta-tramp);
Gy = GradTrap(t,Gy,Gd(2),t0_gdiff_A,tramp,opts.little_delta-tramp);
Gz = GradTrap(t,Gz,Gd(3),t0_gdiff_A,tramp,opts.little_delta-tramp);

Gx = GradTrap(t,Gx,Gd(1),t0_gdiff_B,tramp,opts.little_delta-tramp);
Gy = GradTrap(t,Gy,Gd(2),t0_gdiff_B,tramp,opts.little_delta-tramp);
Gz = GradTrap(t,Gz,Gd(3),t0_gdiff_B,tramp,opts.little_delta-tramp);

%--------------------------------------------------------------------
% k-space inversion points
%--------------------------------------------------------------------

kinv = {opts.TE/2};
