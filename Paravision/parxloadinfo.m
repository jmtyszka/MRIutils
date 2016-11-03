function [info, status, errmsg] = parxloadinfo(serdir)
% [info, status, errmsg] = parxloadinfo(serdir)
%
% Load all the IMND information from this path.
% Assumes that serdir contains an imnd series and
% that the parent directory contains a subject text file.
% Non-essential missing information (eg patient name)
% is filled with sensible default values.
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech BIC
% DATES  : 10/05/2000 JMT From scratch
%          12/23/2002 JMT Update with fullfile() calls
%          04/04/2003 JMT Merge pvmloadinfo into this function
%          01/17/2006 JMT M-Lint corrections
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

% Default arg
if nargin < 1; serdir = pwd; end
if isequal(serdir,'.'); serdir = pwd; end

% Check acquisition type (IMND or PvM)
if isequal(parxacqmeth(serdir),'pvm')
  [info,status,errmsg] = pvmloadinfo(serdir);
  return
end

% Default status 1 => everything ok
status = 1;
errmsg = [];

% Default structure member
info.name = 'Unknown';

% Check for existence of imnd or method file
imndfile = fullfile(serdir,'imnd');
if ~exist(imndfile,'file')
  status = -1;
  errmsg = 'No imnd file\n';
  return
end

% Check for existence of acqp file
acqpfile = fullfile(serdir,'acqp'); 
if ~exist(acqpfile,'file')
  status = -2;
  errmsg = 'No acqp file\n';
  return
end

% Check for existence of subject file
subjfile = fullfile(serdir,'..','subject'); 
if ~exist(subjfile,'file')
  status = -3;
  errmsg = 'No subject file\n';
end

% Check for existence of reco file
recofile = fullfile(serdir,'pdata','1','reco');
if ~exist(recofile,'file')
  status = -4;
  errmsg = 'No reco file\n';
  return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parse the IMND file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Load the full contents into a cell array of strings
% Don't use Matlab textread if standalone code is required
imndinfo = parxtextread(imndfile);
if isempty(imndinfo)
  status = -5;
  return
end

% Assume the series number is also the containing directory number
info.serno = str2double(lastdir(serdir));
info.scanno = info.serno; % Duplicate for backwards consistency

% Pulse sequence parameters
info.method = parxextractstring2(imndinfo, '##$IMND_method=');
info.etl = parxextractdouble(imndinfo, '##$IMND_rare_factor=');
info.tr = parxextractdouble(imndinfo, '##$IMND_recov_time='); % ms
info.te = parxextractdouble(imndinfo, '##$IMND_echo_time=');
info.ti = parxextractdouble(imndinfo, '##$IMND_t1_inv_delay=');
info.esp = parxextractdouble(imndinfo, '##$IMND_esp=');
info.bw = parxextractdouble(imndinfo, '##$IMND_bandwidth_1=');
info.navs = parxextractdouble(imndinfo, '##$IMND_n_averages=');
info.navigate = parxextractyesno(imndinfo, '##$BIC_navigate=');
info.excbw = parxextractdouble(imndinfo, '##$IMND_exc_sl_thick_hz=');
info.refbw = parxextractdouble(imndinfo, '##$IMND_ref_sl_thick_hz=');
info.acqtime = parxextractstring2(imndinfo,'##$IMND_expt_time=');
info.echopos = parxextractdouble(imndinfo, '##$IMND_echo_pos=');

% Echo position trap
if isnan(info.echopos); info.echopos = 50.0; end

% Scout parameters
info.scoutmatrix = parxextractmatrix(imndinfo, '##$IMND_scout_orient_matrix=');

% Geometry parameters
info.fov = parxextractmatrix(imndinfo, '##$IMND_fov=');
info.nslice = parxextractdouble(imndinfo, '##$IMND_n_slices=');
info.sloffset = parxextractdouble(imndinfo, '##$IMND_slice_offset=');
info.slsepn = parxextractmatrix(imndinfo, '##$IMND_slice_sepn=');
info.slthick = parxextractdouble(imndinfo, '##$IMND_slice_thick=');
info.slangle = parxextractmatrix(imndinfo, '##$IMND_slice_angle=');
info.rdoffset = parxextractdouble(imndinfo, '##$IMND_read_offset_eq=');
info.slpackvector = parxextractmatrix(imndinfo, '##$IMND_slicepack_vector=');
info.slpackpos = parxextractmatrix(imndinfo, '##$IMND_slicepack_position=');
info.slpackgap = parxextractmatrix(imndinfo, '##$IMND_slicepack_gap=');
info.rdvector = parxextractmatrix(imndinfo, '##$IMND_read_vector=');
info.slpackrdoffset = parxextractmatrix(imndinfo, '##$IMND_slicepack_read_offset=');
info.ph1offset = parxextractmatrix(imndinfo, '##$IMND_phase1_offset=');

