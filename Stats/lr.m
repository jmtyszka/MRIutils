function [a,b,r,t,df,p] = lr(x,y)
% [a,b,r,t,df,p] = lr(x,y)
%
% Perform good old-fashioned linear regression on the vectors x and y
%
% Use explicit formula for linear regression
%
% b = (n * Sxy - Sx * Sy) / (n * Sxx - Sx * Sx)
% a = (Sy - b * Sx) / n
%
% ARGS:
% x,y = coordinate pairs
% 
% RETURNS:
% a  = linear regression intercept
% b  = linear regression slope
% r  = linear correlation coefficient
% t  = t value for this r and df
% df = degrees of freedom of linear regression
% p  = probability for this t and df
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 10/17/2001 JMT From scratch

% Flatten to column vectors
x = x(:);
y = y(:);

% Calculate summations for the regression
n = length(x);
Sx = sum(x);
Sy = sum(y);
Sxx = sum(x .* x);
Syy = sum(y .* y);
Sxy = sum(x .* y);

SSx = Sxx - (Sx * Sx) / n;
SSy = Syy - (Sy * Sy) / n;
SCxy = Sxy - (Sx * Sy) / n;

% Slope
b = SCxy / SSx;

% Intercept
a = (Sy - b * Sx) / n;

% Linear correlation coefficient
r = SCxy / sqrt(SSx * SSy);

% Degrees of freedom of fit
df = n-2;

% t-value for r
t = r / sqrt((1-r*r)/df);

% Probability of this t and df (using stats toolbox)
% p = tcdf(-abs(t),df)
p = 0;