function [M0, T2, C, Mask] = t2fitn(TE, S, verbose, M0_0, T2_0, C_0)
% [M0, T2, C, Mask] = t2fitn(TE, S, verbose, M0_0, T2_0, C_0)
%
% Fit the T2 contrast equation:
%
%   S(TE) = M0 * exp(-TE/T2) + C
%
% to the last dimension of an N-D matrix, S[]
%
% ARGS:
% TE = echo time vector for the final dimension (ms)
% S  = N-D matrix with echo time as final dimension
% verbose = 0 (none), 1 (text), 2 (graph)
%
% RETURNS:
% M0 = S(TE=0) matrix
% T2 = T2 matrix in ms
% C  = baseline offset
% Mask = fit mask used for calculation
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 09/06/2001 JMT Adapt from srfit.m
%          01/26/2004 JMT Update with mask
%          09/19/2005 JMT Add initial value args
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
if nargin < 4 M0_0 = []; end
if nargin < 5 T2_0 = []; end
if nargin < 6 C_0 = []; end

% Get dimensions
dims = size(S);
ndims = length(dims);
nvox = prod(dims(1:(ndims-1)));
nte1 = dims(ndims);
nte2 = length(TE);

% Default returns
M0 = [];
T2 = [];
C  = [];
Mask = [];

% Check that enough TE values were provided
if ~isequal(nte1, nte2)
  fprintf('TE values do not match final dimension of data\n');
  return
else
  nte = nte1;
end

% Normalize maximum data to 1.0
sf = max(S(:));
S = S / sf;

% Reshape and make space for results
S  = reshape(S, [nvox nte]);
M0 = zeros(nvox,1);
T2 = zeros(nvox,1);
C  = zeros(nvox,1);

% Flatten initial guesses
M0_0 = M0_0(:);
T2_0 = T2_0(:);
C_0 = C_0(:);

% Create a mask from the image with the shortest TE
[minTE, tmin] = min(TE(:));
maxS = S(:,tmin);
Sthresh = max(maxS(:)) * 0.1;
Mask = maxS > Sthresh;

nmask = sum(Mask);

% Optimization options
mode = 'unconstrained';
options = optimset('lsqcurvefit');
options = optimset(options,...
  'TolFun',1e-4,...
  'TolX',1e-4,...
  'Jacobian','on',...
  'Largescale','off',...
  'Display','off');

% Update interval in voxels
dv = round(nmask / 100);

% Mask voxel counter
count = 0;

% Start stopwatch for VPS
t0 = clock;

for v = 1:nvox

  if Mask(v)
    
    % Update mask voxel counter
    count = count + 1;
    
    %---------------------------------------------------
    % Fit T2 relaxation curve for single voxel time-course
    %---------------------------------------------------

    % Extract current voxel echo train
    Sv = S(v,:);
    
    % Setup initial estimates if available
    if isempty(M0_0)
      M0_0v = [];
    else
      M0_0v = M0_0(v);
    end
    if isempty(T2_0)
      T2_0v = [];
    else
      T2_0v = T2_0(v);
    end
    if isempty(C_0)
      C_0v = [];
    else
      C_0v = C_0(v);
    end

    % Call T2 fit function
    [M0(v), T2(v), C(v), S_fit] = t2fit(TE,Sv,mode,options,M0_0v,T2_0v,C_0v);

    % Update waitbar progress
    if (mod(v,dv) == 0)
        
      fp = count/(nmask+eps);
      vps = v/(etime(clock,t0)+eps);
      res_str = sprintf('%5.1f%% done %0.3f vox/s : M0 = %0.3f T2 = %0.3fms C = %0.3f', fp*100,vps,M0(v),T2(v),C(v));
      
      switch verbose
        case 1
          disp(res_str);
        case 2
          figure(1); clf;
          plot(TE,Sv,'o',TE,S_fit);
          set(gca,'YLim',[0 max(Sv) * 1.1]);
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
M0 = reshape(M0, vdims) * sf; % Restore scaling
T2 = reshape(T2, vdims);
C  = reshape(C,  vdims) * sf; % Restore scaling
Mask = reshape(Mask, vdims);
