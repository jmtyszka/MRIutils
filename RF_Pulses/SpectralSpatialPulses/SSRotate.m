function newm = SSRotate(m, alpha, axis)

% Transfrom axis to spherical coordinates
[th,phi,r] = cart2sph(axis(1), axis(2), axis(3));

% Rotate world so that axis lies along x axis
cth = cos(th); sth = sin(th);
cphi = cos(phi); sphi = sin(phi);

% Theta is the counter-clockwise angle about z from the x axis
IRtheta = [cth sth 0; -sth cth 0; 0 0 1];

% Phi is the elevation angle about y now that we've undone theta
IRphi = [cphi 0 sphi; 0 1 0; -sphi 0 cphi];

% Rotate world so that axis lies along positive x
IR = IRphi * IRtheta;
m = IR * m;

% Now rotate by alpha about the x axis
ca = cos(alpha); sa = sin(alpha);
Ra = [1 0 0; 0 ca -sa; 0 sa ca];

m = Ra * m;

% Reverse spherical rotations
newm = inv(IR) * m;