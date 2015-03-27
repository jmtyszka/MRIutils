function [hardi_scans, s0_scans, dwi_scans] = jmt_ddr_findscans(study_dir)

d = dir(study_dir);
nd = length(d);

hardi_scans = zeros(1,nd);
s0_scans = zeros(1,nd);
dwi_scans = zeros(1,nd);

hardi_count = 0;
dwi_count = 0;
s0_count = 0;

for dc = 1:length(d)
  
  fname = d(dc).name;
  
  % Convert directory/filename to a number if possible
  scan_no = str2double(fname);
  
  % Check for scan directory (number)
  if isnumeric(scan_no)
    
    info = parxloadinfo(fullfile(study_dir,fname));
    if ~isequal(info.name,'Unknown')
    
      if isequal(info.method,'jmt_ddr')
        
        if (info.ndim == 3) && (info.etl ~= info.sampdim(2))

          if info.bfactor > 0.0
            dwi_count = dwi_count + 1;
            dwi_scans(dwi_count) = scan_no;
          else
            s0_count = s0_count + 1;
            s0_scans(s0_count) = scan_no;
          end
          
        end
        
      end
      
    end
    
  end
  
end

% Clip unused elements
s0_scans = s0_scans(1:s0_count);
dwi_scans = dwi_scans(1:dwi_count);

% Sort scan lists
s0_scans = sort(s0_scans);
dwi_scans = sort(dwi_scans);
hardi_scans = sort([s0_scans dwi_scans]);
