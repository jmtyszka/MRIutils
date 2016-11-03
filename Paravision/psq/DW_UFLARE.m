function [t,B1t,Gx,Gy,Gz,kinv] = DW_UFLARE(opts)
% [t,B1t,Gx,Gy,Gz,kinv] = DW_UFLARE(opts)
%
% Generate waveforms for DW_UFLARE sequence with appropriate
% non-MG spoiling.
%
% ARGS :
% opts  = UFLARE options structure :
%   .esp        = echo spacing (s)
%   .etl        = echo train length
%   .alpha      = refocusing flip angle (deg);
%   .t_excite   = RF excitation time (s)
%   .t_ref      = RF refocusing time (s)
%   .t_ramp     = gradient ramp time (s)
%   .t_spoil    = UFLARE homospoil time (s)
%   .t_unblank  = RF unblanking time (s)
%   .FOV        = field of view (m)
%   .Nx         = readout samples
%   .ReadBW     = readout bandwidth (Hz)
%   .SliceThick = slice thickness (m)
%   .TB         = time-bandwidth product of RF pulses (s Hz)
%   .G_spoil    = UFLARE homospoil gradient amplitude (T/m)
%   .smalldelta = small delta (attack start to decay start) (s)
%   .bigdelta   = big delta (1st attach start to 2nd attack start) (s)
%   .G_diff     = diffusion gradient amplitude (T/m)
%
% RETURNS :
% t        = time vector (s)
% B1t      = RF transmit waveform (T)
% Gx,Gy,Gz = gradient waveforms (T)
% kinv     = k inversion time points (s) 
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 02/27/2002 Adapt from UFLARE.m
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

% Pulse sequence parameters

% PGSE timing and gradient parameters
t0_excite   = -opts.t_excite/2 - opts.t_ramp;

% UFLARE timing and gradient parameters
t_acq       = opts.Nx / opts.ReadBW; 
SliceBW     = opts.TB / opts.t_excite;
G_read      = opts.ReadBW / (GAMMA_1H * opts.FOV);
G_readdeph  = (G_read * (opts.t_ramp + t_acq)/2) / (opts.t_spoil + opts.t_ramp);
G_pe        = 0.5 * opts.Nx / (GAMMA_1H * opts.FOV * (opts.t_spoil + opts.t_ramp));
G_slice     = SliceBW / (GAMMA_1H * opts.SliceThick);
G_spoil     = max([opts.G_spoil G_read G_slice]);

% PGSE timings

% Start of rise for first diffusion pulse
t0_Gda = opts.t_excite/2 + opts.t_unblank + 2 * opts.t_ramp + opts.t_pgse_spoil;

% Position of center of PGSE refocusing pulse
t0_pgse_ref0 = t0_Gda + (opts.t_ramp + opts.littledelta)/2 + opts.bigdelta/2;

% Start of PGSE refocusing pulse
t0_pgse_ref =  t0_pgse_ref0 - opts.t_refocus/2;

% Start of rise for PGSE pre-refocus homospoil
t0_pgse_prespoil = t0_pgse_ref - opts.t_unblank - opts.t_pgse_spoil - 2 * opts.t_ramp;

% Start of rise for PGSE post-refocus homospoil
t0_pgse_postspoil = t0_pgse_ref + opts.t_refocus + opts.t_unblank;

% Diffusion gradient timings
t0_prediff = opts.t_excite/2 + 2 * opts.t_ramp + opts.t_spoil;
t0_postdiff = t0_prediff + opts.bigdelta;

% Slice refocusing moment
M_slref = G_slice * (opts.t_excite + opts.t_ramp)/2;
G_slref = -M_slref / (opts.t_spoil + opts.t_ramp);

% Estimate total time range of sequence and construct time vector
dt = 4e-6;
Ttot = opts.bigdelta + opts.esp * (opts.etl + 1);
t = (-Ttot * 0.1):dt:(Ttot * 1.1);

% Initialize return vectors
B1t = zeros(size(t));
Gx = B1t;
Gy = B1t;
Gz = B1t;

%---------------------------------------------------------
% Diffusion PGSE sequence
%---------------------------------------------------------

% RF Excite pulse
B1t = RFWave(t,B1t,'hsinc',90.0,0.0,t0_excite+opts.t_ramp,opts.t_excite);

