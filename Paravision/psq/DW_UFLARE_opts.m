function opts = UFLARE_opts
% opts = UFLARE_opts
%
% Setup default options for UFLARE
%
%
% RETURNS :
% B1t,Mxy    = RF transmit waveform
% Gx,Gy,Gz = gradient waveforms
% ksgn     = sign vector for k(t) calculations 
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 02/27/2002 From scratch
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

opts.esp          = 4e-3;      % Echo spacing (s)
opts.etl          = 8;         % Echo train length
opts.alpha        = 180.0;     % Refocussing flip angle (degs)
opts.t_excite     = 512e-6;    % Excitation pulse time (s)
opts.t_refocus    = 512e-6;    % Refocussing pulse time (s)
opts.t_ramp       = 100e-6;    % Gradient ramp time (s)
opts.t_unblank    = 25e-6;     % RF unblank time (s)
opts.t_spoil      = 250e-6;    % Homospoil time (s)
opts.t_pgse_spoil = 1e-3;      % PGSE homospoil time (s)
opts.FOV          = 2e-2;      % Field of view (m)
opts.Nx           = 128;       % Readout samples
opts.ReadBW       = 125e3;     % Readout bandwidth (Hz)
opts.SliceThick   = 2e-2;      % Slice thickness (m)
opts.TB           = 6;         % Time-bandwidth product of RF pulses (s Hz)
opts.G_spoil      = 0.25;      % Homospoil gradient amplitude (T/m) 100 G/cm = 1 T/m
opts.littledelta  = 5e-3;      % Small delta (s)
opts.bigdelta     = 10e-3;     % Small delta (s)

opts.G_diff       = [0.30 -0.20 0.0]; % Diffusion gradient vector (T/m)

% Dependent parameters
opts.TE = opts.esp * fix(opts.etl/2);
