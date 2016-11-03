function [t,B1t,Gx,Gy,Gz,kinv] = DW_STE(opts)
% [t,B1t,Gx,Gy,Gz,kinv] = DW_STE(opts)
%
% Generate waveforms for diffusion-weighted stimulated echo sequence
%
% ARGS :
% opts  = DWSTE options structure :
%   .TE         = echo time (s)
%   .TM         = mixing time (s)
%   .t_90   = excitation pulse width (s)
%   .t_ramp     = gradient ramp time (s)
%   .t_hspoil   = homospoil duration (s)
%   .t_tmspoil  = homospoil duration (s)
%   .FOV        = FOV (m)
%   .Nx         = readout samples
%   .ReadBW     = readout bandwidth (Hz)
%   .SliceThick = slice thickness (mm)
%   .TB         = time-bandwidth product of RF pulses (s Hz)
%   .G_homo     = homospoiler amplitude (T/m)
%   .G_TM       = TM spoiler amplitude (T/m)
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

% Utility variables
tramp = opts.t_ramp;

%-------------------------------------------------------------
% Estimate total time range of sequence and construct time vector
%-------------------------------------------------------------

% Temporal sampling interval (4us)
dt = 4e-6;
Ttot = 3 * tramp + opts.t_90/2 + opts.TE + opts.TM + opts.t_tmspoil;

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
% Precalculate sequence parameters
%-------------------------------------------------------------

t_acq = opts.Nx / opts.ReadBW; 
SliceBW = opts.TB / opts.t_90;

% Gradients in T/m
gam = GAMMA_1H / (2 * pi);
G_read = opts.ReadBW / (gam * opts.FOV);
G_slice = SliceBW / (gam * opts.SliceThick);
G_readdeph = (G_read * (tramp + t_acq)/2) / (opts.t_hspoil + tramp);
G_pe = 0.5 * opts.Nx / (gam * opts.FOV * (opts.t_hspoil + tramp));

M_slref = G_slice * (opts.t_90 + tramp)/2;

t0_90_1 = -opts.t_90/2 - tramp;
t0_90_2 = t0_90_1 + opts.TE/2;
t0_90_3 = t0_90_2 + opts.TM;
t0_prespoil = t0_90_2 - opts.t_hspoil - tramp;
t0_postspoil = t0_90_3 + tramp + opts.t_90;
t0_read = opts.echoloc - t_acq/2 - tramp;
t0_depe = t0_read + 2 * tramp + t_acq;

t0_gdiff_A = t0_prespoil - opts.little_delta - tramp;
t0_gdiff_B = t0_postspoil + opts.t_hspoil;

% Adjust pre-90_2 homospoil moment for slice refocusing
G_prespoil = (opts.G_hspoil * (opts.t_hspoil + tramp) - M_slref) / (opts.t_hspoil + tramp);

%-------------------------------------------------------------
% Summary
%-------------------------------------------------------------

if opts.verbose

  fprintf('\n');
  fprintf('DW-STE Pulse Sequence\n');
  fprintf('------------------------\n');
  fprintf('TIMINGS:\n');
  fprintf('  TE        : %0.3f ms\n', opts.TE * 1e3);
  fprintf('  TM        : %0.3f ms\n', opts.TM * 1e3);
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

% 90_1 RF pulse
B1t = RFWave(t,B1t,'hsinc',90.0,0.0,t0_90_1+tramp,opts.t_90);

% 90_2 RF pulse
B1t = RFWave(t,B1t,'hsinc',90.0,0.0,t0_90_2+tramp,opts.t_90);

% 90_3 RF pulse
B1t = RFWave(t,B1t,'hsinc',90.0,0.0,t0_90_3+tramp,opts.t_90);

% RF slice select gradient
Gz = GradTrap(t,Gz,G_slice,t0_90_1,tramp,opts.t_90);

% Pre-90_2 homospoil (bridged to refocus slice select)
Gz = GradTrap(t,Gz,G_prespoil,t0_prespoil,tramp,opts.t_hspoil-2*tramp);

% Post-90_3 homospoil (bridged to refocus slice select)
Gz = GradTrap(t,Gz,opts.G_hspoil,t0_postspoil,tramp,opts.t_hspoil-2*tramp);

% Read gradient
Gx = GradTrap(t,Gx,G_read,t0_read,tramp,t_acq);

% Read dephase
Gx = GradTrap(t,Gx,G_readdeph,t0_prespoil,tramp,opts.t_hspoil-2*tramp);

% Phase encode (assume square FOV and matrix)
% phi = gamma * G * x * t
% Gy = GradTrap(t,Gy,G_pe,t0_postspoil,tramp,opts.t_hspoil-2*tramp);

% Dephase encode
% Gy = GradTrap(t,Gy,-G_pe,t0_depe,tramp,opts.t_hspoil-2*tramp);

%--------------------------------------------------------------------
% Diffusion weighting
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

kinv = [opts.TM + opts.TE/2];

