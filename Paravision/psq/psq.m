function psq(pseq)
% psq(pseq)
%
% Pulse sequence analysis
%
% - 0th (k) and 1st gradient moments
% - b tensor
% - 2D isochromat phantoms with B0 inhomogeneity
% - eddy current convolution
%
% bij(t) = Integral[0,t]{dt' |ki(t')| * |kj(t')|}
%
% ARGS:
% pseq = valid method name:
%        'SpinEcho'
%        'UFLARE'
%        'DW_UFLARE'
%        'DW_STE'
%        'SSFP'
%        'JMT_DDR'
%        'JMT_DR'
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 12/30/2001 JMT From scratch
%          04/07/2004 JMT New pseq argument
%          01/09/2008 JMT Add JMT_DDR and JMT_DR support
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
if nargin < 1 pseq = []; end

% Operation control
dobloch    = 1;          % Perform Bloch simulation
doplot     = 0;
dosavewave = 0;          % Save the waveforms in a MAT file

psq = {'SpinEcho','UFLARE','DW_UFLARE','DW_STE','DW_SE','SSFP','JMT_DDR','JMT_DR'};

if isempty(pseq)

  % Present user with pulse sequence menu
  fprintf('Select a pulse sequence:\n');
  for pc = 1:length(psq)
    fprintf('%d. %s\n', pc, psq{pc});
  end
  psq_choice = input('Enter a sequence number [1] : ');

  if psq_choice < 1 || psq_choice > length(psq)
    fprintf('Invalid selection\n');
    return
  end

  % Pulse sequence choice
  pseq = psq{psq_choice};
  
end

% Initialize waveform vectors
t = [];
B1t = [];
Gx = [];
Gy = [];
Gz = [];
kinv = [];

%---------------------------------------------------
% Generate waveforms
%---------------------------------------------------

fprintf('Generating pulse sequence waveforms\n');
  
switch upper(pseq)
    
  case 'SPINECHO'
    opts = SpinEcho_opts;
    [t,B1t,Gx,Gy,Gz,kinv] = SpinEcho(opts);
    
  case 'UFLARE'
    opts = UFLARE_opts;
    [t,B1t,Gx,Gy,Gz,kinv] = UFLARE(opts);
    
  case 'DW_UFLARE'
    opts = DW_UFLARE_opts;
    [t,B1t,Gx,Gy,Gz,kinv] = DW_UFLARE(opts);
    
  case 'DW_STE'
    opts = DW_STE_opts;
    [t,B1t,Gx,Gy,Gz,kinv] = DW_STE(opts);
    
  case 'DW_SE'
    opts = DW_SE_opts;
    [t,B1t,Gx,Gy,Gz,kinv] = DW_SE(opts);
    
  case 'SSFP'
    opts = SSFP_opts;
    [t,B1t,Gx,Gy,Gz,kinv] = SSFP(opts);
    
  case 'JMT_DDR'
    opts = JMT_DDR_opts;
    [t,B1t,Gx,Gy,Gz,kinv] = JMT_DDR(opts);
            
  case 'JMT_DR'
    opts = JMT_DR_opts;
    [t,B1t,Gx,Gy,Gz,kinv] = JMT_DR(opts);
    
  otherwise
    
    fprintf('Unknown pulse sequence : %s\n', pseq);
    return
    
end

if dosavewave
  
  % Prompt user to save waveform
  [wavename, wavedir] = uiputfile(['*.mat']);
  if isequal(wavename,0) | isequal(wavedir,0)
    fprintf('No waveform data saved - exiting\n');
    return
  end
  
  % Save waveform data
  wavefile = [wavedir filesep wavename];
  fprintf('Saving waveforms in %s\n', wavefile); 
  save(wavefile,'t','B1t','Gx','Gy','Gz','kinv');
  
end

%---------------------------------------------------
% Bloch simulation
%---------------------------------------------------

if dobloch
  
  % Setup isochromats for a phantom
  fprintf('Constructing spherical phantom\n');
  
  % Xenopus embryo: 650um radius, 2mm FOV
  Rs   = 650 * 1e-6;
  FOV  = [2 2 0] * 1e-3;
  Dims = [64 64 1];
  
  [xi,yi,zi,Mxi,Myi,Mzi] = SpherePhantom(Dims,FOV,Rs);
  
  % Run a Bloch simulation using this phantom
  fprintf('Bloch simulation\n');
  [Mx,My,Mz] = bloch(t,complex(real(B1t),imag(B1t)),Gx,Gy,Gz,xi,yi,zi,Mxi,Myi,Mzi);
  
end

%---------------------------------------------------
% Calculate kx(t), ky(t), kz(t) in cycles/m
%---------------------------------------------------

fprintf('Calculating k-space trajectory\n');

% Zero gradient waveforms for t < 0
negi = t < 0;
Gx(negi) = 0;
Gy(negi) = 0;
Gz(negi) = 0;

% First calculate the k trajectory without inversions
dt = t(2) - t(1);
kx = gamma_1H * cumsum(Gx) * dt;
ky = gamma_1H * cumsum(Gy) * dt;
kz = gamma_1H * cumsum(Gz) * dt;

% Locate indices of k inversion points
iinv = round(interp1(t,1:length(t),kinv,'*linear'));
iinv(isnan(iinv)) = [];

% Apply cumulative inversions to k trajectory
% Invert by subtracting 2 * k'(tinv) from all t > tinv
% Repeat for all inversions, replacing k with k' at each iteration

Ninv = length(iinv);
Nsamp = length(kx);

for ks = 1:Ninv
  
  iinv_ks = iinv(ks);
  kinds = iinv_ks:Nsamp;
  
  kx(kinds) = kx(kinds) - 2 * kx(iinv_ks);
  ky(kinds) = ky(kinds) - 2 * ky(iinv_ks);
  kz(kinds) = kz(kinds) - 2 * kz(iinv_ks);
  
end

% Calculate b-matrix at echo location (not necessarily t = TE, eg STE)
fprintf('Calculating b-matrix at echo\n');
b_i = (t >= 0 & t <= opts.echoloc(1));
kxb = kx(b_i);
kyb = ky(b_i);
kzb = kz(b_i);

% Calculate upper triangle of b-matrix
% s/(m^2)
bxx = sum(kxb .* kxb) * dt;
byy = sum(kyb .* kyb) * dt;
bzz = sum(kzb .* kzb) * dt;
bxy = sum(kxb .* kyb) * dt;
bxz = sum(kxb .* kzb) * dt;
byz = sum(kyb .* kzb) * dt;

% Construct the b-matrix and rescale from s/(m^2) to s/(mm^2)
b = [bxx bxy bxz; bxy byy byz; bxz byz bzz] * 1e-6;

fprintf('\nb-matrix (s/(mm^2))\n\n');
disp(b);

fprintf('\nTr(b) = %0.3f s/mm^2\n', trace(b));

%---------------------------------------
% Plot RF, gradient waveforms and k trajectories
%---------------------------------------

if doplot
  psqplotwaveforms(t,B1t,Gx,Gy,Gz,kx,ky,kz);
end

%---------------------------------------
% Draw total magnetization evolution
%---------------------------------------

if dobloch
  
  % Setup phantom and sequence figure
  figure(2); clf; set(gcf,'color','w');
  colormap gray;
  
  [nxi,nyi,nzi] = size(Mzi);
  subplot(121), imagesc(Mzi(:,:,round(nzi/2))); axis equal off;
  title('Phantom cross-section');
  
  subplot(322), plot(t,Mx); title('Mx(t)');
  xlabel('Time (s)');
  set(gca,'YLim',[-1 1]);
  
  subplot(324), plot(t,My); title('My(t)');
  set(gca,'YLim',[-1 1]);
  xlabel('Time (s)');
  
  subplot(326), plot(t,Mz); title('Mz(t)');
  set(gca,'YLim',[-1 1]);
  xlabel('Time (s)');
  
end
