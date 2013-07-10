function B = ScaleImage(A,minmax)

minA = min(min(A));
maxA = max(max(A));

scale = (minmax(2)-minmax(1))/(maxA-minA);

B = (A - minA) * scale + minmax(1);