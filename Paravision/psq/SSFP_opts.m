function opts = SSFP_opts
% opts = SSFP_opts
%
% Setup default options for early-echo SSFP
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

opts.TE         = 1.5e-3;    % Echo time (s)
opts.t_excite   = 0.5e-3;    % excitation pulse time (s)
opts.t_ramp     = 80e-6;     % Gradient ramp time (s)
opts.FOV        = 20e-3;     % Field of view (m)
opts.Nx         = 128;       % Readout samples
opts.ReadBW     = 100e3;     % Readout bandwidth (Hz)
opts.SliceThick = 1e-3;      % Slice thickness (m)
opts.TB         = 6;         % Time-bandwidth product of RF pulses (s Hz)
opts.flip       = 20;        % Flip angle (degrees)
opts.TR         = 50e-3;     % Repetition time (s)
opts.nTRs       = 10;        % Number of TRs to simulate

opts.t_slref    = 0.5e-3;
opts.t_readdeph = opts.t_slref;

% Spoilers
opts.t_spoil    = 1.0e-3;    % Homospoil time (s)
opts.G_spoil    = 0.30;      % TM spoiler amplitude (T/m) 1T/m = 100G/cm

% True echo location
opts.echoloc = opts.TE;

% Verbosity
opts.verbose = 0;
