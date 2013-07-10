function srfittest

n = 16;
nreps = 100;
T1 = 111;
A = 5;
SNR = 30;

t  = linspace(0,5*T1,n);
s0 = A * (1 - exp(-t / T1));

tc = zeros(1,nreps);

for rc = 1:nreps
  
  sn = s0 + randn(1,n) * A / SNR;

  tic;
  [Afit, T1fit, sfit] = srfit(t,sn);
  tc(rc) = toc;
  
  plot(t,s0,t,sn,'o',t,sfit);
  drawnow;

  fprintf('T1 = %0.3f (%0.3f)\n', T1fit, T1);

end

fprintf('Mean time = %0.3fs\n', mean(tc));
