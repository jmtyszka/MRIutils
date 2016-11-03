function [M0, T2, C, Mask] = t2fitn_ms(TE, S, scalefactors, verbose)
% [M0, T2, C, Mask] = t2fitn_ms(TE, S, scalefactors, verbose)
%
% This is the multiscale version of t2fitn for 2D multiecho data.
%
% Multiscale fit the T2 contrast equation:
%
%   S(TE) = M0 * exp(-TE/T2) + C
%
% to the last dimension of an N-D matrix, S[]
%
% ARGS:
% TE = echo time vector for the final dimension (ms)
% S  = 2D spatial x 1D echo time data (nx x ny x nte)
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

% Default returns
M0 = [];
T2 = [];
C  = [];
Mask = [];

% Get dimensions
[nx,ny,nte1] = size(S);
nte2 = length(TE);

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

%---------------------------------------------
% Multiscale loop
%---------------------------------------------

% Flag to use previous scale maps as guess for current scale
useguess = 0;

for sf = scalefactors

  fprintf('Downsampling image by %d ',sf);
  Sdwn = [];
  for tc = 1:nte
    fprintf('.');
    Sdwn(:,:,tc) = imresize(S(:,:,tc),1/sf);
  end
  
  [nxd,nyd,nte] = size(Sdwn);
  nvox = nxd * nyd;
  
  % Upsample previous scale maps to act as estimates for this level
  if useguess
    M0_0 = imresize(M0d,[nxd nyd],'nearest');
    T2_0 = imresize(T2d,[nxd nyd],'nearest');
    C_0 = imresize(Cd,[nxd nyd],'nearest');
  else
    M0_0 = Sdwn(:,:,1);
    T2_0 = mean(TE) * ones(nxd,nyd);
    C_0  = zeros(nxd,nyd);
  end
  
  % Make space for maps
  M0d = zeros(nxd,nyd);
  T2d = M0d;
  Cd = M0d;
  
  % Create a mask from the image with the shortest TE
  [minTE, tmin] = min(TE(:));
  Sminte = Sdwn(:,:,tmin);
  Sthresh = max(Sminte(:)) * 0.1;
  Mask = Sminte > Sthresh;
  nmask = sum(Mask(:));

  % Optimization options
  mode = 'unconstrained';
  options = optimset('lsqcurvefit');
  options = optimset(options,...
    'TolFun',1e-6,...
    'TolX',1e-6,...
    'Jacobian','on',...
    'Largescale','off',...
    'Display','off');

  % Start clock
  t0 = clock;

  % Mask voxel counter
  vcount = 0;
  
  % Create waitbar
  hwb = waitbar(0,'Searching for first voxel');
  
  for yc = 1:nyd
    for xc = 1:nxd

      if Mask(xc,yc)

        % Update mask voxel counter
        vcount = vcount + 1;

        %---------------------------------------------------
        % Fit T2 relaxation curve for single voxel time-course
        %---------------------------------------------------

        % Extract current voxel echo train
        Sv = reshape(Sdwn(xc,yc,:),1,[]);

        % Call T2 fit function
        [M0d(xc,yc), T2d(xc,yc), Cd(xc,yc), S_fit] = t2fit(TE,Sv,mode,options,M0_0(xc,yc),T2_0(xc,yc),C_0(xc,yc));
        
        if mod(vcount,10) == 0

          % Update waitbar progress
          fp = vcount/(nmask+eps);
          vps = vcount/(etime(clock,t0)+eps);
          trem = (nmask - vcount) / vps;
          [hr,mn,sc] = hms(trem);
          res_str = sprintf('%5.1f%% -%02dh%02dm%0.1fs', fp*100,hr,mn,sc);
          waitbar(fp,hwb,res_str);

          switch verbose
            case 1
              disp(res_str);
            case 2
              figure(1); clf;
              subplot(221), imagesc(Sdwn(:,:,1)); axis image off; title('S(0)');
              subplot(222), imagesc(M0d(:,:,1)); axis image off; title('M(0)');
              subplot(223), imagesc(T2d(:,:,1)); axis image off; title('T2');
              subplot(224), plot(TE,Sv,'o',TE,S_fit); axis tight; title(res_str);
              drawnow;
            otherwise
              % Do nothing
          end
          
        end % Waitbar conditional

      end % Mask conditional

    end % x loop
  end % y loop
  
  dt = etime(clock,t0);
  [hr,mn,sc] = hms(dt);
  fprintf(' %02dh%02dm%0.1fs\n',hr,mn,sc);
  
  % Close waitbar
  close(hwb);

  % Restore maps to 2D and save as estimate for next scale
  M0d = reshape(M0d,nxd,nyd);
  T2d = reshape(T2d,nxd,nyd);
  Cd  = reshape(Cd,nxd,nyd);
  
  % Set guess flag after first pass
  useguess = 1;
  
end % Multiscale loop

% Return maps from final iteration
M0 = M0d;
T2 = T2d;
C  = Cd;
