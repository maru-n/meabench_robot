%% analysis of stim parameters



%% -- 090623-B (334) 39DIV, k seeding
% reliability in time drops to zero! too fast stim??
% large jitter (~1ms) -- maybe monosynaptic connection?
% **Appears to possibly b monosynaptic neuron - maybe an IN being evoked by
% an unobserved EN (EN->IN supposedly strong and reliable synapse).

% try for record ele in upper left corner too ##

clear all;
Info.Exptitle='090623-B'; 
expt     =['/home/bakkum/spikes/spikeform/' Info.Exptitle '.spikeform'];
spikefile=['/home/bakkum/spikes/' Info.Exptitle '.spike']
rawfile  =['/home/bakkum/raw/' Info.Exptitle '.raw']
trigfile =['/home/bakkum/raw/' Info.Exptitle '.raw.trig']
mapfile  = '/opt/cmosmea_external/configs/090622-A-spont-closeblock/090622-A-stimsetup_neuromap.m';

tlen=300;       % -5 to 10 ms (peaks not aligned in rawsrv...)
tzero=101;
ntrig=1224;
stim_el=10188;  % 300ms ISI
adc=2.99;       % range [volts]
record_el=[9257 9256]; % target neuron's electrode (THIS appears to be IN)
% record_el=[8745]; % similar behavior to others

%% -- 090623-C (334) 39DIV, k seeding
% **Appears to possibly b monosynaptic neuron - maybe an IN being evoked by
% an unobserved EN (EN->IN supposedly strong and reliable synapse).
clear all;
Info.Exptitle='090623-C'; 
expt     =['/home/bakkum/spikes/spikeform/' Info.Exptitle '.spikeform'];
spikefile=['/home/bakkum/spikes/' Info.Exptitle '.spike']
rawfile  =['/home/bakkum/raw/' Info.Exptitle '.raw']
trigfile =['/home/bakkum/raw/' Info.Exptitle '.raw.trig']
mapfile  = '/opt/cmosmea_external/configs/090622-A-spont-closeblock/090622-A-stimsetup_neuromap.m';

tlen=300;       % -5 to 10 ms (peaks not aligned in rawsrv...)
tzero=101;
stim_el=10188;  % 1Hz
ntrig=1224;
adc=2.99;       % range [volts]
record_el=[9257 9256]; % target neuron's electrode (THIS appears to be IN)
% record_el=[8745]; % similar behavior to others

%%
%%
%% -- 090718-B (253) 31DIV, 5k seeding
% GOOD data
clear all;
Info.Exptitle='090718-B'; 
expt     =['/home/bakkum/spikes/spikeform/' Info.Exptitle '.spikeform'];
spikefile=['/home/bakkum/spikes/' Info.Exptitle '.spike']
rawfile  =['/home/bakkum/raw/' Info.Exptitle '.raw']
trigfile =['/home/bakkum/raw/' Info.Exptitle '.raw.trig']
mapfile  = '/opt/cmosmea_external/configs/090718-stimscan/stimparam-B_neuromap.m';
el2fifile= '/opt/cmosmea_external/configs/090718-stimscan/stimparam-B.el2fi.nrk2';

tlen=300;       % -5 to 10 ms (peaks not aligned in rawsrv...)
tzero=101;
ntrig=1400;
stim_el=2029;   % 1Hz
adc=2.99;       % range [volts]
record_el=[7032 6931]; % target neuron's electrode (POSITIVE spikes)


%%
%%
%% -- 090824-A (308) 28DIV, 5.2k seeding
%     090824-B (308) 28DIV, 5.2k seeding
%     090824-C (308) 28DIV, 5.2k seeding
%  !! BAD STIMULI (mostly 400 us widths) due to error in FPGA update !! 
%
% clear all;
% Info.Exptitle='090824-A'; 
% expt     =['/home/bakkum/spikes/spikeform/' Info.Exptitle '.spikeform'];
% spikefile=['/home/bakkum/spikes/' Info.Exptitle '.spike']
% rawfile  =['/home/bakkum/raw/' Info.Exptitle '.raw']
% trigfile =['/home/bakkum/raw/' Info.Exptitle '.raw.trig']
% mapfile  = '/opt/cmosmea_external/configs/090824-stimparam/090824-A_neuromap.m';
% el2fifile= '/opt/cmosmea_external/configs/090824-stimparam/090824-A.el2fi.nrk2';
% 
% tlen=300;       % -5 to 10 ms (peaks not aligned in rawsrv...)
% tzero=105;  % % % PROBLEM with DAC timing between DAC1 and DAC2...
% ntrig=2479;
% stim_el=5332;   % 1Hz
% adc=2.99;       % range [volts]
% record_el=[2532 2533]; % target neuron's electrode 

%% -- 090825-A (308) 29DIV, 5.2k seeding
% 
clear all;
Info.Exptitle='090825-A'; 
expt     =['/home/bakkum/spikes/spikeform/' Info.Exptitle '.spikeform'];
spikefile=['/home/bakkum/spikes/' Info.Exptitle '.spike']
rawfile  =['/home/bakkum/raw/' Info.Exptitle '.raw']
trigfile =['/home/bakkum/raw/' Info.Exptitle '.raw.trig']
mapfile  = '/opt/cmosmea_external/configs/090825-stimparam/090825-A_neuromap.m';
el2fifile= '/opt/cmosmea_external/configs/090825-stimparam/090825-A.el2fi.nrk2';

tlen=300;       % -5 to 10 ms (peaks not aligned in rawsrv...)
tzero=101;
ntrig=2756;
stim_el=5683;   % 2Hz
adc=2.99;       % range [volts]
record_el=[4653]; % target neuron's electrode 

%% -- 090825-B (308) 29DIV, 5.2k seeding
% 
clear all;
Info.Exptitle='090825-B'; 
expt     =['/home/bakkum/spikes/spikeform/' Info.Exptitle '.spikeform'];
spikefile=['/home/bakkum/spikes/' Info.Exptitle '.spike']
rawfile  =['/home/bakkum/raw/' Info.Exptitle '.raw']
trigfile =['/home/bakkum/raw/' Info.Exptitle '.raw.trig']
mapfile  = '/opt/cmosmea_external/configs/090825-stimparam/090825-B_neuromap.m';
el2fifile= '/opt/cmosmea_external/configs/090825-stimparam/090825-B.el2fi.nrk2';

tlen=300;       % -5 to 10 ms (peaks not aligned in rawsrv...)
tzero=101;
ntrig=2454;
stim_el=3027;   % 2Hz
adc=2.99;       % range [volts]
record_el=[1343]; % target neuron's electrode 



%%   !!!!!!!!!!!!!!!

%   ## need to check if correct record_el -- doesnt look clean
%   ## do a raster plot....
    
%% -- 100926-B (517) 65DIV, 44k seeding -- vary phase1 volt,width and phase2 volt,width
% 
clear all;
Info.Exptitle='100926-B'; 
expt     =['/local0/bakkumd/spikes/spikeform/' Info.Exptitle '.spikeform'];
spikefile=['/local0/bakkumd/spikes/' Info.Exptitle '.spike']
rawfile  =['/local0/bakkumd/raw/' Info.Exptitle '.raw']
trigfile =['/local0/bakkumd/raw/' Info.Exptitle '.raw.trig']
mapfile  = '/local0/bakkumd/configs/bakkum/100926/100926-B_neuromap.m';
el2fifile= '/local0/bakkumd/configs/bakkum/100926/100926-B.el2fi.nrk2';

tlen=300;       % -3 to 12 ms 
tzero=61;
ntrig=2000;
stim_el=7580;   % 2Hz
stim_el_n=[7478 7579 7581 7681 7683 7682]; % neighboring elc
adc=2.99;       % range [volts]
record_el=[8393]; % target neuron's electrode 

%% -- 100926-C (517) 65DIV, 44k seeding -- vary phase1, phase2, and phase3 volt,width
% 
% 
clear all;
Info.Exptitle='100926-C'; 
expt     =['/local0/bakkumd/spikes/spikeform/' Info.Exptitle '.spikeform'];
spikefile=['/local0/bakkumd/spikes/' Info.Exptitle '.spike']
rawfile  =['/local0/bakkumd/raw/' Info.Exptitle '.raw']
trigfile =['/local0/bakkumd/raw/' Info.Exptitle '.raw.trig']
mapfile  = '/local0/bakkumd/configs/bakkum/100926/100926-B_neuromap.m';
el2fifile= '/local0/bakkumd/configs/bakkum/100926/100926-B.el2fi.nrk2';

