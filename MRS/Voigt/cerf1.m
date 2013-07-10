function c1 = cerf1(T)
% Approximation 1 to the complex error function
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 4/28/00 Start from web page Fortran code
% REFS   : Humlicek J, JQSRT 1982; 27:437
%          Schreier F JQSRT 1992; 48:743-762

c1 = T .* 0.5641896 ./ (0.5 + T .* T);
