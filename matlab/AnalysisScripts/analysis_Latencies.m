%%%%
% %%      Generate FIGURES 
%         Script to pick axonal AP times for latency / velocity analysis
%
%         - First load Info from StimScan
%   
%         Contains extra code to correlate electrodes with images (load and plot 'im' using analysis_ImageAlignment.m)
%
%
%%   
%    
%
%

Info.Map       = loadmapfile(Info.FileName.Map,1111); % load Info.FileName.Map and plot elc locations in figure 1111
Info.Trig      = loadtrigfile(Info.FileName.Trig);

if ~isfield(Info.Trig,'E')
    spike       = loadspikeform(Info.FileName.SpikeForm);
    spike       = spikeform_EpochFix(Info,spike);
    Info.Trig.E = addTrigEpoch(Info,spike);
end

[bpB, bpA] = ums2000_setup;
load global_cmos


%% Find Elc to use by using clickelectrode()

    elc = clickelectrode('r',1);
%    elc = clickelectrode('g',12);

% Remove doubles while maintaining order
e   = [];
cnt = 0;
for i = elc
    cnt = cnt+1;
    if cnt>1    
        if find(i==(elc(1:cnt-1))), continue, end    % skip doubles
    end
    e  = [e i];
end

% Print to screen
fprintf('Elc = [')
for i = e, fprintf('%i ',i), end
fprintf('];\n\n')






%% Load experiment specific parameters
%   Set:
%       'Elc' to use, 
%       time to 'BLANK', and 
%       'StartPoint' (~time of first AP) if using AUTOTIMES routine
%

if strcmp(Info.Exptitle,'090315-E3')
    Elc    = [5808 5807 5809 5909 5911 5910 6013 6012 6114 6215 6217 6218];
    BLANK  = 0;
    StartPoint  = Info.Parameter.TriggerTimeZero + BLANK; % start point for autotimes routine

    
elseif strcmp(Info.Exptitle,'130109-B')
    Elc   = [ 1937        2039        2141        2038        2140        2139        2241        2240        2341        2342        2443        2444        2445        2547        2649        2446       2548        2650        2753        2855        2854        2752        2853        2955        2852        2851        2953        2850       2952        2951        3053        3156        3155        3258        3257        3360        3359        3462        3461        3564        3463        3565        3668        3769        3669        3770       3670        3771        3466        3671        3772        3569        3875];
    BLANK = 0;
    StartPoint  = Info.Parameter.TriggerTimeZero + BLANK; % start point for autotimes routine

    
elseif strcmp(Info.Exptitle,'090409-D') || strcmp(Info.Exptitle,'090409-C')
    %Elc = [6949 6643 6542      6341          5937 5938 5837 5737      5535 5435 5335           5133 5033 5034 4834 4631 4427 4225        4022        3616        3515                    3107                    2801        2495        2497       2907        3213        3521        3725        3931        4137]; 
    Elc   = [6949 6643           6341          5937      5837 5737      5535 5435 5335           5133 5033 5034 4834 4631 4427 4225        4022        3616        3515                    3107                    2801        2495        2497       2907        3213        3521        3725        3931        4137]; 
    BLANK = 20;
    StartPoint  = 40;
    
elseif     strcmp(Info.Exptitle,'120919-100mv')
    reply = input('Which branch? South [S] or East [E] (default is South) ', 's');
    if isempty(reply)
        reply = 'S';
    end
    reply = lower(reply);
    if(     strcmp(reply,'s') || strcmp(reply,'south') )
        SOUTH = 1;
        fprintf(2,'Using South branch.\n');
    elseif( strcmp(reply,'e') || strcmp(reply,'east') )
        SOUTH = 0;
        fprintf(2,'Using East branch.\n');
    end
        
    if SOUTH
        % reduced, trunck + branch south
        disp 'USING SOUTH BRANCH'
        Elc = [9246        9245        9144        9042        8939        8734        8836        8631        8528        8426        8324        8222        8120        8018        7916        7814        7710        7709        7607        7504       7402        7301        7199        7097        6995        6893        6791        6792        6690        6588        6383        6281        6179        6077       5975        5872        5770        5565        5564        5462        5461        5359        5256        5255        5151        5048        4945        4944        4839        4941       4838        4836        4936        4831        4829        4828        4725        4622        4621        4519        4416        4314        4313                4108        3904        3700        3497        3395        3191        3089        2987        2886        2784        2785        2683        2582        2380        2278        2177        2075        1871        1770        1669        1567        1465        1366        1265       1369        1268        1371        1167        1168        1272        1273        1376        1478        1581        1582        1787       1890        1891        1892        1893        1894        1997        1998        2000        2103       2307        2409        2511        2613       2715        2714        2816        2917        3121        3223        3325];    
        id  = 1:2:length(Elc); % Use half to increase distance for more accuracy
        Elc = Elc(id);
        
    else
        % reduced, trunck + branch east
        disp 'USING EAST BRANCH'
        Elc = [9246        9245        9144        9042        8939        8734        8836        8631        8528        8426        8324        8222        8120        8018        7916        7814        7710        7709        7607        7504       7402        7301        7199        7097        6995        6893        6791        6792        6690        6588        6383        6281        6179        6077       5975        5872        5770        5565        5564        5462        5461        5359        5256        5255        5151        5048        4945        4944        4839        4941       4838        4836        4936        4831        4829        4828        4725        4622        4621        4519        4416        4314        4313                4108        3904        3700        3497        3395        3191        3089        2987        2886        2784        2785        2683        2582        2380        2278        2177        2075        1871        1770        1669        1567        1465        1366        1265       1369        1268        1371        1167        1168        1272        1273        1376        1478        1581        1582        1787       1890        1891        1892        1893        1894        1997        1998        2000        2103       2104        2106        2209        2210        2212        ];
        id  = 1:2:length(Elc);
        Elc = Elc(id);
        
    end   
    BLANK = 5;
    StartPoint  = 70;

    

