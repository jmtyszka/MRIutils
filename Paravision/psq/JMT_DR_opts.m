function opts = JMT_DR_opts(scandir)
% opts = JMT_DR_opts
%
% Setup default options for JMT_DDR
%
% RETURNS :
% opts = opts structure for this sequence
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 02/18/2008 JMT Adapt from JMT_DDR_opts.m
%          06/27/2008 JMT Extract opts code from psqmkopts.m
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

% Read sequence information
info = parxloadinfo(scandir);

% Fill opts structure
opts.TE         = info.TE_DW/1000;         % Single echo time for DW prep (s)
opts.t_90       = info.excpulse.pw/1000;   % 90 deg pulse time (s)
opts.t_180      = info.refpulse.pw/1000;   % 180 deg pulse time (s)
opts.t_ramp     = info.t_ramp / 1000;      % Gradient ramp time (s)
opts.FOV        = info.fov(1) / 1000;      % Field of view (m)
opts.Nx         = info.sampdim(1);         % Readout samples
opts.ReadBW     = info.bw;                 % Readout bandwidth (Hz)
opts.SliceThick = Inf;                     % Slice thickness (m)
opts.TB         = info.excpulse.tb / 1000; % Time-bandwidth product of RF pulses (s Hz)
opts.rfpad      = info.delays(4);          % RF padding delay (s)

% RF waveform
switch info.excpulse.shape
  case {'<bp32.exc>','<bp.exc>'}
    opts.RFwave     = 'rect';
  case {'<hermite.exc>'}
    opts.RFwave = 'hsinc';
  otherwise
    opts.RFwave = 'hsinc';
end

% Diffusion weighting
opts.delta1 = info.delta1 / 1000; % delta1 - DW pulse width (s)
opts.delta4 = info.delta4 / 1000; % delta4 - DW pulse width (s)
opts.G_diff = info.Gdiff / 100;   % Diffusion gradient amplitude (T/m)
opts.diff_vec = info.diffdir;     % Diffusion gradient direction

% Spoilers
opts.t_hspoil   = info.t_hspoil / 1000;                % Full homospoiler time (s)
opts.G_hspoil   = info.G_hspoil * info.maxgrad * 1e-4; % Homospoiler amplitude (T/m) 1T/m = 100G/cm

% True echo time and percent position within acquire window
opts.echoloc = opts.TE;
opts.echopos = info.echopos;

% Verbosity
opts.verbose = 1;
