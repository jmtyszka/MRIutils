function r = rms(x)
% Calculate rms value of a field
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech
% DATES  : 01/23/2009 JMT From scratch
%
% Copyright 2009 California Institute of Technology
% All rights reserved

r = sqrt(mean(x(:).^2));