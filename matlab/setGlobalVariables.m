%% Global variables for the CMOS array and Meabench analysis code
%     Douglas Bakkum 2012
%
%  To add global variables, add below and run the code to save a
%  global_cmos.mat file. Then load this file whenever needed.
%
%


clear all

GAIN            =  0.762;  % convert to uV (normal settings give 0.762uV/digi in Meabench)
FREQ_HZ         =  20000;  % sampling frequency
FREQ_KHZ        =     20;  % sampling frequency (kHz)
NCHAN           =    126;  % number of recording channels
NDAC            =      2;  % number of dac channels
NELC            =  11016;  % number of electrodes, including dummies
[ELC.X ELC.Y]   = el2position(0:NELC-1); % electrode positions


% electrode sizes.  default v2 is type "M Pt3um default" 8.2x5.8um
ELC_M_Pt3um.X   = 8.2; % um
ELC_M_Pt3um.Y   = 5.8; % um  % from unique(diff(mposy))



save('global_cmos.mat');










