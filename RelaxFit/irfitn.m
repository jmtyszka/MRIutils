function [S0, T1, Mask] = irfitn(IR, TI)
% [S0, T1, Mask] = irfitn(IR, TI)
%
% Fit the IR contrast equation:
%
%   IR(TI) = S0 * ((1 - exp(-TI/T1))
%
% to the last dimension of an N-D matrix, SR[]
%
% ARGS:
% IR = N-D matrix with inversion time as final dimension
% TI = Inversion times for each time point
%
% RETURNS:
% S0 = S(TI=Inf) matrix
% T1 = T1 matrix (ms)
% Mask = fit mask used to reduce voxel count
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 09/06/2001 Adapt from srfit.m

% Get dimensions
dims = size(IR);
ndims = length(dims);
nvox = prod(dims(1:(ndims-1)));
nti1 = dims(ndims);
nti2 = length(TI);

% Default returns
S0 = [];
T1 = [];

% Check that enough TI values were provided
if ~isequal(nti1, nti2)
  fprintf('Not enough TI values provided for final dimension of data\n');
  return
else
  nt = nti1;
end

% Reshape and make space for results
IR = reshape(IR, [nvox nt]);
S0 = zeros(nvox,1);
T1 = zeros(nvox,1);

% Create a mask from the image with the greatest TR
[maxTI, tmax] = max(TI(:));
maxIR = IR(:,tmax);
IRthresh = max(maxIR(:)) * 0.25;
Mask = maxIR > IRthresh;

nmask = sum(Mask);

% Fit SR equation to each voxel in turn
hwb = waitbar(0,'');
for v = 1:nvox
  waitbar(v/nvox,hwb,sprintf('Fitting IR equation : %d/%d', v, nvox));
  if Mask(v)
    [S0(v), T1(v), alpha] = irfit(IR(v,:), TI, 1);
  end
end
close(hwb);

% Reshape maps back to Ndims-1
vdims = dims(1:(ndims-1));
S0 = reshape(S0, vdims);
T1 = reshape(T1, vdims);
Mask = reshape(Mask, vdims);