elseif     strcmp(Info.Exptitle,'120919-B-200mv') 
    % Antidromic
    Elc     = fliplr([9245 9144 9042 8939 8120 8018 7916 7814 7710 7709 7607 7504 7402 7301 7199 7097 6995 6893 6791 6792 6690 6383 6281 6179 6077 5975 5872 5770 5565 5564 5462 5461 5256 5255 5151 5048 4945 4944 4838 4836 4936 4829 4828 4725 4622 4621 4519 4108 3904 ]);
    Elc     = fliplr([9245 9144 9042 8939 8120 8018 7916 7814 7710 7709 7607 7504 7402 7301 7199 7097 6995 6893 6791 6792 6690 6383 6281 6179 6077 5975 5872 5770 5565 5564 5462 5461 5256 5255 5151 5048 4945 4944 4838 4836 4936 4829           4622 4621 4519  ]);
    Elc     = [Elc 9244 9346 9448 9550 9652 9754 9857 9959 10061];
    % Orthodromic 
    Elc     = [2278 2075 1871 1770 1669 1567 1465 1369 1268 1371 1167 1168 1272 1273 1376 1478 1582 1787 1890 1891 1892 1893 1997 1998 2000 2103 2307 2409 2511 2613 2715 ];  
    Elc     = [2278 2075 1871 1770 1669 1567 1465           1371 1167 1168 1272 1273 1376                               1893 1997 1998 2000 2103 2307 2409 2511 2613 2715 ];  
    BLANK = 7;
    StartPoint  = 78;
            
    
    
elseif strcmp(Info.Exptitle,'130110-D')     
    % 130110-D   dish 967
    %Elc = [3152 3151 3150 3149 3046 2944 2946 2945 2843 2536 2537 2332 1922 1620 1518 1416 1314 1211 1109 1006 1007 906 907 703 705 502 503 402 403 301 302 200 201 202 100 203 101 99 3977 4077  4075 4279 4381 4380];
    %Elc = [2536 2537 2332 1922 1620 1518 1416 1314  1007 906 907 703 705 502 503 402  301 302 200 201 202 100 203 101 99 3977 4077  4075 4279 4381 4380];
    %Elc = [2948 3051 3154 3153 3050 3152 3151 3150 3048 3149 3251 3148 3147 3046 3045 2944 2943 2841 2740 2739 2638 2536 2434 2332 2435 2331 2433 2229 2127 2128 2026 2025 1923 1922 1822 1821 1720 1823 1721 1722 1620 1621 1518 1519 1416 1417 1315 1212 1213 1110 1109 1008 1007 906 1009 907 703 805 601 704 705 603 604 502 503 402 403 302 404 405 303 201 202 100 101 203 99 ];
    %Elc = [ 3151 3149 3046 3045  2943   2739 2638 2536 2434 2332  2127 2128  1922 1821 1720 1620 1518 1416 1007 906 907 703 704 705 603 402   303 201 100  ];
    %Elc = [ 2128 1922  1620 1417]; % 130110-D for velocity measurements
    Elc = [ 2128 1922  1620 1416 ]; % 130110-D for velocity measurements
       
    % for scatter of time/height plots (2D color bar)
    %%%Elc = [2745 2746 2644 2950 2643 2847 2642 3052 3053 2848 3154 3051 2949 3153 3256 3255 3152 3050 3253 3254 3151 3150 3355 3252 2947 2946 3049 2844 2948 2845 2846 3047 3149 3046 3048 2944 2945 3148 3147 3251 3045 2943 2942 2840 2841 2842 3044 3043 3146 3249 2843 2740 2741 2738 2739 2636 2839 2638 2637 2536 2639 2640 2537 2538 2535 2432 2534 2433 2434 2435 2230 2332 2231 2333 2331 2127 2229 2228 2330 2128 2129 2025 2027 2026 1924 1925 1923 1824 1822 1823 1922 2024 1921 1820 2126 2023 1819 1920 1718 2022 1821 1720 1719 1722 1721 1620 1723 1619 1618 1516 1617 1621 1520 1622 1623 1519 1518 1825 1416 1517 1415 1314 1414 1316 1418 1419 1417 1317 1315 1214 1521 1313 1211 1212 1210 1312 1213 1112 1111 1215 1110 1311 1310 1413 1208 1209 1109 1006 1007 1008 1108 904 1009 908 1010 907 906 804 905 803 702 805 704 806 703 807 601 705 602 499 500 603 600 604 706 707 605 502 501 400 503 399 504 607 606 505 402 401 300 299 298 403 404 507 506 405 609 302 301 200 303 199 304 305 407 202 406 203 100 201 99 98 101 508 509 611 610 96 198 197 95 97 1412 1411 1309 1207 1106 1107 701 497 498 2641 2436 2334 2232 2130 2028 1926 1522 1420 1011 909 808 ];
    BLANK = 9;
    StartPoint  = Info.Parameter.TriggerTimeZero + BLANK; % start point for autotimes routine
    
    
elseif strcmp(Info.Exptitle,'130111-967-D3') ||  strcmp(Info.Exptitle,'130111-967-D4')
    % 130111-D3-part2  -- MUCH BETTER --
    %Elc = [3153 3152 3151 3150 3251 3148 3249 3146 3145 3043 2942 2943 2842 2843 2740 2741 2638 2639 2536 2537 2435 2231 2334 2232 2129 2027 2128 2026 2025 1923 1924 1822 1823 1721 1722 1824 1926 1825 1724 1723 1622 1623 1520 1521 1418 1519 1417 1316 1315 1213 1112 1111 1010 1009 908 907 703 601 704 602 705 603 604 707 605 606 504 505 404 405 304 305 407 ];
    %Elc = [3153 3152 3151 3150 3251 3148 3249 3146 3145 3043 2942 2943 2842 2740 2638 2536 2537 2435 2231 2232 2027 2025 1923 1822 1823 1722 1825 1723 1622 1520 1519 1316 1315 1213 1010 908 703 601 602 705 604 605 606 504 505 405 304 305 ];
    %Elc = [   3153            3152         3151        3150        3251        3148           3249        3146        3145            3043        2942       2943         2842        2740            2638        2536        2537        2435        2231            2232       2027         2025        1923            1822        1823        1722        1825            1723        1622        1520        1519            1316        1315        1213        1010            908         703         601             602         705         604         606             504         505         405         304         305 ];
    %Elc = [3153 3151 3150 3251 3249 3146 3145 3043 2942 2943 2842 2740 2638 2536 2537 2435 2129 2027 2025 1923 1822 1823 1722 1825 1723 1622 1519 1417 1315 1213 1112 1010 908 703 602 707 606 504 505 404 405 304 305 ];
    Elc   = [ 2027 1822  1622 1417]; % 130111-D3 for velocity measurements
    BLANK = 9;
    StartPoint  = Info.Parameter.TriggerTimeZero + BLANK; % start point for autotimes routine
    