tlen=300;       % -3 to 12 ms 
tzero=61;
ntrig=2000;
stim_el=7580;   % 2Hz
stim_el_n=[7478 7579 7581 7681 7683 7682]; % neighboring elc
adc=2.99;       % range [volts]
record_el=[8393]; % target neuron's electrode 
%% -- 100930-A (517) 69DIV, 44k seeding -- vary volt ratio phase1 and phase3 - charge balanced
%  !!! use 101001-A instead !!!
% 
clear all;
Info.Exptitle='100930-A'; 
expt     =['/local0/bakkumd/spikes/spikeform/' Info.Exptitle '.spikeform'];
spikefile=['/local0/bakkumd/spikes/' Info.Exptitle '.spike']
rawfile  =['/local0/bakkumd/raw/' Info.Exptitle '.raw']
trigfile =['/local0/bakkumd/raw/' Info.Exptitle '.raw.trig']
mapfile  = '/local0/bakkumd/configs/bakkum/100926/100926-B_neuromap.m';
el2fifile= '/local0/bakkumd/configs/bakkum/100926/100926-B.el2fi.nrk2';

tlen=300;       % -3 to 12 ms 
tzero=61;
ntrig=400;
stim_el=7580;   % 2Hz
stim_el_n=[7478 7579 7581 7681 7683 7682]; % neighboring elc
stim_el_2=[7376 7477 7479 7476 7582 7578 7684 7680 7786 7783 7785 7784]; % next neighboring elc
adc=2.99;       % range [volts]
record_el=[]; % target neuron's electrode 
%% -- 101001-A (517) 70DIV, 44k seeding -- vary volt ratio phase1 and phase3 - charge balanced
%  
% 
clear all;
Info.Exptitle='101001-A'; 
expt     =['/local0/bakkumd/spikes/spikeform/' Info.Exptitle '.spikeform'];
spikefile=['/local0/bakkumd/spikes/' Info.Exptitle '.spike']
rawfile  =['/local0/bakkumd/raw/' Info.Exptitle '.raw']
trigfile =['/local0/bakkumd/raw/' Info.Exptitle '.raw.trig']
mapfile  = '/local0/bakkumd/configs/bakkum/100926/100926-B_neuromap.m';
el2fifile= '/local0/bakkumd/configs/bakkum/100926/100926-B.el2fi.nrk2';

tlen=300;       % -3 to 12 ms 
tzero=61;
ntrig=800;
stim_el=7580;   % 2Hz
stim_el_n=[7478 7579 7581 7681 7683 7682]; % neighboring elc
stim_el_2=[7376 7477 7479 7476 7582 7578 7684 7680 7786 7783 7785 7784]; % next neighboring elc
adc=2.99;       % range [volts]
record_el=[]; % target neuron's electrode 


%% -- 101001-B (517) 70DIV, 44k seeding -- vary volt ratio phase1 and phase3 REVERSED - charge balanced
%  
% 
clear all;
Info.Exptitle='101001-B'; 
expt     =['/local0/bakkumd/spikes/spikeform/' Info.Exptitle '.spikeform'];
spikefile=['/local0/bakkumd/spikes/' Info.Exptitle '.spike']
rawfile  =['/local0/bakkumd/raw/' Info.Exptitle '.raw']
trigfile =['/local0/bakkumd/raw/' Info.Exptitle '.raw.trig']
mapfile  = '/local0/bakkumd/configs/bakkum/100926/100926-B_neuromap.m';
el2fifile= '/local0/bakkumd/configs/bakkum/100926/100926-B.el2fi.nrk2';

tlen=300;       % -3 to 12 ms 
tzero=61;
ntrig=800;
stim_el=7580;   % 2Hz
stim_el_n=[7478 7579 7581 7681 7683 7682]; % neighboring elc
stim_el_2=[7376 7477 7479 7476 7582 7578 7684 7680 7786 7783 7785 7784]; % next neighboring elc
adc=2.99;       % range [volts]
record_el=[]; % target neuron's electrode 

%% -- 101001-C (517) 70DIV, 44k seeding -- vary volt ratio phase1 and phase3 NORMAL+REVERSED - charge balanced
%                                       -- increased width from 100us to 200us
% 
clear all;
Info.Exptitle='101001-C'; 
expt     =['/local0/bakkumd/spikes/spikeform/' Info.Exptitle '.spikeform'];
spikefile=['/local0/bakkumd/spikes/' Info.Exptitle '.spike']
rawfile  =['/local0/bakkumd/raw/' Info.Exptitle '.raw']
trigfile =['/local0/bakkumd/raw/' Info.Exptitle '.raw.trig']
mapfile  = '/local0/bakkumd/configs/bakkum/100926/100926-B_neuromap.m';
el2fifile= '/local0/bakkumd/configs/bakkum/100926/100926-B.el2fi.nrk2';

tlen=300;       % -3 to 12 ms 
tzero=61;
ntrig=800;
stim_el=7580;   % 2Hz
stim_el_n=[7478 7579 7581 7681 7683 7682]; % neighboring elc
stim_el_2=[7376 7477 7479 7476 7582 7578 7684 7680 7786 7783 7785 7784]; % next neighboring elc
adc=2.99;       % range [volts]
record_el=[]; % target neuron's electrode 

%% -- 101003-A (517) 72DIV, 44k seeding -- vary volt ratio phase1 and phase3 NORMAL+REVERSED - charge balanced
%                                       -- width 200us -- NEW config
% 
clear all;
Info.Exptitle='101003-A'; 
expt     =['/local0/bakkumd/spikes/spikeform/' Info.Exptitle '.spikeform'];
spikefile=['/local0/bakkumd/spikes/' Info.Exptitle '.spike']
rawfile  =['/local0/bakkumd/raw/' Info.Exptitle '.raw']
trigfile =['/local0/bakkumd/raw/' Info.Exptitle '.raw.trig']
mapfile  = '/local0/bakkumd/configs/bakkum/101003/101003-A_neuromap.m';
el2fifile= '/local0/bakkumd/configs/bakkum/101003/101003-A.el2fi.nrk2';

tlen=300;       % -3 to 12 ms 
tzero=61;
ntrig=800;
stim_el=1842;   % 2Hz
stim_el_n=[1741 1841 1843 1943 1945 1944]; % neighboring elc
stim_el_2=[1639 1740 1742 1739 1844 1840 1946 1942 2048 2045 2047 2046]; % next neighboring elc
adc=2.99;       % range [volts]
record_el=[]; % target neuron's electrode 


%% -- 101003-B (517) 72DIV, 44k seeding -- vary volt ratio phase1 and phase3 NORMAL+REVERSED - charge balanced
%                                       -- width 200us -- NEW config
% 
clear all;
Info.Exptitle='101003-B'; 
expt     =['/local0/bakkumd/spikes/spikeform/' Info.Exptitle '.spikeform'];
spikefile=['/local0/bakkumd/spikes/' Info.Exptitle '.spike']
rawfile  =['/local0/bakkumd/raw/' Info.Exptitle '.raw']
trigfile =['/local0/bakkumd/raw/' Info.Exptitle '.raw.trig']
mapfile  = '/local0/bakkumd/configs/bakkum/101003/101003-B_neuromap.m';
el2fifile= '/local0/bakkumd/configs/bakkum/101003/101003-B.el2fi.nrk2';

tlen=300;       % -3 to 12 ms 
tzero=61;
ntrig=800;
stim_el=8438;   % 2Hz
stim_el_n=[8336 8335 8337 8437 8439 8540]; % neighboring elc
stim_el_2=[8234 8233 8235 8334 8338 8436 8440 8538 8542 8539 8541 8642]; % next neighboring elc
adc=2.99;       % range [volts]
record_el=[]; % target neuron's electrode 


%% -- 101003-C (517) 72DIV, 44k seeding -- vary volt ratio phase1 and phase3 NORMAL+REVERSED - charge balanced
%                                       -- width 200us -- NEW config
% 
clear all;
Info.Exptitle='101003-C'; 
expt     =['/local0/bakkumd/spikes/spikeform/' Info.Exptitle '.spikeform'];
spikefile=['/local0/bakkumd/spikes/' Info.Exptitle '.spike']
rawfile  =['/local0/bakkumd/raw/' Info.Exptitle '.raw']
trigfile =['/local0/bakkumd/raw/' Info.Exptitle '.raw.trig']
mapfile  = '/local0/bakkumd/configs/bakkum/101003/101003-C_neuromap.m';
el2fifile= '/local0/bakkumd/configs/bakkum/101003/101003-C.el2fi.nrk2';

