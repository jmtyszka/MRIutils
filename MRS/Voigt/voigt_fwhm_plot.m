function [gL,gD,fwhm] = voigt_fwhm_plot(n)
%VOIGT_FWHM_PLOT Contour plot of results with labels

gmax = 0.1;

dn = gmax/n;

gL = dn:dn:gmax;
gD = dn:dn:gmax;

fwhm = zeros(n,n);

for ll = 1:n
   for dd = 1:n
      
      fwhm(ll,dd) = voigt_fwhm(gL(ll),gD(dd));
      
   end
end

% Contour plot of results with labels
[c,h] = contour(gL,gD,fwhm);
clabel(c,h)
xlabel('gD'); ylabel('gL');
