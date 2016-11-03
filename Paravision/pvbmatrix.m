function b_matrix = pvbmatrix(scandir)
% Numerical estimate of actual bmatrix for a DW sequence
%
% SYNTAX: b = pvbmatrix(scandir)
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech
% DATES  : 01/10/2008 JMT From scratch
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

if nargin < 1; scandir = pwd; end

if ~exist(scandir,'dir')
  fprintf('Could not find %s\n', scandir);
  return
end

info = parxloadinfo(scandir);

% Create options structure from sequence details
psqoptions = psqmkopts(scandir);

% Generate waveforms
switch upper(info.method)
  case {'BIC_DWSE','JMT_DWSE'}
    [t,B1t,Gx,Gy,Gz,kinv] = DW_SE(psqoptions);
  case 'JMT_DDR'
    [t,B1t,Gx,Gy,Gz,kinv] = JMT_DDR(psqoptions);
  case 'JMT_DR'
    [t,B1t,Gx,Gy,Gz,kinv] = JMT_DR(psqoptions);
end

% Calculate b-matrix in s/mm^2
[b_matrix,kx,ky,kz] = psqbmatrix(t,Gx,Gy,Gz,kinv,psqoptions.echoloc);

% Total b-value is the trace of the b-matrix
bval_sim = trace(b_matrix);

fprintf('Simulated b-value : %0.3f s/mm^2\n', bval_sim);

% Plot waveforms
psqplotwaveforms(t,B1t,Gx,Gy,Gz,kx,ky,kz);