% Catch empty FOV
if isempty(info.fov); info.fov = zeros(1,3); end

% For TOMO and BIOSPEC methods
info.evolution = parxextractyesno(imndinfo,'##$IMND_evolution=');
if info.evolution
  info.evocycles = parxextractdouble(imndinfo,'##$IMND_n_evolution_cycles=');
else
  info.evocycles = 1;
end

% MRS parameters
info.sw_spec_Hz = parxextractdouble(imndinfo, '##$IMND_spect_sw_h=');
info.tr_mrs = parxextractdouble(imndinfo, '##$IMND_rep_time=');
info.te_mrs = parxextractdouble(imndinfo, '##$IMND_csi_echo_time=');
info.vsize_mrs = parxextractmatrix(imndinfo, '##$IMND_voxel_size=');
info.vpos = parxextractmatrix(imndinfo, '##$IMND_voxel_position=');

% PC parameters

switch upper(info.method)
 
case {'BIC_PC3D','BIC_PC4D'}
 
  info.venc    = parxextractdouble(imndinfo, '##$IMND_VENC=');
  info.vencdir = parxextractstring(imndinfo, '##$IMND_VENC_Dir=');
  info.bpm     = parxextractdouble(imndinfo, '##$IMND_bpm=');
  
otherwise

  % Do nothing

end
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parse the ACQP file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Load the full contents into a cell array of strings
acqpinfo = parxtextread(acqpfile);
if isempty(acqpinfo)
  status = -6;
  return
end

% Extract useful parameters from acqp file
info.nims = parxextractdouble(acqpinfo, '##$NI=');
info.time = parxextractstring2(acqpinfo, '##$ACQ_time=');
info.acq_scantime = parxextractdouble(acqpinfo, '##$ACQ_scan_time=')/1000; % seconds
info.prefill = parxextractdouble(acqpinfo, '##$DSPFVS=');
info.nreps = parxextractdouble(acqpinfo, '##$NR=');
info.nechoes = parxextractdouble(acqpinfo, '##$NECHOES=');
info.cf = parxextractdouble(acqpinfo, '##$BF1=');

% Get sample dimensions for ACQP (closer to acquisition)
info.sampdim = parxextractmatrix(acqpinfo, '##$ACQ_size=');
info.sampdim(1) = info.sampdim(1)/2;

% Record number of spatial dimensions
info.ndim = length(info.sampdim);

% Determine acquisition bit depth - essential for offline recon
wsize = parxextractstring(acqpinfo, '##$ACQ_word_size=');
if isempty(wsize); wsize = 'Unknown'; end
switch wsize
case '_32_BIT'
  info.acqdepth = 32;
case '_16_BIT'
  info.acqdepth = 16;
otherwise
  fprintf('Unknown acq bit-depth - defaulting to 32\n');
  info.acqdepth = 32;
end

% Multislice interleaved slice ordering
info.objorder = parxextractmatrix(acqpinfo, '##$ACQ_obj_order=');
info.slicepos = parxextractmatrix(acqpinfo, '##$ACQ_slice_offset=');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parse the SUBJECT file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Load the full contents into a cell array of strings
subjinfo = parxtextread(subjfile);
if isempty(subjinfo)
  status = -7;
  return
end

% Extract useful parameters from subject file
info.id = parxextractstring2(subjinfo, '##$SUBJECT_id=');
info.name = parxextractstring2(subjinfo, '##$SUBJECT_name_string=');
info.purpose = parxextractstring2(subjinfo, '##$SUBJECT_purpose=');
info.studyname = parxextractstring2(subjinfo, '##$SUBJECT_study_name=');
info.studyno = parxextractdouble(subjinfo, '##$SUBJECT_study_nr');
info.remarks = parxextractstring2(subjinfo,'##$SUBJECT_remarks=');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parse the RECO file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Load the full contents into a cell array of strings
recoinfo = parxtextread(recofile);
if isempty(recoinfo)
  status = -8;
  return
end

% Extract useful parameters from reco file
info.recodim = parxextractmatrix(recoinfo,'##$RECO_ft_size=');
info.recotx  = parxextractmatrix(recoinfo,'##$RECO_transposition=');
info.recorot = parxextractmatrix(recoinfo,'##$RECO_rotate=');

% RECO normaly assumes phase chopping in the X (read) dimension
info.recorot(1) = 0.5;

% Guess the bit depth of the acquisition
bitdepth = parxextractstring(recoinfo, '##$RECO_wordtype=');
switch bitdepth
case '_16BIT_SGN_INT'
  info.recodepth = 16;