elseif strcmp(Info.Exptitle,'130112-967-D7') || strcmp(Info.Exptitle,'130112-967-D8')
    Elc = [ 2026 1823  1724 1418]; % 130112-D7,8  for velocity measurements
    BLANK = 9;
    StartPoint  = Info.Parameter.TriggerTimeZero + BLANK; % start point for autotimes routine
    
elseif strcmp(Info.Exptitle,'130111-967-E2') ||  strcmp(Info.Exptitle,'130111-967-E1')
    % Neuron E - includes electrodes that give response in stimmap experiment
    Elc         = [5001 5002 5003 5106 5005 5006 5109 5110 5111 5010 4805 4806 4705 4706 4707 4708 4811 4710 4608 4607 4504 4402 4300 4301 4200 4098 4099 3895 3896 3794 3692 3590 3589 3487 3385 3283 3281 3178 3075 3074 2971 2970 2868 2766 2664 2562 2459 2357 2356 2254 2152 2049 2048 1946 1844 ];
    Dist        = [0 1.707508e+01 3.410770e+01 5.093174e+01 7.157860e+01 8.687674e+01 1.034897e+02 1.196728e+02 1.318844e+02 1.519467e+02 1.721981e+02 1.967147e+02 2.159508e+02 2.348195e+02 2.510528e+02 2.675744e+02 2.815185e+02 2.984581e+02 3.151746e+02 3.374943e+02 3.572132e+02 3.827952e+02 4.072115e+02 4.195719e+02 4.399001e+02 4.582350e+02 4.851919e+02 5.051524e+02 5.374561e+02 5.562055e+02 5.855628e+02 6.053064e+02 6.230700e+02 6.444324e+02 6.659136e+02 6.826259e+02 7.124645e+02 7.295170e+02 7.462473e+02 7.675450e+02 7.874730e+02 8.014637e+02 8.217633e+02 8.411980e+02 8.622431e+02 8.808396e+02 8.971235e+02 9.166966e+02 9.290655e+02 9.494496e+02 9.719580e+02 9.932394e+02 1.008990e+03 1.025490e+03 1.045955e+03 ];
    Soma        = 3283; 
    BLANK       = 9;
    StartPoint  = 75;        
    
    % found earlier, using now to quickly recalc velocities....
    TimePeak  = [NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN 7.644222e+01 7.686250e+01 7.816400e+01 7.901856e+01 8.005253e+01 8.029453e+01 8.119784e+01 8.178556e+01 8.264609e+01 8.376881e+01 8.491138e+01 8.604794e+01 8.679881e+01 8.804466e+01 8.893456e+01 9.038469e+01 9.176600e+01 9.245372e+01 9.354372e+01 9.349153e+01 9.424647e+01 9.588822e+01 9.672406e+01 9.850528e+01 9.963506e+01 1.045134e+02 1.076762e+02 1.083209e+02 1.095788e+02 1.101400e+02 1.118545e+02 1.132482e+02 1.136717e+02 1.159881e+02 1.174173e+02 NaN NaN NaN NaN NaN NaN NaN NaN NaN ];
    id = find(~isnan(TimePeak));
    Elc = Elc(id);
    Dist = Dist(id);
    clear TimePeak
    
%     % For footprint picture
%     Elc = [4806 4705 4704 4807 4703 4908 4805 4808 4603 4601 4706 4909 4605 4707 4604 4708 4503 4809 4501 4606 4504 4607 4709 4401 4505 4608 4502 4710 4811 4506 4711 4812 4404 4507 4405 4302 4403 4406 4609 4303 4402 4499 4498 4397 4600 4500 4396 4497 4602 4395 4398 4295 4399 4400 4297 4298 4299 4296 4195 4300 4198 4301 4197 4199 4095 4096 4200 4098 4201 4099 4097 3996 4202 4100 4203 4304 4305 3998 3999 4101 4102 3897 3895 4306 3795 3896 3794 3898 3693 3796 3793 4000 3792 3997 3894 3689 3691 3690 3893 3591 3590 3692 3488 3592 3489 3490 3589 3386 3593 3388 3491 3694 3385 3284 3487 3387 3283 3384 3282 3285 3182 3181 3079 3078 3080 3180 2976 2978 3179 3183 3485 3486 3587 3484 3382 3383 3588 3688 3381 3177 3280 3178 3279 3075 3278 3176 3281 3076 3483 3074 3073 2971 2972 3072 2973 3175 3277 2869 2970 3379 3380 2969 2868 3174 3276 2974 3077 2975 2872 2871 2873 2874 2870 2769 2768 2767 2667 2770 2665 2666 2765 2766 2663 2764 2867 2866 2664 2662 2562 2459 2460 2461 2561 2563 2357 2560 2359 2564 2458 2356 2355 2255 2457 2253 2358 2254 ];
%     Dist = 20*[1:length(Elc)];
    
    
end
%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
%      PARAMETERS         %

P.GETTIMES        =     1; % Click on plot to load Time variable
    P.SLOPE       =     0; % Calculate Time point from maximum P.SLOPE instead of minimum peak
    P.POS_PEAK    =     0; % Calculate Time point from maximum P.SLOPE instead of minimum peak
    P.STEREO      =     0; % Filter signal using P.STEREOtypical axonal signal 
    AUTOTIMES     =     0; % Automatically choose the times (BE CAREFUL)
