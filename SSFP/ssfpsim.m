function ssfpsim
% ssfpsim
%
% Bloch simulation of bSSFP sequences
%
% ARGS :
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

% Default args
if nargin < 1; T1 = 1400; end
if nargin < 2; T2 = 120; end
if nargin < 3; TR = 5; end
if nargin < 4; Alpha_deg = 60; end
if nargin < 5; Phi_deg = [0 90]; end

nTR = round(5 * T1 / TR);
nFreq = 256;

fprintf('T1          : %0.1f ms\n', T1);
fprintf('T2          : %0.1f ms\n', T2);
fprintf('TR          : %0.1f ms\n', TR);
fprintf('Alpha       : %0.1f deg\n', Alpha_deg);
fprintf('Isochromats : %d\n', nFreq);
fprintf('TRs         : %d\n', nTR);

% Convert angles to radians
Alpha_rad = Alpha_deg * pi / 180;
Phi_rad = Phi_deg * pi / 180;

% RF flip about x' axis
sina = sin(Alpha_rad);
cosa = cos(Alpha_rad);
RF_Flip = [1 0 0; 0 cosa -sina; 0 sina cosa];

% Phase program
nPhi = length(Phi_rad);
nPhi_reps = ceil(nTR / nPhi);
Phi_t = repmat(Phi_rad,[1, nPhi_reps]);
cosPh_t = cos(Phi_t);
sinPh_t = sin(Phi_t);

% Relaxation matrices
E1 = exp(-TR/T1);
E2 = exp(-TR/T2);
E12 = [E2 0 0; 0 E2 0; 0 0 E1];
EMz = repmat([0 0 1-E1]',[1 nFreq]);

% Initialize isochromats
M = repmat([0 0 1]',[1 nFreq]);
Theta_rad = linspace(-pi,pi,nFreq);
Theta_deg = Theta_rad * 180 /pi;
cosTh_f = cos(Theta_rad);
sinTh_f = sin(Theta_rad);

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
  
 
  % RF Pulse to all isochromats
  M = RF_Flip * M;

  % Save M+
  Mxplus(tc,:) = M(1,:);
  Myplus(tc,:) = M(2,:);
  Mzplus(tc,:) = M(3,:);
  
  % Free precession between TRs
  for fc = 1:nFreq
    
    Rz = [cosTh_f(fc) -sinTh_f(fc) 0; sinTh_f(fc) cosTh_f(fc) 0; 0 0 1];
    M(:,fc) = Rz * M(:,fc);
    
  end
  
  % T1 and T2 Relaxation
  M = E12 * M + EMz;

  % Save M-
  Mxminus(tc,:) = M(1,:);
  Myminus(tc,:) = M(2,:);
  Mzminus(tc,:) = M(3,:);
  
end

Myss = Myplus(nTR,:);
Mxss = Mxplus(nTR,:);
Mzss = Mzplus(nTR,:);

% Draw evolution figures
figure(1); clf;
plot(Theta_deg, Mxss, Theta_deg, Myss, Theta_deg, Mzss);
legend('Mx SS','My SS');
