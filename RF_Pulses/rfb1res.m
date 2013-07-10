function rfb1res(rfname)
%
% rfb1(rfname)
%
% Calculate various dependent results from the Bloch simulation of the B1
% dependence of an RF waveform using rfb1.m
%
% ARGS:
% rfname    = Name of RF pulse - used to construct full path to .rho file
%
% RETURNS:
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : City of Hope, Duarte CA
% DATES  : 11/27/2000 From scratch

global rfdir

% Pass and stop band criterion for best alpha
best_crit = 'mean';

% Construct filename for the .mat results file
resfile  = [rfdir '\' rfname '\' rfname '.mat'];

% Load the results file
load(resfile);

% Calculate the pass and stop bands of the pulse (5% and 95% of max |Mxy|)
% mxy is arranges in (alpha, f) order
amxy = abs(mxy);
max_amxy = max(amxy');

na = length(alphascale);

% Loop over all alphas (rows)
for a = 1:na
   
   % Extract the frequency response for this alpha
   this_amxy = amxy(a,:);
   
   pass_inds = find(this_amxy > (max_amxy(a) * 0.95));
   stop_inds = find(this_amxy < (max_amxy(a) * 0.05));
   
   % Calculate median |Mxy| in the pass and stop bands
   switch lower(best_crit)
   case 'median'
      all_pass(a) = median(this_amxy(pass_inds));
      all_stop(a) = median(this_amxy(stop_inds));
   case 'mean'
      all_pass(a) = mean(this_amxy(pass_inds));
      all_stop(a) = mean(this_amxy(stop_inds));
   case 'max'
      all_pass(a) = max(this_amxy(pass_inds));
      all_stop(a) = max(this_amxy(stop_inds));
   case 'sum'
      all_pass(a) = sum(this_amxy(pass_inds));
      all_stop(a) = sum(this_amxy(stop_inds));
   otherwise
      all_pass(a) = 0;
      all_stop(a) = 0;
   end
   
end

% Find the value of alpha in the range 0.75 to 1.25 for which the stop band median was a minimum
crop_inds = find(alphascale > 0.75 & alphascale < 1.25);
[minm, ind] = min(all_stop(crop_inds))
min_alpha = alphascale(ind + min(crop_inds) - 1);
min_i = find(alphascale == min_alpha)

% Report key results
fprintf('Pulse name  : %s\n', rfname);
fprintf('Best alpha  : %g\n', min_alpha);
fprintf('Old max B1  : %g\n', max(B1));
fprintf('Best max B1 : %g\n', max(B1) * min_alpha);

% Plot the results
clf;

subplot(221), plot(alphascale, all_pass, alphascale, all_stop);
xlabel('\alpha');
ylabel('median(|M_{xy}|)');
legend('Pass', 'Stop');
set(gca, 'YScale', 'log');

subplot(222), plot(f, amxy(min_i,:));
xlabel('Frequency (Hz)');
ylabel('|M_{xy}|');
set(gca, 'YScale', 'log');
title(sprintf('|M_{xy}| \\alpha = %g', min_alpha));

subplot(223), plot(f, amxy(1,:));
xlabel('Frequency (Hz)');
ylabel('|M_{xy}|');
set(gca, 'YScale', 'log');
title(sprintf('|M_{xy}| \\alpha = %g', alpha(1)));






