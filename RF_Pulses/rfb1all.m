function rfb1all

% Minimum phase PI/2 pulse (6ms, 4kHz, 1.0/0.2% pass/stop ripples)
rfname = 'MN_P2_8m_3k_10_02';
flipangle = 90;  % degrees
duration = 6e-3; % seconds

% Bloch simulate the B1 sensitivity
rfb1(rfname, flipangle, duration);

% Work up the results
rfb1res(rfname);