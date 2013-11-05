%% David's image alignment code (see notes 130903 for instructions)
%  code copied from svn:matlab/trunk/StimFootprint/ImgAlign_script.m - 2013.09.03
%


%% set path

clear all
close all

im_path='/home/bakkumd/Data_bak/130903-testDavidsAlignmentCode/';
im_path='/home/bakkumd/Data_bak/131014-lipofection/';

% %% params

reversed=0; % set to one if chip was oriented incorrectly during imaging


% %% if needed to check elcalibrate1

els=hidens_get_all_electrodes(3,1)

figure

if reversed
    plot_electrode_map(els,'el_idx','reverse')
else
    plot_electrode_map(els,'el_idx')
end

% %% calibrate params

cal_index       =     1;
cal_electrode   = 10607; % Electrode number to use for calibration 
                         % 11015 is bottom of second to last right column
                         %   . . . . 
                         %    . . . .
                         %   . . . . 
                         %    . . . .
                         %   . . . o
                         
                         
%% Calibrate
%  use defaults (?) 
%  (Step 1) click on the calibration electrode
%  (Step 2) draw a vertical line for angle adjustment

dat_cal         = load_lif_file([im_path 'Calibrate' num2str(cal_index) '.lif']);

cal             = calibrate_DM6000B(dat_cal,'which_el',cal_electrode, 'do_plots');

save([im_path 'Calibration_' num2str(cal_index) '.mat'],'cal'); % easiest way to store calibration


%%
% Match electrodes (same as in Urs code) - >File>ExportToWorkspace ; 'enter' ; 'enter' ; 'ok' (warning box)

dat2=load_lif_file([im_path 'Calibrate_obj.lif']);
obj_cal=perform_objective_calibration(dat2);
save([im_path 'Calibration_obj.mat'],'obj_cal');


%%


% ----------------------------------------------------------------------- %
% ----------------------------------------------------------------------- %


%% Load calibration data

load([im_path 'Calibration_' num2str(cal_index) '.mat'],'cal'); % easiest way to store calibration
load([im_path 'Calibration_obj.mat'],'obj_cal'); 


%% Load experiment pictures and align

dat3=load_lif_file([im_path 'Experiment_001.lif'])

clear transformed
for i=1:length(dat3)
    if reversed
        transformed{i}=transform_align_image(dat3,i,cal,obj_cal, 'crop_method','keep_size')
    else
        transformed{i}=transform_align_image(dat3,i,cal,obj_cal,'not_reversed', 'crop_method','keep_size')
    end
end

%% Plot all pictures together

figure;
hold on
for ii=1%:length(transformed)
    plot_aligned_image(transformed{ii})
end
axis ij

% plot_electrode_map(els,'el_idx')
% clickelectrode



