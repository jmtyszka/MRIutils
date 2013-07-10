function VH = voigt_half(f, gL, gD)

V = real(voigt_mex(f, 1, 0, gL, gD, 0));

VH = V - 0.5;