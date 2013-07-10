function f = T1residual(x,xdata,ydata,mag,ncomps)
% Return difference between IR decay function
% calculated from x and xdata and the experimental
% decay in ydata as a sum of squared differences.
% mag is a flag for absolute signal calculation
% ncomps is the number of T1 components to be fitted

f = T1func(x,xdata,mag,ncomps) - ydata;

% Apply constraints
% scale = 1;
% for c = 1:ncomps
%   this_M0 = x(2*c-1);
%   this_T1 = x(2*c);
%   scale = scale * (1+exp(-this_T1)) * (1+exp(-this_M0));
% end
%
% f = f * scale;