P.BANDPASS        =     0; % P.BANDPASS signal
P.SUPPRESS_ART    =     0; % Artifact Suppression using 7th order Fourier series fit (like salpa)
P.BOOTSTRAP       =     1; % [1] do P.BOOTSTRAP. [0] no P.BOOTSTRAP, use traces
P.BOOTSTRAP_N     =   100; % number of P.BOOTSTRAPs
P.BLANK           =  Info.Parameter.TriggerTimeZero + BLANK; % [samples] Time to blank before and after tzero
P.upsample_factor =     4;

  PAUSE           =     0; % Pause between electrode traces plotted
  NOTATE          =     1; % Write electrode numbers on fig_all
  PLOTPATCH       =     0; % Use patch() to plot all traces
  Stereofilt      = [ 0.1056    0.1239    0.1884    0.2628    0.2387   -0.1710   -0.7791   -0.3514   -0.1108    0.0369    0.1026    0.0993    0.0872    0.0792    0.0592    0.0285 ];
  Fig_im          =  1111; % image figure to plot locations
  Fig_all         =  9967;
  Fig_proc        =  4444; % Plot signal processing here (artsuppression, bandpass, etc.)


P.ELECTRODE       =  Elc;


%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%

if P.SLOPE + P.POS_PEAK + P.STEREO > 1
    disp 'Choose at most one of P.SLOPE or P.POS_PEAK or P.STEREO'
    beep
    return
end


fclose('all');
clear bootstrap_traces bootstrap_traces_mean trace_all boot_mean boot_std

trace_all     = zeros(length(Elc),Info.Parameter.TriggerLength);
clr_r         = [rand rand rand];
clr_r_        = [rand rand rand];

Time          = []; % AP time [sample]
Time_boot     = []; % AP time bootstrap_traces_mean [nelc x nstim] in units of [samples]
Time_boot_m   = []; % AP time bootstrap_traces_mean [samples]
Time_boot_sd  = []; % AP time bootstrap_traces_mean [sample] s.t.d.
Height_boot_m = []; % AP height (V zero-to-peak)
Use           = []; % Use Elc(i) or not [0/1]





%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(Fig_proc); clf
figure(Fig_all);  clf
figure(98);       clf
figure(Fig_im);  
    [x y] = el2position(P.ELECTRODE);
    plot(x,y,'ks','markerfacecolor','k')


