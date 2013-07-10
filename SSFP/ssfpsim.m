function ssfpsim
% ssfpsim
%
% Bloch simulation of SSFP sequences
%
% ARGS :
% mode  = sequence type ('FISP', 'PSIF', 'TrueFISP') ['TrueFISP']
% T1    = sample T1 in ms [500]
% T2    = sample T2 in ms [10]
% TR    = repetition time in ms [10]
% Alpha = RF flip angle in degrees [20]
% Phi   = phase program in degrees [0]
%
% RETURNS :
% Mx,My,Mz = M+ components (ie immediately after RF pulse) for phase
%            accumulations running from -180 to 180 degrees. Each
%            components is a matrix Nfreq x nTR
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 08/05/2005 JMT From scratch
%
% Copyright 2005 California Institute of Technology.
% All rights reserved.

% Default args
if nargin < 1 mode = 'TrueFISP'; end
if nargin < 2 T1 = 100; end
if nargin < 3 T2 = 100; end
if nargin < 4 TR = 5; end
if nargin < 5 Alpha = 5; end
if nargin < 6 Phi = [0 90]; end

nTR = round(5 * T1 / TR);
nFreq = 256;

fprintf('T1          : %0.1f ms\n', T1);
fprintf('T2          : %0.1f ms\n', T2);
fprintf('TR          : %0.1f ms\n', TR);
fprintf('Alpha       : %0.1f deg\n', Alpha);
fprintf('Isochromats : %d\n', nFreq);
fprintf('TRs         : %d\n', nTR);

% Convert angles to radians
Alpha = Alpha * pi / 180;
Phi = Phi * pi / 180;

% RF flip about x axis
sina = sin(Alpha);
cosa = cos(Alpha);
Rx = [1 0 0; 0 cosa -sina; 0 sina cosa];

% Phase program
nPhi = length(Phi);
nPhi_reps = ceil(nTR / nPhi);
Phi_t = repmat(Phi,[1, nPhi_reps]);
cosPh_t = cos(Phi_t);
sinPh_t = sin(Phi_t);

% Relaxation matrices
E1 = exp(-TR/T1);
E2 = exp(-TR/T2);
E12 = [E2 0 0; 0 E2 0; 0 0 E1];
EMz = repmat([0 0 1-E1]',[1 nFreq]);

% Initialize isochromats
M = repmat([0 0 1]',[1 nFreq]);
Theta = linspace(-3*pi,3*pi,nFreq);
Theta_deg = Theta * 180 /pi;
cosTh_f = cos(Theta);
sinTh_f = sin(Theta);

% Setup M+ and M- arrays
Mxplus = zeros(nTR,nFreq);
Myplus = zeros(nTR,nFreq);
Mzplus = zeros(nTR,nFreq);
Mxminus = zeros(nTR,nFreq);
Myminus = zeros(nTR,nFreq);
Mzminus = zeros(nTR,nFreq);

%----------------------------------------------
% TR Loop
%----------------------------------------------

for tc = 1:nTR
  
  % RF pulse phase relative to x' axis
  % Create forward and backward phasing rotations about z
  Pz_plus = [cosPh_t(tc) -sinPh_t(tc) 0; sinPh_t(tc) cosPh_t(tc) 0; 0 0 1];
  
  % Phased RF Pulse to all isochromats
  % Pz_plus \ M = inv(Pz_plus) * M
  M = Pz_plus * Rx * (Pz_plus \ M);

  % Save M+
  Mxplus(tc,:) = M(1,:);
  Myplus(tc,:) = M(2,:);
  Mzplus(tc,:) = M(3,:);
  
  % Free precession between TRs
  for fc = 1:nFreq
    
    Rz = [cosTh_f(fc) -sinTh_f(fc) 0; sinTh_f(fc) cosTh_f(fc) 0; 0 0 1];
    M(:,ic) = Rz * M(:,ic);
    
  end
  
  % T1 and T2 Relaxation
  % M = E12 * M + EMz;

  % Save M-
  Mxminus(tc,:) = M(1,:);
  Myminus(tc,:) = M(2,:);
  Mzminus(tc,:) = M(3,:);
  
end

Myss = Myplus(nTR,:);
Mxss = Mxplus(nTR,:);

% Draw evolution figures
figure(1); clf;
plot(Theta_deg, Mxss, Theta_deg, Myss);
legend('Mx SS','My SS');
