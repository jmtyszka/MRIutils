function [S0, T2, Mask] = logfitn(TE, S, verbose)
% [S0, T2, Mask] = t2fitn(TE, S, verbose)
%
% Fit the T2 contrast equation in log-linear space:
%
%   log(S(TE)) = S0 - TE/T2
%
% to the last dimension of an N-D matrix, S[]
%
% ARGS:
% TE = echo time vector for the final dimension (ms)
% S  = N-D matrix with echo time as final dimension
%
% RETURNS:
% S0 = S(TE=0) matrix
% T2 = T2 matrix in ms
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 04/06/2004 JMT Adapt from t2fitn.m (JMT)
%
% Copyright 2002-2004 California Institute of Technology
% All rights reserved.

% Default args
if nargin < 3 verbose = 0; end

% Get dimensions
dims = size(S);
ndims = length(dims);
nvox = prod(dims(1:(ndims-1)));
nte1 = dims(ndims);
nte2 = length(TE);

% Default returns
S0 = [];
T2 = [];
Mask = [];

% Check that enough TE values were provided
if ~isequal(nte1, nte2)
  fprintf('TE values do not match final dimension of data\n');
  return
else
  nte = nte1;
end

% Reshape and take log of S(TE)
S  = reshape(S, [nvox nte]);
logS = log(S);

S0 = zeros(nvox,1);
T2 = zeros(nvox,1);

% Create a 10% mask from the mean image
mS = mean(S,2);
Mask = mS > max(mS(:)) * 0.1;

nmask = sum(Mask);

hwb = waitbar(0,'');

for v = 1:nvox

  f = v/nvox;
  waitbar(f,hwb,sprintf('Fitting voxel %d of %d - %0.0f%% complete',v,nvox,f*100));
    
  if Mask(v)
    
    p = polyfit(TE,logS(v,:),1);
    S_fit = polyval(p, TE);
    T2(v) = -1/p(1);
    S0(v) = p(2);
    
    if verbose
      figure(10); clf;
      plot(TE,log(S(v,:)),'o',TE,S_fit);
      title(sprintf('T_2 = %0.3f\n', T2(v)));
      drawnow;
    end
    
  end
  
end

close(hwb);

% Reshape maps back to Ndims-1
vdims = dims(1:(ndims-1));
S0 = reshape(S0, vdims);
T2 = reshape(T2, vdims);
Mask = reshape(Mask, vdims);
