function [t,B1t,Gx,Gy,Gz,kinv] = SpinEcho(opts)
% [t,B1t,Gx,Gy,Gz,kinv] = SpinEcho(opts)
%
% Generate waveforms for spin echo sequence
%
% ARGS :
% opts  = UFLARE options structure :
%   .TE    = echo time (s)
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
fprintf('Spin Echo Pulse Sequence\n');
fprintf('------------------------\n');

%-------------------------------------------------------------
% Estimate total time range of sequence and construct time vector
%-------------------------------------------------------------

dt = 4e-6;
Ttot = 3 * opts.t_ramp + opts.t_excite/2 + opts.TE + opts.t_spoil;
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

fprintf('Acq Time : %0.3f ms\n', t_acq);
fprintf('Slice BW : %0.1f Hz\n', SliceBW);

G_read = opts.ReadBW / (GAMMA_1H * opts.FOV);
G_slice = SliceBW / (GAMMA_1H * opts.SliceThick);
G_readdeph = (G_read * (opts.t_ramp + t_acq)/2) / (opts.t_spoil + opts.t_ramp);
G_pe = 0.5 * opts.Nx / (GAMMA_1H * opts.FOV * (opts.t_spoil + opts.t_ramp));

M_slref = G_slice * (opts.t_excite + opts.t_ramp)/2;

t0_excite = -opts.t_excite/2 - opts.t_ramp;
t0_ref = opts.TE/2 - opts.t_ref/2 - opts.t_ramp;
t0_prespoil = t0_ref - opts.t_spoil - opts.t_ramp;
t0_postspoil = t0_ref + opts.t_ramp + opts.t_ref;
t0_read = opts.TE - t_acq/2 - opts.t_ramp;
t0_depe = t0_read + 2 * opts.t_ramp + t_acq;

%-------------------------------------------------------------
% Spin Echo pulse sequence
%-------------------------------------------------------------

% RF Excite pulse
B1t = RFWave(t,B1t,'hsinc',90.0,0.0,t0_excite+opts.t_ramp,opts.t_excite);

% RF Refocus pulse
B1t = RFWave(t,B1t,'hsinc',180.0,90.0,t0_ref+opts.t_ramp,opts.t_ref);

% Excite slice select gradient
Gz = GradTrap(t,Gz,G_slice,t0_excite,opts.t_ramp,opts.t_excite);

% Refocus slice select gradient
Gz = GradTrap(t,Gz,G_slice,t0_ref,opts.t_ramp,opts.t_ref);

% Adjust pre-180 homospoil moment for slice refocusing
G_prespoil = (opts.G_spoil * (opts.t_spoil + opts.t_ramp) - M_slref) / (opts.t_spoil + opts.t_ramp);

% Pre-180 homospoil (bridged to refocus slice select)
Gz = GradTrap(t,Gz,G_prespoil,t0_prespoil,opts.t_ramp,opts.t_spoil);

% Post-180 homospoil (bridged to refocus slice select)
Gz = GradTrap(t,Gz,opts.G_spoil,t0_postspoil,opts.t_ramp,opts.t_spoil);

% Read gradient
Gx = GradTrap(t,Gx,G_read,t0_read,opts.t_ramp,t_acq);

% Read dephase
Gx = GradTrap(t,Gx,G_readdeph,t0_prespoil,opts.t_ramp,opts.t_spoil);

% Phase encode (assume square FOV and matrix)
% phi = gamma * G * x * t
% Gy = GradTrap(t,Gy,G_pe,t0_postspoil,opts.t_ramp,opts.t_spoil);

% Dephase encode
% Gy = GradTrap(t,Gy,-G_pe,t0_depe,opts.t_ramp,opts.t_spoil);

%--------------------------------------------------------------------
% Create vector of time points at which k is inverted by an RF pulse
%--------------------------------------------------------------------

kinv = opts.TE/2;
