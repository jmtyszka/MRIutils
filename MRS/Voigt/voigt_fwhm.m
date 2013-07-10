function FWHM = voigt_fwhm(gL, gD)

x0 = max([gL gD]);

options = optimset('fzero');
options.Display = 'off';

x = fzero('voigt_half', x0, options, gL, gD);

FWHM = x * 2;