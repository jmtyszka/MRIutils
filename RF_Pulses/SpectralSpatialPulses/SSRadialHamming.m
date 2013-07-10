function hamming = SSRadialHamming(a)

[nx,ny] = size(a);

dx = 2.0/nx;
dy = 2.0/ny;

[x,y] = meshgrid(-1.0:dx:(1.0-dx),-1.0:dy:(1.0-dy));

% Radius in space of a normalized to coordinates in range [-1.0,1.0]
r = abs(x + i*y);

% Set values outside unit radius to zero
w = (r <= 1.0);

hamming = (0.54 + 0.46 * cos(pi * r)) .* w;

hamming = hamming';