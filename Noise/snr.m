function sn = snr(im)
% sn = snr(im)
%
% Estimate the SNR of an image.
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 08/18/2005 JMT From scratch
%
% Copyright 2005 California Institute of Technology.
% All rights reserved.

% Get the 95th percentile signal
s95 = percentile(s,95);
