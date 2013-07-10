function y = medianfilt(x, w)
%
% y = medianfilt(x, w)
%
% Median filter x using a w sample kernel
%
% ARGS:
% x = vector of uniformly sampled values
% w = filter kernel width [3]
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : City of Hope, Duarte, CA
% DATES  : 05/31/00 Add index range
%          06/01/00 Remove index range
%          08/09/00 Add defaults and syntax message

if nargin < 1
   fprintf('SYNTAX: y = medianfilt(x,w)\n');
   return;
end

% Default kernel width of 3 samples
if nargin < 2
   w = 3;
end

nx = length(x);

% Half the kernel width rounded down
hk = floor(w/2);

p0 = (1:nx) - hk;
p1 = (1:nx) + hk;

% Keep start and end points within bounds
p0(p0 < 1) = 1;
p1(p1 > nx) = nx;

for p = 1:nx
   y(p) = median(x(p0(p):p1(p)));
end