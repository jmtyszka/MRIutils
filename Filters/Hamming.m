function H = hamming(n)
% H = hamming(n)
%
% Generate an n-point Hamming filter function
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 02/17/2004 JMT From scratch
%
% Copyright 2004 California Institute of Technology.
% All rights reserved.

% Create index
x = linspace(-pi,pi,n);

% Calculate symmetric Hamming with n points
H = 0.54 + 0.46 * cos(x);
