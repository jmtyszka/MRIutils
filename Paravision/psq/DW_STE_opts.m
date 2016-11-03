function opts = DW_STE_opts
% opts = DW_STE_opts
%
% Setup default options for DW-STE
%
% RETURNS :
% B1t,Mxy    = RF transmit waveform
% Gx,Gy,Gz = gradient waveforms
% ksgn     = sign vector for k(t) calculations 
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 02/25/2002 From scratch
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

opts.TE         = 4.9e-3;    % Echo time (s)
opts.TM         = 72.5e-3;   % Mixing time (s)
opts.t_90       = 0.5e-3;    % 90 deg pulse time (s)
opts.t_ramp     = 80e-6;     % Gradient ramp time (s)
opts.FOV        = 2e-3;      % Field of view (m)
opts.Nx         = 32;        % Readout samples
opts.ReadBW     = 40e3;      % Readout bandwidth (Hz)
opts.SliceThick = Inf;       % Slice thickness (m)
opts.TB         = 6;         % Time-bandwidth product of RF pulses (s Hz)

% Diffusion weighting
opts.little_delta = 0.75e-3;         % Little delta - DW pulse width (s)
opts.big_delta    = 75e-3;           % Big delta - DW pulse interval (s)
opts.G_diff       = 0.80;            % Diffusion gradient amplitude (T/m)
opts.diff_vec     = [-0.526 0 0.851]; % Diffusion gradient direction

% Spoilers
opts.t_hspoil   = 0.5e-3;    % Homospoil time (s)
opts.t_tmspoil  = 5.0e-3;    % Homospoil time (s)
opts.G_hspoil   = 0;         % Homospoiler amplitude (T/m) 1T/m = 100G/cm
opts.G_tmspoil  = 0.30;      % TM spoiler amplitude (T/m) 1T/m = 100G/cm

% True echo location
opts.echoloc = opts.TE + opts.TM;

% Verbosity
opts.verbose = 0;
