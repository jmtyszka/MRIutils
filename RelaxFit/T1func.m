function f = T1func(x,xdata,mag,ncomps)
% Mz(t) = sum_i(M0i(1-E1i) + Mzi(0)E1i)
% f = abs(Mz(t)) if mag == 1

f = zeros(1,length(xdata));

for c = 1:ncomps
   M0 = x(c*2-1);
   E1 = exp(-xdata/x(c*2));
   f = f + M0 * (1-2*E1);
end

if (mag == 1)
   f = abs(f);
end