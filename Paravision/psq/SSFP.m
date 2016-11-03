function [t,B1t,Gx,Gy,Gz,kinv] = SSFP(opts)
% [t,B1t,Gx,Gy,Gz,kinv] = SSFP(opts)
%
% Generate waveforms for spin echo sequence
%
% ARGS :
% opts  = UFLARE options structure :
%   .TE    = echo time (s)
%   .t_excite   = excitation pulse duration (s)
%   .t_ramp     = gradient ramp time (s)
%   .t_spoil    = transverse spoiler duration (s)
%   .FOV        = field of view (m)
%   .Nx         = readout samples
%   .ReadBW     = read bandwidth (Hz)
%   .SliceThick = slice thickness (m)
%   .TB         = time-bandwidth product of RF pulses (s Hz)
%   .G_spoil    = transverse spoiler amplitude (T/m)
%   .nTRs       = number of TRs to simulate
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
%          02/25/2002 Add options structure
%          02/27/2002 Change ksgn to kinv
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

fprintf('\n');
fprintf('Steady-state Free Precession\n');
fprintf('----------------------------\n');

% Utility variables
tramp = opts.t_ramp;

%-------------------------------------------------------------
% Estimate total time range of sequence and construct time vector
%-------------------------------------------------------------

dt = 4e-6;
Ttot = opts.TR * opts.nTRs;
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
SliceBW = opts.TB / opts.t_excite;

G_read = opts.ReadBW / (GAMMA_1H * opts.FOV);
G_slice = SliceBW / (GAMMA_1H * opts.SliceThick);
G_pe = 0.5 * opts.Nx / (GAMMA_1H * opts.FOV * (opts.t_spoil + tramp));

M_readdeph = G_read * (tramp + t_acq)/2;
G_readdeph = -M_readdeph / (opts.t_spoil + tramp);

M_slref = G_slice * (opts.t_excite + tramp)/2;
G_slref = -M_slref / (opts.t_slref + tramp);

t0_excite = -opts.t_excite/2 - tramp;
t0_slref = opts.t_excite/2 + tramp;
t0_readdeph = t0_slref;
t0_read = opts.TE - t_acq/2 - tramp;
t0_depe = t0_read + 2 * tramp + t_acq;

%-------------------------------------------------------------
% SSFP early echo pulse sequence
%-------------------------------------------------------------

for tc = 1:opts.nTRs

  t0 = (tc-1) * opts.TR;
  
  % RF Excite pulse
  B1t = RFWave(t,B1t,'hsinc',opts.flip,0.0,t0+t0_excite+tramp,opts.t_excite);

  % Excite slice select gradient
  Gz = GradTrap(t,Gz,G_slice,t0+t0_excite,tramp,opts.t_excite);

  % Slice refocus gradient
  Gz = GradTrap(t,Gz,G_slref,t0+t0_slref,tramp,opts.t_slref);

  % Read gradient
  Gx = GradTrap(t,Gx,G_read,t0+t0_read,tramp,t_acq);

  % Read dephase
  Gx = GradTrap(t,Gx,G_readdeph,t0+t0_readdeph,tramp,opts.t_readdeph);

  % Phase encode (assume square FOV and matrix)
  % phi = gamma * G * x * t
  % Gy = GradTrap(t,Gy,G_pe,t0_postspoil,tramp,opts.t_spoil);
  
  % Dephase encode
  % Gy = GradTrap(t,Gy,-G_pe,t0_depe,tramp,opts.t_spoil);

end

%--------------------------------------------------------------------
% Create vector of time points at which k is inverted by an RF pulse
%--------------------------------------------------------------------

kinv = [];
