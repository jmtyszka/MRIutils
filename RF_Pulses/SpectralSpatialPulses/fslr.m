function [a, b, B1] = fslr
% Forward SLR transform of a Hamming filtered sinc pulse
% Lets us look at the basic form of a and b for a non-optimal
% pulse shape
%
% JMT 12/10/98
% City of Hope

% 1H gamma in rad/s/T
GAMMA_1H = 2 * pi * 4.2e7;

% Time samples (s)
nt = 64;
PW = 4e-3;
dt = PW/nt;
t = 0.0:dt:(PW-dt);

% x samples points (m)
nx = 128;
FOVx = 2.0e-3;
dx = FOVx/nx;
x = -FOVx/2:dx:(FOVx/2-dx);

% Gradient strength (T)
G = 1.0e-4; % 1G/cm

% Z samples on unit circle
z_1 = exp(-i*GAMMA_1H*G*x*dt);

% 3 lobe Hamming filtered sinc pulse
B1 = hsinc(t, 5e-6);

% Forward SLR transform
a = zeros(nt,1);
b = zeros(nt,1);
sb = zeros(nt,1);
a(1) = 1.0;
b(1) = 0.0;

% Forward SLR transform
for j = 1:nt
   
   phi = GAMMA_1H * abs(B1(j)) * dt / 2.0;
   theta = angle(B1(j));
   
   C = cos(abs(phi));
   S = exp(i * theta) * sin(phi);
   
   % Shift b down one
   sb(1,1) = 0;
   sb(2:nt,1) = b(1:(nt-1),1);
   
   % Calculate new coefficients
   na = C * a - conj(S) * sb;
   nb = S * a + C * sb;
   
   a = na;
   b = nb;
   
end

subplot(1,3,1), plot(1:nt, real(B1), 1:nt, imag(B1)); title('B1(t)');
subplot(1,3,2), plot(1:nt, real(a), 1:nt, imag(a)); title('an,k');
subplot(1,3,3), plot(1:nt, real(b), 1:nt, imag(b)); title('bn,k');