function spgrtest
% spgrtest
%
% Test SPGR function fitting
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 2/14/2002 From scratch
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

% Physiological values
T1  = 400.0; % ms
T2s = 20.0;  % ms
M0  = 1.0;   % AU

% Pulse sequence parameters
TE = 2:2:18;
TR = TE + 4;
alpha = 20 * ones(size(TE));

% Calculate ideal SPGR signal
Sideal = spgreq(TR,TE,alpha,T1,T2s,M0);

% Add some Gaussian noise - randn gives mu = 0, sd = 1
SNR = 20;
Snoisy = Sideal + randn(size(Sideal)) * max(Sideal) / SNR;

% Fit the SPGR function to the noisy data
[M0fit,T1fit,T2sfit,Sfit,resnorm] = spgrfit(Snoisy,TR,TE,alpha);

% Report the results
fprintf('\n*** Fit Results ***\n\n');
fprintf('%16s%16s%16s%16s\n','Parameter','Actual','Fitted','% Error');
fprintf('%16s%16.3f%16.3f%16.3f\n','T1',T1,T1fit,(T1fit-T1)/T1*100);
fprintf('%16s%16.3f%16.3f%16.3f\n','T2*',T2s,T2sfit,(T2sfit-T2s)/T2s*100);
fprintf('%16s%16.3f%16.3f%16.3f\n','M0',M0,M0fit,(M0fit-M0)/M0*100);

% Plot the results
figure(1); clf;
plot(TE,Sideal,':',TE,Snoisy,'o',TE,Sfit);
legend('Ideal','Noisy','Fitted');
title('SPGR function fitting test');
xlabel('TE (ms)');
ylabel('Signal (AU)');
