function boldeff
% Plot SNR and SNR efficiency against TR for simulated GM
%
% AUTHOR: Mike Tyszka
% PLACE : Caltech Brain Imaging Center
% DATES : 07/17/2009 JMT From scratch for NSF MRI
%
% The MIT License (MIT)
%
% Copyright (c) 2016 Mike Tyszka
%
%   Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
%   documentation files (the "Software"), to deal in the Software without restriction, including without limitation the
%   rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
%   permit persons to whom the Software is furnished to do so, subject to the following conditions:
%
%   The above copyright notice and this permission notice shall be included in all copies or substantial portions of the
%   Software.
%
%   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
%   WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
%   COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
%   OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

% Gray matter T1 in ms
T1 = 1450;

% Range of TRs in ms
logTR = linspace(0,4,128);
TR = 10.^logTR;

% Saturation term
E1 = exp(-TR/T1);

% Ernst angle in radians
alpha_e = acos(E1);

% Saturation recovery contrast equation
% Assume SNR is proportional to Mze
% See Haacke eqn 18.12, p455
SNR = (1 - E1) ./ (1 - E1 .* cos(alpha_e));

% SNR efficiency assuming total imaging time is proporational to TR
eta = SNR ./ sqrt(TR);

% Plot SNR vs TR
subplot(211), plot(TR,SNR,TR,eta);
xlabel('TR (ms)');
title('SNR vs TR for Ernst Angle excitation');
legend('SNR','SNR / sqrt(TR)','Location','Northwest');
set(gca,'XScale','log');

subplot(212), plot(TR, alpha_e * 180/pi);
xlabel('TR (ms)');
ylabel('Ernst Angle (degrees)');
title('Ernst Angle vs TR');
