function c4 = cerf4(T,U)
% Approximation 4 to the complex error function
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 4/28/00 Start from web page Fortran code
% REFS   : Humlicek J, JQSRT 1982; 27:437
%          Schreier F JQSRT 1992; 48:743-762

c4 = (T .* (36183.31 - U .* (3321.99 - U .* (1540.787 - U .* ...
     (219.031 - U .* (35.7668 - U .* (1.320522 - U .* .56419)))))) / ...
     (32066.6 - U .* (24322.8 - U .* (9022.23 - U .* ...
     (2186.18 - U .* (364.219 - U .* (61.5704 - U .* (1.84144 - U))))))));
