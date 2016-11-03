function [xx,yy] = circle(x0,y0,a,varargin)
% Draw a circle in an axis
%
% [xx,yy] = circle(x0,y0,a,plotopts...)
%
% ARGS:
% x0,y0    = circle center
% a        = circle radius
% varargin = standard plot options (eg 'r:','linewidth',3,...)
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 10/19/2001 JMT from scratch
%          05/16/2003 JMT Add return arguments
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

% Default args
if nargin < 1; x0 = 0; end
if nargin < 2; y0 = 0; end
if nargin < 3; a = 1; end
if nargin < 4; varargin = {}; end

% Define circle at 5 degree intervals
dtheta = 5;
theta = (0:dtheta:360) * pi / 180;

% Vertices
xx = a * cos(theta) + x0;
yy = a * sin(theta) + y0;

% Plot circle if no return arguments requested
if nargout < 1
  plot(xx,yy,varargin{:});
end
