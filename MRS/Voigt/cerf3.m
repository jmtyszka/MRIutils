function c3 = cerf3(T)
% Approximation 3 to the complex error function
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 4/28/00 Start from web page Fortran code
% REFS   : Humlicek J, JQSRT 1982; 27:437
%          Schreier F JQSRT 1992; 48:743-762

c3   = (16.4955 + T .* (20.20933 + T .* (11.96482 + ...
        T .* (3.778987 + 0.5642236 .* T)))) / ...
       (16.4955 + T .* (38.82363 + T .* ...
       (39.27121 + T .* (21.69274 + T .* (6.699398 + T)))));