cnt = 0;
for elc = P.ELECTRODE(cnt+1:end)
    
    if strcmp(Info.Exptitle,'130111-967-E2')
        if elc == 3487, AUTOTIMES=0; end
        beep
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Load data (depending on expt type)
    cnt = cnt +1;
    if ~isnan(elc)
        if strcmp(Info.Exptype,'StimMap')
            pt = spike.T( spike.C==127 & spike.P_el==elc );
            if isempty(pt) || ~isempty(find(soma.el==elc))
                epoch = [];
            else
                [trace epoch map] = extractTrigRawTrace(Info,Soma,'probetime',pt);
            end
        else % StimScan
            [trace epoch map] = extractTrigRawTrace(Info,elc);
        end
    else
        epoch = [];
    end
    if isempty(epoch)
        trace = nan(Info.Parameter.NumberStim,Info.Parameter.TriggerLength);
    end
    
    
    
    %%%%%%%%%%%%%%%%%%%
    % Corrections
    
    % Correct voltage scaling for v3 chips (approx)
    %trace = trace*.75;
    
    % Skip first stim trial in case there is artifact
    range    = 2:(size(trace,1));
    
    % Skip channels at rail
    xx  = find( max(trace(range,70:end)') < 4080 );
    if length(xx)==1, continue, end
    
    
    %%%%%%%%%%%%%%%%%%%
    % Blank signal
    if P.BLANK && ~isempty(epoch)
        trace_bak = trace; % for plotting before stim if desired
        trace(:,1:P.BLANK) = 0;
    end
    
    %%%%%%%%%%%%%%%%%%%
    % Suppress artifact
    x_trc  = ([1:Info.Parameter.TriggerLength]-Info.Parameter.TriggerTimeZero)/20;
    x_sa   = [P.BLANK+1:Info.Parameter.TriggerLength];
    if P.SUPPRESS_ART   
        x_sa       = [P.BLANK+1:Info.Parameter.TriggerLength];
        trace_mean  = mean(trace(range(xx),:));
        y           = trace_mean(x_sa);
        [yfit, gof] = fit(x_sa',y','fourier7');
        yfit        = feval(yfit,x_sa);
        trace_yf    = trace_mean(x_sa) - yfit';
        bndpss      = filtfilt(bpB,bpA,trace_yf)';

        trace(:,x_sa)     = trace(:,x_sa) - repmat(yfit',size(trace,1),1);
        trace(:,1:x_sa-1) = 0;
        
        figure(Fig_proc); clf, hold on, 
            if PLOTPATCH
                for i=xx
                    y        = trace_bak(i,:); % one example trace
                    y(end+1) = NaN;
                    y(Info.Parameter.TriggerTimeZero:P.BLANK) = NaN;
                    x        = [1:length(y)]/20 - Info.Parameter.TriggerTimeZero/20;
                    patch([x_trc NaN],y,'k','edgecolor','k','linewidth',.25,'edgealpha',.1)

                    y        = trace(i,:) - 80; % one example trace
                    y(end+1) = NaN;
                    x        = [1:length(y)]/20 - Info.Parameter.TriggerTimeZero/20;
                    patch([x_trc NaN],y,'k','edgecolor','k','linewidth',.25,'edgealpha',.1)
                end
                figure_size(16,12)
            else
                figure_size(6,6)
            end
            lnw   = .25;              line([ 1 P.BLANK+1]/20-Info.Parameter.TriggerTimeZero/20, [0 0],'color','k','linewidth',lnw)
            lnw   =   1;  clr = 'r';  plot3( x_trc(x_sa) , mean(trace(:,x_sa)) - 80, ones(size(x_sa)), 'color',clr, 'linewidth',lnw)
            lnw   =   1;  clr = 'r';  plot3( x_trc(x_sa) , mean(trace_bak(:,x_sa)),  ones(size(x_sa)), 'color',clr, 'linewidth',lnw)
            lnw   =  .5;  clr = 'g';  plot3( x_trc(x_sa) , yfit,                      ones(size(x_sa)), 'color',clr, 'linewidth',lnw)
                    xlabel 'Latency [ms]'
                    ylabel 'Voltage [uV]'
                    figure_fontsize(8,'bold')  
                    view(2)
    end
    
    
    %%%%%%%%%%%%%%%%%
    % Bandpass filter
    if P.BANDPASS
        trace(:,P.BLANK:end) = filtfilt(bpB,bpA,trace(:,P.BLANK:end)')'; 
            figure(Fig_proc); 
            if PLOTPATCH
            for i=xx
                y        = trace(i,:) - 140; % one example trace
                y(end+1) = NaN;
                x        = [1:length(y)]/20 - Info.Parameter.TriggerTimeZero/20;
                patch([x_trc NaN],y,'k','edgecolor','k','linewidth',.25,'edgealpha',.1)
            end
            end
            lnw   =   1;  clr = 'r';  plot3( x_trc(x_sa) , mean(trace(:,x_sa)) - 140, ones(size(x_sa)), 'color',clr, 'linewidth',lnw)
            view(2)
    end        
        
    %%%%%%%%%%%%%%%%%
    % Bootstrap
    clear bootstrap_traces
    if P.BOOTSTRAP
        clear rng
        if strcmp(Info.Exptitle,'--------') 
            rng(1490);
        else
            sprev = rng('shuffle'); % reset random seed   
        end
        bootstrap_traces      = zeros([P.BOOTSTRAP_N  size(trace(range,:))]);
        for i=1:P.BOOTSTRAP_N
            %disp(P.BOOTSTRAP_N-i)
            nstim = length(range);
            id  = randi(nstim,1,nstim);
            tmp = trace(range(id),:);
            bootstrap_traces(i,:,:) = tmp;
        end
    else
        P.BOOTSTRAP_N      = 1;
        bootstrap_traces(1,:,:) = trace(range,:);
    end
    
    bootstrap_traces_mean = squeeze( mean(bootstrap_traces(:,:,:),2) );
    boot_mean = mean( bootstrap_traces_mean );
    boot_std  = std(  bootstrap_traces_mean );
    
       
    %off = 68;
    if P.BOOTSTRAP
        trc              = boot_mean;%(off:end);
        trace_all(cnt,:) = boot_mean;
            figure(Fig_proc); 
            if PLOTPATCH
            for i=1:P.BOOTSTRAP_N
                y        = bootstrap_traces_mean(i,:) - 200; % one example trace
                y(end+1) = NaN;
                x        = [1:length(y)]/20 - Info.Parameter.TriggerTimeZero/20;
                patch([x_trc NaN],y,'r','edgecolor','r','linewidth',.25,'edgealpha',.1)
            end
            end
            lnw   =   1;  clr = 'b';  plot3( x_trc(x_sa) , mean(trace(:,x_sa)) - 200, ones(size(x_sa)), 'color',clr, 'linewidth',lnw)
            view(2)
            if 0
                filename = ['/home/bakkumd/Desktop/' Info.Exptitle '-Elc' num2str(elc) '-SignalProcessing'];
                print('-dpdf','-r250',filename)
            end
            
    else
        %trc              = mean(trace(range(xx),off:end));
        trc              = mean(trace(range(xx),:));
        trace_all(cnt,:) = mean(trace(range(xx),:));
    end
        trc_stimmap      =     (trace(range,:));
    
    
    %%%%%%%%%%%%%%%%%%
    % Remove baseline
    trace_all(cnt,:) =  trace_all(cnt,:) - trace_all(cnt,Info.Parameter.TriggerTimeZero) ;

    
    %%%%%%%%%%%%%%%%%%%%%%%
    % Correct sampling bias
    samp_bias = Info.Map.offset(find(Info.Map.el==elc,1));
    if isempty(samp_bias), samp_bias = 0; end
    
    %x   = ([1:length(trc)]+off-1-Info.Parameter.TriggerTimeZero)/20;
    x_trc   = [1:length(trc)]+samp_bias;
    
    
    %%%%%%%%%%%%%%%%%%%%%%%
    % Convolve with generic (stereotypcial) axonal waveform
    if P.STEREO
        disp 'WARNING  Using stereofilter to filter traces.'
        %%%  SHOULD be done on orignal data, not mean data ???
        
        P.STEREO = zeros(size(trc));
        s      = length(Stereofilt);
        y_     = [zeros(1,s) trc zeros(1,s)];
        boot_traces_P.STEREO      = zeros(size(bootstrap_traces));
        boot_traces_P.STEREO_mean = zeros(size(bootstrap_traces_mean));
        nstim  = size(bootstrap_traces,2);
        clear y_b
        y_b = [zeros(P.BOOTSTRAP_N,s) bootstrap_traces_mean zeros(P.BOOTSTRAP_N,s)];
        for j=1:length(trc)
            P.STEREO(j)                = -Stereofilt*y_([1:s]+s/2+j-1)' ;
        end
        for j=1:length(trc)
            for k=1:P.BOOTSTRAP_N
                boot_traces_P.STEREO_mean(k,j) = -Stereofilt*y_b(k,[1:s]+s/2+j-1)' ;
            end
        end        
    end
        
    
    %%%%%%%%%%%%%%%%%%%%%%%%
    % Plot all traces
    figure(Fig_all);         
        if     strcmp(Info.Exptitle,'130111-967-E2')
               yoff = Dist(cnt); % load Dist below % 
               plot(x_trc/20-Info.Parameter.TriggerTimeZero/20,trc+yoff,'color',[1 1 1]*0,'linewidth',1);    hold on
        elseif strcmp(Info.Exptitle,'130111-967-E1')
               yoff = Dist(cnt)*15; % load Dist below % 
               %yoff = cnt*200;   % 
               plot(x_trc/20-Info.Parameter.TriggerTimeZero/20,trc_stimmap+yoff,'color',[1 1 1]*0,'linewidth',1);    hold on
        else
               yoff = -trc(50)+cnt*20;
               plot(x_trc/20-Info.Parameter.TriggerTimeZero/20,trc+yoff,'color',[1 1 1]*0,'linewidth',1);    hold on
        end
        if P.STEREO
            plot(x_trc/20-Info.Parameter.TriggerTimeZero/20,P.STEREO+yoff,'color',[1 0 0]*.5,'linewidth',1);
        end
        if NOTATE
            text( -3, yoff,num2str(elc),'color','b')
        end
        if cnt==1
            grid off, box off
            title([Info.Exptitle '  ' num2str(elc) ])
            set(gca,'xlim',[-3 7])
            xlabel 'Latency [ms]'
            figure_size(4,8)
            figure_fontsize(8,'bold')
        end
        

    %%%%%%%%%%%%%%%%%%%%%%%%
    % Plot location
    figure(Fig_im), 
        hold on
        [x y]=el2position(elc);
        plot(x,y,'s','color',clr_r_,'markerfacecolor',clr_r)
    
        
        
    %%%%%%%%%%%%%%%%%%%%%%%%
    % Get timepoints from plots
    if P.GETTIMES
    figure(98)        
        % Upsample to get more accurate peak
        up_range          = [5:80]+Info.Parameter.TriggerTimeZero;
        if P.STEREO
            [trace_up x_up]   = reconstruct( P.STEREO(up_range), P.upsample_factor );   % upsample
        else
            [trace_up x_up]   = reconstruct( trc(up_range), P.upsample_factor );   % upsample
        end
        [a_ id_]          = min(trace_up);                                   % find minimum 
    
        subplot(3,1,1);      hold off
            if P.BOOTSTRAP
                X  = [1:length(boot_mean)]+samp_bias;
                Y1 = boot_mean + boot_std;
                Y2 = boot_mean - boot_std;
                clr = 'r';
                fill([X X(end:-1:1)],[Y1 Y2(end:-1:1)],clr,'edgecolor',clr); 
            else
                plot(repmat(x_trc,length(range),1)',trace(range,:)'); 
            end
            hold on
            plot(x_trc,trc,'k','linewidth',2)
            title([Info.Exptitle '  ' num2str(elc) ])
    
        subplot(3,1,2);               hold off
            if P.BOOTSTRAP,   fill([X X(end:-1:1)],[Y1 Y2(end:-1:1)],clr,'edgecolor',clr); hold on, end
            if P.STEREO,      plot(x_trc,P.STEREO,'color',[1 0 0]*.5); hold on,                          end
                            plot(x_trc,trc,'color',[1 1 1]*.5); hold on
                            plot(x_up+up_range(1)-1+samp_bias,trace_up,'k')
                            set(gca,'xlim',up_range([1 end]))
                            ylim = get(gca,'ylim'); 
                            ylim(1) = min([ylim(1) -10]);
                            ylim(2) = max([ylim(2)  10]);
                            set(gca,'ylim',ylim);
        
        if ~P.SLOPE
            NONE = 0;
            if ~AUTOTIMES
                fprintf('Pick the AP time point (valley) by clicking in the figure. Press a key to skip\n')
                if( ~waitforbuttonpress )
                    StartPoint = get(gca,'CurrentPoint');
                else
                    NONE  = 1;
                end
            else
                
                diff_min =  5; % [samples] difference from last
                diff_max =  5; % [samples] difference from last
                tmp = trc; 
                %tmp(trc>-2)=-2;
                [tmp loc]=findpeaks(-tmp);  tmp=-tmp;
                xx=find( loc>StartPoint-diff_min & loc<StartPoint+diff_max );
                loc=loc(xx); tmp=tmp(xx);
                [junk  b] = min(tmp(1:min([5 length(tmp)]))); 
                StartPoint = loc(b);
                gcf_ = gcf;
                figure(Fig_all)
                plot((StartPoint-Info.Parameter.TriggerTimeZero)/20,trc(loc(b))+yoff,'ro')
                figure(98); subplot(3,1,2)
            end
            if ~NONE
                
                % Find time of peak in trace_up in a range around the button click.                        
                [tmp id0] = min(abs(x_up+up_range(1)-1-StartPoint(1,1)));  % [sample]
                
                tmp_rng_1 = -P.upsample_factor*5;
                tmp_rng   = [tmp_rng_1:P.upsample_factor*4]+id0;
                tmp_rng(tmp_rng<1) = 1;
                               
                if P.POS_PEAK
                    %[tmp id1] = max(trace_up([-P.upsample_factor:P.upsample_factor]+id0));
                    [tmp id1] = max(trace_up(tmp_rng));
                else
                    %[tmp id1] = min(trace_up([-P.upsample_factor:P.upsample_factor]+id0));
                    [tmp id1] = min(trace_up(tmp_rng));
                end
                id        = id1 + id0 + tmp_rng_1 - 1;   
                %id        = id1 + id0-P.upsample_factor;            
                x         = x_up(id)+up_range(1)-1+samp_bias;
                disp(x)
                subplot(3,1,2), line([0 0]+x,[get(gca,'ylim')],'color','g')
                subplot(3,1,1), line([0 0]+x,[get(gca,'ylim')],'color','g')
                Use  = [Use  1];
                Time = [Time x]; % [samples]
                pause(.5)

            else
                Use  = [Use    0];
                Time = [Time NaN];
            end
        else
            subplot(3,1,3);               hold off
            plot(x_trc(2:end),diff(trc),'color',[1 1 1]*.5); hold on
            xx = x_up(2:end)+up_range(1)-1+samp_bias;
            yy = diff(trace_up);
            plot(xx,yy,'k')
            set(gca,'xlim',up_range([1 end]))
            xlabel '1st derivative'        
            fprintf('Pick the AP time point (valley) by clicking in the figure. Press a key to skip\n')
            if( ~waitforbuttonpress )
                StartPoint        = get(gca,'CurrentPoint');

                % Find time of min diff(trace_up) in a range around the button click.                        
                [tmp id0] = min(abs(xx-StartPoint(1,1)));  % [sample]
                tmp_rng_1 = -P.upsample_factor*5;
                tmp_rng   = [tmp_rng_1:P.upsample_factor]+id0;
                %tmp_rng   = tmp_rng(tmp_rng>0);
                tmp_rng(tmp_rng<1) = 1;
                [tmp id1] = min(yy(tmp_rng));
                id        = id1 + id0 + tmp_rng_1;   
                x         = x_up(id)+up_range(1)-1+samp_bias;
                disp(x)
                subplot(3,1,2), line([0 0]+x,[get(gca,'ylim')],'color','b')
                subplot(3,1,3), line([0 0]+x,[get(gca,'ylim')],'color','b')
                subplot(3,1,1), line([0 0]+x,[get(gca,'ylim')],'color','b')
                Use  = [Use  1];
                Time = [Time x]; % [samples]
                pause(.5)

            else
                Use  = [Use    0];
                Time = [Time NaN];
            end
        end
              
        if Use(end)
            %up_range          = 1:Info.Parameter.TriggerLength;
            up_range          = round(Time(end)) + [-10:10];
            if P.STEREO
                [trace_up x_up]   = reconstruct( boot_traces_P.STEREO_mean(:,up_range), P.upsample_factor );   % upsample
            elseif P.SLOPE
                [trace_up x_up]   = reconstruct( [zeros(P.BOOTSTRAP_N,1) diff(bootstrap_traces_mean(:,up_range)')'], P.upsample_factor );   % upsample
            else
                [trace_up x_up]   = reconstruct( bootstrap_traces_mean(:,up_range), P.upsample_factor );   % upsample
            end
            [trace_up_orig tmp]   = reconstruct( bootstrap_traces_mean(:,up_range), P.upsample_factor );   % upsample
            xx               = x_up + up_range(1)-1+samp_bias;
            [tmp id]         = min(abs( xx - Time(end) ));
            rng              = id + [-P.upsample_factor*2:P.upsample_factor*2];
            rng_h            = id + [-P.upsample_factor*4:P.upsample_factor*4];
            trace_up_orig_m  = mean(trace_up_orig);
            [hgt_min id]     = min(trace_up_orig_m(rng_h)');
            [hgt_max id]     = max(trace_up_orig_m(rng_h)');
            [tmp id]         = min(trace_up(:,rng)');
            pks              = x_up(rng(id))+up_range(1)-1+samp_bias;
            Time_boot(cnt,:) = pks;
            Time_boot_m      = [ Time_boot_m   mean(pks)  ];
            Time_boot_sd     = [ Time_boot_sd  std(pks)   ];
            Height_boot_m    = [ Height_boot_m hgt_max-hgt_min  ]; % peak-to-peak
            fprintf('Elc %i  peak at sample %2.2f±%1.4f\n',elc,mean(pks),std(pks))
                subplot(3,1,2); 
                    %line([up_range([1 end])],[1 1]*hgt_min,'color',[1 1 1]*.8)
                    %line([up_range([1 end])],[1 1]*hgt_max,'color',[1 1 1]*.8)
                    line([x_up(rng_h([1 end]))+up_range(1)-1+samp_bias],[1 1]*hgt_min,'color',[1 1 1]*.8)
                    line([x_up(rng_h([1 end]))+up_range(1)-1+samp_bias],[1 1]*hgt_max,'color',[1 1 1]*.8)
                figure(Fig_im), 
                    [x y]=el2position(elc);
                    plot(x,y,'s','color',1-clr_r_,'markerfacecolor',1-clr_r)
        else
            Time_boot(cnt,:) = zeros(1,P.BOOTSTRAP_N);
            Time_boot_m      = [ Time_boot_m   NaN ];
            Time_boot_sd     = [ Time_boot_sd  NaN ];
            Height_boot_m    = [ Height_boot_m NaN ];
            figure(Fig_im), 
                [x y]=el2position(elc);
                plot(x,y,'ks','markerfacecolor','k')
        end
    end
    if PAUSE,  pause,  end    
end


    %%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%
    
    
 figure(Fig_all)
     set(gca,'ylim',[-20 yoff+20])
     set(gca,'xlim',[0 6])
     figure_size(4,24)
     if 0
        title ''
        set(gca,'ytick',[],'ycolor',[1 1 1]*.99)
        filename = ['/home/bakkumd/Desktop/' Info.Exptitle '-Traces-2'];
        print('-dpdf','-r250',filename)
     end
 
     %%%
     
 figure(88)
 imagesc(flipud(trace_all))
     colormap(gray)
     %colorbar
     caxis([-1 1]*25)
     set(gca,'ylim',[0 size(trace_all,1)+1])
     set(gca,'xlim',[0 10]*20)
     figure_size(5,12)
     if 0
        filename = ['/home/bakkumd/Desktop/' Info.Exptitle '-Traces_alt'];
        print('-dpdf','-r250',filename)
     end

     
 figure(89); clf
 plot(Time_boot'/20-Info.Parameter.TriggerTimeZero/20,'.')
     ylabel 'Latency [ms]'
     xlabel 'Bootstrap trial'
     title([Info.Exptitle])
     
     
     
     %%%%%%%%%%%%%

     
%%  Calculate distance based on electrode spacing

clear d
cnt = 0;
for i=2:length(Elc)
    cnt = cnt+1;
    d(cnt) = electrode_distance(Elc(cnt),Elc(cnt+1));
end

% Get cummulative distance instead of electrode-to-electrode distance
clear DistElc
DistElc(1) = 0;
cnt = 1;
for i = d
    cnt = cnt+1;
    DistElc(cnt) = DistElc(cnt-1)+i;
end



%% Calculate distance by clicking on plots (such as a microscope image from analysis_ImageAlignment.m)
%
% NOTE - for 130111-D3 pathway saved in fig/130111-D-part2-DistancePath.fig
%

dist = [];
cnt  = 0
while 1
    position = clickposition('c');
    
    cnt = cnt+1;
    d   = 0;
    for i=1:length(position.x)-1
        d  =  d  +  (   diff(position.x([0 1]+i))^2  +  diff(position.y([0 1]+i))^2    )^.5;
    end
    dist  =  [dist d];
end


% Get cummulative distance instead of electrode-to-electrode distance
clear DistClick
DistClick(1) = 0;
cnt = 1;
for i = dist
    cnt = cnt+1;
    DistClick(cnt) = DistClick(cnt-1)+i;
end



%% Print vector values to screen (to more easily copy into a script)

%  tmp  =  Dist; name = 'Dist';
%  tmp  =  Time_boot_m; name = 'Time';
%  tmp  =  Height_boot_m; name = 'Height';

fprintf([name ' = ['])
for i = tmp, fprintf('%i ',i), end
fprintf('];\n\n')



%% Save bootstrap values for making velocity plots and statistics
%  Use in analysis_Velocities.m
%

 clear Boot
 Boot.Time   = Time_boot;
 Boot.Height = Height_boot_m;
 Boot.Elc    = Elc;
 Boot.Dist   = DistElc;
 %Boot.Dist   = DistClick;
 if 0
     filename = ['mat/' Info.Exptitle '-Boot-Peak-EAST2.mat'];
     save(filename,'Boot','Info','P');
 end  
     
 
    
     

 
 
 
 
 
 
 




%
%
%
%
%
%% Plot latencies/height fill over image (2D colorbar plot)

depth = 256; % colormap depth

figure

    axis([1600 2000 50 700])
    elc   = plotelectrodenumbers('figure',0);
    tzero = 0;
    tm    = (Time_boot_m-Info.Parameter.TriggerTimeZero)/20;
    ht    = Height_boot_m;

    hmax =  10;
    hmin =  0;

    tmax = 10; % [ms]
    tmin =  0; % [ms]


rng     = find(~isnan(tm) & ht>hmin);
[x y]   = el2position(Elc(rng));

hgt             = ht(rng);
hgt(hgt>hmax)   = hmax;
hgt(hgt<hmin)   = hmin;
hgt             = hgt-hmin;
hmax            = hmax-hmin;
hgt             = floor( hgt/hmax*(depth-1) );
hgt_3           = repmat(hgt,3,1)';


clr             = tm(rng);
clr(clr>tmax)   = tmax;
clr(clr<tmin)   = tmin;
clr             = clr - tmin ;
clr             = floor( clr/max(clr)*(depth-1) );


%map = (flipud( lbmap(depth,'RedBlue') ))   % colormaps for the colorblind
map = mkpj(depth,'J_DB');              % modified by me to add more red (perceptually balanced colormaps)
clr = map(clr+1,:);
clr = clr +  (1-clr).*(depth-hgt_3)/(depth);




%     imagesc(im)
%     axis equal
%     colormap gray
%     caxis([0 im_ul-im_ll])
%     title(fn1)
    figure_size(8,12)
    axis fill
    

hold on
art_rng = 90; % [um]

id_  = [];
cnt  = 0;
for i = elc
    cnt = cnt+1;
    id = find(Info.Map.el==i);
    if ~isempty(id)  &&  electrode_distance(i,Info.Parameter.StimElectrode)>art_rng  % skip unconnected
        [px py] = el2position(i);
        x       = px + ELC_M_Pt3um.X*[-0.5 -0.5   0.5  0.5 -0.5];
        y       = py + ELC_M_Pt3um.Y*[-0.5  0.5   0.5 -0.5 -0.5];
        id      = find(i==Elc(rng));
        if ~isempty(id)
            %f = fill(x,y,(clr(id,:)));
            id_ = [id_ cnt];
        else
            %f = fill(x,y,[1 1 1]);
        end
        %set(f,'edgecolor','k')
        %alpha(f,.8);
    end
end

%     % Do a scatter plot instead of filling
%     sz = 5;
%     clr_factor = 10;
%     map = mkpj(64,'J_DB');              % modified by me to add more red (perceptually balanced colormaps)
%     [px py] = el2position(elc(id_));
%     scatter(px,py,sz*7, [1 1 1]*.9,'filled'); 
%     scatter(px,py,sz*5, [1 1 1]*.6,'filled'); 
%     scatter(px,py,sz*3, (tm(id_)-tzero)*clr_factor,'filled'); 
%     colormap(map)    
    
    
    %caxis(([-2 1])*clr_factor) % match to StimMap caxis
    caxis(round([tmin tmax]-tzero)*clr_factor) % match to StimMap caxis
    axis([1600 2000 50 700])
    
    if 0
        title ''
        filename = ['/home/bakkumd/Desktop/' Info.Exptitle '-VelocityHeightFill'];
        print('-dpdf','-r250',filename)
    end




%% (cont) 2d colorbar

depth = 64;
map = mkpj(depth,'J_DB');              % modified by me to add more red (perceptually balanced colormaps)

clear index
cnt = 0;
for x_=1:depth
    for y_=1:depth
        cnt = cnt+1;
        
        c  = map(x_,:);
        c(c<.05) = .05;
        c = c +  (1-c).*(depth-y_)/depth;
        %c = c .* y/(depth-1); % low height -> black
                
        index.x(cnt)   = x_;
        index.y(cnt)   = y_;
        index.c(cnt,:) = c;
        %plot(x,y,'s','color',c,'markerfacecolor',c)
               
        
    end
end

figure;
scatter(fliplr(index.y),index.x,120,index.c,'s','filled')
    
    figure_size(5,5)
    axis equal 

    set(gca,'xtick',[0  depth],'xticklabel',[hmin hmax],'xlim',[-5 depth+5])
    %set(gca,'ytick',[0 (tzero-tmin)/(tmax-tmin)*depth depth],'yticklabel',{tmin/20, 'soma', tmax/20},'ylim',[-5 depth+5])
    set(gca,'ytick',[0 (tzero-tmin)/(tmax-tmin)*depth depth],'yticklabel',[tmin-tzero 0 tmax-tzero]/20,'ylim',[-5 depth+5])
    xlabel 'Height'
    ylabel 'Time [ms]'

 
    if 0
        title ''
        filename = ['/home/bakkumd/Desktop/' Info.Exptitle '-VelocityHeight2DColorbar'];
        filename = ['/home/bakkumd/Desktop/' Info.Exptitle '-VelocityHeight2DColorbar-axisoff'];
        print('-dpdf','-r250',filename)
    end


%% (cont) plot boxes over Elc

rng     = find(~isnan(tm) & ht>hmin);
figure
figure_size(8,12)
axis fill
hold on
for i=find(~isnan(elc))%1:length(id)
    x = ELC.X(elc(i)+1) + ELC_M_Pt3um.X*[-0.5 -0.5   0.5  0.5 -0.5];
    y = ELC.Y(elc(i)+1) + ELC_M_Pt3um.Y*[-0.5  0.5   0.5 -0.5 -0.5];
    f=fill(x,y,[1 1 1]); hold on
    set(f,'edgecolor','k')
    %line(x,y,'color',[1 1 1]*0)
end  
    
    axis ij equal off
    if strcmp(Info.Exptitle,'130111-967-E2')
        axis([150 600 400 1070])
    else
        axis([1600 2000 50 700])
    end
    

    if 0
        filename = ['/home/bakkumd/Desktop/' Info.Exptitle '-VelocityHeightFill-electrodeboxes'];
        print('-dpdf','-r250',filename)
    end
    
    
    
    
    
    
    
    


    