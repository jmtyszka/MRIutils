function se = stderr(x,dim)
% Unbiased estimate of the standard error of the mean of a sample
%
% USAGE: se = stderr(x,dim)
%
% AUTHOR: Mike Tyszka, Ph.D.
% PLACE : Caltech BIC
% DATES : 02/23/2005 JMT From scratch
%         12/23/2011 JMT Add dimension argument
%
% Copyright 2011 California Institute of Technology.
% All rights reserved.

n = size(x,dim);

% Note: use unbiased estimate of variance and normalize SE to n
se = sqrt(var(x,0,dim)/n);
