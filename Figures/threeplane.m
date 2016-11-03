function [x3,y3,z3] = threeplane(s,clims,cmap,vsize)
% Interactive 3-plane view of a 3D dataset
%
% [x3,y3,z3] = threeplane(s,clims,cmap,vsize)
%
% User can adjust the 3-plane intersection with left mouse button
% clicks. A right mouse button click returns the intersection point.
%
% ARGS :
% s     = 3D scalar data (suggest 256x256x256 or smaller)
% clims = optional colormap limits to apply [min max]
% cmap  = optional colormap (N x 3) [gray(256)]
% vsize = voxel dimensions in um [1 1 1]
%
% RETURNS :
% [x3,y3,z3] = final intersection point of three-plane view
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 07/17/2002 JMT Adapt from egg3plane.m (JMT)
%          11/17/2003 JMT Change background to white and add colorbar
%          01/17/2006 JMT M-Lint corrections
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

% For image display:
% x = 1st index = matrix rows = y in display axes
% y = 2nd index = matrix cols = x in display axes

if nargin < 1
  fprintf('USAGE: [x3,y3,z3] = threeplane(s,clims)\n');
  return
end
if nargin < 2; clims = []; end
if nargin < 3; cmap = gray(256); end
if nargin < 4; vsize = [1 1 1]; end

% Fill colormap limits if empty
if isempty(clims)
  
  smin = min(s(:));
  smax = max(s(:)) + eps;
  asmax = max(abs([smin smax]));
  
  if smin >= 0
    clims = [0 asmax];
  else
    clims = [-asmax asmax];
  end
    
end

% Fill colormap if empty
if isempty(cmap); cmap = gray(256); end

% Prepare figure
clf;
colormap(cmap);

% Grab data dimensions
[nx,ny,nz] = size(s);

% Initialize intersection in matrix coordinates
x3 = round(nx/2);
y3 = round(ny/2);
z3 = round(nz/2);

% Axis vectors
xv = ((1:nx)-1)*vsize(1);
yv = ((1:ny)-1)*vsize(2);
zv = ((1:nz)-1)*vsize(3);

minx = min(xv); maxx = max(xv);
miny = min(yv); maxy = max(yv);
minz = min(zv); maxz = max(zv);

% Set z-buffer rendering
set(gcf,'Renderer','zbuffer');

keepgoing = 1;

while keepgoing
  
  %--------------------------------------
  % Axial Red : matrix(x,y) -> plot(x,y)
  %--------------------------------------
  
  zz = fix(z3 / vsize(3)) + 1;
  subplot(221), imagesc(xv,yv,squeeze(s(:,:,zz))',clims);
  title('Axial'); xlabel('x'); ylabel('y');
  axis image xy
  set(gca,'XColor','r','YColor','r');
  hax = gca;

  % Draw in sagittal and coronal plane intersections
  line([x3 x3],[miny maxy],'color','b'); % Coronal
  line([minx maxx],[y3 y3],'color','g'); % Sagittal
  
  %------------------------------------------
  % Coronal Green : matrix(x,z) -> plot(x,y)
  %------------------------------------------

  yy = fix(y3 / vsize(2)) + 1;
  subplot(223), imagesc(xv,zv,squeeze(s(:,yy,:))',clims);
  title('Coronal'); xlabel('x'); ylabel('z');
  axis image xy
  set(gca,'XColor','g','YColor','g');
  hcor = gca;
  
  % Draw in axial and coronal plane intersections
  line([minx maxx],[z3 z3],'color','r'); % Axial
  line([x3 x3],[minz maxz],'color','b'); % Sagittal
  
  %------------------------------------------
  % Sagittal Blue : matrix(y,z) -> plot(x,y)
  %------------------------------------------

  xx = fix(x3 / vsize(1)) + 1;
  subplot(224), imagesc(yv,zv,squeeze(s(xx,:,:))',clims);
  title('Sagittal'); xlabel('y'); ylabel('z');
  axis equal xy
  set(gca,'XColor','b','YColor','b');
  hsag = gca;

  % Add colorbar to sagittal view
  colorbar('peer',hsag);
  
  % Draw in axial and sagittal plane intersections
  line([y3 y3],[minz maxz],'color','g'); % Coronal
  line([miny maxy],[z3 z3],'color','r'); % Axial
  
  %-------------------------------------------------------
  % Report cursor location and voxel value
  %-------------------------------------------------------

  subplot(222)
  axis off;
  title(sprintf('S(%d,%d,%d) = %0.3g',x3,y3,z3,s(xx,yy,zz)));
  
  % Refresh figure
  drawnow
  
  % Wait for button press and recenter
  try
    if keepgoing
      [xb,yb,button] = ginput(1);
    end
  catch
    % Window was probably closed by user - exit gracefully
    keepgoing = 0;
  end
  
  % Only process mouse location if window is still open
  if keepgoing
    
    xb = round(xb);
    yb = round(yb);
  
    switch button
      
    case 1 % Left mouse button
    
      switch gca
      
      case hax
        x3 = clamp(xb,minx,maxx);
        y3 = clamp(yb,miny,maxy);
      
      case hcor
        x3 = clamp(xb,minx,maxx);
        z3 = clamp(yb,minz,maxz);
      
      case hsag
        y3 = clamp(xb,miny,maxy);
        z3 = clamp(yb,minz,maxz);
      
      otherwise
      
        % Do nothing
      
      end
  
    case 3 % Right mouse button
    
      % Allow exit from while loop
      keepgoing = 0;
    
    end
    
  end
    
end
