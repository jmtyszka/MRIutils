function [info, status, errmsg] = loadspar(scanname)
% Parse a Philips TSI spectroscopy parameter file
%
% [info, status, errmsg] = loadtspar(scanname)
%
% AUTHOR: Mike Tyszka, Ph.D.
% PLACE : Caltech BIC and ETH Zuerich
% DATES : 08/01/2003 JMT From scratch
%         08/16/2003 JMT Expand text parsing to all fields
%         01/17/2006 JMT M-Lint corrections
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

info = [];
status = 0;
errmsg = '';

sparfile = [scanname '.spar'];

fd = fopen(sparfile,'r');
if fd < 0
  status = -1;
  errmsg = sprintf('Could not open %s to read',sparfile);
  return
end

info.examination_name         = sparstr(fd);
info.scan_id                  = sparstr(fd);
info.scan_date                = sparstr(fd);
info.patient_name             = sparstr(fd);
info.patient_birth_date       = sparstr(fd);
info.patient_position         = sparstr(fd);
info.patient_orientation      = sparstr(fd);
info.samples                  = sparnum(fd);
info.rows                     = sparnum(fd);
info.synthesizer_frequency    = sparnum(fd);
info.offset_frequency         = sparnum(fd);
info.sample_frequency         = sparnum(fd);
info.echo_nr                  = sparnum(fd);
info.mix_number               = sparnum(fd);
info.nucleus                  = sparstr(fd);
info.t0_mu1_direction         = sparnum(fd);
info.echo_time                = sparnum(fd);
info.repetition_time          = sparnum(fd);
info.averages                 = sparnum(fd);
info.volume_selection_enable  = sparstr(fd);
info.volumes                  = sparnum(fd);
info.ap_size                  = sparnum(fd);
info.lr_size                  = sparnum(fd);
info.cc_size                  = sparnum(fd);
info.ap_off_center            = sparnum(fd);
info.lr_off_center            = sparnum(fd);
info.cc_off_center            = sparnum(fd);
info.ap_angulation            = sparnum(fd);
info.lr_angulation            = sparnum(fd);
info.cc_angulation            = sparnum(fd);
info.volume_selection_method  = sparstr(fd);
info.t1_measurement_enable    = sparstr(fd);
info.t2_measurement_enable    = sparstr(fd);
info.time_series_enable       = sparstr(fd);
info.phase_encoding_enable    = sparstr(fd);
info.nr_phase_encoding_profiles = sparnum(fd);
info.si_ap_off_center         = sparnum(fd);
info.si_lr_off_center         = sparnum(fd);
info.si_cc_off_center         = sparnum(fd);
info.si_ap_off_angulation     = sparnum(fd);
info.si_lr_off_angulation     = sparnum(fd);
info.si_cc_off_angulation     = sparnum(fd); 
info.t0_kx_direction          = sparnum(fd);
info.t0_ky_direction          = sparnum(fd);
info.nr_of_phase_encoding_profiles_ky = sparnum(fd);
info.phase_encoding_direction = sparstr(fd);
info.phase_encoding_fov       = sparnum(fd);
info.slice_thickness          = sparnum(fd);
info.ps_slice_orientation     = sparstr(fd);
info.ps_ap_off_center         = sparnum(fd);
info.ps_lr_off_center         = sparnum(fd);
info.ps_cc_off_center         = sparnum(fd);
info.ps_ap_angulation         = sparnum(fd);
info.ps_lr_angulation         = sparnum(fd);
info.ps_cc_angulation         = sparnum(fd);
info.image_in_plane_transf    = sparstr(fd);
info.spec_data_type           = sparstr(fd);
info.spec_sample_extension    = sparstr(fd);
info.spec_num_col             = sparnum(fd);
info.spec_col_lower_val       = sparnum(fd);
info.spec_col_upper_val       = sparnum(fd);
info.spec_col_extension       = sparstr(fd);
info.spec_num_row             = sparnum(fd);
info.spec_row_lower_val       = sparnum(fd);
info.spec_row_upper_val       = sparnum(fd);
info.spec_row_extension       = sparstr(fd);
info.SUN_num_dimensions       = sparnum(fd);
info.SUN_dim1_ext             = sparstr(fd);
info.SUN_dim1_pnts            = sparnum(fd);
info.SUN_dim1_low_val         = sparnum(fd);
info.SUN_dim1_step            = sparnum(fd);
info.SUN_dim1_direction       = sparstr(fd);
info.SUN_dim1_t0_point        = sparnum(fd);
info.SUN_dim2_ext             = sparstr(fd);
info.SUN_dim2_pnts            = sparnum(fd);
info.SUN_dim2_low_val         = sparnum(fd);
info.SUN_dim2_step            = sparnum(fd);
info.SUN_dim2_direction       = sparstr(fd);
info.SUN_dim2_t0_point        = sparnum(fd);
info.SUN_dim3_ext             = sparstr(fd);
info.SUN_dim3_pnts            = sparnum(fd);
info.SUN_dim3_low_val         = sparnum(fd);
info.SUN_dim3_step            = sparnum(fd);
info.SUN_dim3_direction       = sparstr(fd);
info.SUN_dim3_t0_point        = sparnum(fd);

% Close file
fclose(fd);
