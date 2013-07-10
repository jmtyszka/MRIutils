function cscale_rgb = colorscaleim(outfile,rng,orient,poscmap,negcmap)
% Create a high-quality colorscale image that can be added to figures, etc
%
% cscale_rgb = colorscaleim(outfile,rng,orient,poscmap,negcmap)
%
% ARGS:
% outfile = output colorscale image filesub (without extension) 
% rng     = calibrated first range of colormap (min,max).
% orient  = colorscale orientation ('horiz','vert')
% poscmap = positive range colormap (n x 3)
% negcmap = negative range colormap (n x 3) []
%       
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 02/21/2005 JMT From scratch
%          01/17/2006 JMT M-Lint corrections
%
% Copyright 2005-2006 California Institute of Technology.
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
if nargin < 1; outfile = []; end
if nargin < 2; rng = [0 1]; end
if nargin < 3; orient = 'horiz'; end
if nargin < 4; poscmap = hot; end
if nargin < 5; negcmap = []; end

if isempty(negcmap)
  signed = 0;
else
  signed = 1;
end

% Size of output image in voxels
nx = 256; ny = 16;

% Range limits
rmin = rng(1); rmax = rng(2);

%------------------------------------------------
% Create grayscale image of the values required
% in the colorscale over the required range
%------------------------------------------------

if signed
  % Negative and positive range colorscale
  cscale = linspace(-rmax,rmax,nx)'; % Column vector
  cscale = repmat(cscale,[1 ny]); % Vertical colorbar
  if isequal(orient,'horiz'); cscale = cscale'; end
  cscale_pos_rgb = colorize(cscale,rng,poscmap);
  cscale_neg_rgb = colorize(-cscale,rng,negcmap);
  cscale_rgb = cscale_pos_rgb + cscale_neg_rgb;
else
  % Single range colorscale
  cscale = linspace(rmin,rmax,nx)';
  cscale = repmat(cscale,[1 ny]);
  if isequal(orient,'horiz'); cscale = cscale'; end
  cscale_rgb = colorize(cscale,rng,poscmap);
end

% Clamp RGB limits
cscale_rgb(cscale_rgb > 1) = 1;
cscale_rgb(cscale_rgb < 0) = 0;

% Create a figure and draw the colorscale
h = figure;

if signed

  % Image coordinate grid
  xc = linspace(-rmax,rmax,nx);
  yc = xc * ny/nx;
  
  % Signed colorscale
  switch orient
    case 'horiz'
      imagesc(xc,yc,cscale_rgb);
    otherwise
      imagesc(yc,xc,cscale_rgb);
  end
  
  axis equal tight xy;
  set(gcf,'Position',[100 100 640 640]);
  switch orient
    case 'horiz'
      set(gca,'XTick',[-rmax -rmin rmin rmax],'YTick',[]);
    otherwise
      set(gca,'YTick',[-rmax -rmin rmin rmax],'XTick',[]);
  end

else
  % Image coordinate grid
  xc = linspace(rmin,rmax,nx);
  yc = xc * ny/nx;
  
  % Signed colorscale
  switch orient
    case 'horiz'
      imagesc(xc,yc,cscale_rgb);
    otherwise
      imagesc(yc,xc,cscale_rgb);
  end

  axis equal tight xy;
  set(gcf,'Position',[100 100 640 640]);
  switch orient
    case 'horiz'
      set(gca,'XTick',[rmin rmax],'YTick',[]);
    otherwise
      set(gca,'YTick',[rmin rmax],'XTick',[]);
  end

end

% Save figure
if ~isempty(outfile)
  print('-dpng','-r300',[outfile '.png']);
end

% Close window
close(h);
