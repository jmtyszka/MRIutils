function PhantomSolutions(T1, T2, Gd)
% Report concentrations of Gd-DTPA required for given T1, T2
%
% ARGS:
% T1 = vector of T1 values in ms
% T2 = vector of T2 values in ms
% Gd = vector of Gd-DTPA concentrations in mM (optional)
%
% AUTHOR : Mike Tyszka
% PLACE  : Caltech
% DATES  : 2016-02-03 JMT From scratch
%
% Copyright 2016 California Institute of Technology

if nargin < 1; T1 = []; end
if nargin < 2; T2 = []; end
if nargin < 3; Gd = []; end

% Relaxivities of Gd-DTPA @ 3T, 37C in /s/mM
r1 = 3.1;
r2 = 3.7;

% Relaxation rates for water @ 3T, 37C in /s
R1w = 0.2;
R2w = 0.32;

% Gd concentrations for a given T1
if ~isempty(T1)
  Gd_T1 = (1./T1 - R1w) / r1;
else
  Gd_T1 = [];
end

if ~isempty(T2)
  Gd_T2 = (1./T2 - R2w) / r2;
else
  Gd_T2 = [];
end

% Relaxation times for given Gd concentration
if ~isempty(Gd)
  T1_Gd = 1./(R1w + r1 * Gd);
  T2_Gd = 1./(R2w + r2 * Gd);
else
  T1_Gd = [];
  T2_Gd = [];
end

%% Results tables
if ~isempty(Gd_T1)
  
end