tlen=300;       % -3 to 12 ms 
tzero=61;
ntrig=800;
stim_el=1842;   % 2Hz
stim_el_n=[1741 1841 1843 1943 1945 1944]; % neighboring elc
stim_el_2=[1639 1740 1742 1739 1844 1840 1946 1942 2048 2045 2047 2046]; % next neighboring elc
adc=2.99;       % range [volts]
record_el=[]; % target neuron's electrode 



%% -- 101003-D (517) 72DIV, 44k seeding -- vary volt ratio phase1 and phase3 NORMAL+REVERSED - charge balanced
%                                       -- width 200us -- ZOOM IN 95-100% ratios only
% 
clear all;
Info.Exptitle='101003-D'; 
expt     =['/local0/bakkumd/spikes/spikeform/' Info.Exptitle '.spikeform'];
spikefile=['/local0/bakkumd/spikes/' Info.Exptitle '.spike']
rawfile  =['/local0/bakkumd/raw/' Info.Exptitle '.raw']
trigfile =['/local0/bakkumd/raw/' Info.Exptitle '.raw.trig']
mapfile  = '/local0/bakkumd/configs/bakkum/101003/101003-C_neuromap.m';
el2fifile= '/local0/bakkumd/configs/bakkum/101003/101003-C.el2fi.nrk2';

tlen=300;       % -3 to 12 ms 
tzero=61;
ntrig=800;
stim_el=1842;   % 2Hz
stim_el_n=[1741 1841 1843 1943 1945 1944]; % neighboring elc
stim_el_2=[1639 1740 1742 1739 1844 1840 1946 1942 2048 2045 2047 2046]; % next neighboring elc
adc=2.99;       % range [volts]
record_el=[]; % target neuron's electrode 


%% -- 101003-E (517) 72DIV, 44k seeding -- vary volt ratio phase1 and phase3 NORMAL+REVERSED - charge balanced
%                                       -- repeat A, use new amp settings
%                                       A1 30fc70  A2 30fc20  A3 --
% 
clear all;
Info.Exptitle='101003-E'; 
expt     =['/local0/bakkumd/spikes/spikeform/' Info.Exptitle '.spikeform'];
spikefile=['/local0/bakkumd/spikes/' Info.Exptitle '.spike']
rawfile  =['/local0/bakkumd/raw/' Info.Exptitle '.raw']
trigfile =['/local0/bakkumd/raw/' Info.Exptitle '.raw.trig']
mapfile  = '/local0/bakkumd/configs/bakkum/101003/101003-A_neuromap.m';
el2fifile= '/local0/bakkumd/configs/bakkum/101003/101003-A.el2fi.nrk2';

tlen=300;       % -3 to 12 ms 
tzero=61;
ntrig=800;
stim_el=1842;   % 2Hz
stim_el_n=[1741 1841 1843 1943 1945 1944]; % neighboring elc
stim_el_2=[1639 1740 1742 1739 1844 1840 1946 1942 2048 2045 2047 2046]; % next neighboring elc
adc=2.99;       % range [volts]
record_el=[]; % target neuron's electrode 


%% -- 101003-F (517) 72DIV, 44k seeding -- vary volt ratio phase1 and phase3 NORMAL+REVERSED - charge balanced
%                                       -- repeat A, use new amp settings
%                                       A1 30fc20  A2 10fc16  A3 2
% 
clear all;
Info.Exptitle='101003-F'; 
expt     =['/local0/bakkumd/spikes/spikeform/' Info.Exptitle '.spikeform'];
spikefile=['/local0/bakkumd/spikes/' Info.Exptitle '.spike']
rawfile  =['/local0/bakkumd/raw/' Info.Exptitle '.raw']
trigfile =['/local0/bakkumd/raw/' Info.Exptitle '.raw.trig']
mapfile  = '/local0/bakkumd/configs/bakkum/101003/101003-A_neuromap.m';
el2fifile= '/local0/bakkumd/configs/bakkum/101003/101003-A.el2fi.nrk2';

tlen=300;       % -3 to 12 ms 
tzero=61;
ntrig=800;
stim_el=1842;   % 2Hz
stim_el_n=[1741 1841 1843 1943 1945 1944]; % neighboring elc
stim_el_2=[1639 1740 1742 1739 1844 1840 1946 1942 2048 2045 2047 2046]; % next neighboring elc
adc=2.99;       % range [volts]
record_el=[]; % target neuron's electrode 


%% -- 101001-G (517) 70DIV, 44k seeding -- vary volt ratio phase1 and phase3 NORMAL+REVERSED - charge balanced
%                                       -- decreased width back to 100us 
%                                       -- TRIANGLE pulses,  config from 101001-C
% 
clear all;
Info.Exptitle='101003-G'; 
expt     =['/local0/bakkumd/spikes/spikeform/' Info.Exptitle '.spikeform'];
spikefile=['/local0/bakkumd/spikes/' Info.Exptitle '.spike']
rawfile  =['/local0/bakkumd/raw/' Info.Exptitle '.raw']
trigfile =['/local0/bakkumd/raw/' Info.Exptitle '.raw.trig']
mapfile  = '/local0/bakkumd/configs/bakkum/100926/100926-B_neuromap.m';
el2fifile= '/local0/bakkumd/configs/bakkum/100926/100926-B.el2fi.nrk2';

tlen=300;       % -3 to 12 ms 
tzero=61;
ntrig=800;
stim_el=7580;   % 2Hz
stim_el_n=[7478 7579 7581 7681 7683 7682]; % neighboring elc
stim_el_2=[7376 7477 7479 7476 7582 7578 7684 7680 7786 7783 7785 7784]; % next neighboring elc
adc=2.99;       % range [volts]
record_el=[]; % target neuron's electrode 


%% -- 101001-H (517) 70DIV, 44k seeding -- vary volt ratio phase1 and phase3 NORMAL+REVERSED - charge balanced
%                                       -- decreased width back to 100us 
%                                       -- TRIANGLE pulses,  config from 101001-C
%                                       -- REPEAT OF G w/o DAC2 -- TEST if
%                                       DAC2 is affecting current avaible to DAC1/stim_el and subsequent artifacts
% 
clear all;
Info.Exptitle='101003-H';
expt     =['/local0/bakkumd/spikes/spikeform/' Info.Exptitle '.spikeform'];
spikefile=['/local0/bakkumd/spikes/' Info.Exptitle '.spike']
rawfile  =['/local0/bakkumd/raw/' Info.Exptitle '.raw']
trigfile =['/local0/bakkumd/raw/' Info.Exptitle '.raw.trig']
mapfile  = '/local0/bakkumd/configs/bakkum/100926/100926-B_neuromap.m';
el2fifile= '/local0/bakkumd/configs/bakkum/100926/100926-B.el2fi.nrk2';

tlen=300;       % -3 to 12 ms 
tzero=61;
ntrig=800;
stim_el=7580;   % 2Hz
stim_el_n=[7478 7579 7581 7681 7683 7682]; % neighboring elc
stim_el_2=[7376 7477 7479 7476 7582 7578 7684 7680 7786 7783 7785 7784]; % next neighboring elc
adc=2.99;       % range [volts]
record_el=[]; % target neuron's electrode 


%% -- 101004-A (517) 73DIV, 44k seeding -- vary volt ratio phase1 and phase3 NORMAL+REVERSED - charge balanced
%                                       -- width 100us
%                                       -- A1 30fc70   A2 10fc16   A3 2x
% 
clear all;
Info.Exptitle='101004-A'; 
expt     =['/local0/bakkumd/spikes/spikeform/' Info.Exptitle '.spikeform'];
spikefile=['/local0/bakkumd/spikes/' Info.Exptitle '.spike']
rawfile  =['/local0/bakkumd/raw/' Info.Exptitle '.raw']
trigfile =['/local0/bakkumd/raw/' Info.Exptitle '.raw.trig']
mapfile  = '/local0/bakkumd/configs/bakkum/101003/101003-A_neuromap.m';
el2fifile= '/local0/bakkumd/configs/bakkum/101003/101003-A.el2fi.nrk2';

