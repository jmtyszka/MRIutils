function [S0, T1, C, Mask] = srfitn(TR, SR, verbose)
% [S0, T1, C, Mask] = srfitn(TR, SR)
%
% Fit the SR contrast equation:
%
%   SR(TR) = S0 * (1 - exp(-TR/T1)) + C
%
% to the last dimension of an N-D matrix, SR[]
%
% ARGS:
% SR = N-D matrix with repetition time as final dimension
% TR = Repetition times for each dataset (ms)
%
% RETURNS:
% S0 = S(TR=Inf) matrix
% T1 = T1 matrix (ms)
% Mask = fit mask used to reduce voxel count
% verbose = verbosity flag (0 = none, 1 = text only, 2 = text and graphs)
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 09/06/2001 JMT Adapt from srfit.m
%          11/03/2004 JMT Add verbosity arg
%
% The MIT License (MIT)
%
% Copyright (c) 2016 Mike Tyszka
%
%   Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
%   documentation files (the "Software"), to deal in the Software without restriction, including without limitation the
%   rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
%   permit persons to whom the Software is furnished to do so, subject to the following conditions:
%
%   The above copyright notice and this permission notice shall be included in all copies or substantial portions of the
%   Software.
%
%   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
%   WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
%   COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
%   OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

% Default args
if nargin < 3 verbose = 0; end

% Get dimensions
dims = size(SR);
ndims = length(dims);
nvox = prod(dims(1:(ndims-1)));
ntr1 = dims(ndims);
ntr2 = length(TR);

% Default returns
S0 = [];
T1 = [];
C  = [];
Mask = [];

% Check that enough TR values were provided
if ~isequal(ntr1, ntr2)
  fprintf('Not enough TR values provided for final dimension of data\n');
  return
else
  nt = ntr1;
end

% Normalize maximum SR data to 1.0
SR = SR / max(SR(:));

% Reshape and make space for results
SR = reshape(SR, [nvox nt]);
S0 = zeros(nvox,1);
T1 = zeros(nvox,1);
C  = zeros(nvox,1);

% Create a mask from the image with the greatest TR
[maxTR, tmax] = max(TR(:));
maxSR = SR(:,tmax);
SRthresh = max(maxSR(:)) * 0.1;
Mask = maxSR > SRthresh;

nmask = sum(Mask);

% Setup optimization options
options = optimset('lsqcurvefit');
options = optimset(options,...
  'TolFun',1e-6,...
  'TolX',1e-6,...
  'Jacobian','on',...
  'Display','off');
mode = 'unconstrained';

%
% Fit SR equation to each voxel in turn
%

fprintf('\n');
fprintf('-------------------\n');
fprintf('Start curve fitting\n');
fprintf('-------------------\n');
fprintf('\n');

% Start clock
t0 = clock;

% Update interval in voxels
dv = round(nmask / 100);

for v = 1:nvox
  
  if Mask(v)

    %---------------------------------------------------
    % Fit SR T1 relaxation curve for single voxel time-course
    %---------------------------------------------------
    
    SRv = SR(v,:);
    
    [S0(v), T1(v), C(v), s_fit] = srfit(TR,SRv,mode,options);

    % Update waitbar progressand display results
    if (mod(v,dv) == 0)
 
      fp = v/(nvox+eps);
      vps = v/(etime(clock,t0)+eps);
      res_str = sprintf('%5.1f%% done %0.3f vox/s : S0 = %0.3f T1 = %0.3fms C = %0.3f', fp*100,vps,S0(v),T1(v),C(v));
      
      switch verbose
        case 1
          disp(res_str);
        case 2
          figure(1); clf;
          plot(TR, SRv, 'o', TR, s_fit);
          set(gca,'YLim',[0 max(SRv(:)) * 1.1]);
          title(res_str);
          drawnow;
        otherwise
          % Do nothing
      end

    end

  end
end

% Reshape maps back to Ndims-1
vdims = dims(1:(ndims-1));
S0 = reshape(S0, vdims);
T1 = reshape(T1, vdims);
C  = reshape(C, vdims);
Mask = reshape(Mask, vdims);
