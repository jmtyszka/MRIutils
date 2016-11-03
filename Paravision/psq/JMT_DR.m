function [t,B1t,Gx,Gy,Gz,kinv] = JMT_DR(opts)
% [t,B1t,Gx,Gy,Gz,kinv] = JMT_DR(opts)
%
% Generate waveforms for double-echo prep DWRARE sequence.
% Currently ignores RARE b-matrix - calculates double echo prep
% b-matrix only.
%
% *** Current support for single echo DW only (JMT 2/18/2008)
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
%   .delta1     = delta1 (s)
%   .delta2     = delta2 (s)
%   .delta3     = delta3 (s)
%   .delta4     = delta4 (s)
%   .G_diff1    = dependent diffusion gradient amp (T/m)
%   .G_diff4    = reference diffusion gradient amp (T/m)
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
% DATES  : 01/08/2008 JMT Adapt from DW_SE.m
%          06/20/2008 JMT Fix dependent diff gradient bug
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
% Precalculate sequence parameters
%-------------------------------------------------------------

t_acq = opts.Nx / opts.ReadBW; 
SliceBW = opts.TB / opts.t_90;

%-------------------------------------------------------------
% Calculate read gradient time before echo
%-------------------------------------------------------------

t_acq_wait = opts.t_hspoil - tramp;

%-------------------------------------------------------------
% Estimate total time range of sequence and construct time vector
%-------------------------------------------------------------

% Temporal sampling interval (4us)
dt = 4e-6;

% Update
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

%-------------------------------------------------------------
% Gradients in T/m
%-------------------------------------------------------------

gam = GAMMA_1H / (2 * pi);
G_read = opts.ReadBW / (gam * opts.FOV);
G_slice = SliceBW / (gam * opts.SliceThick);
G_readdeph = (G_read * (tramp/2 + t_acq_wait + t_acq * opts.echopos/100)) / (opts.t_hspoil - tramp);

M_slref = G_slice * (opts.t_90 + tramp)/2;

%-------------------------------------------------------------
% Timing parameters in seconds
%-------------------------------------------------------------

% RF padding delay
t_rfpad = opts.rfpad;

% Refocus group duration (t_hspoil is for full trapezoid)
t_refgroup = opts.t_180 + (opts.t_hspoil + t_rfpad) * 2;

% Calculate single echo preparation TE
t_TE_DW =   opts.t_90/2 + tramp + ...
  opts.delta1 + tramp + t_refgroup + opts.delta4 + tramp + ...
  tramp + t_acq_wait + (t_acq * opts.echopos/100);

% RF Pulse waveform start points
% t = 0 at midpoint of 90
t0_90 = -opts.t_90/2;
t0_180_1 = t_TE_DW * 0.5 - opts.t_180/2;

t0_prespoil_1 = t0_180_1 - t_rfpad - opts.t_hspoil;
t0_postspoil_1 = t0_180_1 + opts.t_180 + t_rfpad;

t0_read = opts.echoloc - (t_acq * opts.echopos/100) - t_acq_wait - tramp;

% Note: diffusion pulses are NOT bridged to homospoil pulses
t0_gdiff_1 = opts.t_90/2 + tramp;
t0_gdiff_4 = t0_gdiff_1 + opts.delta1 + tramp + t_refgroup;

% Adjust pre-180 homospoil moment for slice refocusing
G_prespoil = (opts.G_hspoil * (opts.t_hspoil - tramp) - M_slref) / (opts.t_hspoil - tramp);

%-------------------------------------------------------------
% Summary
%-------------------------------------------------------------

if opts.verbose

  fprintf('\n');
  fprintf('JMT_DR Pulse Sequence\n');
  fprintf('----------------------\n');
  fprintf('TIMINGS:\n');
  fprintf('  TE_DW (seq) : %0.3f ms\n', opts.TE * 1e3);
  fprintf('  TE_DW (sim) : %0.3f ms\n', t_TE_DW * 1e3);
  fprintf('  Acq Time    : %0.3f ms\n', t_acq * 1e3);
  fprintf('  Read BW     : %0.1f kHz\n', opts.ReadBW / 1e3);
  fprintf('  Slice BW    : %0.1f kHz\n', SliceBW / 1e3);
  fprintf('GRADIENTS:\n');
  fprintf('  Read        : %0.3f G/cm\n', G_read * 100);
  fprintf('  Read Deph   : %0.3f G/cm\n', G_readdeph * 100);
  fprintf('\n');
  
end

%-------------------------------------------------------------
% Diffusion-weighted stimulated echo pulse sequence
%-------------------------------------------------------------

% 90 excitation RF pulse
B1t = RFWave(t,B1t,opts.RFwave,90.0,0.0,t0_90,opts.t_90);

% First 180 refocus RF pulse
B1t = RFWave(t,B1t,opts.RFwave,180.0,0.0,t0_180_1,opts.t_180);

% Excite slice select gradient
Gz = GradTrap(t,Gz,G_slice,t0_90-tramp,tramp,opts.t_90);

% Pre-180 homospoil 1 (bridged to refocus slice select)
Gz = GradTrap(t,Gz,G_prespoil,t0_prespoil_1,tramp,opts.t_hspoil-2*tramp);

% Post-180 homospoil 1 (bridged to refocus slice select)
Gz = GradTrap(t,Gz,opts.G_hspoil,t0_postspoil_1,tramp,opts.t_hspoil-2*tramp);

% Read gradient
Gx = GradTrap(t,Gx,G_read,t0_read,tramp,t_acq_wait+t_acq+t_acq_wait);

% Read dephase
% Single echo: +ve before 1st 180
% Double echo: -ve after 2nd 180
Gx = GradTrap(t,Gx,G_readdeph,t0_prespoil_1,tramp,opts.t_hspoil-2*tramp);

%--------------------------------------------------------------------
% Diffusion weighting pulses
%--------------------------------------------------------------------

Gd4 = opts.G_diff * opts.diff_vec;
Gd1 = Gd4 * opts.delta4 / opts.delta1;

Gx = GradTrap(t,Gx,Gd1(1),t0_gdiff_1,tramp,opts.delta1-tramp);
Gy = GradTrap(t,Gy,Gd1(2),t0_gdiff_1,tramp,opts.delta1-tramp);
Gz = GradTrap(t,Gz,Gd1(3),t0_gdiff_1,tramp,opts.delta1-tramp);

Gx = GradTrap(t,Gx,Gd4(1),t0_gdiff_4,tramp,opts.delta4-tramp);
Gy = GradTrap(t,Gy,Gd4(2),t0_gdiff_4,tramp,opts.delta4-tramp);
Gz = GradTrap(t,Gz,Gd4(3),t0_gdiff_4,tramp,opts.delta4-tramp);

%--------------------------------------------------------------------
% k-space inversion points
%--------------------------------------------------------------------

% Create single cell for compatibility with other psq functions
kinv = {0.5 * t_TE_DW};