tlen=300;       % -3 to 12 ms 
tzero=61;
ntrig=800;
stim_el=1842;   % 2Hz
stim_el_n=[1741 1841 1843 1943 1945 1944]; % neighboring elc
stim_el_2=[1639 1740 1742 1739 1844 1840 1946 1942 2048 2045 2047 2046]; % next neighboring elc
adc=2.99;       % range [volts]
record_el=[]; % target neuron's electrode 


%% -- 101004-B (517) 73DIV, 44k seeding -- vary volt ratio phase1 and phase3 NORMAL+REVERSED - charge balanced
%                                       -- change to width 200us
%                                       -- A1 30fc70   A2 10fc16   A3 2x
% 
clear all;
Info.Exptitle='101004-B'; 
expt     =['/local0/bakkumd/spikes/spikeform/' Info.Exptitle '.spikeform'];
spikefile=['/local0/bakkumd/spikes/' Info.Exptitle '.spike']
rawfile  =['/local0/bakkumd/raw/' Info.Exptitle '.raw']
trigfile =['/local0/bakkumd/raw/' Info.Exptitle '.raw.trig']
mapfile  = '/local0/bakkumd/configs/bakkum/101003/101003-A_neuromap.m';
el2fifile= '/local0/bakkumd/configs/bakkum/101003/101003-A.el2fi.nrk2';

tlen=300;       % -3 to 12 ms 
tzero=61;
ntrig=800;
stim_el=1842;   % 2Hz
stim_el_n=[1741 1841 1843 1943 1945 1944]; % neighboring elc
stim_el_2=[1639 1740 1742 1739 1844 1840 1946 1942 2048 2045 2047 2046]; % next neighboring elc
adc=2.99;       % range [volts]
record_el=[]; % target neuron's electrode 


%% -- 101004-C (517) 73DIV, 44k seeding -- vary volt ratio phase1 and phase3 NORMAL+REVERSED - charge balanced
%                                       -- width 200us -- ZOOM IN 95-100% ratios only
%                                       -- A1 30fc70   A2 10fc16   A3 2x
% 
clear all;
Info.Exptitle='101004-C';
expt     =['/local0/bakkumd/spikes/spikeform/' Info.Exptitle '.spikeform'];
spikefile=['/local0/bakkumd/spikes/' Info.Exptitle '.spike']
rawfile  =['/local0/bakkumd/raw/' Info.Exptitle '.raw']
trigfile =['/local0/bakkumd/raw/' Info.Exptitle '.raw.trig']
mapfile  = '/local0/bakkumd/configs/bakkum/101003/101003-A_neuromap.m';
el2fifile= '/local0/bakkumd/configs/bakkum/101003/101003-A.el2fi.nrk2';

tlen=300;       % -3 to 12 ms 
tzero=61;
ntrig=800;
stim_el=1842;   % 2Hz
stim_el_n=[1741 1841 1843 1943 1945 1944]; % neighboring elc
stim_el_2=[1639 1740 1742 1739 1844 1840 1946 1942 2048 2045 2047 2046]; % next neighboring elc
adc=2.99;       % range [volts]
record_el=[]; % target neuron's electrode 


%% -- 101004-D (517) 73DIV, 44k seeding -- vary volt ratio phase1 and phase3 NORMAL+REVERSED - charge balanced
%                                       -- width 200us
%                                       -- A1 30fc70   A2 10fc16   A3 2x
%                                       -- DISCONNECT DAC1 1samp after stim, connect 1samp before stim
%
clear all;
Info.Exptitle='101004-D';
expt     =['/local0/bakkumd/spikes/spikeform/' Info.Exptitle '.spikeform'];
spikefile=['/local0/bakkumd/spikes/' Info.Exptitle '.spike']
rawfile  =['/local0/bakkumd/raw/' Info.Exptitle '.raw']
trigfile =['/local0/bakkumd/raw/' Info.Exptitle '.raw.trig']
mapfile  = '/local0/bakkumd/configs/bakkum/101003/101003-A_neuromap.m';
el2fifile= '/local0/bakkumd/configs/bakkum/101003/101003-A.el2fi.nrk2';

tlen=300;       % -3 to 12 ms 
tzero=61;
ntrig=800;
stim_el=1842;   % 2Hz
stim_el_n=[1741 1841 1843 1943 1945 1944]; % neighboring elc
stim_el_2=[1639 1740 1742 1739 1844 1840 1946 1942 2048 2045 2047 2046]; % next neighboring elc
adc=2.99;       % range [volts]
record_el=[]; % target neuron's electrode 


%% -- 101004-E (517) 73DIV, 44k seeding -- vary volt ratio phase1 and phase3 NORMAL+REVERSED - charge balanced
%                                       -- width 200us
%                                       -- NORMAL gains: A1 30fc20   A2 30fc5   A3 -
%                                       -- DISCONNECT DAC1 1samp after stim, connect 1samp before stim
%
clear all;
Info.Exptitle='101004-E';
expt     =['/local0/bakkumd/spikes/spikeform/' Info.Exptitle '.spikeform'];
spikefile=['/local0/bakkumd/spikes/' Info.Exptitle '.spike']
rawfile  =['/local0/bakkumd/raw/' Info.Exptitle '.raw']
trigfile =['/local0/bakkumd/raw/' Info.Exptitle '.raw.trig']
mapfile  = '/local0/bakkumd/configs/bakkum/101003/101003-A_neuromap.m';
el2fifile= '/local0/bakkumd/configs/bakkum/101003/101003-A.el2fi.nrk2';

tlen=300;       % -3 to 12 ms 
tzero=61;
ntrig=800;
stim_el=1842;   % 2Hz
stim_el_n=[1741 1841 1843 1943 1945 1944]; % neighboring elc
stim_el_2=[1639 1740 1742 1739 1844 1840 1946 1942 2048 2045 2047 2046]; % next neighboring elc
adc=2.99;       % range [volts]
record_el=[]; % target neuron's electrode 

%% -- 101005-A (601) 15DIV, 30k seeding -- vary volt ratio phase1 and phase3 NORMAL+REVERSED - charge balanced
%                                       -- width 200us
%                                       -- NORMAL gains: A1 30fc20   A2 30fc5   A3 -
%                                       -- DISCONNECT DAC1 1samp after stim, connect 10samp before stim
%
clear all;
Info.Exptitle='101005-A';
expt     =['/local0/bakkumd/spikes/spikeform/' Info.Exptitle '.spikeform'];
spikefile=['/local0/bakkumd/spikes/' Info.Exptitle '.spike']
rawfile  =['/local0/bakkumd/raw/' Info.Exptitle '.raw']
trigfile =['/local0/bakkumd/raw/' Info.Exptitle '.raw.trig']
mapfile  = '/local0/bakkumd/configs/bakkum/101003/101003-A_neuromap.m';
el2fifile= '/local0/bakkumd/configs/bakkum/101003/101003-A.el2fi.nrk2';

tlen=300;       % -3 to 12 ms 
tzero=61;
ntrig=800;
stim_el=1842;   % 2Hz
stim_el_n=[1741 1841 1843 1943 1945 1944]; % neighboring elc
stim_el_2=[1639 1740 1742 1739 1844 1840 1946 1942 2048 2045 2047 2046]; % next neighboring elc
adc=2.99;       % range [volts]
record_el=[]; % target neuron's electrode 

%% -- 101005-B (601) 15DIV, 30k seeding -- vary volt ratio phase1 and phase3 NORMAL+REVERSED - charge balanced
%                                       -- width 200us
%                                       -- NORMAL gains: A1 30fc20   A2 30fc5   A3 -
%                                       -- DISCONNECT DAC1 2samp after stim (delay call +usleep(50)), connect 1samp before stim
%
clear all;
Info.Exptitle='101005-B';
expt     =['/local0/bakkumd/spikes/spikeform/' Info.Exptitle '.spikeform'];
spikefile=['/local0/bakkumd/spikes/' Info.Exptitle '.spike']
rawfile  =['/local0/bakkumd/raw/' Info.Exptitle '.raw']
trigfile =['/local0/bakkumd/raw/' Info.Exptitle '.raw.trig']
mapfile  = '/local0/bakkumd/configs/bakkum/101003/101003-A_neuromap.m';
el2fifile= '/local0/bakkumd/configs/bakkum/101003/101003-A.el2fi.nrk2';

