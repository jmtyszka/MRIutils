function stats = motion_analysis(moco_par_file, do_plot, do_report)
% Report statistics of FSL rigid body motion regression parameters
%
% USAGE: 
%
% ARGS:
% moco_par_file = filename of FSL motion parameter file
% do_plot       = flag to plot total rotation/displacement timeseries
% do_report     = flag for text reporting
%
% AUTHOR : Mike Tyszka, Ph.D.
% PLACE  : Caltech
% DATES  : 02/10/2012 JMT From scratch
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

% Default arguments
if nargin < 1
  [fname, dname] = uigetfile('*.par','Select motion parameter file');
  if isequal(fname,0) || isequal(dname,0)
    return
  end
  moco_par_file = fullfile(dname, fname);
end

if nargin < 2; do_plot   = false; end
if nargin < 3; do_report = false; end

% Load and parse file
C = textread(moco_par_file);

% Parse rotation (radians) columns and convert to milliradians 
theta_x_mrad = C(:,1) * 1e3;
theta_y_mrad = C(:,2) * 1e3;
theta_z_mrad = C(:,3) * 1e3;

% Create millidegree copies for rotation timeseries (for reports, graphs)
theta_x_mdeg = theta_x_mrad * 180/pi;
theta_y_mdeg = theta_y_mrad * 180/pi;
theta_z_mdeg = theta_z_mrad * 180/pi;

% Parse displacement (mm) columns and convert to microns
d_x_um = C(:,4) * 1e3;
d_y_um = C(:,5) * 1e3;
d_z_um = C(:,6) * 1e3;

% Total rotation angle/axis at each time point in milliradians
[theta_total_mrad, axis_total] = total_rotation(theta_x_mrad, theta_y_mrad, theta_z_mrad);

% Total displacement in microns at each time point
d_total_um = sqrt(d_x_um.^2 + d_y_um.^2 + d_z_um.^2);

% Temporal differences
dd_x_um = [diff(d_x_um); 0];
dd_y_um = [diff(d_y_um); 0];
dd_z_um = [diff(d_z_um); 0];
dtheta_x_mrad = [diff(theta_x_mrad); 0];
dtheta_y_mrad = [diff(theta_y_mrad); 0];
dtheta_z_mrad = [diff(theta_z_mrad); 0];

% Total displacement difference
dd_total_um = sqrt(dd_x_um.^2 + dd_y_um.^2 + dd_z_um.^2);

% Total rotation/axis difference
[dtheta_total_mrad, daxis_total] = total_rotation(dtheta_x_mrad, dtheta_y_mrad, dtheta_z_mrad);

% Calculate mean/sd displacement results in microns
stats.mean_d_total_um  = mean(d_total_um);
stats.sd_d_total_um    = std(d_total_um);
stats.max_d_total_um   = max(d_total_um);
stats.mean_dd_total_um = mean(dd_total_um);
stats.sd_dd_total_um   = std(dd_total_um);
stats.max_dd_total_um  = max(dd_total_um);

% Calculated mean/sd rotation results and convert to millidegrees

theta_total_mdeg  = theta_total_mrad * 180/pi;
dtheta_total_mdeg = dtheta_total_mrad * 180/pi;

stats.mean_theta_total_mdeg  = mean(theta_total_mdeg);
stats.sd_theta_total_mdeg    = std(theta_total_mdeg);
stats.max_theta_total_mdeg   = max(theta_total_mdeg);
stats.mean_dtheta_total_mdeg = mean(dtheta_total_mdeg);
stats.sd_dtheta_total_mdeg   = std(dtheta_total_mdeg);
stats.max_dtheta_total_mdeg  = max(dtheta_total_mdeg);

%% Plot results

if do_plot
  
  figure(1), clf;
  
  t = 1:length(d_x_um);
  
  subplot(321), plot(t, d_x_um, t, d_y_um, t, d_z_um);
  legend('x','y','z');
  title('Displacement (um)');
  
  subplot(322), plot(t, theta_x_mdeg, t, theta_y_mdeg, t, theta_z_mdeg);
  legend('x','y','z');
  title('Rotation (mdeg)');

  subplot(323), ax1 = plotyy(t, d_total_um, t, theta_total_mdeg);
  set(get(ax1(1),'Ylabel'),'String','Total Displacement (um)')
  set(get(ax1(2),'Ylabel'),'String','Total Rotation (mdeg)')
  title('Total displacement and rotation');
  
  subplot(324), plot(t, axis_total(:,1), t, axis_total(:,2), t, axis_total(:,3));
  legend('x','y','z');
  title('Total rotation axis vector')
  
  subplot(325), ax2 = plotyy(t, dd_total_um, t, dtheta_total_mdeg);
  set(get(ax2(1),'Ylabel'),'String','Total F-F Displacement (um)')
  set(get(ax2(2),'Ylabel'),'String','Total F-F Rotation (mdeg)')
  title('Total Frame-to-Frame displacement and rotation');
  
  subplot(326), plot(t, daxis_total(:,1), t, daxis_total(:,2), t, daxis_total(:,3));
  legend('x','y','z');
  title('Total F-F rotation axis vector');
  
  drawnow
  
end

%% Write text report to command window

if do_report
  
  fprintf('Motion Analysis\n');
  fprintf('---------------\n');
  fprintf('MoCo file     : %s\n', moco_par_file);
  fprintf('Analysis Date : %s\n', datestr(now));
  fprintf('\n');
  
  fprintf('Total displacement : %0.3f (%0.3f) [ %0.3f - %0.3f ]\n', ...
    stats.mean_d_total_um, stats.sd_d_total_um, min(d_total_um), max(d_total_um));
  
  fprintf('F-F displacement   : %0.3f (%0.3f) [ %0.3f - %0.3f ]\n', ...
    stats.mean_dd_total_um, stats.sd_dd_total_um, min(dd_total_um), max(dd_total_um));
  
  fprintf('Total rotation     : %0.3f (%0.3f) [ %0.3f - %0.3f ]\n', ...
    stats.mean_theta_total_mdeg, stats.sd_theta_total_mdeg, min(theta_total_mdeg), max(theta_total_mdeg));
  
  fprintf('F-F rotation       : %0.3f (%0.3f) [ %0.3f - %0.3f ]\n', ...
    stats.mean_dtheta_total_mdeg, stats.sd_dtheta_total_mdeg, min(dtheta_total_mdeg), max(dtheta_total_mdeg));
  
  fprintf('---------------\n');
  fprintf('Displacements in microns (um)\n');
  fprintf('Rotations in millidegrees (mdeg)\n');
  fprintf('Values quoted as mean (sd) [ min - max ]\n');
  
end

