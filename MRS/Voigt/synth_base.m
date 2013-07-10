function b = synth_base(n, sd_b)
%
% Create a synthetic random baseline
% from smoothed Gaussian white noise
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 04/28/2000 Start from scratch
%          07/05/2012 Switch to smoothed noise

noise = mrs_noise(n, sd_b);

% Filter span for smoothin
span = n/4;

b = smooth(real(noise), span) + 1i * smooth(imag(noise), span);

b = b';

