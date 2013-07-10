function [x, Mfit] = T1Fit(M, TI, ncomps, mag)
% T1 inversion recovery fit for one voxel
%
% [T1, M0] = T1Fit(M, TI, comps, Mag)
%
% M  : contains N magnitude signal samples
% TI : contains the N TIs corresponding to S
% ncomps : number of T1 components to fit
% mag : real data (=0) magnitude data (=1)
%
% Mz(t) = sum_i(M0i(1-E1i) + Mzi(0)E1i)

[nx,nTI] = size(M);

% Initial guesses
M0guess = M(nTI);
T1guess = mean(TI);

% Initial guess array
x0 = (ones(ncomps,1) * [M0guess T1guess])';
x0 = x0(:); % Flatten

% Iteration options
options(1) = -1;   % Full messages
options(7) = 1;    % Safeguarded cubic search
options(14) = 500*length(x0);

% Iterate
[x,options,lambda,hess] = leastsq('T1residual',x0,options,[],TI,M,mag,ncomps);
Mfit = T1func(x,TI,mag,ncomps);