case '_32BIT_SGN_INT'
  info.recodepth = 32;
otherwise
  fprintf('Unknown bit-depth - defaulting to 32\n');
  info.recodepth = 32;
end

% Need to deal with byte ordering with switch to Intel LINUX
info.byteorder = parxextractstring(recoinfo,'##$RECO_byte_order=');

% Extract the image intensity mapping parameters
% These values must be used for correct quantitative scaling
% Extract the image intensity mapping parameters
% These values must be used for correct quantitative scaling
info.map_mode = parxextractstring(recoinfo,'##$RECO_map_mode=');
info.map_range = parxextractmatrix(recoinfo,'##$RECO_map_range=');
info.map_percentile = parxextractmatrix(recoinfo,'##$RECO_map_percentile=');
info.map_error = parxextractdouble(recoinfo,'##$RECO_map_error=');
info.minima = parxextractmatrix(recoinfo,'##$RECO_minima=');
info.maxima = parxextractmatrix(recoinfo,'##$RECO_maxima=');
info.map_min = parxextractmatrix(recoinfo,'##$RECO_map_min=');
info.map_max = parxextractmatrix(recoinfo,'##$RECO_map_max=');
info.map_offset = parxextractmatrix(recoinfo,'##$RECO_map_offset=');
info.map_slope = parxextractmatrix(recoinfo,'##$RECO_map_slope=');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Dependent parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% UFLARE specific parameters
switch upper(info.method)
  
  case 'BIC_UFLARE3D'
  
  info.uflare_flip = parxextractdouble(imndinfo, '##$BIC_uflare_flip=');
  info.uflare_echopath = parxextractstring(imndinfo, '##$IMND_echo_paths=');
  info.diffmode = parxextractyesno(imndinfo, '##$BIC_diff_mode=');
  
  % Get diffusion-weighting information
  if info.diffmode
    info.diffdir = parxextractmatrix(imndinfo, '##$BIC_diff_dir=');
    info.bfactor = parxextractmatrix(imndinfo, '##$BIC_b_factor=');
    info.little_delta = parxextractdouble(imndinfo, '##$BIC_little_delta=');
    info.big_delta = parxextractdouble(imndinfo, '##$BIC_big_delta=');
    info.Gdiff = parxextractdouble(imndinfo, '##$BIC_diff_grad_amp=');
  end
  
otherwise

  info.uflare_flip = 0.0;
  info.uflare_echopath = 'AddedCoherently';
  info.diffmode = 0;
  
end
  
% MRS and MRI specific parameters
switch info.method
  
case {'VSEL_SE','VSEL_STE','BIC_STEAM','BIC_PRESS'}
  
  % This is SV-MRS data
  info.sampdim = [info.sampdim(1) 1 1 1];
  info.recodim = [info.recodim(1) 1 1 1];
  info.fov = info.vsize_mrs;
  info.vsize = info.vsize_mrs;
  
  % Spectroscopy sweep widths, etc
  info.sw_spec_Hz    = parxextractdouble(imndinfo,'##$IMND_spect_sw_h=');
  info.sw_spec_ppm   = info.sw_spec_Hz / info.cf;
  info.sw_offset_Hz  = 0.0;
  info.sw_offset_ppm = 0.0;
  
otherwise
  
  % This is MRI data

  % Fill 4D sampled spatial dimensions
  switch info.ndim
  case 1 % 1D
    info.sampdim(3:4) = info.nreps;
  case 2 % 2D
    info.sampdim(1:2,1) = info.sampdim(1:2);
    info.sampdim(3,1) = info.nims;
    info.sampdim(4,1) = info.nreps;
  case 3 % 3D
    info.sampdim(1:3,1) = info.sampdim(1:3);
    info.sampdim(4,1) = info.nreps * info.nims;
  otherwise
    % Do nothing - may require special handling in future
  end

  % Fill 4D recon spatial dimensions
  switch info.ndim
    case 1 % 1D
      info.recodim(3:4,1) = info.nreps;
      info.fov = [info.fov(1); 0.0; 0.0; 0.0];
    case 2 % 2D
      info.recodim(1:2,1) = info.recodim(1:2);
      info.recodim(3,1) = info.nims;
      info.recodim(4,1) = info.nreps;
      info.fov = [info.fov(1:2); 0.0; 0.0];
    case 3 % 3D
      info.recodim(1:3,1) = info.recodim(1:3);
      info.recodim(4,1) = info.nreps * info.nims;
      info.fov = [info.fov(1:3); 0.0];
    otherwise
      % Do nothing - may require special handling in future
  end
  
  % Calculate voxel size in um from FOV and recon'd matrix
  info.vsize = info.fov ./ (info.recodim + eps) * 1e3;
  
end
