function b1slr
%
% Run a bloch sim of the RF pulse over a range of B1 scalings
%
% AUTHOR: Mike Tyszka, Ph.D.
% PLACE : City of Hope, Duarte CA
% DATES : 2000-08-07 JMT From scratch
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

b1scale = 0.05:0.05:2.0;

meanstop = zeros(size(b1scale));
meanpass = zeros(size(b1scale));

for bc = 1:length(b1scale);
   
   fprintf('Simulating B1 scale of %g\n', b1scale(bc));
   
   [f, mxy, mz, mxyz] = bloch(b1scale(bc));
   
   % Calculate mean stop and pass band |Myx|
   passband = find(f < 1500);
   stopband = find(f > 3000);
   meanstop(bc) = mean(abs(mxy(stopband)));
   meanpass(bc) = mean(abs(mxy(passband)));
   
end

% Plot ratio of mean |Mxy| in pass (< 1.5kHz) and stop (> 3kHz) bands
subplot(131), plot(b1scale, meanstop); title('Mean |Mxy| Stop');
subplot(132), plot(b1scale, meanpass); title('Mean |Mxy| Pass');
subplot(133), plot(b1scale, meanstop./meanpass); title('Stop/Pass');
