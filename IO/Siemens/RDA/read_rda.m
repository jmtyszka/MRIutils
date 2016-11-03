function [rda, sf, f] = read_rda(rda_filename)
% Read spectroscopy RDA file from Siemens machine
%
% ORIGINAL AUTHOR : Matt Robson (FMRIB)
% MODIFIED : Mike Tyszka (Caltech)
% DATES : 12/01/2011 JMT From Read_rda102.m
%
% The MIT License (MIT)
%
% Copyright (c) 2016 Mike Tyszka
%
%   Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
%   documentation files (the "Software"), to deal in the Software without restriction, including without limitation the
%   rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
%   permit persons to whom the Software is furnished to do so, subject to the following conditions:
%
%   The above copyright notice and this permission notice shall be included in all copies or substantial portions of the
%   Software.
%
%   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
%   WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
%   COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
%   OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

if nargin < 1
  [filename, pathname ] = uigetfile('*.rda', 'Select an RDA file');
  rda_filename = [pathname, filename]; %'c:/data/spectroscopy/spec raw data/MrSpec.20020531.160701.rda'
end

fid = fopen(rda_filename);

head_start_text = '>>> Begin of header <<<';
head_end_text   = '>>> End of header <<<';

tline = fgets(fid);

while (isempty(strfind(tline, head_end_text)))
  
  tline = fgets(fid);
  
  if ( isempty(strfind (tline, head_start_text)) + isempty(strfind (tline, head_end_text )) == 2)
    
    % Store this data in the appropriate format
    
    occurence_of_colon = findstr(':',tline);
    variable = tline(1:occurence_of_colon-1) ;
    value    = tline(occurence_of_colon+1 : length(tline)) ;
    
    switch variable
      
      case {'PatientID', 'PatientName', 'StudyDescription', ...
          'PatientBirthDate', 'StudyDate', 'StudyTime', 'PatientAge', ...
          'SeriesDate', 'SeriesTime', 'SeriesDescription', ...
          'ProtocolName', 'PatientPosition', 'ModelName', 'StationName', ...
          'InstitutionName', 'DeviceSerialNumber', 'InstanceDate', ...
          'InstanceTime', 'InstanceComments', 'SequenceName', ...
          'SequenceDescription', 'Nucleus', 'TransmitCoil', 'FrequencyCorrection' }
        
        eval(['rda.' variable ' = strtrim(value);']);
        
      case { 'PatientSex' }
        switch value
          case 1
            rda.sex = 'Male';
          case 2
            rda.sex = 'Female';
          otherwise
            rda.sex = 'Unknown';
        end
        
      case {'SeriesNumber', 'InstanceNumber', 'AcquisitionNumber', ...
          'NumOfPhaseEncodingSteps', 'NumberOfRows', 'NumberOfColumns' ,...
          'VectorSize', 'PatientWeight', 'TR', 'TE', 'TM', 'TI', ...
          'DwellTime', 'NumberOfAverages', 'MRFrequency', ...
          'MagneticFieldStrength', 'FlipAngle', 'SliceThickness', ...
          'FoVHeight', 'FoVWidth', 'PercentOfRectFoV', ...
          'PixelSpacingRow', 'PixelSpacingCol'}
        
        eval(['rda.', variable, ' = str2double(value);']);
        
      case {'SoftwareVersion[0]' }
        rda.SoftwareVersion = strtrim(value);
      case {'CSIMatrixSize[0]' }
        rda.CSIMatrix_Size(1) = str2double(value);
      case {'CSIMatrixSize[1]' }
        rda.CSIMatrix_Size(2) = str2double(value);
      case {'CSIMatrixSize[2]' }
        rda.CSIMatrix_Size(3) = str2double(value);
      case {'PositionVector[0]' }
        rda.PositionVector(1) = str2double(value);
      case {'PositionVector[1]' }
        rda.PositionVector(2) = str2double(value);
      case {'PositionVector[2]' }
        rda.PositionVector(3) = str2double(value);
      case {'RowVector[0]' }
        rda.RowVector(1) = str2double(value);
      case {'RowVector[1]' }
        rda.RowVector(2) = str2double(value);
      case {'RowVector[2]' }
        rda.RowVector(3) = str2double(value);
      case {'ColumnVector[0]' }
        rda.ColumnVector(1) = str2double(value);
      case {'ColumnVector[1]' }
        rda.ColumnVector(2) = str2double(value);
      case {'ColumnVector[2]' }
        rda.ColumnVector(3) = str2double(value);
        
      otherwise
        % We don't know what this variable is.  Report this just to keep things clear
        disp(['Unrecognised variable ', variable ]);
    end
    
  else
    % Don't bother storing this bit of the output
  end
  
end

% Siemens documentation suggests that the data should be in a double complex format
st = fread(fid, rda.CSIMatrix_Size(1) * rda.CSIMatrix_Size(1) * rda.CSIMatrix_Size(1) * rda.VectorSize * 2, 'double');

fclose(fid);

% Reshape FIDs so that we can get the real and imaginary separated
st = reshape(st,  2, rda.VectorSize, rda.CSIMatrix_Size(1),  rda.CSIMatrix_Size(2),  rda.CSIMatrix_Size(3) );

% Combine the real and imaginary FIDs into a complex matrix
st = complex(st(1,:,:,:,:), st(2,:,:,:,:));

% Remove leading singular dimension
st = reshape(st, rda.VectorSize, rda.CSIMatrix_Size(1),  rda.CSIMatrix_Size(2),  rda.CSIMatrix_Size(3));

% FFT time domain
sf = fftshift(fft(st,[],1));

% Time vector in seconds
nt = rda.VectorSize;
dt = rda.DwellTime / 1e6;
t = (0:(nt-1)) * dt;
t_ms = t * 1e3;

% Spectral bandwidth in Hz
bw = 1 / rda.DwellTime;

% Frequency vector in Hz
nf = nt;
f = linspace(-bw/2, bw/2, nf);

if prod(rda.CSIMatrix_Size) == 1

  subplot(121), plot(t_ms, real(st), t_ms, imag(st));
  xlabel('Time (ms)');
  title('FID');

  % Plot SV FID and spectrum
  subplot(122), plot(f, real(sf), f, imag(sf));
  xlabel('Frequency (Hz)');
  title('Spectrum');
  
end
