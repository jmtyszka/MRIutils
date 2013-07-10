function shexp
% shexp
%
% Spherical harmonic experiments
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 01/07/2002 From scratch

% Angular quantum number
L = 5;

dec_v = 0:(pi/60):pi;     % Elevation range
azi_v = 0:(pi/60):(2*pi); % Azimuth range

% Get an Associated Legendre Polynomial (L = 1, M = 0,1)
P1m = legendre(L,cos(dec_v));

% Plot each component
figure(1); clf
subplot(121), polar(dec_v, real(P1m(1,:))); title('P10(cos(dec))');
subplot(122), polar(dec_v, real(P1m(2,:))); title('P11(cos(dec))');

% Construct surface of rotation of ALP in elevation
[azi,dec] = meshgrid(azi_v,dec_v);
P1m = legendre(L,cos(dec));

Ylm = zeros([2 size(dec)]);
for m = 0:1
  Y1m(m+1,:,:) = abs(squeeze(P1m(m+1,:,:))) .* abs(cos(m * azi));
end

% Extract Y10 and Y11
Y10 = squeeze(Y1m(1,:,:));
Y11 = squeeze(Y1m(2,:,:));

% Convert to cartesian coordinates
[x10,y10,z10] = sph2cart(azi,pi/2-dec,Y10);
[x11,y11,z11] = sph2cart(azi,pi/2-dec,Y11);

figure(2); clf; set(gcf,'color','w');

colormap(gray)

subplot(121), surfl(x10,y10,z10);
axis equal vis3d off
shading interp;
lighting phong
camlight('headlight');

subplot(122), surfl(x11,y11,z11);
axis equal vis3d off
shading interp
lighting phong
camlight('headlight');
