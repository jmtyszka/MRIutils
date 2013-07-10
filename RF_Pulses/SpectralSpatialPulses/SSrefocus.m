function tiso = SSrefocus(x, f, mx, my, mz)
% Calculate refocusing moments and isodelay for the SS rf pulse

nx = length(x);
nf = length(f);

df = (max(f) - min(f)) / nf; % In Hz
dx = (max(x) - min(x)) / nx; % In mm

% Extract dTheta/df
hf = nf/2;
hx = nx/2;
theta_0 = angle(mx(hf,hx) + i * my(hf,hx));
theta_df = angle(mx(hf+1,hx) + i * my(hf+1,hx));
theta_dx = angle(mx(hf,hx+1) + i * my(hf,hx+1));

tiso = (theta_df - theta_0)/(2*pi*df)*1e6; % us

fprintf('Isodelay is %g us\n', tiso);

% Extract dTheta/dx