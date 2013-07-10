function over_edge_rgb = edgeoverlay(bg,over,rng,poscmap,negcmap)
% Overlay edges on an image
%
% over_edge_rgb = edgeoverlay(bg,over,rng,cmap1,cmap2)
%
% Create an overlay on an edge detected anatomic image.
% Intended for CSI, fMRI or SPM overlays.
%
% If overlay is signed, rng is used symmetrically for positive and negative
% values. Hot body colormap is used for positive values. Cold body is used for
% negative values if present.
%
% ARGS:
% bg   = background image
% over = overlay image (signed data allowed)
% rng  = clamp range for overlay
% poscmap = positive range colormap
% negcmap = negative range colormap
%
% RETURNS:
% over_edge_rgb = RGB color overlay image
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 08/25/2004 JMT Adapt from ismrm04.m (JMT)
%          08/31/2004 JMT Add return args
%          02/21/2005 JMT Remove return cmap. Add cmap args
%          01/17/2006 JMT M-Lint corrections
%
% Copyright 2003-2006 California Institute of Technology.
% All rights reserved.
%
% This file is part of MRutils.
%
% MRutils is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% MRutils is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with MRutils; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

% Default args
if nargin < 4; poscmap = hot; end
if nargin < 5; negcmap = cold; end

%---------------------------------------------------------------
% Process anatomic reference
%---------------------------------------------------------------

% Resample to make maximum dimension = 1280
[nx,ny] = size(bg);
ar = nx / ny;
if nx > ny
  nxi = 1280;
  nyi = 1280 / ar;
else
  nxi = 1280 * ar;
  nyi = 1280;
end

bg = imresize(bg,[nxi nyi],'bicubic');

% Edge detect
bg_edge = double(edge(bg,'canny',[],1.0));

% Blur out slightly
h = fspecial('gaussian',[3 3],2.0);
bg_edge = imfilter(bg_edge,h);

% Convert background edges to RGB
bg_rgb = colorize(bg_edge,[],gray);

% Resize overlay to same size as background
over = imresize(over,size(bg_edge),'bicubic');

% Colorize positive overlay values
over_pos_rgb = colorize(over, rng, poscmap);

% Colorize negative overlay values
over_neg_rgb = colorize(-over, rng, negcmap);

% Merge positive and negative overlays
over_rgb = over_pos_rgb + over_neg_rgb;
over_rgb(over_rgb > 1) = 1;
over_rgb(over_rgb < 0) = 0;

% Overlay on edge detected anatomy
over_edge_rgb = overlayrgb(over_rgb,bg_rgb,1,0.5,'normal');