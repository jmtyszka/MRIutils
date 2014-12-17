function [H, x] = fermi(n, fr, fw)
% [H, x] = fermi(n, fr, fw)
%
% Return a 1D Fermi filter function
%
% ARGS:
% n  = number of filter points
% fr = fractional filter radius [0, 1] [0.5]
% fw = fractional filter transition width [0, 1] [0.05]
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech Biological Imaging Center
% DATES  : 10/28/2003 JMT Adapt from fermi3.m (JMT)
%          03/22/2004 JMT Add tails argument
%          04/11/2014 JMT Remove tails argument, limit to positive x
%
% Copyright 2014 California Institute of Technology
% All rights reserved

% Default arguments
if nargin < 1, n = 128; end
if nargin < 2, fr = 0.5; end
if nargin < 3, fw = 0.05; end

% Construct a normalized coordinate
x = linspace(0,1,n);

% Construct 1D Fermi filter vector
H = 1 ./ (1 + exp((x - fr)/fw));