% Excite slice select gradient
Gz = GradTrap(t,Gz,G_slice,t0_excite,opts.t_ramp,opts.t_excite);

% Excite slice refocus gradient
Gz = GradTrap(t,Gz,G_slref,opts.t_excite/2 + opts.t_ramp,opts.t_ramp,opts.t_spoil);

% PGSE refocus pulse
B1t = RFWave(t,B1t,'hsinc',180.0,90.0,t0_pgse_ref,opts.t_refocus);

% PGSE refocus slice select
Gz = GradTrap(t,Gz,G_slice,t0_pgse_ref-opts.t_unblank-opts.t_ramp,opts.t_ramp,opts.t_refocus + 2*opts.t_unblank);

% PGSE pre-spoilers
Gx = GradTrap(t,Gx,G_spoil,t0_pgse_prespoil,opts.t_ramp,opts.t_pgse_spoil);
Gy = GradTrap(t,Gy,G_spoil,t0_pgse_prespoil,opts.t_ramp,opts.t_pgse_spoil);
Gz = GradTrap(t,Gz,G_spoil,t0_pgse_prespoil,opts.t_ramp,opts.t_pgse_spoil);

% PGSE post_spoil
Gx = GradTrap(t,Gx,G_spoil,t0_pgse_postspoil,opts.t_ramp,opts.t_pgse_spoil);
Gy = GradTrap(t,Gy,G_spoil,t0_pgse_postspoil,opts.t_ramp,opts.t_pgse_spoil);
Gz = GradTrap(t,Gz,G_spoil,t0_pgse_postspoil,opts.t_ramp,opts.t_pgse_spoil);

% PGSE pre diffusion
Gx = GradTrap(t,Gx,opts.G_diff(1),t0_prediff,opts.t_ramp,opts.littledelta-opts.t_ramp);
Gy = GradTrap(t,Gy,opts.G_diff(2),t0_prediff,opts.t_ramp,opts.littledelta-opts.t_ramp);
Gz = GradTrap(t,Gz,opts.G_diff(3),t0_prediff,opts.t_ramp,opts.littledelta-opts.t_ramp);

% PGSE post diffusion
Gx = GradTrap(t,Gx,opts.G_diff(1),t0_postdiff,opts.t_ramp,opts.littledelta-opts.t_ramp);
Gy = GradTrap(t,Gy,opts.G_diff(2),t0_postdiff,opts.t_ramp,opts.littledelta-opts.t_ramp);
Gz = GradTrap(t,Gz,opts.G_diff(3),t0_postdiff,opts.t_ramp,opts.littledelta-opts.t_ramp);

%---------------------------------------------------------
% UFLARE sequence start
%---------------------------------------------------------

% Position of UFLARE start and PGSE echo
t0_ufl = t0_pgse_ref0 * 2;

% Position of rise for UFLARE refocus slice select
t0_ref = t0_ufl + opts.esp/2 - opts.t_refocus/2 - opts.t_ramp;

% Position of rise for pre-refocus homospoil
t0_prespoil = t0_ref - opts.t_spoil - opts.t_ramp;

% Read dephase
Gx = GradTrap(t,Gx,G_readdeph,t0_prespoil,opts.t_ramp,opts.t_spoil);

%---------------------------------------------------------
% Echo loop
%---------------------------------------------------------

for ec = 1:opts.etl
  
  % Calculate timing positions for this echo
  toff = t0_ufl + opts.esp * (ec-1);
  t0_ref = toff + opts.esp/2 - opts.t_refocus/2 - opts.t_ramp;
  t0_postspoil = t0_ref + opts.t_ramp + opts.t_refocus;
  t0_read = toff + opts.esp - t_acq/2 - opts.t_ramp;
  t0_prespoil = t0_ref - opts.t_spoil - opts.t_ramp;

  % RF Refocus pulse
  B1t = RFWave(t,B1t,'hsinc',opts.alpha,90.0,t0_ref + opts.t_ramp,opts.t_refocus);

  % Refocus slice select gradient
  Gz = GradTrap(t,Gz,G_slice,t0_ref,opts.t_ramp,opts.t_refocus);

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

kinv = [t0_pgse_ref0 (t0_ufl + ((1:opts.etl)-0.5) * opts.esp)];
