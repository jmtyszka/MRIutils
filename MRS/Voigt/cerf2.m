function c2 = cerf2(T,U)
% Approximation 2 to the complex error function
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 4/28/00 Start from web page Fortran code
% REFS   : Humlicek J, JQSRT 1982; 27:437
%          Schreier F JQSRT 1992; 48:743-762

c2 = (T .* (1.410474 + U .* 0.5641896)) ./ (0.75 + (U .* (3 + U)));
