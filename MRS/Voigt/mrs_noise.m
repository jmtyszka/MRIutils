function noise = mrs_noise(n, sd_n)
%
% Generate complex Normal noise with mean = 0 and sd = sd_n
%
% sd_n  = sd of complex Gaussian noise in AU
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 4/28/00 Start from scratch

if (sd_n ~= 0)
  noise = random('norm',0,sd_n,1,n) + ...
      i * random('norm',0,sd_n,1,n);
else
  noise = zeros(1,n);
end