tlen=300;       % -3 to 12 ms 
tzero=61;
ntrig=800;
stim_el=1842;   % 2Hz
stim_el_n=[1741 1841 1843 1943 1945 1944]; % neighboring elc
stim_el_2=[1639 1740 1742 1739 1844 1840 1946 1942 2048 2045 2047 2046]; % next neighboring elc
adc=2.99;       % range [volts]
record_el=[]; % target neuron's electrode 
%% -- 101005-C (601) 15DIV, 30k seeding -- vary volt ratio phase1 and phase3 NORMAL+REVERSED - charge balanced
%                                       -- width 200us
%                                       -- NEW gains: A1 30fc70   A2 10fc16   A3 2x
%                                       -- DISCONNECT DAC1 2samp after stim (delay call +usleep(50)), connect 1samp before stim
%
clear all;
Info.Exptitle='101005-C';
expt     =['/local0/bakkumd/spikes/spikeform/' Info.Exptitle '.spikeform'];
spikefile=['/local0/bakkumd/spikes/' Info.Exptitle '.spike']
rawfile  =['/local0/bakkumd/raw/' Info.Exptitle '.raw']
trigfile =['/local0/bakkumd/raw/' Info.Exptitle '.raw.trig']
mapfile  = '/local0/bakkumd/configs/bakkum/101003/101003-A_neuromap.m';
el2fifile= '/local0/bakkumd/configs/bakkum/101003/101003-A.el2fi.nrk2';

tlen=300;       % -3 to 12 ms 
tzero=61;
ntrig=800;
stim_el=1842;   % 2Hz
stim_el_n=[1741 1841 1843 1943 1945 1944]; % neighboring elc
stim_el_2=[1639 1740 1742 1739 1844 1840 1946 1942 2048 2045 2047 2046]; % next neighboring elc
adc=2.99;       % range [volts]
record_el=[]; % target neuron's electrode 


%% -- 101012-B (596) 22DIV, 30k seeding -- vary volt and width for pos-neg, neg-pos, pos, neg pulses
%                                       -- DISCONNECT DAC1 2samp after end of DAC2 encoding (usleep(50) = delay call), connect 1samp before stim
%
clear all;
Info.Exptitle='101012-B';
expt     =['/local0/bakkumd/spikes/spikeform/' Info.Exptitle '.spikeform'];
spikefile=['/local0/bakkumd/spikes/' Info.Exptitle '.spike']
rawfile  =['/local0/bakkumd/raw/' Info.Exptitle '.raw']
trigfile =['/local0/bakkumd/raw/' Info.Exptitle '.raw.trig']
mapfile  = '/local0/bakkumd/configs/bakkum/101012/101012-B_neuromap.m';
el2fifile= '/local0/bakkumd/configs/bakkum/101012/101012-B.el2fi.nrk2';

tlen=300;       % -3 to 12 ms 
tzero=61;
ntrig=1200;
stim_el=3124;   % 2Hz
stim_el_n=[]; % neighboring elc
stim_el_2=[]; % next neighboring elc
adc=2.99;       % range [volts]
record_el=[]; % target neuron's electrode 
avoid_el=[1967]; % noisy


%%

% 
% 
% del=40;    % [samples]
% thresh=80; % [digi]
% 
% 
% 
% del_l=50;  % [samples]  lower range of dAP after tzero
% del_u=100; % [samples]  upper range of dAP after tzero
% thresh=80; % [digi]     thresh of dAP

%%
%% create mapfile

%  cmd=['/opt/cpp/CMOS/bin/el2fi_to_neuromap -o ' mapfile ' -i ' el2fifile ]
%  system(cmd)

%%
%% mapfile loading/testing

map=load(mapfile,'-ascii');

ww=find(map(:,3)>100); % find connected chnls
ch=map(:,1);  % use these for re-running code
el=map(:,2);
px=map(:,3);
py=map(:,4);
idd=find(ch+1>0); % avoid non-connected channels
idn=find(ch<0);   % non-connected channels

clear record_ch
for i=1:length(record_el)
  record_ch(i)=ch(find(el==record_el(i)));
end

figure(111)
plot(px,py,'ro')
set(gca,'YDir','reverse','Color',[1 1 1]*1)
axis equal

stim_ch=ch(find(el==stim_el));
[stim_x stim_y]=el2position(stim_el);
hold on; plot(stim_x,stim_y,'k.'); hold off

ch_d=((px-stim_x).^2+(py-stim_y).^2).^.5;

%%% use mapfile to get and test neighbor locations
  c=0; c0=0; c1=0; c2=0; id=[]; id0=[]; id1=[]; id2=[];
  for i=idd'
      OK=1; OK0=0; OK1=0; OK2=0;
      if el(idd(i))==stim_el, OK=0; OK0=1;  end
      for ex=[stim_el_n] % elc to exclude
      if el(idd(i))==ex, OK=0; OK1=1; end
      end
      for ex=[stim_el_2] % elc to exclude
      if el(idd(i))==ex, OK=0; OK2=1; end
      end
      for ex=[avoid_el] % elc to exclude
      if el(idd(i))==ex, OK=0; end
      end
      if OK,    c=c+1;   id(c)=idd(i); end % all other electrodes
      if OK0, c0=c0+1; id0(c0)=idd(i); end % stim electrode
      if OK1, c1=c1+1; id1(c1)=idd(i); end % neighbor elc
      if OK2, c2=c2+1; id2(c2)=idd(i); end % next neighbor elc
  end
figure(111)
plot(px,py,'ko'), hold on
plot(px(id),py(id),'k.'); hold on
plot(px(id0),py(id0),'r.'); hold on
plot(px(id1),py(id1),'g.'); hold on
plot(px(id2),py(id2),'c.'); hold off
set(gca,'YDir','reverse','Color',[1 1 1]*1)
axis equal
drawnow

% %%
% 
% 
% Hmin=zeros(1,126);
% xo=zeros(1,126);
% yo=zeros(1,126);
% for i=0:126
%     xx=find( C==i & L>2 & L<150 & H<0);
%     if ~isempty(xx)
%         Hmin(i+1)=min(H(xx));
%     end
%     xx=find(ch == i);
%     if ~isempty(xx)
%         xo(i+1)=max(px(xx));
%         yo(i+1)=max(py(xx));
%     end
% end
% 
% 
% 
% 
% 
%     scatter(xo,yo,15,Hmin,'filled')
%     set(gca,'YDir','reverse','Color',[1 1 1]*.6)
%     colorbar%('location','east')
%     box off
%     axis equal
%     
%     ll= -400;
%     ul= -0;
%     caxis([ll ul])
% 
%     
%     
%% trig file to get trig time stamps (can compare to analog detection in spikefile)
% 
% 
% 
% %  *** can load trig times from raw.trig file ***
 trigl=load(trigfile,'-ascii');
 trig.N=trigl(:,1); % number (some may have been dropped)
 trig.T=trigl(:,2); % time
%  plot(trig.T-trig.T(1),trig.N,'.')

% Match spikefile probe info to trig info in order to align spikes with raw data 
% L, P_hw ?
P_num_ = zeros(size(T));
P_t_   = zeros(size(T));
for i=1:length(trig.T)
    id_=find(P_t==trig.T(i));
    P_t_(id_)=trig.T(i);
    P_num_(id_)=i;
disp([num2str(i) '/' num2str(ntrig) ])
end
    
    
    
%%
%%
%% compare raw data

%  fclose(fh)

%  fn=['/home/bakkum/raw/tmp.raw']
fn=rawfile
fh = fopen(fn,'rb')
fseek(fh,0,1);
len = ftell(fh);
fseek(fh,0,-1); 


rast=zeros(128,ntrig); cc=0;
www=zeros(1,ntrig); % stim width
vvv=zeros(1,ntrig); % stim volt
aaa=zeros(1,ntrig); % stim artifact on 1st record_ch
lll=zeros(1,ntrig); % record el latency
hhh=zeros(1,ntrig); % record el height
typ=zeros(1,ntrig); % stim type (pos-neg:1, neg-pos:2, neg:3, pos:4)


