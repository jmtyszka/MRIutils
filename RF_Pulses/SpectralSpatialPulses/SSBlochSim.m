function [x,w,mxy] = SSBlochSim(t,Gt,B1t)
% mxy = SSBlochSim(t,Gt,B1t)
% Bloch equation simulation of the gradient and RF waveform
%
% INPUT PARAMETERS:
% t   : Time samples vector
% Gt  : Gradient waveform vector
% B1t : Complex RF waveform
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : City of Hope, Duarte CA
% DATES  : 10/1/98   Convert to quaternion rotations

fprintf('\nInitializing Bloch Simulation\n');

% Temporary default parameters
FOVx = 4.0e-2;      % m
BWw = 2*pi * 2000.0; % rad/s

nx = 32;
nw = 34;
nt = length(t);

% Initialize complex transverse magnetization array
mxy = zeros(nx,nw);

% Gyromagnetic ratio in rad/s/T
GAMMA = 2 * pi * 42e6;

% Initialize location matrix
dx = FOVx / (nx-1);
x = -FOVx/2:dx:FOVx/2;
fprintf('FOV in x is [%f,%f] mm with %d points\n', min(x)*1000, max(x)*1000, length(x));

% Initialize chemical shift matrix (rad/s off resonance)
dw = BWw / (nw-1);
w = -BWw/2:dw:BWw/2;
fprintf('BW in w is [%f,%f] Hz with %d points\n', min(w)/(2*pi), max(w)/(2*pi), length(w));

% Time difference - assume constant throughout
dt = t(2)-t(1);

fprintf('Performing Bloch Simulation for %d points:\n',length(t)-1);

fprintf('Progress : ');
previous = -10;

for xc = 1:nx
   this_x = x(xc);
   
   % Progress indicator
   progress = floor(xc/nx*10);
   if (progress ~= previous)
      fprintf('%d%%-',progress*10);
      previous = progress;
   end

   for wc = 1:nw
      this_w = w(wc);
        
      % Initialize total quaternion to identity matrix
      Q = eye(2);
      
      for tc = 1:nt
         
         % Frequencies due to gradient/chem shift and B1
         wGj = GAMMA*Gt(tc)*this_x + this_w;
         wB1j = GAMMA*B1t(tc);
         
         % Rotation angle and axis for this timestep
         phij = -dt * sqrt(wB1j*conj(wB1j) + wGj*wGj);
         nj = dt / abs(phij) * [real(wB1j) ; imag(wB1j) ; wGj];
         
         % Trig functions of half rotation angle
         sinphij2 = sin(phij/2.0);
         cosphij2 = cos(phij/2.0);
         
         % Cayley-Klein parameters for this timestep
         aj = cosphij2 - i * nj(3) * sinphij2;
         bj = -i * (nj(1) + i * nj(2)) * sinphij2;
         
         % Calculate quaternion matrix
         Qj = [aj -conj(bj) ; bj conj(aj)];
         
         % Transform total quaternion by the quaternion for this timestep
         Q = Qj * Q;
         
      end
      
      % Now apply total quaternion to equilibrium magnetization
      % This can be precalculated in terms of the total Cayley-Klein parameters
      mxy(xc,wc) = 2*Q(2,2)*Q(2,1);
      
   end
end

fprintf('done\n');
