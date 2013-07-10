function f = HammingSinc(l, n)
% f = HammingSinc(l, n)
%
% Generate an <n> point <l> lobe Hamming filtered sinc function
% Mike Tyszka, Ph.D. City of Hope National Medical Center
% 990830

t = -l:(2*l/(n-1)):l;



f = (sin(pi * t) + 1e-10)./(pi * t + 1e-10);

H = 0.54 + 0.46 * cos(pi * t/l);

f = f .* H;

plot(t, f);
axis off;