stim.W1=zeros(1,ntrig); % stim width [samp] phase 1  % for variable widths / volts
stim.W2=zeros(1,ntrig); % stim width [samp] phase 2
stim.W3=zeros(1,ntrig); % stim width [samp] phase 3
stim.V1=zeros(1,ntrig); % stim volt phase 1
stim.V2=zeros(1,ntrig); % stim volt phase 1
stim.V3=zeros(1,ntrig); % stim volt phase 3
stim.A =zeros(1,ntrig); % stim artifact sum(area_allelc) [volt*msec] (exclude stim site and neighbors)
stim.A0=zeros(1,ntrig); % stim artifact at stim site
stim.A1=zeros(1,ntrig); % stim artifact at neighboring electrodes to stim site
stim.A2=zeros(1,ntrig); % stim artifact at next neighboring electrodes to stim site
stim.AA=zeros(128,ntrig);   % stim artifact at all
stim.D1=zeros(ntrig,tlen);  % stim waveform DAC1 [volt]
stim.AW=zeros(ntrig,tlen);  % stim waveform, stim channel 
stim.AW=zeros(ntrig,tlen);  % stim waveform, stim channel 
stim.dAP={};%zeros(1,ntrig);    % APs within 12ms (extracted from traw)
stim.sAP=zeros(1,ntrig);    % APs after 15ms before next stim (use spikeform Latency) 
sign   =ones(1,ntrig);      % neg vs pos waveform

%prob_W=zeros(3,20); % genetic algorithm - count successful widths
%prob_V=zeros(3,23); % genetic algorithm - count successful voltages (bin into 23 bins)

for i=1:ntrig
 stim.dAP{i}.L=[]; % dap latency (using custom spk det)
 stim.dAP{i}.C=[]; % dap channel (using custom spk det)
 stim.dAP{i}.H=[]; % dap height  (using custom spk det)
end


set(0,'DefaultFigurePosition',[1 900 560 420])

%% plot raw traces and scatter plot of artifact; print parameters and artifact
PLOT=0; if PLOT, figure(2), end
artstart=11; % wait [artstart] samples after tzero to begin art calc
while 1
cc=cc+1;
[dat, cnt] = fread(fh,[128 tlen],'int16');
if isempty(dat)
    disp EndOfFile
    break
end
disp([num2str(cc) '/' num2str(ntrig) ])





