function b1slr
%
% Run a bloch sim of the RF pulse over a range of B1 scalings
%
% AUTHOR: Mike Tyszka, Ph.D.
% PLACE : City of Hope, Duarte CA
% DATES : 000807 From scratch

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
