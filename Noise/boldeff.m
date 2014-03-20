function boldeff
% Plot SNR and SNR efficiency against TR for simulated GM
%
% AUTHOR: Mike Tyszka
% PLACE : Caltech Brain Imaging Center
% DATES : 07/17/2009 JMT From scratch for NSF MRI
%
% This file is part of MRIutils.
%
%     MRIutils is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
%
%     MRIutils is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
%
%     You should have received a copy of the GNU General Public License
%     along with MRIutils.  If not, see <http://www.gnu.org/licenses/>.
%
% Copyright 2009,2013 California Institute of Technology.

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
