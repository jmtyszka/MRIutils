function bvec = fslloadbvec(fname)

fd = fopen(fname,'r');
if fd < 0
  return;
end

C = textscan(fd,'%f');

bvec = reshape(C{1},[],3);

fclose(fd);
