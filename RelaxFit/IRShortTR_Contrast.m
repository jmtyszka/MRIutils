function Mz = IRShortTR_Contrast(T1, TI, TD)
% Short TR IR-GE contrast equation
%
% 180-TI-90-TD where TR = TI + TD and TR < T1
%
% ARGS:
% T1 = T1 relaxation time of tissue in ms (nD mesh)
% TI = Inversion time in ms (nD mesh)
% TD = Delay time in ms (nD mesh)
%
% RETURNS:
% Mz = longitudinal magnetization at time of 90 (M0 = 1)
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech
% DATES  :2014-01-16 JMT From scratch
%
% Copyright 2014 California Institute of Technology.
% All rights reserved.

% Total TR in ms
TR = TI + TD;

% Assume M0 = 1
Mz = 1 - 2 * exp(-TI ./ T1) + exp(-TR ./ T1);
