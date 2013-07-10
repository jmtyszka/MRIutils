function [f, x, rmsf, rmsx] = ReadSSrms(dirname, name, nf, nx)

rmsffile = sprintf('%s/%s.rmsf', dirname, name);

% Read in Mxy data
fd = fopen(rmsffile,'r');
data = fscanf(fd, '%f', [2,Inf]);
fclose(fd);

f = data(1,:);
rmsf = data(2,:);

rmsxfile = sprintf('%s/%s.rmsx', dirname, name);

% Read in Mxy data
fd = fopen(rmsxfile,'r');
data = fscanf(fd, '%f', [2,Inf]);
fclose(fd);

x = data(1,:);
rmsx = data(2,:);
