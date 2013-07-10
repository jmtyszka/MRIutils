function b_matrix = pvbmatrix(scandir)
% Numerical estimate of actual bmatrix for a DW sequence
%
% SYNTAX: b = pvbmatrix(scandir)
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech
% DATES  : 01/10/2008 JMT From scratch
%
% Copyright 2008 California Institute of Technology.
% All rights reserved.

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