% %%%%%%
% %%  spike detection on raw data -- seems to work
%   get threshold from 10-90% range of sig
% %% try a filter a la salpa
% subtract median value over window of xx samples for each sample
wn=10;
sig=zeros(size(dat));
for k=wn+1:size(dat,2)-wn-1
    sig(:,k)=dat(:,k)-median(dat(:,k-wn:k+wn)')';
end

% figure(9), hold off  
for i = 1:128
 digi=16; % digi value in meabench data
 [b id_]=sort(sig(i,:)); %     plot([1:length(b)]/length(b),b)
 [id2_ tmp]=sort(id_(floor(length(b)*.10):ceil(length(b)*.90)));
 thresh=max([5*std(sig(i,id2_)) 3*digi]); % 5std or if std=zero, then 3*minimum digi unit
 yy=find((sig(i,:))<-thresh); yy_last=-2; spk=[]; c=0; h=[]; chn=[];
 for j=yy
    if(j-yy_last>2)
        hh=sig(i,j);
        c=c+1; h=[h hh]; spk=[spk j]; chn=[chn i];
        %if(j>tzero+artstart), stim.dAP(cc)=stim.dAP(cc)+1; stim.dAP(cc); end
    else
        hh=sig(i,j);
        if hh<=h(c)
            h(c)=hh; spk(c)=j;
    end,end
    yy_last=j;
 end    
 stim.dAP{cc}.H=[stim.dAP{cc}.H h];
 stim.dAP{cc}.L=[stim.dAP{cc}.L (spk-tzero)/20];
 stim.dAP{cc}.C=[stim.dAP{cc}.C chn];
 
%   plot([1:size(sig,2)]/20-tzero/20,sig(i,:)'-i*500-median(sig(i,:))), hold on
%   if ~isempty(yy)
%     %plot(yy/20-tzero/20,0-i*500-median(sig(i,:)),'co'), hold on
%     plot(spk/20-tzero/20,h-i*500-median(sig(i,:)),'g*')
%     plot([1:size(sig,2)]/20-tzero/20,-thresh-i*500-median(sig(i,:)),'k'), %hold off
%   end
%    
%   plot([1:size(dat,2)]/20-tzero/20,dat(i,:)'-i*500-median(dat(i,:)),'r'), hold on
%   xx=find(P_t_==trig.T(cc) & L>1 & L<12 & C==i-1 & (H<-80 | H>30));
%   if ~isempty(xx)
%   plot(L(xx),median(sig(i,:)'-i*500),'r*')
%   end
%   drawnow
%   grid on
%   pause , hold off
end
  xx=find(P_t_==trig.T(cc));
  %stim.dAP(cc)=length(find(L(xx)>1  & L(xx)<15)); %iterate above using spk det from traw
  stim.sAP(cc)=length(find(L(xx)>15 & L(xx)<mean(diff(trig.T))*1000));
% %%%%%%%%%%%%
  
  
  
  clear odat
  stim_=(dat(127,:)-dat(127,1))*adc/2^12; 
  
  if(stim_(tzero)>0), stim_=-stim_; sign(cc)=0; else sign(cc)=1; end % REVERSE
  
  stim_w1=length(find(stim_(1:tzero)>0)) ;
  stim_w2=length(find(stim_(tzero:end)<0)) ;
  stim_w3=length(find(stim_(tzero:end)>0)) ;
  for i=1:128
    odat(i,:)=(dat(i,:)-mean(dat(i,1:(tzero-stim_w1-1))));
  end
    odat(stim_ch+1,:)=(dat(stim_ch+1,:)-mean(dat([1:stim_ch stim_ch+2:126],1)));
  
  % abs artifact area of all electrodes (trapezoidal integration)
  tmp=odat(:,(tzero+artstart:end))';
  [mpx mpy]=el2position(el(idd));
  artarea=trapz(tmp(:,ch(idd)+1))*adc/2^12/20;
  stim.A(cc) =sum(abs(trapz(tmp(:,ch(id )+1))*adc/2^12/20));
  stim.A0(cc)=sum((trapz(tmp(:,ch(id0)+1))*adc/2^12/20));
  stim.A1(cc)=sum((trapz(tmp(:,ch(id1)+1))*adc/2^12/20));
  stim.A2(cc)=sum((trapz(tmp(:,ch(id2)+1))*adc/2^12/20));
  stim.AA(ch(idd)+1,cc)=trapz(tmp(:,ch(idd)+1))*adc/2^12/20;
  
  
  
  
  
  stim_v1=max(stim_(find(stim_(1:tzero)>0)));  tmp2=stim_(tzero:end);
  stim_v2=min(tmp2(find(tmp2<0)));             tmp3=stim_((tzero+stim_w2):end);
  stim_v3=max(tmp3(find(tmp3>0)));
  if ~sign(cc)
      stim_v1=-stim_v1;
      stim_v2=-stim_v2;
      stim_v3=-stim_v3;
  end
      
  stim.D1(cc,:)=stim_;
  stim.AW(cc,:)=dat(stim_ch+1,:)*adc/2^12; 
  stim.W1(cc)=stim_w1;
  stim.W2(cc)=stim_w2;
  stim.W3(cc)=stim_w3;
  if ~isempty(stim_v1),  stim.V1(cc)=stim_v1;   else stim_v1=0; end
  if ~isempty(stim_v2),  stim.V2(cc)=stim_v2;   end
  if ~isempty(stim_v3),  stim.V3(cc)=stim_v3;   else stim_v3=0; end
  
  if PLOT
      %disp(num2str(stim_v1./(stim_v1+stim_v3)))
  if 1%( stim_v1./(stim_v1+stim_v3) <.04 && sign(cc)==0 )
  subplot(211);
  plot(dat(ch(idd)+1,:)','color',[1 1 1]*.9); hold on
  plot(dat(ch(id1)+1,:)','color',[1 1 1]*.5); hold on
  plot(dat(ch([id id2])+1,:)')
  hold on; plot(dat(stim_ch+1,:),'r','linewidth',2); hold off; grid on
  hold on; plot(dat(127,:),'ko-','linewidth',2); hold off; grid on
  
  subplot(212); hold off
  scatter(mpx,mpy,60,artarea,'filled'); % [volts*msec]
  set(gca,'YDir','reverse','Color',[1 1 1]*.6)
  axis equal
  colorbar
  caxis([-16 16])
  
  disp ' '
  disp([num2str(sum(abs(artarea))) ' artifact    '  num2str(100*stim_v1/(stim_v1+stim_v3)) '%'])
  disp(num2str([stim_w1 stim_w2 stim_w3])),  disp(num2str([stim_v1 stim_v2 stim_v3])),  disp ' '
  disp(['dAP:' num2str(stim.dAP(cc)) '   sAP:' num2str(stim.sAP(cc))])
  pause
  end
  end

  
  
%   if(stim_w1*stim_w2*stim_w3 && stim.A(cc)<100)
%   prob_W(1,stim_w1)=prob_W(1,stim_w1)+1;
%   prob_W(2,stim_w2)=prob_W(2,stim_w2)+1;
%   prob_W(3,stim_w3)=prob_W(3,stim_w3)+1;
%   
%   idd=floor(stim_v1*1000/50)-1;  prob_V(1,idd)=prob_V(1,idd)+1;
%   idd=floor(-stim_v2*1000/50)-1; prob_V(2,idd)=prob_V(2,idd)+1;
%   idd=floor(stim_v3*1000/50)-1;  prob_V(3,idd)=prob_V(3,idd)+1;  
%   end
end

%% plot ratio vs artifact: stim_el, neighbors, next neighbors, others, total; normalized per electrode
figure, hold on
plot(-sign+stim.V1./(stim.V1+stim.V3),(stim.A+stim.A1+stim.A0+stim.A2)/length(find(ch>-1)),'k.')
plot(-sign+stim.V1./(stim.V1+stim.V3),stim.A/(length(find(ch>-1))-length(stim_el_n)-length(stim_el_2)-1),'.b')
plot(-sign+stim.V1./(stim.V1+stim.V3),stim.A1/length(stim_el_n),'og')
plot(-sign+stim.V1./(stim.V1+stim.V3),stim.A2/length(stim_el_2),'+c')
plot(-sign+stim.V1./(stim.V1+stim.V3),stim.A0,'r.')
hold off
grid on
xlabel ratio
ylabel 'artifact [volt*msec]'
title(Info.Exptitle) 

%% plot width height for diff stim types (2 phase tests)
stim.type=zeros(1,ntrig); % pos-neg[1], neg-pos[2], pos[3], neg[4]
id__{1}=find(stim.V1>0  & stim.V2<0); stim.type(id__{1})=1;
id__{2}=find(stim.V1<0  & stim.V2>0); stim.type(id__{2})=2;
id__{3}=find(stim.V1==0 & stim.V2>0); stim.type(id__{3})=3;
id__{4}=find(stim.V1==0 & stim.V2<0); stim.type(id__{4})=4;
label={'posneg' 'negpos' 'pos' 'neg'};

figure(222)
ll=0; uu=8;
chn=0;
while chn<126, 
chn=chn+1; disp(num2str(chn))
for i=1:4
    subplot(2,2,i)
    id_=id__{i};
    %c=[]; for j=id_, c=[c length(stim.dAP{j}.L(stim.dAP{j}.L>1))]; end
    c=[]; for j=id_, 
        xx=find(stim.dAP{j}.L>1 & stim.dAP{j}.C==chn-1);
        if ~isempty(xx), c=[c stim.dAP{j}.L(xx(1))]; else, c=[c 0]; end    
    end
    x=(stim.W2(id_)+rand(size(stim.W1(id_)))/2)*50;
    y=abs(stim.V2(id_)+rand(size(stim.V2(id_)))/40);
    scatter(x,y,60,c,'filled'), set(gca,'Color',[1 1 1]*.6), %colorbar
    %if i==1, cax=caxis; else caxis(cax); end 
    caxis([ll uu])
    axis([0 550 .4 1.3]), xlabel(label{i})
    colorbar
end
pause
end



%%
   if 1%SAVE
    filename=sprintf('/home/bakkumd/home/Documents/Pictures/Matlab/%s.jpg',Info.Exptitle)
    cnt=cnt+1;
    set(gcf,'inverthardcopy','off')
    print('-djpeg','-r150',filename) 
    % convert to jpg and use ffmpeg
   end

   
%% plot ratio vs artifact for each electrode
figure(6), hold off
[x jj]=sort(-sign+stim.V1./(stim.V1+stim.V3));
clr=jet(ceil(max(ch_d(idd)+1)));
ccc=0;
for i=ch(idd)'
    ii=find(ch==i-1); 
    if ~isempty(ii) && i~=0
        ccc=ccc+1;
        disp(num2str(ccc))
    y=stim.AA(i,jj);
    plot(x,y,'color',clr(ceil(ch_d(ii(1))+1),:)), hold on
    axis([-1 1 -8 12])
    end
end
hold off

[x ii]=sort(-sign+stim.V1./(stim.V1+stim.V3));
n1=stim.A1(ii)/length(stim_el_n);
n2=stim.A2(ii)/length(stim_el_2);
n0=stim.A0(ii);





%%
%%























PLOT=0;
while 1 %cc<ntrig
[dat, cnt] = fread(fh,[128 tlen],'int16'); 
if cnt<tlen*128
    disp EndOfFile
    return
end
cc=cc+1;
disp([num2str(cc) '/' num2str(ntrig) ])



% % calculate artifact area for pos and neg art
%   get stim info
stim_=(dat(127,:)-dat(127,1))*adc/2^12; 
stim.D1(cc,:)=stim_;
stim.W1(cc)=length(find(stim_(1:tzero)>0)) ;
stim.W2(cc)=length(find(stim_(tzero:end)<0)) ;
stim.W3(cc)=length(find(stim_(tzero:end)>0)) ;
stim.V1(cc)=max(stim_(find(stim_(1:tzero)>0))); tmp=stim_(tzero:end);   
stim.V2(cc)=min(tmp(find(tmp<0))); tmp=stim_((tzero+stim.W2):end); tmp2=max(tmp(find(tmp>0)));
if(isempty(tmp2)) stim.V3(cc)=0; else stim.V3(cc)=tmp2; end

%   first offset baselines
clear odat
for i=1:128
    odat(i,:)=(dat(i,:)-mean(dat(i,1:(tzero-stim.W1(cc)-1))));
end

% abs artifact area of all electrodes (trapezoidal integration)
tmp=abs(odat(:,(tzero+stim.W2(cc)+stim.W3(cc):end))');
stim.A(cc)=sum(trapz(tmp(:,1:126)))*adc/2^12/20; % [volts*msec]

continue

% ### do reconstruction ### and do band pass first to remove offset?


wn=10;
fdat=zeros(size(dat)); % filter data -- seems work better than meabench highpass filter...
for k=wn+1:size(dat,2)-wn-1
    fdat(1:126,k)=dat(1:126,k)-median(dat(1:126,k-wn:k+wn)')';
    fdat(127:128,k)=dat(127:128,k)-median(dat(127:128,:)')';
end

if PLOT
  %subplot(1,2,1)
  plot(fdat');  axis([50 200 -4096 4096])
  hold on; plot(fdat(127,:),'k','linewidth',2); hold off; grid on
end
stim=fdat(127,:)*adc/2^12;  
tol=.02;
stim_nv=min(stim)     ;
stim_pv=max(stim)     ;
stim_nl=length(find(stim<0))    ;
stim_pl=length(find(stim>0))    ;
%if (-stim_nv-stim_pv)/max(abs([stim_nv stim_pv]))>tol
% if abs(stim_nv+stim_pv)>tol && stim_nv*stim_pv~=0
%     disp VoltError
%     continue
% end
% if abs(stim_nl-stim_pl)>1 && stim_nl*stim_pl~=0
%     disp WidthError
%     continue
% end

%[tmpmin tmpid] = min(fdat(:,tzero+del:end)');
%xx=find(tmpmin < -thresh); if ~isempty(xx), rast(xx,cc)=tmpmin(xx); end
%if max( tmpmin(record_ch+1) < -thresh ) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  lll(cc)=( max(tmpid(record_ch+1))+del+1)/20;       % [ms]
%  hhh(cc)=  min(tmpmin(record_ch+1))*adc/2^12*1000;  % [uV]
%end

[tmpmax tmpid] = max(abs(fdat(:,tzero+del_l:tzero+del_u)'));
xx=find(tmpmax > thresh); if ~isempty(xx), rast(xx,cc)=tmpmax(xx); end
if max( tmpmax(record_ch+1) > thresh ) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  lll(cc)=( max(tmpid(record_ch+1))+del+1)/20;       % [ms]
  hhh(cc)=  max(tmpmax(record_ch+1))*adc/2^12*1000;  % [uV]
end
if      stim_nl*stim_pl==0 && stim_nv==0,      typ(cc)=4; % single  pos stim
elseif  stim_nl*stim_pl==0 && stim_pv==0,      typ(cc)=3; % single  neg stim
elseif  stim_nl*stim_pl~=0 && stim(tzero-1)<0, typ(cc)=2; % reverse neg-pos stim
elseif  stim_nl*stim_pl~=0 && stim(tzero-1)>0, typ(cc)=1; % normal  pos-neg stim
else
    disp TypeError
    return
end
   
if stim_nl*stim_pl==0 
 www(cc)=([stim_nl+stim_pl])/20*1000;      % [us]
 vvv(cc)=(abs([stim_nv+stim_pv]))*1000;    % [mV]
else
 www(cc)=mean([stim_nl stim_pl])/20*1000;      % [us]
 vvv(cc)=mean(abs([stim_nv stim_pv]))*1000;    % [mV]
end
aaa(cc)=(dat(record_ch(end),tzero+del)-median(dat(record_ch(1),end-40:end)))*adc/2^12*1000; % [uV]

ww1(cc)=stim_pl/20*1000;
ww2(cc)=stim_nl/20*1000;
vv1(cc)=stim_pv;
vv2(cc)=stim_nv;

 
if 0%PLOT
  %subplot(1,2,2)
  scatter(xo,yo,15,tmpmax(1:126),'filled')
  set(gca,'YDir','reverse','Color',[1 1 1]*.6)
  axis equal
  colorbar

  l= 0;
  u= 200;
  caxis([l u])
  drawnow
  pause(1)
end  
if PLOT
  drawnow
  pause(1)
end
  
end
%%

%%
%%
%% analysis      


rng=1:400;
rng=1:length(vvv);
rdiv=.08;    

type=1;

%% artifact area
[a id]=sort(stim.A);
x=45; y=45; dx=50; dy=3;
c=0;
figure(111); hold off
for i=id
    c=c+1;
    osx=mod(dx*c,dx*x);
    osy=-mod(floor(c/y),y)*dy
    C=jet(ceil(max(stim.A))+1);
    X1=[-stim.W1(i) 0 0 -stim.W1(i)];
    Y1=[stim.V1(i) stim.V1(i)  0  0];
    X2=[0 stim.W2(i) stim.W2(i) 0];
    Y2=[stim.V2(i) stim.V2(i) 0 0];
    X3=[stim.W2(i) stim.W2(i)+stim.W3(i) stim.W2(i)+stim.W3(i) stim.W2(i)];
    Y3=[stim.V3(i) stim.V3(i) 0 0];
    fill(X1+osx,Y1+osy,C(floor(stim.A(i))+1,:)); hold on
    fill(X2+osx,Y2+osy,C(floor(stim.A(i))+1,:)); hold on
    fill(X3+osx,Y3+osy,C(floor(stim.A(i))+1,:)); hold on
    colorbar
    caxis([0 ceil(max(stim.A))+1])
    %axis([-20 20 -1.2 1.2])
    %grid on
    drawnow
    %pause
end

%x = [stim.V1' stim.V2' stim.W1' stim.W2' ];
%gplotmatrix(x,[],ceil(stim.A/max(stim.A)*4),[],'+xo')
%[d,p,stats] = manova1(x,ceil(stim.A/max(stim.A)*4))

%%
posx=stim.V1.*stim.W1; 
posy=-stim.V2.*stim.W2;
id=find(posx.*posy~=0); posx=posx(id); posy=posy(id);
    spacingx=(max(posx)-min(posx))/20;
    spacingy=(max(posy)-min(posy))/20;
    sx=min(posx):spacingx:max(posx);
    sy=min(posy):spacingy:max(posy);
    [sx,sy]=meshgrid(sx,sy);
    z=griddata(posx,posy,stim.A(id),sx,sy);  
       
fs = smoothn(z); % DCT-based smoothing
subplot(131), imagesc(sx(1,:),sy(:,1),z);   axis square, set(gca,'YDir','normal'),axis([sx(1,[1 end]) sy([1 end],1)'])
subplot(132), imagesc(sx(1,:),sy(:,1),fs);  axis square, set(gca,'YDir','normal'),axis([sx(1,[1 end]) sy([1 end],1)'])
subplot(133), scatter(posx,posy,20,stim.A(id),'filled'); axis square, axis([sx(1,[1 end]) sy([1 end],1)'])
    
    

%% width volt height 


%   figure
%subplot(1,3,1)
r=find(hhh~=0 & typ==type);
scatter(www(r)+(rand(size(www(r)))-.5)/rdiv,vvv(r),60,hhh(r),'filled'); hold on
r=find(hhh==0 & typ==type);
plot(www(r)+(rand(size(www(r)))-.5)/rdiv,vvv(r),'.','color',[1 1 1]*.4,'markersize',10); hold off
colorbar
set(gca,'Color',[1 1 1]*.6)
grid on
caxis([0 200])
axis([0 1000 450 1350])
ylabel StimVoltage[+/-mV]
xlabel StimPhaseWidth[usec]
title('Spike Height [uV]')

%   figure
%subplot(1,3,2)
r=find(lll~=0 & typ==type);
scatter(www(r)+(rand(size(www(r)))-.5)/rdiv,vvv(r),60,lll(r),'filled'); hold on
r=find(lll==0 & typ==type);
plot(www(r)+(rand(size(www(r)))-.5)/rdiv,vvv(r),'.','color',[1 1 1]*.4,'markersize',10); hold off
colorbar
set(gca,'Color',[1 1 1]*.6)
grid on
caxis([0 10])
axis([0 1000 450 1350])
ylabel StimVoltage[+/-mV]
xlabel StimPhaseWidth[usec]
title('Spike Latency [ms]')

% % artifact (offset/slope) (do as % maximum)
%   figure
%subplot(1,3,3)
r=find(typ==type);
scatter(www(r)+(rand(size(www(r)))-.5)/rdiv,vvv(r),60,aaa(r)/max(aaa(r)),'filled'); hold off
colorbar
set(gca,'Color',[1 1 1]*.6)
grid on
caxis([0 1])
axis([0 1000 450 1350])
ylabel StimVoltage[+/-mV]
xlabel StimPhaseWidth[usec]
title('Artifact[%]')



%% reliability in time
%   figure
bin=20; % [stim num]
step=5;
clear tmp tmpx; cc=0;
for i=1:step:ntrig-bin-1
    cc=cc+1;
    tmp(cc)=length(find(lll(i:i+bin)~=0))/bin;
    tmpx(cc)=i;
end
plot(tmpx,tmp,'.')
set(gca,'ylim',[0 1])
xlabel Time
ylabel('Reliability[%]')


%% latency vs volt
%   figure
plot(lll,vvv,'.')
ylabel StimVoltage[+/-mV]
xlabel Latency[msec]



%% reliability vs volt
bin=20; % [mV]
step=5;
clear tmp tmpx; cc=0;
for i=min(vvv(vvv>0)):step:max(vvv(vvv>0))-bin
    cc=cc+1;
    xx=find(vvv(rng)>=i & vvv(rng)<=i+bin);
    if isempty(xx)
        disp ERROR
        cc
        %return
    end
    tmp(cc)=length(find(lll(rng(xx))~=0))/length(xx);
    tmpx(cc)=i;
end
plot(tmpx,tmp,'.')
set(gca,'ylim',[0 1])

%% reliability vs width
bin =.15; % [ms]
step=.05;
clear tmp tmpx; cc=0;
for i=min(www(www>0)):step:max(www(www>0))-bin
    cc=cc+1;
    xx=find(www(rng)>=i & www(rng)<=i+bin);
    if isempty(xx)
        disp ERROR
        cc
        return
    end
    tmp(cc)=length(find(lll(rng(xx))~=0))/length(xx);
    tmpx(cc)=i;
end
plot(tmpx,tmp,'.')
set(gca,'ylim',[0 1])


%% reliability vs width*volt
bin =.15; % [ms]
step=.05;
clear tmp tmpx; cc=0;
%mmm=( (www-min(www(www>0))) / (max(www)-min(www(www>0))) ) .* ( (vvv-min(vvv(vvv>0))) / (max(vvv)-min(vvv(vvv>0))) );
mmm=( www / max(www) ) .* ( vvv / max(vvv) );
for i=min(mmm(mmm>0)):step:max(mmm(mmm>0))-bin
    cc=cc+1;
    xx=find(mmm(rng)>=i & mmm(rng)<=i+bin);
    if isempty(xx)
        disp ERROR
        cc
        return
    end
    tmp(cc)=length(find(lll(rng(xx))~=0))/length(xx);
    tmpx(cc)=i;
end
plot(tmpx,tmp,'.')
set(gca,'ylim',[0 1])



