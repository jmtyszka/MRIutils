function B = ClampImage(A,minmax)

B = A;
B(A < minmax(1)) = minmax(1);
B(A > minmax(2)) = minmax(2);