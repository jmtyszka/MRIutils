function B1est = B1(studydir, scans)

nscans = length(scans);

for sc = 1:nscans
  
  scandir = fullfile(studydir,num2str(scans(sc)));
  
  [s,info] = parxrecon(scandir);
  
  fprintf('Loading scan %d\n',scans(sc));
  fprintf('Dimensions: %d x %d x %d\n', info.sampdim(1), info.sampdim(2), info.sampdim(3));
  fprintf('A0: %0.1fdB\n', info.

  if sc == 1
    
    B1est = zeros([size(s) nscans]);
    
  end
  
  size(s)
  
  B1est(:,:,:,sc) = s;
  
end

% FFT pulse amplitude dimension
B1est = fft(B1est,[],4);


  
  
  