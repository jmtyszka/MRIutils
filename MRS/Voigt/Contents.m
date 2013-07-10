% VOIGT
%
% Files
%   cerf            - Adaptive complex error function approximation
%   cerf1           - Approximation 1 to the complex error function
%   cerf2           - Approximation 2 to the complex error function
%   cerf3           - Approximation 3 to the complex error function
%   cerf4           - Approximation 4 to the complex error function
%   Humlicek        - [cn,c0] = humlicek(x,y)
%   lsq_model       - Least-square curve fitting function
%   model_demo      - model_demo
%   model_f0        - Calculate the ppm shifts of NAA, Cr, Cho and water
%   model_fit       - Fit a model spectrum of four Voigt resonances to
%   model_mrs       - s = model_mrs(I, f0, gL, gD, phi, T)
%   model_ppm       - Calculate the ppm scale for a spectrum
%   mrs_noise       - Generate complex Normal noise with mean = 0 and sd = sd_n
%   refine_fit      - Subtract baseline estimate from s_expt
%   synth_base      - Create a synthetic random baseline
%   synth_demo      - synth_demo
%   synth_mrs       - Generate a synthetic long TE 1H brain spectrum
%   voigt           - V = voigt(f, I0, f0, gL, gD, phi)
%   voigt_area      - Q = voigt_area(A, gL, gD)
%   voigt_demo      - Demonstrate the Voigt lineshape
%   voigt_fwhm      - 
%   voigt_fwhm_plot - Contour plot of results with labels
%   voigt_half      - 
%   voigt_real      - V = voigt(f, gL, gD)
%   voigtcmp        - Compare results of M and MEX versions of voigt
