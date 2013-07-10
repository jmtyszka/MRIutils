function IC = InitIC(M0,N,FOVx,Vx,T1,T2,D)

% Initialize magnetization vector for each isochromat
IC.M = repmat(M0(:),N);

%
x = linspace(-BW/2,FOV/2,N);

% First three rows are magnetization components
% Successive rows are position, diffusion coefficient
V = [M;x;Vx;Dx];

