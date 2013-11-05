%%      Figure_Bursts.m      %%
%
%  START with this script to load data and run burst detection
%
%  Burst detection figures
%  Long term spont burst analysis (signatures / burst types / etc.)
%
%
%


%% Load mapfile and spike data

Info.Map=loadmapfile(Info.FileName.Map,1111); % load Info.FileName.Map and plot elc locations in figure 1111

%%


clear Spike

if strcmp(Info.Exptitle,'121227-F') || strcmp(Info.Exptitle,'120829-A') || strcmp(Info.Exptitle,'130104-A') || strcmp(Info.Exptitle,'120830-B') 
    Spike   = loadspikeform(Info.FileName.SpikeForm,4000000);
else
    Spike   = loadspikeform(Info.FileName.SpikeForm);
end


% Take last hour of data
if ~strcmp(Info.Exptitle,'120829-A') 
    xx = find(Spike.T(end)-Spike.T<60*60,1);
    Spike_.T    = Spike.T(xx:end);
    Spike_.C    = Spike.C(xx:end);
    Spike_.H    = Spike.H(xx:end);
    Spike_.clid = Spike.clid(xx:end);
    clear Spike
    Spike = Spike_;
end


fprintf('Duration %.2f [min]\n',diff(Spike.T([1 end]))/60 ) 

% % Find id of spike at 60 minute mark
%   find(Spike.T-Spike.T(1)>60*60,1)

tonic = [];

%% Set 'tonic' channels
%
% 
%  Spont Expts not appropriate:
%       090611--    only 1 neuron
%       100413-C    only tonic channels, few
%       101121-E    (27DIV) superbursts - detection ok, but dont use
%       101122-L    (28DIV) strange data, looks incorrect - too many tonic
%       101231-R    (17DIV) only ~20 channels, 2hrs - detection works pretty good though. few bursts (421) but see some diff in small v large
%       110201-C,U  (18DIV) only large bursts, large IBI, good detection
%       110311-B    only 10-20 active channels
%           12-E,G  (same)
%       110513-B,C  (36DIV) superbursting, grouped config
%       110516-A    (     ) only large bursts, after media change, good detection
%       110518-N    (     ) almost only tonic
%       
%       


% Set tonic channels

if      strcmp(Info.Exptitle,'120829-A' )
    tonic = [115 103 95 74 98 87 84 14 ];% 89 88    4 97]; % last two are close to tonic thresh
elseif  strcmp(Info.Exptitle,'120830-B' )
    tonic = [91 82 3 7 22 59 88 85 43      75 71 39 23  ]; % last four are not tonic but appear to be repeated spikes from channel 24, and so are dropped
elseif  strcmp(Info.Exptitle,'121227-F' )
    %tonic =  [54 58 125];
    tonic = [54 125];
elseif  strcmp(Info.Exptitle,'130104-A' )
    tonic = [112 104 92 28 26 93 5    69 ];    


% elseif  strcmp(Info.Exptitle,'110518-N' )  % LOTS tonic - too much
%     tonic = -1 + [ 37 93    1     7     9    12    13   16    19    20    23    26    30    31    32    41    43    45    46    49    54    62    63    64    65    67    70    75    78    80    83    85    87    92    97   102   106   108   111  112   114   119   120   122   126];
elseif  strcmp(Info.Exptitle,'110516-A' ) % ONLY large bursts (after media change, 36DIV) % same dish as 18-N, grouped config, after media change
    tonic = [7 67 91 117 92 49 10 51 9];
elseif  strcmp(Info.Exptitle,'110201-C' ) % ONLY large bursts (18DIV)
    tonic = [0 73 67];
elseif  strcmp(Info.Exptitle,'101121-E' ) % SUPERBURSTS
    tonic = [111];
    
    
elseif  strcmp(Info.Exptitle,'130520-A' ) % 
    tonic = [106 2 16];
elseif  strcmp(Info.Exptitle,'130520-B' ) % 
    tonic = [56 48 66 2 60];
elseif  strcmp(Info.Exptitle,'130520-C' ) % ONLY large bursts (29DIV)
    tonic = [109 97 93];
    
    
    
elseif  strcmp(Info.Exptitle,'110907-B' ) % THALAMUS - ok, but get transient stretches of high tonic activity that makes long detected bursts
    tonic = [72 99 44 29 19 49 22 26 7];
    
    
% elseif  strcmp(Info.Exptitle,'110311-B' )  % only 10-20 active channels... 
%     tonic = [121 61 49 32 33 46 67 77];    
% elseif  strcmp(Info.Exptitle,'090623-A' )  % only 10-15 active channels...
%     tonic = [ 44 2 ]; 
    
else
%     tonic = [];
end

% Set spike.tonic
Spike.tonic = zeros(size(Spike.C));
for c = tonic
    Spike.tonic(Spike.C==c) = 1;
end    

% % Set tonic electrodes
% tonic_el = zeros(size(tonic));
% cnt      = 0;
% for c = tonic
%     cnt = cnt+1;
%     tonic_el(cnt) = Info.Map.el(find(Info.Map.ch==c,1));
%     pause
% end



%% Find tonic channels
%  Get a 'tonic' firing rate by introducing a refractory period 
%  on the order of a burst width. Tonic channels will have high
%  'tonic' firing rate.
%  


% refract   = .5;   % [sec]
% tonic_th  =  1;   % [Hz] consider above this to be tonic channels
% refract   = .1;   % [sec]
% tonic_th  =  2;   % [Hz] consider above this to be tonic channels
refract   = .25;   % [sec]
tonic_th  =  1;   % [Hz] consider above this to be tonic channels
 
outside   = zeros(1,126);
inside    = zeros(1,126);
outside_r = zeros(1,126);
total     = zeros(1,126);
tmpclr    = zeros(1,126);

ID_tonic = {};
for c=0:125
    cc = find(Spike.C==c & Spike.H<-60 & Spike.clid);
    if isempty(cc), continue, end
    
    cnt = 1;
    clear ID_t 
    ID_t(cnt) = cc(1);%Spike.T(cc(1));
    t_old = min(Spike.T);
    for i=cc(2:end);
        if Spike.T(i)-t_old > refract
            t_old    = Spike.T(i);
            cnt      = cnt+1;
            ID_t(cnt) = i;%Spike.T(i);
        end
    end
        
    dT   = diff(Spike.T(cc));
    
    cut = refract;
    % outside(c+1)   = length(find(dT>cut));  % long ISI
    inside(c+1)    = length(find(dT<=cut));  % short ISI
    outside_r(c+1) = length(ID_t);
    total(c+1)     = length(cc);
    ID_tonic{c+1}  = ID_t;
    
    
    if ~isempty(find(tonic==c, 1))
        tmpclr(c+1) = 1;
    else
        tmpclr(c+1) = 0;
    end
    
end

%% tonic activity plot

    SAVE      = 0;

    mrksz     = 3;
    
    
    figure%(999)
    clf
    hold on
    
    tm = max(Spike.T)-min(Spike.T); % calculate firing rate over duration of whole experiment
    
    out  = outside_r / tm;
    x_ax = total / tm; %inside / tm;
    xx = find(~tmpclr);
    tt = find(tmpclr);
    %line([0 20],[0 0]+tonic_th,'color',[1 1 1]*.5)
    if ~SAVE, text(x_ax,out,int2str([0:125]'),'color',[1  1 1]*1); end
    plot(x_ax(xx),out(xx),'k+','markersize',mrksz)
    if ~SAVE,    plot(x_ax(tt),out(tt),'ro'); end
    clr = [1 1 1]*.5;
    plot(x_ax(tt),out(tt),'^','markersize',mrksz,'color',clr,'markerfacecolor',clr)

            tonic_ch = find(outside_r/tm>tonic_th)-1;
            disp('Tonic channels:')
            disp(tonic_ch)
            
            figure_size(8,8)
            if ~SAVE, 
                set(gca,'color',[1 1 1]*.3), 
                grid on
            end
            ax = axis;
            set(gca,'ylim',[0 1/refract])
            set(gca,'xlim',[0 round(max(x_ax))+1])
            %xlabel 'Inside [Hz]'
            xlabel 'Total Firing Rate [Hz]'
            ylabel 'Tonic Firing Rate [Hz]'
            title([Info.Exptitle '   Refract = ' num2str(refract) ' [sec]'])
            
            if SAVE
                box on
                set(gca,'ytick',[0:1:1/refract])
                figure_fontsize(8,'bold')
                filename = ['/home/bakkumd/Desktop/' Info.Exptitle '-TonicChannels'];
                print('-dpdf','-r250',filename)
            end
    
      
%%  
% raster plots ordered by amount of tonic activity
figure
hold on
    [a b]=sort(outside_r);
    cnt = -1;
    for c=b-1
        cnt = cnt+1;
        cc = find(Spike.C==c & Spike.H<-60 & Spike.clid);
        if isempty(cc), continue, end
        if ~isempty(find(tonic==c, 1))
            clr = 'r';
        else
            clr = 'k';
        end
        plot(Spike.T(cc),ones(size(cc))*cnt,'.','color',clr)
        text(Spike.T(1)-10,cnt,int2str(c));
    end
    title(Info.Exptitle)
    
    
%%  FIGURE - Tonic example raster plot
% Use 130104-A data.
% raster plots ordered by amount of tonic activity


    SAVE = 1;

    if     strcmp(Info.Exptitle,'130104-A')
        x1            = 14871; % axis limits [sec]
        x2            = 14894; % axis limits [s
    else
        disp 'WRONG EXPT. EXITING'
        return
    end

    mrksz         = 3;


    fig1=figure(801); clf;   hold on
    fig2=figure(802); clf;  hold on
    [a b]=sort(outside_r);
    cnt = 0;%-length(find(outside_r>0));
    cnt_t = 0;
    for c=b-1
        cc   = find(Spike.C==c & Spike.H<-60 & Spike.clid & Spike.T>x1 & Spike.T<x2);
        if isempty(cc), continue, end
        ID_t = ID_tonic{c+1};
        cc_t = find(Spike.T(ID_t)>x1 & Spike.T(ID_t)<x2);
        if ~isempty(find(tonic==c, 1))
            mrk = '^';
            cnt_t = cnt_t-1;
            clr = [1 1 1]*.5;
            off = cnt_t;
        else
            mrk = '+';
            cnt = cnt+1;
            clr = 'k';
            off = cnt;
        end
        figure(fig2); 
        plot(Spike.T(ID_t(cc_t)),ones(size(cc_t))*off,mrk,'markersize',mrksz,'color',clr,'markerfacecolor',clr)
        figure(fig1); 
        plot(Spike.T(cc),ones(size(cc))*off,mrk,'markersize',mrksz,'color',clr,'markerfacecolor',clr)

    end
    
    
    for fig = [fig1 fig2]
        figure(fig); 
        title(Info.Exptitle)

        % Plot red lines for when burst occurred
        xx=find(Burst.T_end<x2 & Burst.T_start>x1);
        tmp = [];
        for i=xx
            st = Burst.T_start(i);
            en = Burst.T_end(i);
            if en-st<.05, en=st+.05; end % Fix for printing plots. Too small causes funny shape.
            tmp = [tmp st en NaN];
        end
        plot(tmp,( cnt+2)*ones(size(tmp)),'r','linewidth',4)
                xlabel 'Time [sec]'
                ylabel 'Channel'
                title([Info.Exptitle])
                set(gca,'xlim',[x1-1 x2+1])
                %set(gca,'ylim',[-10 44])
                box off
                title ''
                figure_size(19,8)
                figure_fontsize(8,'bold')
                if SAVE    
                    set(gca,'xtick',[x1:5:x2],'xtickLabel',[0:5:(x2-x1)])
                    set(gca,'ytick',[cnt_t:10:60],'yticklabel',[0:10:60])                    
                    filename = ['/home/bakkumd/Desktop/' Info.Exptitle '-TonicRaster-' int2str(fig)];
                    print('-dpdf','-r250',filename)
                end
    end
    
    
        
        
    
%%
    % electrode locations
    Info.Map=loadmapfile(Info.FileName.Map,1111); % load Info.FileName.Map and plot elc locations in figure 1111
    hold on
    for c=0:125
        
        if ~isempty(find(tonic==c, 1))
            xx = find(Info.Map.ch==c);
            plot(Info.Map.px(xx),Info.Map.py(xx),'r.')
        else
            xx = find(Info.Map.ch==c);
            plot(Info.Map.px(xx),Info.Map.py(xx),'b.')
        end        
        
    end
    axis ij equal




    
    
    
    
    
%% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %%
%% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %%
%% Run burst detection code (matlab) from loaded spike data

    % Parameters
    %Parameter.N         = 10;    % FRnum within FRbin satisfies condition of high FR
    %Parameter.ISIn         = 0.05; % [sec]
    %Parameter.Gap           = Parameter.ISIn;% 100000;%0.025; % [sec] - a high value ignores the condition
    %Parameter.GoodSpikes    = find(~Spike.tonic & Spike.H<-60 & Spike.clid);                   % Use only non-tonically firing channels
    % Parameter.GoodSpikes    = find(               Spike.H<-60 & Spike.clid);                   % Use only non-tonically firing channels
  
%  [Burst Sort]  = BurstDetect(Spike,Parameter);  

% burst.C = burstCenters(burst,spike); % find burst center time points [sec]
% %burst.C = burstCenters(burst,spike,'number',100); % find burst center time points [sec]
% %burst.C = burstCenters(burst,spike,'figure',6,'number',100); % find burst center time points [sec]




%%   FIGURE   - ISIn historgrams
%    Burst detection conditions - low Gap, high FR
%    Probability versus ISI{j-i}
%
%  For figure, use data from 120829-A  
%
%  Assuming bursting state is different than non-bursting state, should see
%  difference in data trends. Therefore, use a point of interest in power law
%  curves for thresholds?
%

% %%  Code moved into function (for publishing purposes)
% %
%         %SpikeTimes =  ---- ;             % Load spike times here.
%         
%         GoodSpikes = find(~Spike.tonic & Spike.H<-60 & Spike.clid);                   % Use only non-tonically firing channels
%         SpikeTimes = Spike.T(GoodSpikes);
%         N          = [2:10];             % Range of N to plot ISI_N histograms.
%         Steps      = 10.^[-5:.05:1.5];   % Create uniform steps for log plot.
%         HistogramISIn(SpikeTimes,N,Steps)
% %
% %%


   
SAVE   = 0;

N    = [2:1:9 10]; % (j-i)  -- set of j to plot
%N    = [2 50 100 200 500 10]; % (j-i)  -- set of j to plot
%N = 63;
N = [2 10];


% Use increasing bin size such that uniform step sizes on a loglog plot
% steps  = 10.^[log10(.01):.05:log10(20000)];
Steps  = 10.^[log10(.01):.02:log10(20000)]; % [ms]
% steps  = 0:1:1000; % [ms] linearly spaced steps


GoodSpikes  = find(~Spike.tonic & Spike.H<-60 & Spike.clid);                   % Use only non-tonically firing channels

% % Sort spike times as not necessarily in order in spike file
 ID          = GoodSpikes;
 [Sort.T IX] = sort(Spike.T(ID) + rand(size(ID))/20000 ); % Jitter by up to 1 sample to make curve smoother at high frequencies (minimizes bias due to discrete sampling)
 Sort.C      = Spike.C(ID(IX));


figure; hold on

SMOOTH = 1;  % smooth curves


for FRnum = N
    if find(FRnum == N(end))
        clr    = 'r';
        mrk    = '-';
        mrksz  =  12;
        width  =   2;
    elseif find(FRnum == 2)
        clr    = 'k';
        mrk    = '-';
        mrksz  =  12;
        width  =   2;
    else
        clr    = [1 1 1]*.5;
        mrk    =  '.';
        mrksz  =   0;
        width  =   1;
    end
    
    
%     % ** For distributions to match BurstDet code:    (very slow for large N)
%     % ** Need  MINIMUM  ISI_i-j for range around i of bin width N; i.e. j=i+[-N+1:N-1]
%     clear d dtest
%     for j = [1:FRnum]-1
%         d(j+1,:)     = Spike( [FRnum:end-(FRnum-1)]+j ) - Spike( [1:end-(FRnum-1)*2]+j );            
%     end 
%     dt      = min(d);
    
%     % ** Use this for estimation with large N  (get nicer curves? smoother and larger distant ISI peak)
%     disp 'WARNING! Distribution does not match BurstDet code!'
     dt      = Sort.T( [FRnum:end] ) - Sort.T( [1:end-(FRnum-1)] );  
    
    
    
    [n x] = histc( dt*1000, Steps);     
    n(n==0) = 1; % fix for loglog plotting
    if mrksz
        loglog(Steps,n/sum(n),mrk,'color',clr,'markersize',mrksz);  hold on
    end
    if SMOOTH
        n = smooth(n);    
    end
    loglog(Steps,n/sum(n),'-','color',clr,'linewidth',width)
    
end

        





        if strcmp(Info.Exptitle,'120829-A')
            %  FRbin = 0.050;      line([1 1]*FRbin*1000,[10^-1.2 .15],'color',[1 1 1]*0)
            %  Gap   = 0.020;      line([1 1]*Gap*1000,  [10^-1   .15],'color',[1 1 1]*0)
            axis([Steps(1) 2500 .0001 1])
        end
        xlabel 'Network ISI, T_i - T_{i-(N-1) _{ }} [ms]'
        ylabel 'Probability [%]'
        title([Info.Exptitle])
        box on
        set(gca,'xtick',10.^[-1:3]) 
        figure_size(8,8)
        set(gca,'xscale','log')
        set(gca,'yscale','log')
        

        if SAVE
            figure_fontsize(8,'bold')
            filename = ['/home/bakkumd/Desktop/' Info.Exptitle '-NetworkISIPowerLaw2'];
            print('-dpdf','-r250',filename)
        end
        

%% Test of historgram plots code to be published

N           = [2:10];                               % Range of N to plot ISI_N histograms
Steps       = 10.^[-5:.05:1.5];                     % Create uniform step sizes for a log plot
GoodSpikes  = find(~Spike.tonic & Spike.H<-60 & Spike.clid);                   % Use only non-tonically firing channels

% % Sort spike times as not necessarily in order in spike file
 ID          = GoodSpikes;
 [Sort.T IX] = sort(Spike.T(ID) + rand(size(ID))/20000 ); % Jitter by up to 1 sample to make curve smoother at high frequencies (minimizes bias due to discrete sampling)
 Sort.C      = Spike.C(ID(IX));


HistogramISIn(Sort.T,N,Steps)






 %% (cont) 
%  Alternate plot - Scatter plot dt2 vs dt10
%                 - Pie chart 
%                 - Example raster plot - color-coded
%
%  * FIRST run burst detection code to get Burst and Parameter.N *
%

clear dt


        FRnumX =  2; % ISI x axis
        FRnumY = 10; 
        
        if strcmp(Info.Exptitle,'120829-A')
            FRbin_ = Parameter.ISIn; % threshold for ISI_i-j
            Gap    = .02; %Parameter.Gap;
        else
            FRbin_ = FRbin; % threshold for ISI_i-j
            Gap    = .02; %Parameter.Gap;
        end

  
for FRnum=[2:10]
    % ** Need  MINIMUM  ISI_i-j for range around i of bin width Num; i.e. j=i+[-Num+1:Num-1]
    d = zeros(FRnum,length(Sort.T))+inf;
    for j = 0:FRnum-1
        d(j+1,[FRnum:length(Sort.T)-(FRnum-1)]) = Sort.T( [FRnum:end-(FRnum-1)]+j ) - Sort.T( [1:end-(FRnum-1)*2]+j ); 
    end 
    dt(FRnum,:) = min(d);
end    

off = find(Sort.T > Sort.T(1)+5*60,1);        % start at 5 minute mark
len = find(Sort.T > Sort.T(off)+10*60,1)-off; % end after 10 minutes
fprintf('Time considered %0.2f minutes.\n',diff(Sort.T([off off+len]))/60);

 
% %%

figure(98)
clf

        x       = dt(FRnumX,[1:len]+off)*1000;
        y       = dt(FRnumY,[1:len]+off)*1000;
        

        fprintf(' * Skipped plotting diff(ISI-1-2) (x-axis) less than 1 sample, as log(0)=-Inf');
        quad1 =(find(x<=Gap*1000 & y >FRbin_*1000 & x>.05 )) ;  % skip plotting differences less than 1 sample, as log(0)=-Inf
        quad3 =(find(x<=Gap*1000 & y<=FRbin_*1000 & x>.05 )) ;  % skip plotting differences less than 1 sample, as log(0)=-Inf
        quad2 =(find(x >Gap*1000 & y >FRbin_*1000 )) ;  
        quad4 =(find(x >Gap*1000 & y<=FRbin_*1000 )) ; 
        disp(length(quad1))
        
        
        mrksz         = 5;
        
        hold on
        clr = 'k';          loglog(x(quad3),y(quad3), '.', 'color',clr,'markersize',mrksz)%'markersize',5) 
        clr = [0 1 1]/1.4;  loglog(x(quad1),y(quad1), '.', 'color',clr,'markersize',mrksz,'markerfacecolor',clr)
        clr = [0 1 0]/1.2;  loglog(x(quad2),y(quad2), '.', 'color',clr,'markersize',mrksz,'markerfacecolor',clr)
        clr = 'b';          loglog(x(quad4),y(quad4), '.', 'color',clr,'markersize',mrksz,'markerfacecolor',clr)
        set(gca,'XScale','log')
        set(gca,'YScale','log')
        
        line([10^-2 10^4],[1 1]*FRbin_*1000,'color',[1 1 1]*0)
        line([1 1]*Gap*1000,  [10^-2   10^4],'color',[1 1 1]*0)
        
        xlabel([ 'Network ISI, T_i - T_{i-' num2str(FRnumX-1)  '_{ }} [ms]' ])
        ylabel([ 'Network ISI, T_i - T_{i-' num2str(FRnumY-1)  '_{ }} [ms]' ])
        title([Info.Exptitle])
        
        axis([.03 2500 .03 2500])
        set(gca,'xtick',10.^[-1:3])
        set(gca,'ytick',10.^[-1:3])
        
%     pause
% end
% figure
% plot(err)
% %%
        

        if SAVE
            box on
            title ''
            figure_size(8,8)
            figure_fontsize(8,'bold')
            filename = ['/home/bakkumd/Desktop/' Info.Exptitle '-NetworkISIPowerLaw_Alt3'];
            print('-dpdf','-r250',filename)
        end
        
        
        
        
        % Test correct IDs on raster plots
        figure(99); clf; hold on
            
        
            % Order channels by FR for plot
            N = zeros(1,126); 
            for c = 0:125
               N(c+1) = length(find(Spike.C(GoodSpikes)==c));
            end
            [b cc] = sort(N);
            for c = 1:126
               C(c) = find(cc==c);
            end
       
        
            quad1 =(find(x<=Gap*1000 & y >FRbin_*1000)) ; 
            quad2 =(find(x >Gap*1000 & y >FRbin_*1000)) ; 
            quad3 =(find(x<=Gap*1000 & y<=FRbin_*1000)) ; 
            quad4 =(find(x >Gap*1000 & y<=FRbin_*1000)) ; 

            mrksz         = 3;
            clr = [0 1 1]/1.4;  plot(Sort.T(quad1+off),C(1+Sort.C(quad1+off)), 'o' ,'color',clr,'markersize',mrksz,'markerfacecolor','w')
            clr = [0 1 0]/1.2;  plot(Sort.T(quad2+off),C(1+Sort.C(quad2+off)), '<' ,'color',clr,'markersize',mrksz,'markerfacecolor',clr)
            clr = 'b';          plot(Sort.T(quad4+off),C(1+Sort.C(quad4+off)), 's' ,'color',clr,'markersize',mrksz,'markerfacecolor',clr)
            clr = 'k';          plot(Sort.T(quad3+off),C(1+Sort.C(quad3+off)), '+' ,'color',clr,'markersize',mrksz)           

                % Xlim
                %x1 = 1421.5;
                %x2 = 1429.5;
                x1 = 1275;
                x2 = x1+10;
                
                
                % Plot red lines for when burst occurred
                xx=find(Burst.T_end<x2 & Burst.T_start>x1);
                tmp = [];
                for i=xx
                    tmp = [tmp Burst.T_start(i) Burst.T_end(i) NaN];
                end
                plot(tmp,( 126+5)*ones(size(tmp)),'r','linewidth',4)

                axis([x1 x2 -10 133])
                xlabel 'Time [sec]'
                ylabel 'Channel'
                title([Info.Exptitle])
                box off
                figure_size(19,8)
                figure_fontsize(8,'bold')

                if SAVE
                    set(gca,'xtick',[x1:x2],'xtickLabel',[0:(x2-x1)])
                    set(gca,'ytick',[126-length(unique(Sort.C)):20:126],'yticklabel',[0:20:length(unique(Sort.C))])
                    set(gca,'ylim',[126-length(unique(Sort.C))-5 133])
                    filename = ['/home/bakkumd/Desktop/' Info.Exptitle '-BurstDetectionDrops3'];
                    print('-dpdf','-r250',filename)
                end
            
        
            

        figure(97); % Pie chart
            piedata = [length(quad3) length(quad4) length(quad2) length(quad1) ];
            piedata(piedata==0) = 1; % fix for plotting
            h = pie(piedata);
                pieColors = {'k', 'b', [0 1 0]/1.2, [0 1 1]/1.4,};
                for i=1:4;
                    set(h(i*2-1), 'FaceColor', pieColors{i}, 'EdgeColor','none');
                end

                textObjs = findobj(h,'Type','text');
                oldStr   = get(textObjs,{'String'})
                val      = get(textObjs,{'Extent'});
                oldExt   = cat(1,val{:});
                Names    =  {' ';' ';' ';' '};
                set(textObjs,{'String'},Names)



                figure_size(3,3)
                figure_fontsize(8,'bold')
                if SAVE
                    filename = ['/home/bakkumd/Desktop/' Info.Exptitle '-NetworkISIPowerLaw_AltPie3'];
                    print('-dpdf','-r250',filename)
                end


            
            
        
 %% (cont)
%  Histograms for scatter plot edges

SAVE = 0;

figure(101)
dt_ = dt(2,:)*1000;
dt_ = dt_(dt_>.05); % ignore < 1 sample as explained above
[n x] = histc(dt_,steps);
xx = find(n & steps>=0);%0.03);                     % 0.05ms <= sampling rate
%yy = find(n & steps< 0.03);                     % 0.05ms <= sampling rate

n(xx) = smooth(n(xx));
fill([steps(xx(1))-.01 steps(xx(1))-.01 steps(xx) steps(xx(end)) steps(xx(1))-.01],[min(n(xx)) n(xx(1)) n(xx) min(n(xx)) min(n(xx))]/sum(n),'k')
% hold on
% fill([1 1 -1 -1]*.0025+steps(yy),[min(n(xx)) n(yy) n(yy) min(n(xx))]/sum(n),'k')
       



        %axis([.03 2500 .03 2500])
        axis([.01 2500 .001 1])
        set(gca,'XScale','log')
        set(gca,'YScale','log')
        if SAVE
            axis off square
            figure_size(8,8)
            figure_fontsize(8,'bold')
            filename = ['/home/bakkumd/Desktop/' Info.Exptitle '-NetworkISIPowerLaw_Alt_HistDT2'];
            print('-dpdf','-r250',filename)
        end

% %%
figure(102)

dt_ = dt(10,:)*1000;
dt_ = dt_(dt_>.05); % ignore < 1 sample as explained above
[n x] = histc(dt_,steps);
xx = find(n & steps>=0);%0.03);                     % 0.05ms <= sampling rate
%yy = find(n & steps< 0.03);                     % 0.05ms <= sampling rate

n(xx) = smooth(n(xx));
fill([steps(xx(1))-.01 steps(xx(1))-.01 steps(xx) steps(xx(end)) steps(xx(1))-.01],[min(n(xx)) n(xx(1)) n(xx) min(n(xx)) min(n(xx))]/sum(n),'k')
% hold on
% fill([0 0 -1 -1]*.0025+steps(yy),[min(n(xx)) n(yy) n(yy) min(n(xx))]/sum(n),'k')
       
        axis([.01 2500 .001 1])
        set(gca,'XScale','log')
        set(gca,'YScale','log')
        if SAVE
            axis off square
            figure_size(8,8)
            figure_fontsize(8,'bold')
            filename = ['/home/bakkumd/Desktop/' Info.Exptitle '-NetworkISIPowerLaw_Alt_HistDT10'];
            print('-dpdf','-r250',filename)
        end
                
        
        
%% test how close electrods are

el = unique(Info.Map.el(Info.Map.el>-1));
d  = zeros(length(el),1);
cnt = 0;
for e = el'
    cnt = cnt+1;
    tmp  = electrode_distance(e,el);
    d(cnt) = min(tmp(tmp>0));
end

figure
plot(d,'.')
ylabel distance
grid on
title(['min distance = ' num2str(min(d))])




%% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %%
%% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %%
%% Run burst detection code (matlab) from loaded spike data


    if      strcmp(Info.Exptitle,'120829-A' )
        Parameter_N             =  10; % FRnum within FRbin satisfies condition of high FR
        Parameter_ISIn         = .05; % [sec]
        
    elseif  strcmp(Info.Exptitle,'120830-B' )
        Parameter_N             =  10; % FRnum within FRbin satisfies condition of high FR
        Parameter_ISIn         = .04; % [sec]
        
    elseif  strcmp(Info.Exptitle,'121227-F' )
        Parameter_N             =  10; % FRnum within FRbin satisfies condition of high FR
        Parameter_ISIn         = .14; % [sec]

    elseif  strcmp(Info.Exptitle,'130104-A' )
        Parameter_N             =  10; % FRnum within FRbin satisfies condition of high FR
        Parameter_ISIn         = .20; % [sec]


    elseif  strcmp(Info.Exptitle,'110516-A' ) % ONLY large bursts (after media change, 36DIV) % same dish as 18-N, grouped config, after media change
        Parameter_N             =  10; % FRnum within FRbin satisfies condition of high FR
        Parameter_ISIn         = .10; % [sec]
       
    elseif  strcmp(Info.Exptitle,'110201-C' ) % ONLY large bursts (18DIV)
        Parameter_N             =  10; % FRnum within FRbin satisfies condition of high FR
        Parameter_ISIn         = .19; % [sec]
        
    % elseif  strcmp(Info.Exptitle,'101121-E' ) % SUPERBURSTS
       


    elseif  strcmp(Info.Exptitle,'130520-A' )  
        Parameter_N             =  10; % FRnum within FRbin satisfies condition of high FR
        Parameter_ISIn         = .25; % [sec]
       
    elseif  strcmp(Info.Exptitle,'130520-B' )  
        Parameter_N             =  10; % FRnum within FRbin satisfies condition of high FR
        Parameter_ISIn         = .07; % [sec]
       
    elseif  strcmp(Info.Exptitle,'130520-C' ) % ONLY large bursts (29DIV)
        Parameter_N             =  10; % FRnum within FRbin satisfies condition of high FR
        Parameter_ISIn         = .35; % [sec]
        
    end

    
    
    % Parameters
    Parameter.N             = Parameter_N     ;  % FRnum within FRbin satisfies condition of high FR
    Parameter.ISIn          = Parameter_ISIn ;  % [sec]
    Parameter.Gap           = 1000000;%0.025; % [sec] - a high value ignores the condition
    Parameter.GoodSpikes    = find(~Spike.tonic & Spike.H<-60 & Spike.clid);                   % Use only non-tonically firing channels
%     Parameter.GoodSpikes    = find(               Spike.H<-60 & Spike.clid);                   % Use only non-tonically firing channels
  


%%% BurstDetectISIn - code to publish

    % Sort spike times as not necessarily in order in spike file
    [Sort.T IX] = sort(Spike.T(Parameter.GoodSpikes) + rand(size(Parameter.GoodSpikes))/20000 ); % Jitter by up to 1 sample to make curve smoother at high frequencies (minimizes bias due to discrete sampling)
     Sort.C     = Spike.C(Parameter.GoodSpikes(IX));

[Burst BurstN]  = BurstDetectISIn(Sort,Parameter.N,Parameter.ISIn);  
Sort.N          = BurstN;



%%

% BurstDetect - old code
 [Burst Sort]  = BurstDetect(Spike,Parameter);  


% burst.C = burstCenters(burst,spike); % find burst center time points [sec]
% %burst.C = burstCenters(burst,spike,'number',100); % find burst center time points [sec]
% %burst.C = burstCenters(burst,spike,'figure',6,'number',100); % find burst center time points [sec]

% %%
% figure
% hold on
% plot(Sort.T,Sort.C,'.')
% xx=find(Sort.Burst_N==-1);                plot(Sort.T(xx),Sort.C(xx),'k.')
% xx=find(Sort.Burst_N==-10);               plot(Sort.T(xx),Sort.C(xx),'co')
% 
% xx=find(Sort.T>46393 & Sort.Burst_N>0,1); 
% xx=find(Sort.Burst_N==Sort.Burst_N(xx));  
% plot(Sort.T(xx),Sort.C(xx),'ro')
% axis(a)


%% Run burst detection code (cpp) from binary spike file
% 
% %    system(['rm ' outfile])
% 
% outfile = ['/home/bakkumd/Desktop/' Info.Exptitle '.tmp.burst'];
% cmd     = ['/home/bakkumd/Documents/Code/bin/BurstDetector -s ' Info.FileName.Spike ' -o ' outfile]; 
% %    system(cmd)
% 
% 
% % %% Load burst data
% 
% Burst   = loadBURSTinfoCMOS(outfile);
% 
% 
%  
% % burst.C = burstCenters(burst,spike); % find burst center time points [sec]
% % %burst.C = burstCenters(burst,spike,'number',100); % find burst center time points [sec]
% % %burst.C = burstCenters(burst,spike,'figure',6,'number',100); % find burst center time points [sec]
% % spike.B = spikeInBurst(burst,spike);                         % find burst number for all spikes 



%% Raster plots to visually check if burst detection code worked.

HIGHLIGHTTONIC = 1; % plot tonic channels in different color

figure
hold on

xx=find(Burst.T_end<max(Spike.T));
tmp = [];
for i=xx
    tmp = [tmp Burst.T_start(i) Burst.T_end(i) NaN];
end
plot(tmp,128*ones(size(tmp)),'r','linewidth',4)
plot(tmp, -2*ones(size(tmp)),'r','linewidth',4)
plot(Burst.T_start(xx),128,'bo')
plot(Burst.T_start(xx), -2,'bo')


% Order channels by FR for plot
N = zeros(1,126); 
for c = 0:125
   N(c+1) = length(find(Spike.C(Parameter.GoodSpikes)==c));
end
[b cc] = sort(N);
for c = 1:126
   C(c) = find(cc==c);
end

%plot(Spike.T,Spike.C,'.')
plot(Spike.T(Parameter.GoodSpikes),C(1+Spike.C(Parameter.GoodSpikes)),'k.')
%text(min(Spike.T)+zeros(1,126),C,int2str([0:125]'),'color',[1  1 1]*0);
set(gca,'ytick',(min(Spike.C):max(Spike.C))+1,'yticklabel',cc-min(cc)+min(Spike.C))

[n x] = hist(Spike.T,ceil(diff(Spike.T([1 end])))/.05); % 50 ms bins
plot(x,n/max(n)*20+130)
line([Spike.T([1 end])], [0 0]+130+50/max(n)*20,'color','k','linewidth',1) % threshold of 50spikes / bin

grid on
xlabel 'Time [sec]'
ylabel 'Channel'
title([Info.Exptitle])

if HIGHLIGHTTONIC
    id = find(Spike.tonic);
    plot(Spike.T(id),C(1+Spike.C(id)),'.','color',[1 1 1]*.5)
end
figure_size(28,8)


%% Make movie of electrode locations during burst
%  colorbar is log10(Burst.S)


SAVE    = 1;


%[a id]  = sort(Burst.S);
 id      = 1:length(Burst.S);


figure
load global_cmos

ll      = log10(10);
ul      = ceil(log10(max(Burst.S)));
c_scale = 100;
map     = jet((ul-ll)*c_scale);
cnt     = 0;

reverseStr = '';
for i=id%(1:10:end)

    ch = unique(Sort.C(Sort.Burst_N==i));
    
    el = [];
    for c=ch
        el = [el Info.Map.el(Info.Map.ch==c)'];
    end
    clf
    hold on
    plot(ELC.X,ELC.Y,'.','color',[1 1 1]*.5)

    [x y]=el2position(Info.Map.el);
    plot(x,y,'k.')
    
    [x y]=el2position(tonic_el);
    plot(x,y,'.','color',[1 1 1]*.5)
    

    [x y]=el2position(el);
    plot(x,y,'.','color',map(ceil(c_scale*(log10(Burst.S(i))-ll))+1,:) )
    plot(x,y,'ko','markersize',4)
    
        axis ij equal
        title(Burst.S(i))
        colorbar
        caxis([1 ul])
        axis([100 2000 50 2150]);
        axis off
        
        
        if SAVE
            figure_fontsize(8,'bold')
            figure_size(8,8)
            filename=sprintf('/home/bakkumd/Movies/pics/%s_%03d',Info.Exptitle,cnt);
            cnt=cnt+1;
            print('-dpng','-r150',[filename '.png']) 
        else
            pause(.1)
        end
        
        
        msg = sprintf('%d/%d\n', i, length(id) );
        fprintf([reverseStr, msg]);
        reverseStr = repmat(sprintf('\b'), 1, length(msg));    
    
end



%% Make movie from still images saved above

   filename_i = ['/home/bakkumd/Movies/pics/' Info.Exptitle '_']
   filename_o = ['/home/bakkumd/Movies/' Info.Exptitle '_']
   
   cmd=['/usr/local/hierlemann/mplayer/bin/mencoder "mf://' filename_i '*.png" -mf fps=20 -o ' filename_o '.avi -ovc lavc -lavcopts vcodec=msmpeg4v2:vbitrate=800']
   % To scale, use the '-vf scale=width:height' option.
 
   system(cmd)
 
%   PLAY using
%               system('mplayer filename')
%               system(['mplayer ' filename_o '.avi'])



%%   FIGURE   %%
%  Burst detection EXAMPLE raster plot.
%
%    use 120829-A for example figure
%
% %


if     strcmp(Info.Exptitle,'121227-F')
    x1        = 47004   % axis limits [sec]
    x2        = x1+40;  % axis limits [sec]
elseif strcmp(Info.Exptitle,'120829-A')
    % 120829-A
    % x1      = 779;   % axis limits [sec]
    % x2      = x1+30; % axis limits [sec]
    x1        = 1423.9;%1216;   % axis limits [sec]
    x2        = x1+16;%+30; % axis limits [sec]
else
    disp 'WRONG EXPT. EXITING'
    return
end


PLOT_TONIC    = 1;


mrk           = '+';
mrksz         = 2;


figure; 
hold on   
ID_0  = find(Spike.T<x2 & Spike.T>x1 & Spike.H<-60 );

% Order channels by FR for plot
N = zeros(1,126); 
for c = 0:125
   N(c+1) = length(find(Spike.C==c));
end
[b C] = sort(N);


cnt_t =  0;
cnt_b =  0;
for c = C-1 % 0:125
    xx     = ID_0(Spike.C(ID_0)==c);
    if find(tonic==c) 
        if PLOT_TONIC
            cnt_t  = cnt_t+1;
            plot(Spike.T(xx),-cnt_t*ones(size(xx)),mrk,'markersize',mrksz,'color',[1 1 1]*.5)
            text(Spike.T(ID_0(1))-10,-cnt_t,int2str(c))
        end
    else
        cnt_b  = cnt_b+1;
        plot(Spike.T(xx), cnt_b*ones(size(xx)),mrk,'markersize',mrksz,'color',[0 0 1]*0)
        text(Spike.T(ID_0(1))-10, cnt_b,int2str(c))
    end
end

% Plot red lines for when burst occurred
xx=find(Burst.T_end<x2 & Burst.T_start>x1);
tmp = [];
for i=xx
    st = Burst.T_start(i);
    en = Burst.T_end(i);
    if en-st<.05, en=st+.05; end % Fix for printing plots. Too small causes funny shape.
    tmp = [tmp st en NaN];
end
plot(tmp,( cnt_b+5)*ones(size(tmp)),'r','linewidth',4)


        xlabel 'Time [sec]'
        ylabel 'Channel'
        title([Info.Exptitle])
        set(gca,'xlim',[x1-.1 x2+.1])
        set(gca,'ylim',[-cnt_t-7 cnt_b+7])
        box off
        
        figure_size(19,8)
        figure_fontsize(8,'bold')
        
        if 0    
            set(gca,'xtick',[x1:1:x2],'xtickLabel',[0:1:(x2-x1)])
            set(gca,'ytick',[-cnt_t:20:cnt_b],'yticklabel',[0:20:cnt_b+cnt_t])            
            filename = ['/home/bakkumd/Desktop/' Info.Exptitle '-BurstDetectionSorted'];
            print('-dpdf','-r250',filename)
        end

        
%% Plot locations of recording electrodes
    
    SAVE = 0;
    
    figure
    hold on
    [x y] = el2position(0:11015);   %plot(x,y,'.', 'markersize',1,'color',[1 1 1]*.5)
    x = x(x>0);
    y = y(y>0);
    b = 20;  % border
    line([max(x)+b max(x)+b min(x)-b min(x)-b max(x)+b],[max(y)+b min(y)-b min(y)-b max(y)+b max(y)+b],'color','k','linewidth',1.5)
    %y_ax = [min(y)-2*b max(y)+2*b];
    
    mrksz = 4;
    for c = Info.Map.ch'
        if c==-1, continue, end
        [x y] = el2position(Info.Map.el( find(Info.Map.ch==c,1) ));
        if ~isempty(find(tonic==c))
            clr = [1 1 1]*.5;
            plot(x,y,'^','markersize',mrksz,'color',clr,'markerfacecolor',clr)
        else
            clr = [1 1 1]*0;
            plot(x,y,'+','markersize',mrksz,'color',clr,'markerfacecolor',clr)
        end
    end
    line([0  200]+1600, [0 0]+2200,'color','k','linewidth',2) % [200 um] scale bar
    axis ij equal 
    %set(gca,'ylim',y_ax)
    
    figure_size(8,8)
    axis fill
    if SAVE
         axis off
         filename = ['/home/bakkumd/Desktop/' Info.Exptitle 'ElcLocations'];
         print('-dpdf','-r250',filename)
    end
    
    
    
        
%% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %%
%% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %% %%
%%   FIGURE   %%
%    STATS - HISTOGRAMS
%    Number of channels with spikes per burst VS burst size
%
%    Get number of channels with spikes per burst after using BurstDetect.m
%

bst  = Burst.S+rand(size(Burst.S));
chn  = Burst.C+rand(size(Burst.S));

fig = 500;

%
%   Make figures
%

SAVE = 0;


% %% Scatterplot of Burst Size vs Num Channels
figure(fig+4); clf
% Try transparency plot ....
%    x = burst.S(1:length(chn));
%    y = chn;
%    for i = 1:length(x)
%         wx = 1;
%         wy = 1;%0^y(i);
%         fill([0 wx wx 0]+x(i),[0 0 wy wy]+y(i),'k','edgecolor','none','facealpha',.5)
%         hold on
%         pause
%    end
semilogx(bst,chn,'kd','markersize',2)
        set(gca,'xlim',[Parameter.N  max(bst)])
        set(gca,'ylim',[0 130])
        ax1 = axis;
        xlabel 'Network burst size [spikes]'
        ylabel 'Channels with action potentials'
        title([Info.Exptitle])
        if SAVE
            axis square
            figure_size(8,8)
            figure_fontsize(8,'bold')
            filename = ['/home/bakkumd/Desktop/' Info.Exptitle '-BurstSizeVsNumChan'];
            print('-dpdf','-r250',filename)
        end
        
      
% %% Scatterplot of Burst Size vs Burst Width
figure(fig+3); clf
loglog(bst,(Burst.T_end-Burst.T_start)*1000,'kd','markersize',2)
        %set(gca,'ylim',10.^[1 3])
        %set(gca,'xlim',[8 5000])
        ax2 = axis;
        xlabel 'Network burst size [spikes]'
        ylabel 'Network burst width [ms]'
        title([Info.Exptitle])
        if SAVE
            axis square
            figure_size(8,8)
            figure_fontsize(8,'bold')
            filename = ['/home/bakkumd/Desktop/' Info.Exptitle '-BurstSizeVsBurstWidth'];
            print('-dpdf','-r250',filename)
        end
        
   
% %% Histogram of Burst Width
figure(fig+2); clf
dt = Burst.T_end(1:length(chn))-Burst.T_start(1:length(chn));
%hist(log10(dt*1000),30*2);
hist(log10(dt(Burst.S>0)*1000),30*2);
        clr = [1 1 1]*0;
        h = findobj(gca,'Type','patch');
        set(h,'FaceColor',clr,'EdgeColor',clr)
        set(gca,'xlim',log10(ax2([3 4])))
        title 'Burst Width'
        xlabel 'Log scale'
        if SAVE
            title ''
            axis square
            figure_size(8,8)
            figure_fontsize(8,'bold')
            axis off
            filename = ['/home/bakkumd/Desktop/' Info.Exptitle '-BurstSizeVsWidth_WidthHist'];
            print('-dpdf','-r250',filename)
        end
   
% %% Histogram of Burst Size
figure(fig+1); clf
cutoff_bs = 0;  % for finding firing rate of large bursts only             
steps     = [1:.075:log10(ax1(2))+.1]; 
[n ix]    = histc(log10(Burst.S(Burst.S>0)), steps);
            bar(steps,n,'barwidth',1)
            
            
        clr = [1 1 1]*0;
        h = findobj(gca,'Type','patch');
        set(h,'FaceColor',clr,'EdgeColor',clr)
        set(gca,'xlim',[.95 log10(ax1(2))])
        title 'Burst Size'
        xlabel 'Log scale'
        if SAVE
            title ''
            axis square
            figure_size(8,8)
            figure_fontsize(8,'bold')
            axis off
            filename = ['/home/bakkumd/Desktop/' Info.Exptitle '-BurstSizeVsNumChan_BurstSizeHist'];
            print('-dpdf','-r250',filename)
        else
            hold on
            sm = smooth(n);
            plot(steps,sm)
            [xx ii] = min(sm(3:end-2)); % avoid edges
            cutoff_bs = steps(ii+3-1);
            if strcmp(Info.Exptitle,'110518-N') || strcmp(Info.Exptitle,'121227-F') 
                [xx ii] = min(sm(20:end-2)); 
                cutoff_bs = steps(ii+20-1);
            end
            line([0 0]+cutoff_bs,[0 50])
        end


% %% Historgram of Num Channels in a burst
figure(fig+0); clf
cutoff_nc = 0;  % for finding firing rate of large bursts only        
steps     = [0:4:125]; 
[n ix]    = histc(chn(Burst.S>0), steps);
            bar(steps,n,'barwidth',1)
            
        h = findobj(gca,'Type','patch');
        set(h,'FaceColor',clr,'EdgeColor',clr)
        set(gca,'xlim',ax1([3 4]))
        title 'Number Channels'
        if SAVE
            title ''
            axis square
            figure_size(8,8)
            figure_fontsize(8,'bold')
            axis off
            filename = ['/home/bakkumd/Desktop/' Info.Exptitle '-BurstSizeVsNumChan_NumChanHist'];
            print('-dpdf','-r250',filename)
        else
            hold on
            sm = smooth(n);
            plot(steps,sm)
            [xx ii] = min(sm(3:end-12)); % avoid edges
            cutoff_nc = steps(ii+3-1);
            if strcmp(Info.Exptitle,'110518-N') || strcmp(Info.Exptitle,'121227-F') 
                [xx ii] = min(sm(20:end-2)); 
                cutoff_nc = steps(ii+20-1);
            end
            line([0 0]+cutoff_nc,[0 50])
        end

if strcmp(Info.Exptitle,'121227-F')
    cutoff_bs =       2.8;
    cutoff_nc =        95;
    disp '\n***\tHardcoded cutoffs!\t***'
elseif strcmp(Info.Exptitle,'130104-A')
    cutoff_bs = log10(50);
    cutoff_nc =        24;
    disp '\n***\tHardcoded cutoffs!\t***'
elseif strcmp(Info.Exptitle,'130520-A')
    cutoff_bs = log10(490);
    cutoff_nc =         77;
    disp '\n***\tHardcoded cutoffs!\t***'
elseif strcmp(Info.Exptitle,'130520-B')
    cutoff_bs = log10(1000);
    cutoff_nc =         90;
    disp '\n***\tHardcoded cutoffs!\t***'
end
figure(fig+0); line([0 0]+cutoff_nc,[0 50],'color','r')
figure(fig+1); line([0 0]+cutoff_bs,[0 50],'color','r')
drawnow
        
% %% Other parameters
fprintf(['\nExperiment\t\t' Info.Exptitle '\n']);
fprintf('ISIn threshold\t\t%i [ms]\n', round(Parameter.ISIn*1000) );
fprintf('Excluded tonic chn\t\t%i  (%.1f%%)\n', length(tonic), 100*length(tonic)/(length(unique(Spike.C(Parameter.GoodSpikes)))+length(tonic)) );

% Burst rate
% fprintf('Burst rate (all)\t%.2f [Hz]\n', length(Burst.S)/diff(Burst.T_start([2 end])) );
if ~SAVE  
    figure(fig+4); hold on
        line([0 0]+10^cutoff_bs,[ax1([3 4])])
        line([ax1([1 2])],[0 0]+cutoff_nc)
%         fprintf('Burst rate (large) \t%.2f [Hz] \n', length(find(Burst.C>cutoff_nc & Burst.S>10^cutoff_bs))/diff(Burst.T_start([2 end])) )
%         fprintf('Cutoffs: \t\t%i electrodes,  %i spikes \t(excludes tonic)\n', round(cutoff_nc), round(10^cutoff_bs) ); 
%         fprintf('Cutoffs [%% of max]: \t%.2f%% electrodes,  %.2f%% spikes\t(excludes tonic)\n', cutoff_nc/max(Burst.C), 10^cutoff_bs/max(Burst.S) ); 
%         fprintf('Medians (all): \t%.2f electrodes,  %.2f spikes\t(excludes tonic)\n', median(Burst.C), median(Burst.S) ); 
%         fprintf('Largest burst: \t\t%i electrodes \t(excludes tonic)\n', max(Burst.C));
%         fprintf('               \t\t%i spikes \t(excludes tonic)\n',     max(Burst.S));
%         fprintf('               \t\t%.2f [sec]  \t(excludes tonic)\n',   max(Burst.T_end-Burst.T_start));        
%         fprintf('95 percentile: \t\t%.2f%% electrodes \t(excludes tonic)\n', prctile(Burst.C,95)/max(Burst.C));
%         fprintf('               \t\t%i spikes \t(excludes tonic)\n',     round( prctile(Burst.S,95) ) );
%         fprintf('               \t\t%.2f [sec]  \t(excludes tonic)\n',   prctile(Burst.T_end-Burst.T_start,95));
        drawnow
end


% % Overall FR
% fprintf('Network FR \t\t%.2f [Hz] \t(excludes tonic)\n',length(Parameter.GoodSpikes)/diff(Spike.T(Parameter.GoodSpikes([2 end]))) );

% Get amounts of small bursts 
% fprintf('Spikes in small bursts\t%.2f%%\n', sum(Burst.S(Burst.S<10^cutoff_bs))/length(Sort.T)*100)

% Number bursts
% fprintf('Number bursts \t\t%i\n',length(Burst.S))
fprintf('Samll bursts  \t\t%.2f%%\n',100*length(find(Burst.S<10^cutoff_bs))/length(Burst.S))


% Percent spikes in burst
    Burst.S_all = zeros(size(Burst.S));
    goodspikes_no_tonic = find( Spike.H<-60 & Spike.clid & ~Spike.tonic);
    goodspikes          = find( Spike.H<-60 & Spike.clid );
    for b=1:length(Burst.S)
        Burst.S_all(b) = length(find( Spike.T(goodspikes) >= Burst.T_start(b)  &  Spike.T(goodspikes) <= Burst.T_end(b) ));
        if ~mod(b,100) , fprintf(' %i ',round(b/length(Burst.S)*100)), end
    end    
    fprintf('\nSpikes in bursts \t%.2f [%%] (excludes tonic)\n',           100 * sum(Burst.S)     / length(goodspikes_no_tonic) );
    fprintf('Spikes in bursts \t%.2f [%%] (includes all channels)\n',      100 * sum(Burst.S_all) / length(goodspikes) );
    fprintf('Spikes in small bursts \t%.2f [%%] (includes all channels)\n',100 * sum(Burst.S_all(Burst.S<10^cutoff_bs)) / length(goodspikes) );



%% testing - histograms of ISI per channel
% figure
% tmp = []; tmp4 = [];
% for i=0:125
%     ID = find(spike.C == i);% & spike.H<-80);
%     srt = sort(spike.T(ID));
%     dt  = diff(srt);
%     tmp = [tmp dt];
%     
%     dt4 = srt(4:end)-srt(1:end-3);
%     tmp4= [tmp4 dt4];
% 
% %    if length(ID)<200, continue, end
% 
%     [n x]=hist(log10(dt*1000),50);
%     plot(x(n~=0),n(n~=0)/sum(n))
%     %[n x]=hist(dt(dt<.1 & dt>0),100);
%     %[n x]=hist(dt4(dt4<.2),1000);
%     %plot(x,n/sum(n))
%     hold on
%     pause
% end
% xlabel 'ISI [s]'
% ylabel 'count [%]'
% title([Info.Exptitle])



%% Power law -  probability vs size
figure

% Use increasing bin size such that uniform step sizes on a loglog plot
factor =  10;    % will make uniform
steps  = [1:.03:(10000^(1/factor))].^factor;

mrk    = '.';
mrksz  =  12;
width  =   2;

%[n x]=hist(burst.S(burst.S>1100),steps);
[n x]=hist(Burst.S,steps);
%loglog(steps,n/sum(n),'-','color','k','linewidth',width); hold on
loglog(steps,n/sum(n),mrk,'color','k','markersize',mrksz)


xlabel 'Network burst size [spikes]'
ylabel 'Probability [%]'
title([Info.Exptitle])



%%

bin =  0.100;
step = 0.030;

tt = [1:step:100]+Spike.T(1);   % [sec]
frh.nchn = zeros(1,length(tt));
frh.fr   = zeros(1,length(tt));
frh.gap  = zeros(1,length(tt)) + bin;
frh.nspk = zeros(1,length(tt));
cnt = 0;
for i=tt
    cnt = cnt+1;
        
    Ts              = i;
    Te              = i+bin; 
    ID              = find(Spike.T>=Ts & Spike.T<=Te) ;
    if ~isempty(ID)
        frh.nchn(cnt)   = length(unique(Spike.C(ID)));
        frh.nspk(cnt)   = length(ID);
        frh.fr(cnt)     = length(ID)/bin;
        if length(ID)>1
            frh.gap(cnt)    = max([diff(Spike.T(ID)) .001]);
        end
    end
    
    if ~mod(cnt,500)
        fprintf('%i\n',length(tt)-cnt)
    end
        
end





%% %%
%% Manual sorting via spike height (NaN -> dropped channel)
if  strcmp(Info.Exptitle,'120829-A' )
    thresh = [NaN -110 -150 -200 -150 NaN NaN NaN -200 NaN NaN -300 -150 -550 -600 NaN -350 -250 NaN -500 -500 -200 NaN ...
            -150 -100 -220 NaN NaN NaN NaN NaN NaN NaN NaN NaN -90 NaN -400 NaN -80 NaN NaN -300 -200 -100 -150 -150 ...
            -230 NaN NaN -300 -100 NaN NaN NaN -100 NaN NaN NaN NaN -250 NaN -200 NaN -350 NaN NaN -80 -200 NaN -80  ...
            NaN -350 NaN -250 NaN -130 NaN -180 -350 NaN NaN -310 -100 -370 NaN -250 -300 -830 NaN -150 NaN NaN NaN ...
            -380 -150 -200 -150 NaN -200 -310 -150 NaN -200 NaN -100 -250 NaN NaN -100 NaN -300 NaN NaN NaN NaN NaN ...
            -300 NaN NaN NaN NaN -150 NaN NaN -170];
        
elseif  strcmp(Info.Exptitle,'120830-B' )
    thresh = [   -50 -100 -300  NaN -200      NaN -350  NaN -200 -400 ...
                 NaN -300 -200  NaN  NaN      NaN -200  NaN -200  NaN ...
                -250  NaN -450 -400 -400     -350  NaN  NaN -200 -300 ...
                -400  -80  NaN  NaN -400     -300  NaN  NaN -200  NaN ...
                 NaN  NaN  NaN -400  NaN     -400 -150 -150  NaN  NaN ...
                 NaN  NaN  NaN -600 -200      NaN  NaN  NaN  NaN  NaN  ...
                -500  NaN  NaN -200 -300      NaN -500 -350  NaN -100 ...
                -100 -400 -150 -400  NaN     -400  NaN  NaN -100 -300 ...
                -300 -300 -300  NaN  NaN     -500 -100 -550 -300 -500 ...
                -200  NaN -300 -200 -300     -150 -200 -200 -100 -300 ...
                 NaN -400  NaN -100 -500     -200  NaN -250  NaN  -80 ...
                 NaN -300 -250 -120 -300     -500  NaN  NaN  NaN  NaN  ...
                -150  NaN -350 -100  -80      -80 ];
            
elseif  strcmp(Info.Exptitle,'110518-N' )
    thresh = [  -200  -80  NaN  NaN  -70    NaN  NaN  NaN -200 -150 ...
                 -65  NaN  NaN  NaN  NaN    NaN -150  NaN  NaN -200 ...
                 NaN -200 -170  NaN -200    NaN -150 -200  NaN  NaN ...
                 NaN  NaN  NaN  -80 -150    NaN -200  NaN  NaN  NaN ...
                 NaN  NaN  NaN  NaN  NaN    NaN  NaN  -60  NaN  NaN ...
                 NaN  NaN  NaN  NaN  NaN   -150  NaN -600  NaN -150 ...
                 -60  NaN  NaN  NaN  NaN    -70  NaN  NaN  -90  NaN ...
                 NaN  NaN  NaN  NaN  NaN    NaN  -70  NaN  NaN  NaN ...
                -280  NaN  -80  NaN  NaN   -100  NaN  NaN  NaN  NaN ...
                 NaN -100  -80  -80 -100    NaN -200  NaN  NaN  NaN ...
                 NaN -100 -150  -60  NaN   -140  NaN -500  NaN  NaN ...
                 NaN -200 -150  NaN  NaN   -200  NaN  -80  NaN -110 ...
                 NaN  NaN  NaN  NaN  NaN    NaN ];

            
else
    thresh = zeros(1,126);
end




% %% Plot waveforms during a time period for all channels
% 
% 
% T1 = 796.9;  T2 = 797.1;
% %T1 = 779.6;  T2 = 780.2;
% 
% figure 
% set(gca,'color',[1 1 1]*.5)
% hold on
% rng(123456789)
% for ch=0:125
%     yoff = ch*800;
%     clr=[rand rand rand]/2;
%     ID   = find( spike.clid==1  &  spike.H<=thresh(ch+1)  &  spike.T>T1 & spike.T<T2 & spike.C==ch);
%     if ~isempty(ID)
%         [waveform waveform_vector waveform_vector_times]=plotSpikeShape(Info,ID,spike.T(ID),'figure',0);
%         plot(waveform_vector_times,waveform_vector-yoff,'color',clr)
%     end
%     title(ch)
%     pause(.1)
% end



%% %% %% %%
%% Plot raster for a channel across bursts (use for manual spike sorting by spike threshold)
%  Get 'sig' structure filled

PLOT        =   0;  % Plot waveforms of spikes for each burst
min_length  =   0;%100;  % Consider bursts above this threshold



[tmp tt] = sort(Burst.S);
tt  = tt(Burst.C(tt)>0 & Burst.S(tt)> min_length );

%  tt = tt( burst.T_end(tt) < spike.T(end) );
%  tt = tt(1:20:end);
 
for f=[104]
    figure(f); cla, clf
end

networkBS_end  = []; networkBS_st   = [];
chanBS_end     = []; chanBS_st      = [];
diffH_end      = []; diffH_st       = [];
big_end = [];
clear sig 

if      strcmp(Info.Exptitle,'120829-A' )
    big_only_ch = [2 3 11 17 19 20 21 24 42 43 45 46 47 50   55 60 64 67 68 74 76 78 79 83 90 96 99 100 105 106 109];
    % dual      = [4 12 13 14 24 37 44 60 62 70 74 82 88 94 95 97 103 106 122];
elseif  strcmp(Info.Exptitle,'120830-B' )
    big_only_ch = [ 4 6 12 16 18 23 25 29 35 47 54 60 63 64 67 69 70 71 72 73 75 78 79 87 88 89 92 93 94 95 104 105 111 112 113 120 122 123 124 125 ];
else
    big_only_ch = [];
end
big_only_el = []; % get el positions to plot on Info.Map --> distributed across array
big_all     = [];
for i=0:125
    if find(i==big_only_ch)
        big_only_el = [big_only_el Info.Map.el(find(i==Info.Map.ch,1))];
    else
        big_all     = [big_all i];
    end
end


CHN = [big_all big_only_ch];   % Channels to plot


for ch = CHN

    
    if isnan(thresh(ch+1))
        disp Isnan
        sig{ch+1} = [];
        continue;
    else
        ht = thresh(ch+1);
    end

    if PLOT
        f=figure(103); clf
        hold on
        % figure(888); hold off
        % ff=figure(999); hold off
    end


    sig{ch+1}.spike.T    = [];
    sig{ch+1}.spike.H    = [];
    sig{ch+1}.spike.N    = []; % burst number
    sig{ch+1}.no_burstID = [];
    
    cnt=0;
    cnt_off=0;
    ID_0 = find(  Spike.H<=ht  & Spike.C==ch);
 

%%% [b id]=sort(sig{ch+1}.size);             id=sig{ch+1}.burstID(id); PLOT=1; tt =  id;%(end-14:end); % Order by num ch spikes
%%% [b id]=sort(burst.S(sig{ch+1}.burstID)); id=sig{ch+1}.burstID(id); PLOT=1; tt =  id;%(end-14:end); % Order by num ALL ch spikes

for t=tt
    %if burst.T_end(t)>spike.T(end), break, end
    if Burst.T_end(t)>Spike.T(end), continue, end
    
    cnt_off = cnt_off+1;
    yoff    = cnt_off * min(Spike.H(ID_0))*-1;
    %yoff    = cnt_off*800;
    %yoff    = cnt_off*130+ch;
    %yoff    = burst.S(t)*10;
    xoff    = Burst.C(t);
    
    ID    = ID_0(  Spike.T(ID_0)>=Burst.T_start(t) & Spike.T(ID_0)<=Burst.T_end(t)  );
    if ~isempty(ID)
        cnt              = cnt + 1;
        sig{ch+1}.size(cnt)    = length(ID);                  % num spikes in burst
        sig{ch+1}.first(cnt)   = min(Spike.T(ID))-xoff;       % time of first spike wrt burst center [sec]
        sig{ch+1}.t_med(cnt)   = median(Spike.T(ID)-xoff); 
        %sig{ch+1}.t_len(cnt)   = burst.T_end(t)-burst.T_start(t);  
        sig{ch+1}.t_len(cnt)   = diff(Spike.T(ID([1 end])));
        sig{ch+1}.burstID(cnt) = t;
        if length(ID) > 1
            sig{ch+1}.dh(cnt)         = max(Spike.H(ID)) - min(Spike.H(ID));
            sig{ch+1}.isi_median(cnt) = median( diff(Spike.T(ID)) );
        else
            sig{ch+1}.dh(cnt)         = NaN;
            sig{ch+1}.isi_median(cnt) = NaN;
        end
        
        sig{ch+1}.spike.T = [sig{ch+1}.spike.T Spike.T(ID)];
        sig{ch+1}.spike.H = [sig{ch+1}.spike.H Spike.H(ID)];
        sig{ch+1}.spike.N = [sig{ch+1}.spike.N ones(1,length(ID))*t];
        
        if PLOT
            figure(f)
            
            rng(ch)
            clr = [rand rand rand]/2;
            %clr = 'k';
            [waveform waveform_vector waveform_vector_times]=plotSpikeShape(Info,ID,Spike.T(ID),'figure',0);
            plot(waveform_vector_times-xoff,waveform_vector-yoff,'color',clr)

            %line([.0455                   1*.05] - .2, [0 0]-yoff,'color','k','linewidth',2)
            line([0 Burst.S(t)/max(Burst.S)*.05] - .2, [0 0]-yoff,'color','k','linewidth',2)
            text(-.3,-yoff,int2str(t))
            
%             plot(spike.T(ID)-xoff, ones(size(ID))-yoff,'.','color',clr)
%             hold on
%             set(gca,'color',[1 1 1]*.5)
%             xlabel 'time [sec]'
    
            title([Info.Exptitle ' ch' int2str(ch)])
            grid on
            pause(.1)
                        
        end
        
    else
        sig{ch+1}.no_burstID = [sig{ch+1}.no_burstID t];
    end
end

if cnt==0
    disp 'No sig data'
    beep
    continue
    %return
else
    disp 'Have data'
    if PLOT
        %axis([-.21 .2 -220000 -60000])
        set(gcf,'Position',[1681 29 560 840])
    end
end

% %%


x = sig{ch+1}.size + rand(size(sig{ch+1}.size));
y = Burst.S(sig{ch+1}.burstID);

chanBurstSize       = 1:max(sig{ch+1}.size); % chan burst size (number)
networkBurstSize    = zeros(size(chanBurstSize)); % mean net burst size (number)
networkBS_std       = zeros(size(chanBurstSize)); %
networkBS_sem       = zeros(size(chanBurstSize)); %
% diffHeight          = zeros(size(chanBurstSize)); % difference in spike height
% burstLength         = zeros(size(chanBurstSize)); % burst length
% firstSpike          = zeros(size(chanBurstSize)); % first spike time
% isi                 = zeros(size(chanBurstSize)); % median isi - estimate of FR in a burst
c = 0;
for i=chanBurstSize
    c = c+1;
    xx = find( sig{ch+1}.size==i );
    if length(xx)>2
        networkBurstSize(c) = median(y(xx));
        networkBS_std(c)    = std(y(xx));
        networkBS_sem(c)    = std(y(xx))/(length(xx)^.5);
%         diffHeight(c)       = median(sig{ch+1}.dh(xx));
%         isi(c)              = median(sig{ch+1}.isi_median(xx));
%         burstLength(c)      = median(sig{ch+1}.t_len(xx));
%         firstSpike(c)       = median(sig{ch+1}.first(xx));
    end
end
xx                  = find(networkBurstSize);
if ~isempty(xx)
    networkBurstSize    = smooth(networkBurstSize(xx))'; networkBS_end = [networkBS_end networkBurstSize(end)];  networkBS_st = [networkBS_st networkBurstSize(1)]; 
    networkBS_std       = smooth(networkBS_std(xx))';
    networkBS_sem       = networkBS_sem(xx);
    chanBurstSize       = chanBurstSize(xx);             chanBS_end = [chanBS_end chanBurstSize(end)];  chanBS_st = [chanBS_st chanBurstSize(1)]; 
%     isi                 = isi(xx);   
%     burstLength         = burstLength(xx);
%     firstSpike          = firstSpike(xx);
%     diffHeight          = smooth(diffHeight(xx));        diffH_end = [diffH_end diffHeight(end)];  diffH_st = [diffH_st diffHeight(2)];   
end
clr                 = [rand rand rand]/1.2;

% figure(100); hold on
% plot(x,y,'o','color',clr,'markersize',4); hold on
% plot( 0 , burst.S(sig{ch+1}.no_burstID),'.','color',clr,'markersize',5)
% %scatter(sig{ch+1}.size,burst.S(sig{ch+1}.burstID),30,sig{ch+1}.first); colorbar
% set(gca,'color',[1 1 1]*.5)
% set(gca,'xscale','log')
% set(gca,'yscale','log')
% set(gca,'xlim',[0 50])
% xlabel 'size channel burst'
% ylabel 'size network burst'
% title([Info.Exptitle ' ch' int2str(ch)])
% caxis([-1 1]*.15)

% figure(99)
% plot(sig{ch+1}.first,sig{ch+1}.size,'.')
% %plot(sig{ch+1}.t_med,sig{ch+1}.size,'.')
% xlabel 'time of first spike'
% ylabel 'size channel burst'
% title([Info.Exptitle ' ch' int2str(ch)])
% grid on



% check ISI violations and heights
figure(101)
ID    = find( Spike.clid==1  &  Spike.H<=ht & Spike.C==ch);
hist(Spike.H(ID),100)
set(gca,'ylim',[0 300])
xlabel 'spike height'

figure(102)
dt=diff(Spike.T(ID));
yy=find(dt<=.02);
hist(dt(yy),20)
set(gca,'xlim',[0 .02])
xlabel ISI




if find(ch==big_only_ch)
    clr = 'r';
    big_end = [big_end 1];
else
    clr = 'k';
    big_end = [big_end 0];
end

        
    % figure(98); hold on
    % xstd = std(sig{ch+1}.first(xx));
    % xsem = xstd/length(xx)^.5;
    % %plot(sig{ch+1}.size,sig{ch+1}.dh,'.')
    % plot(burst.S(sig{ch+1}.burstID),sig{ch+1}.dh,'o','color',clr,'markersize',2)
    % %plot(chanBurstSize,diffHeight,'-','color',clr); hold on; xlabel 'size channel burst'
    % %plot(nw,dh,'-','color',clr); hold on; xlabel 'size network burst'
    % ylabel 'diff(spike height) norm by dh(1)'
    % mrksz = 8;
    % plot(2*ones(size(diffH_st)),  (diffH_st),'k.','markersize',mrksz); 
    % plot(2*ones(size(find(big_end))),(diffH_st(find(big_end))),'r.','markersize',mrksz)
    % plot((chanBS_end),(diffH_end),'k.','markersize',mrksz); plot((chanBS_end(find(big_end))),(diffH_end(find(big_end))),'r.','markersize',mrksz)
    % set(gca,'xlim',[.9 10^2])
    

% %%
figure(104)
hold on
%patch(log10([chanBurstSize fliplr(chanBurstSize)]),log10([nw+nw_sem fliplr(nw-nw_sem)]),clr,'facealpha',.2,'edgecolor','none')
%plot(log10(chanBurstSize),log10(nw),'-','color',clr,'linewidth',1)
plot(chanBurstSize,networkBurstSize,'-','color',clr,'linewidth',.5)
% set(gca,'color',[1 1 1]*.5)
xlabel 'size channel burst'
ylabel 'size network burst'
title([Info.Exptitle ' ch' int2str(ch)])
grid on
set(gca,'xscale','log','yscale','log')



    % % %%
    % figure(105)
    % hold on
    % plot(chanBurstSize,1./smooth(isi),'-','color',clr); xlabel 'size channel burst'
    % %plot(nw,1./smooth(isi),'-','color',clr); xlabel 'size network burst'
    % set(gca,'color',[1 1 1]*.5)
    % ylabel 'instantaneous firing rate'
    % % ylabel 'median isi in burst'
    % title([Info.Exptitle ' ch' int2str(ch)])
    % grid on


    % figure(106)
    % hold on
    % plot(chanBurstSize,burstLength,'-','color',clr); xlabel 'size channel burst'
    % %plot(nw,tl,'-','color',clr); xlabel 'size network burst'
    % set(gca,'color',[1 1 1]*.5)
    % ylabel 'burst length'
    % title([Info.Exptitle ' ch' int2str(ch)])
    % grid on

% %scatter(1./isi,dh,30,chanBurstSize,'filled')
% scatter(chanBurstSize,1./isi,30,dh,'filled')
% set(gca,'color',[1 1 1]*.5)
% xlabel 'size channel burst'
% ylabel 'instantaneous firing rate'
% %ylabel 'diff(spike height)'
% title([Info.Exptitle ' ch' int2str(ch)])
% grid on



% big_only = [2 3 11 17 19 20 42 43 45 46 47 50 51 55 64 67 68 78 76 79 83 90 96 100 105 109 111];
% vert     = [];%21 24 74 99 103    4 12 13 14 37 44 60 62 70 82 88 94 95 97 106 122];
% big_only_el = []; % get el positions to plot on Info.Map --> distributed across array
% for i=big_only
%     big_only_el = [big_only_el Info.Map.el(find(i==Info.Map.ch))];
% end
% 
% x = log10( x_ + rand(size(sig{ch+1}.size))/1.5 );
% y = log10( burst.S(sig{ch+1}.burstID) );
% 
% % c = min([ max(sig{ch+1}.size)/40 1]);
% % clr = [0 1-c c];
% if 0 %find(ch==big_only)
%     figure(104); 
%     hold on
% elseif 0 %find(ch==vert)
%     figure(105); 
%     hold on
% else
%     figure(106); 
%     hold on
% end
% 
% if 0 %find(ch==[72 45])
%     clr = 'k';
%     % hold on
%     plot(x,y,'r.','MarkerSize',5)
% else
%     clr = 'none';
% end

% [bandwidth,density,X,Y] = kde2d([x;y]',2^4,log10([1 10]),log10([130 10000]));
% [C, h] = contourf(X,Y,density,4, 'edgecolor', clr);
% % ll = get(h,'levellist');
% ll = .25;%ll(1)
% set( h,'levelList', ll )     % set contour level
% h_ch = get(h,'child');
% 
% for j=1:length(h_ch)
%     if strcmp(get(h_ch(j), 'Type'), 'patch')
%         Iso = get(h_ch(j), 'CData');
%         if Iso<ll
%             set(h_ch(j), 'FaceColor', [1 1 1]);
%         else
%             set(h_ch(j), 'FaceColor', [0 0 0]);
%         end
%     end
% end
% alpha( h_ch, 0.05)  % set transparency

% hold on
% plot(x,y,'r.','MarkerSize',5)


title([Info.Exptitle ' ch' int2str(ch)])

pause(.1); drawnow

% plot(x,y,'.','MarkerSize',5,'color',[1 1 1]*.5)

end


        
        
%%  FIGURE  %%
figure(104)
mrksz = 8;
plot((chanBS_st),  (networkBS_st),'k.','markersize',mrksz); plot((chanBS_st(find(big_end))),(networkBS_st(find(big_end))),'r.','markersize',mrksz)
plot((chanBS_end),(networkBS_end),'k.','markersize',mrksz); plot((chanBS_end(find(big_end))),(networkBS_end(find(big_end))),'r.','markersize',mrksz)
% plot(log10(sz_end),log10(nw_end),'k.','markersize',20)
% plot(log10(sz_end(find(big_end))),log10(nw_end(find(big_end))),'r.','markersize',20)

set(gca,'xlim',[.9 10^2])
xlabel 'Neuron burst size [spikes]'
ylabel 'Average network burst size [spikes]'
figure_size(8,8)
    if 0
        grid off
        box on
        figure_fontsize(8,'bold')
        title ''
        filename = ['/home/bakkumd/Desktop/' Info.Exptitle '-NetworkVsNeuronBurstSize'];
        print('-dpdf','-r250',filename)        
    end
    
    
    

%%  FIGURES  %%
%   Using sig{} structure collected above, make plots
%

SAVE  = 0; % Print figures
mrksz = 8; % Plot marker size


for f=[96 97 197 98 105]
    figure(f); cla, clf
end

cnt = 0;
for ch = [big_all big_only_ch]
    
    if isempty(sig{ch+1}), continue, end
    if find(ch==big_only_ch),   clr = 'r';    big_end = [big_end 1];
    else                        clr = 'k';    big_end = [big_end 0];   
    end
    cnt = cnt+1;

    xx       = find(Burst.S(sig{ch+1}.burstID) > 1200);
    first    = mean(sig{ch+1}.first(xx))*1000;
    firststd = std(sig{ch+1}.first(xx))*1000;
    firstsem = firststd/length(xx)^.5;

    xx1   = find(Burst.S(sig{ch+1}.burstID) <  1200);
    xx2   = find(Burst.S(sig{ch+1}.burstID) >= 1200  &  Burst.S(sig{ch+1}.burstID) <= 4000);
    xx3   = find(Burst.S(sig{ch+1}.burstID) >  4000);
    
    
    cnt1    = mean(sig{ch+1}.size(xx1));
    cnt2    = mean(sig{ch+1}.size(xx2));
    cnt3    = mean(sig{ch+1}.size(xx3));
    cnt1sem = std( sig{ch+1}.size(xx1))/length(xx1)^.5;
    cnt2sem = std( sig{ch+1}.size(xx2))/length(xx2)^.5;
    cnt3sem = std( sig{ch+1}.size(xx3))/length(xx3)^.5;
    
    len1    = max([ mean(sig{ch+1}.t_len(xx1) * 1000 )  10 ]); % Set min burst length = 10ms
    len2    = max([ mean(sig{ch+1}.t_len(xx2) * 1000 )  10 ]);
    len3    = max([ mean(sig{ch+1}.t_len(xx3) * 1000 )  10 ]);
    len1sem = std( sig{ch+1}.t_len(xx1) * 1000 )/length(xx1)^.5;
    len2sem = std( sig{ch+1}.t_len(xx2) * 1000 )/length(xx2)^.5;
    len3sem = std( sig{ch+1}.t_len(xx3) * 1000 )/length(xx3)^.5;
    
    % For diff height and isi, need at least 2 spikes in burst. drop NaNs which are set when 1 spike in burst
    xx1   = xx1(~isnan(sig{ch+1}.dh(xx1)));
    xx2   = xx2(~isnan(sig{ch+1}.dh(xx2)));
    xx3   = xx3(~isnan(sig{ch+1}.dh(xx3)));
    
    dh1    = mean(sig{ch+1}.dh(xx1));
    dh2    = mean(sig{ch+1}.dh(xx2));
    dh3    = mean(sig{ch+1}.dh(xx3));
    dh1sem = std(sig{ch+1}.dh(xx1))/length(xx1)^.5;
    dh2sem = std(sig{ch+1}.dh(xx2))/length(xx2)^.5;
    dh3sem = std(sig{ch+1}.dh(xx3))/length(xx3)^.5;

    
    isi1    = mean( sig{ch+1}.isi_median(xx1) * 1000 );
    isi2    = mean( sig{ch+1}.isi_median(xx2) * 1000 );
    isi3    = mean( sig{ch+1}.isi_median(xx3) * 1000 );
    isi1sem = std(  sig{ch+1}.isi_median(xx1) * 1000 )/length(xx1)^.5;
    isi2sem = std(  sig{ch+1}.isi_median(xx2) * 1000 )/length(xx2)^.5;
    isi3sem = std(  sig{ch+1}.isi_median(xx3) * 1000 )/length(xx3)^.5;
%     isi1    = mean( 1 ./ sig{ch+1}.isi_median(xx1));
%     isi2    = mean( 1 ./ sig{ch+1}.isi_median(xx2));
%     isi3    = mean( 1 ./ sig{ch+1}.isi_median(xx3));
%     isi1sem = std(  1 ./ sig{ch+1}.isi_median(xx1))/length(xx1)^.5;
%     isi2sem = std(  1 ./ sig{ch+1}.isi_median(xx2))/length(xx2)^.5;
%     isi3sem = std(  1 ./ sig{ch+1}.isi_median(xx3))/length(xx3)^.5;
    
    rng('default')
    rng(ch*9681)
    off = (rand-.5)/4;
    
     
figure(96); hold on
    if find(ch==big_only_ch), 
        x = [2:3]+off;
        y = [len2 len3];
        e = [len2sem len3sem];
        %y = [cnt2 cnt3];
        %e = [cnt2sem cnt3sem];
    else
        x = [1:3]+off;
        y = [len1 len2 len3];
        e = [len1sem len2sem len3sem];
        %y = [cnt1 cnt2 cnt3];
        %e = [cnt1sem cnt2sem cnt3sem];
    end
    plot(x, y, '-','color',clr);
    errorbar(x, y, zeros(size(e)), e, '.','color',clr,'markersize',mrksz);
    
    
figure(97); hold on
    if find(ch==big_only_ch)
        errorbar(0+off*2,first,firstsem,'.','color',clr,'markersize',mrksz); 
        %text(0+off*2,first,int2str(ch))
    else
        errorbar(1+off*2,first,firstsem,'.','color',clr,'markersize',mrksz); 
        %text(1+off*2,first,int2str(ch))
    end
    hold on

figure(197); hold on; grid on
    plot( first, networkBS_st(cnt),'.','color',clr,'markersize',mrksz)
    text( first, networkBS_st(cnt), int2str(ch))

        
figure(98); hold on
    if find(ch==big_only_ch), 
        plot([2:3]+off, [dh2 dh3], '-','color',clr);
        errorbar([2:3]+off, [dh2 dh3], [0 0], [dh2sem dh3sem], '.','color',clr,'markersize',mrksz);
    else
        plot([1:3]+off, [dh1 dh2 dh3], '-','color',clr);
        errorbar([1:3]+off, [dh1 dh2 dh3], [0 0 0], [dh1sem dh2sem dh3sem], '.','color',clr,'markersize',mrksz);
    end
    %plot(burst.S(sig{ch+1}.burstID),sig{ch+1}.dh,'.')
    
    
figure(105); hold on
    if find(ch==big_only_ch), 
        x = [2:3]+off;
        y = [isi2 isi3];
        e = [isi2sem isi3sem];
    else
        x = [1:3]+off;
        y = [isi1 isi2 isi3];
        e = [isi1sem isi2sem isi3sem];
    end
    plot(x, y, '-','color',clr);
    errorbar(x, y, zeros(size(e)), e, '.','color',clr,'markersize',mrksz);
   
        
end


%% (cont)
figure(96)
    box on
    set(gca,'xlim',[.5 3.5],'xtick',[1:3],'xticklabel',{'<1200','1200 to 4000','>4000'})
    set(gca,'ylim',[9 250],'yscale','log')

    xlabel 'Network burst size [spikes]'
    ylabel 'Neuron burst length [ms]'
    title([Info.Exptitle ' ch' int2str(ch)])
    figure_size(8,8)
        if SAVE
            figure_fontsize(8,'bold')
            title ''
            filename = ['/home/bakkumd/Desktop/' Info.Exptitle '-NeuronBurstLengthInNetBurst'];
            print('-dpdf','-r250',filename)        
        end

        
%% (cont)
figure(97)
    line([-.25  .25],[0 0],'color','k','linewidth',.5)
    line([ .75 1.25],[0 0],'color','k','linewidth',.5)
    set(gca,'xlim',[-.5 1.5],'xtick',[0 1],'xticklabel',[])
    set(gca,'ytick',[-60:20:40])
%     set(gca,'xcolor','w')
%     set(gcf,'color','w')
%     set(gcf,'invertHardcopy','off')
    box off
    ylabel 'First spike time within burst [ms]'
    xlabel 'Burst sizes > 1200 spikes'
    title([Info.Exptitle ' ch' int2str(ch)])
    figure_size(6,8)
        if SAVE
            figure_fontsize(8,'bold')
            title ''
            filename = ['/home/bakkumd/Desktop/' Info.Exptitle '-TimeFirstSpikeInBurst'];
            print('-dpdf','-r250',filename)        
        end

        
figure(197)
    grid on
    box on
    xlabel 'First spike time within burst [ms]'
    ylabel 'Burst size [spikes]'
    set(gca,'yscale','log')
    title([Info.Exptitle])
    figure_size(8,8)


%% (cont)
figure(98)
 set(gca,'xlim',[.5 3.5],'xtick',[1:3],'xticklabel',{'<1200','1200 to 4000','>4000'})
    set(gca,'ylim',[10 1100],'yscale','log')
    xlabel 'Network burst size [spikes]'
    ylabel 'Height difference within burst [uV]'
    title([Info.Exptitle ' ch' int2str(ch)])
    box on
    figure_size(8,8)
        if SAVE
            figure_fontsize(8,'bold')
            title ''
            filename = ['/home/bakkumd/Desktop/' Info.Exptitle '-DiffSpikeHeightVsBurstSize'];
            print('-dpdf','-r250',filename)        
        end

        
%% (cont)
figure(105)
    set(gca,'xlim',[.5 3.5],'xtick',[1:3],'xticklabel',{'<1200','1200 to 4000','>4000'})
    
    set(gca,'ylim',[3 120],'yscale','log')
    %set(gca,'ylim',[10 500],'yscale','log')
    
    xlabel 'Network burst size [spikes]'
    % ylabel 'Instantaneous firing rate'
    ylabel 'Median ISI within burst [ms]'
    title([Info.Exptitle ' ch' int2str(ch)])

    box on
    figure_size(8,8)
        if SAVE
            figure_fontsize(8,'bold')
            title ''
            filename = ['/home/bakkumd/Desktop/' Info.Exptitle '-InstantaneousFRVsBurstSize'];
            print('-dpdf','-r250',filename)        
        end
        
        
        
    
    
    
    
%%

for f = [1:27 29:63]
    figure(f)
    pause%(2)
end
%%





%% %% %% %%
   

%%   FIGURE   %%
%    Raster plots for a set of sorted neurons across bursts (use for manual spike sorting by spike threshold).
%    Example traces for a couple of these plots.

SAVE = 0;

if      strcmp(Info.Exptitle,'120829-A' )
    chns = [19 111 84 95 125]; % Channels with sorted neurons for plots.
% elseif  strcmp(Info.Exptitle,'120830-B' )
%     chns = [8 11 34]; % Channels with sorted neurons for plots.
% end
else 
    disp 'WRONG EXPT'
    beep
    return
end

map    = colormap(lines);
ch_clr = map(1:5,:)/1.5;   % Color code for channels
xlim   = [-250 300];       % X axis limits
min_length = 100;          % Min size of bursts to consider

% %% Select burst.S indices 
    [tmp tt] = sort(Burst.S);
    tt  = tt(Burst.C(tt)>0 & Burst.S(tt)>min_length );
    tt  = tt([1:65 67:end]); % drop a mis-assigned burst
    % Use increasing bin size in log10 for uniform distribution of burst sizes for plotting
    factor =  4;    % will make uniform
    steps  = [100^(1/factor):.1:max(Burst.S)^(1/factor)].^factor;
    clear tt_
    for i = 1:length(steps)
    [a id] = min(abs(Burst.S(tt)-steps(i))); 
    tt_(i) = id;
    end
    tt = tt(tt_);
    tt = unique(tt,'stable');


% %%   Plot distribution of burst sizes for the selected bursts (testing/verification)
figure
hold on
yoff = 0;
for t=fliplr(tt)
    %if burst.T_end(t)>spike.T(end), continue, end
    yoff    = yoff+1;
    x       = Burst.S(t)/max(Burst.S)*50;
    if x<1, x=1; end % needed to avoid artifact during printing
    %line([0                         50] - 150, [0 0]+yoff,'color',[1 1 1]*.5,'linewidth',2)
    line([0 x] - 150, [0 0]+yoff,'color','k','linewidth',4)
end
    line([-100 -100],[1 yoff],'color','k')
    axis([xlim -2 length(tt)+2])
    figure_size(8,8)
    if SAVE
        axis off
        filename = ['/home/bakkumd/Desktop/' Info.Exptitle '-BurstSizes_Scale'];
        print('-dpdf','-r250',filename)        
    end

    
% %%   Plot example raster plots
ch_cnt = 0;
for ch = chns
    ch_cnt  = ch_cnt+1;
    ht      = thresh(ch+1);
    cnt_off = 0;
    ID_0    = find( Spike.clid==1  &  Spike.H<=ht  & Spike.C==ch);
    f       = figure;%(103);
    hold on
    line([0 0],[1 length(tt)],'color',[1 1 1]*0,'linewidth',1)
    for t = tt
        %if burst.T_end(t)>spike.T(end), continue, end

        cnt_off = cnt_off+1;
        yoff    = length(tt) - cnt_off;
        xoff    = Burst.C(t);
        

        ID    = ID_0(  Spike.T(ID_0)>=Burst.T_start(t) & Spike.T(ID_0)<=Burst.T_end(t)  );
        if ~isempty(ID)       
            figure(f)
            clr = ch_clr(ch_cnt,:);            
            plot( (Spike.T(ID)-xoff)*1000, ones(size(ID))+yoff,'d','color',clr,'markersize',2)
            %plot(spike.T(ID)-xoff, ones(size(ID))+yoff,'kd','markersize',3,'markerfacecolor',clr)
            hold on
            title([Info.Exptitle ' ch' int2str(ch)])
            pause(.1)
            
        end
    end
    set(gcf,'Position',[1681 29 560 540])
    axis([xlim -2 length(tt)+2])
    set(gca,'ytick',[1:10:length(tt)+5],'yticklabel',[Burst.S(tt(end:-10:1))])
    xlabel 'Time [ms]'
    ylabel 'Network burst size'
    figure_size(8,8)
    if SAVE
        title ''
        axis off
        figure_fontsize(8,'bold')
        filename = ['/home/bakkumd/Desktop/' Info.Exptitle '-BurstSizes_Ch' int2str(ch)];
        print('-dpdf','-r250',filename)        
        if ch == chns(1) 
            set(gca,'xtick',[-100:50:250])     % plot axes only
            axis on
            cla
            line([0 100]+150,[0 0]+length(tt)/2,'color','k','linewidth',2)
            filename = ['/home/bakkumd/Desktop/' Info.Exptitle '-BurstSizes_Axes'];
            print('-dpdf','-r250',filename)        
        end
        
    end
    
end


% %%  Plot example traces from a couple bursts    
cnt_f = 0;
for t = tt([end 27])
    cnt_f   = cnt_f+1;
    cnt_off = 0;
    yoff    = 0;
    f       = figure;%(103);
    hold on
    for ch = chns
        ht      = thresh(ch+1);
        cnt_off = cnt_off+1;
        %yoff    = yoff-1500;
        xoff    = Burst.C(t);
        
        ID_0    = find( Spike.H<=ht  & Spike.C==ch);
        ID      = ID_0(  Spike.T(ID_0)>=Burst.T_start(t) & Spike.T(ID_0)<=Burst.T_end(t)  );
        if isempty(ID), continue, end
        clr = ch_clr(cnt_off,:);
        [waveform waveform_vector waveform_vector_times]=plotSpikeShape(Info,ID,Spike.T(ID),'figure',0);
        yoff    = yoff + min(waveform_vector) - 200;
        plot( (waveform_vector_times-xoff)*1000 , waveform_vector-yoff,'color',clr)
        yoff    = yoff - max(waveform_vector);
    end    
    title([Info.Exptitle '  ' int2str(t) '  burst size ' int2str(Burst.S(t))])
    xlabel 'Time [ms]'
    ylabel 'Neuron'
    axis([xlim -150 8000])
    line([0   0],    [0 8000],     'color','k','linewidth',1) 
    if cnt_f == 1
        line([0   0]+150,[0 1000]+1000,'color','k','linewidth',2)
        line([0 100]+150,[0    0]+1000,'color','k','linewidth',2)
    end
    if SAVE
        title ''
        %set(gca,'ytick',[])
        axis off
        figure_size(8,4)
        figure_fontsize(8,'bold')
        filename = ['/home/bakkumd/Desktop/' Info.Exptitle '-BurstSizes_Ex' int2str(t)];
        print('-dpdf','-r250',filename)        
    end    
end







%%
%%
%% 
%%  TRY CAT  %%


min_length  = 100;
max_time    = 1*60*60; % 1 hour
PLOT        = 0;

% %% Select burst.S indices 
[tmp tt] = sort(Burst.S);
tt  = tt(Burst.C(tt)>0 & Burst.S(tt)>min_length & Burst.T_end(tt)<Burst.T_start(1)+max_time);
%tt  = tt(1);

neuron.ch = 0:125;%[big_all big_only_ch];
neuron.el = zeros(size(neuron.ch))-1;
for i = 1:length(neuron.ch)
    xx = find(neuron.ch(i)==Info.Map.ch,1);
    if ~isempty(xx) && ~isnan(thresh(neuron.ch(i)+1))
        neuron.el(i) = Info.Map.el(xx);
    end
end
[neuron.x neuron.y] = el2position(neuron.el);

center.x = (max(ELC.X(ELC.X>0))-min(ELC.X(ELC.X>0)))/2+min(ELC.X(ELC.X>0));
center.y = (max(ELC.Y(ELC.Y>0))-min(ELC.Y(ELC.Y>0)))/2+min(ELC.Y(ELC.Y>0));
 
bin      = 0.030;
step     = 0.005;
rng      = -0.3:step:0.3;
smoothing = 30;

CAT.x    = zeros(length(tt),length(rng));
CAT.y    = zeros(length(tt),length(rng));
CAT.tot  = ones(length(tt),length(rng));
FRH      = zeros(length(tt),length(rng), 126);
TIMING   = zeros(length(tt), 126);                  % first spike time

cnt = 0;
if PLOT
    f = 200;
    figure(f+1); hold off
    fig = figure(f);   hold off
end
for t = tt

    if Burst.S(t)>1200
        fig = f+1;
    end
    cnt     = cnt+1;
    yoff    = length(tt) - cnt;
    xoff    = Burst.C(t);
    ID_0    = find(Spike.T>=Burst.T_start(t) & Spike.T<=Burst.T_end(t) & Spike.H<0);

    for i = 1:length(neuron.ch)
        ch = neuron.ch(i);
        el = neuron.el(i);
        px = neuron.x(i);
        py = neuron.y(i);
        if isnan(thresh(ch+1))
            %disp Isnan
            continue;
        else
            ht = thresh(ch+1);
        end
        ID_C = ID_0( Spike.C(ID_0) == ch  &  Spike.H(ID_0)<=ht);
        
        if ~isempty(ID_C)
            TIMING(cnt,ch+1) = min(Spike.T(ID_C))-xoff;      
            cnt_s = 0;
            for s = rng+xoff
                cnt_s = cnt_s+1;
                ID = ID_C( Spike.T(ID_C)>s  &  Spike.T(ID_C)<s+bin );
                if ~isempty(ID)
                    CAT.x(cnt,cnt_s)   = CAT.x(cnt,cnt_s)   + (px-center.x)*length(ID);
                    CAT.y(cnt,cnt_s)   = CAT.y(cnt,cnt_s)   + (py-center.y)*length(ID);
                    CAT.tot(cnt,cnt_s) = CAT.tot(cnt,cnt_s) + length(ID);
                    FRH(cnt,cnt_s,ch+1) = FRH(cnt,cnt_s,ch+1) + length(ID);                
                end
            end
        end
    end
    
    if PLOT
%         figure(10); hold off
%         [b ID] = sort(TIMING(cnt,neuron.ch+1));
%         ID = ID( b~=0 );
%         b  =  b( b~=0 );
%         clr = jet( round(length(rng)/1.5) );
%         for i=1:length(ID)-1
%             id = ID(i:i+1);
%             
%             [c cx] = min( abs(b(i)-rng) );
%             
%             plot( neuron.x(id), neuron.y(id) , 'color', clr(cx,:))
%             hold on
%         end
%         scatter(neuron.x,neuron.y,50,log10(sum(squeeze(FRH(cnt,:,neuron.ch+1)))+1),'filled')
%         axis ij equal
%         set(gca,'color',[1 1 1]*.5)
%         colorbar
%         caxis([0 1.7])
%         title([Info.Exptitle ' burst size' int2str(burst.S(t))])
        
        
        
        figure(fig);
        line([0 0],[-5 5],'color','k')
        line([-5 5],[0 0],'color','k')
        x = CAT.x(cnt,:);%./CAT.tot(cnt,:);  
        y = CAT.y(cnt,:);%./CAT.tot(cnt,:);
        
        x = smooth(x,smoothing);
        y = smooth(y,smoothing);
        x = smooth(x,smoothing);
        y = smooth(y,smoothing);
        
        
        clr = jet( length(x) );
        for i=1:length(x)-1
            plot( x(i:i+1), y(i:i+1), 'color', clr(i,:))
            hold on
        end
         
%         plot(x, y,'c')
%         hold on
        
        %scatter(x, y, 50, 1:length(CAT.x(cnt,:)),'filled')
        plot(x(1),y(1),'.k','markersize',30)
        
        title([Info.Exptitle ' burst size' int2str(Burst.S(t))])
        set(gca,'color',[1 1 1]*.5)
        pause(1)
               
        
        
        
        %scatter(x, y, 50, [1 1 1]*.5,'filled')
%         plot(x, y,'k')
%         plot(x(1),y(1),'.k','markersize',30)
        
    else
        fprintf('%i\n',length(tt)-cnt)
    end
    
end





%%
%%
%%



    spacingx =  1;
    spacingy = 10;
    sx       =  1 : spacingx :  130;
    sy       = 10 : spacingy : 10000;
    %[sx,sy]  = meshgrid(sx,sy);  

    min_x = zeros(size(sx));
    max_x = zeros(size(sx));
    min_y = zeros(size(sy));
    max_y = zeros(size(sy));
    
    z = zeros(length(sx)-1,length(sy)-1);
    
    for i=2:length(sx)
        xx     = find( x<=sx(i) & x>=sx(i-1) );
        if ~isempty(xx)
            min_x(i) = min(x(xx));
            max_x(i) = max(x(xx));
        end
    end
    
    for i=2:length(sy)
        xx     = find( y<=sy(i) & y>=sy(i-1) );
        if ~isempty(xx)
            min_y(i) = min(y(xx));
            max_y(i) = max(y(xx));
        end
    end    
    
%    imagesc(z)
    
    %%
    % IMAGESC to plot quickly
    z = griddata(x,y,ones(size(x)),sx,sy,'cubic');  
    imagesc(sx(1,:),sy(:,1),z); 
    
    axis([sx(1,[1 end]) sy([1 end],1)'])



%% History dependency of spike height

ID    = find( Spike.clid==1  &  Spike.H<=thresh(ch+1) & Spike.C==ch);
t   = Spike.T(ID);
h   = Spike.H(ID);

% t   = sig{ch+1}.spike.T;
% h   = sig{ch+1}.spike.H;


dt  = diff(t);
diffHeight  = diff(abs(h));

figure

plot(dt,diffHeight,'o','markersize',2); grid on
plot(dt,h(2:end),'o','markersize',2)

plot(dt(2:end)+dt(1:end-1),diffHeight(2:end),'o')
plot(dt(3:end)+dt(2:end-1)+dt(3:end-2),diffHeight(3:end),'o')
plot(dt(3:end)+dt(2:end-1)+dt(1:end-2),diffHeight(3:end),'o')
plot(dt(2:end)+dt(1:end-1),diffHeight(2:end),'o')
plot(dt(3:end)+dt(2:end-1)+dt(1:end-2),diffHeight(3:end),'o')
plot(dt(2:end)+dt(1:end-1),diffHeight(2:end),'o')
plot(dt(2:end)+dt(1:end-1),diffHeight(2:end),'o','markersize',5)
plot(dt(2:end)+dt(1:end-1),diffHeight(2:end),'o','markersize',2)


%% Find % spikes in vs out of bursts using spike.B found above

percent = zeros(1,126);
number  = zeros(1,126);
for ch = 0:125
    %ID_0 = find(spike.C==ch & spike.H<thresh(ch+1) ); % outside bursts
    ID_0 = find(Spike.C==ch  ); % outside bursts
    ID_out = ID_0( Spike.B(ID_0)==0 );
    percent(ch+1) = length(ID_out)/length(ID_0);
    number(ch+1)  = length(ID_out);
end
    


%%  Find number of spikes in a burst for each channel
%

Size = 500;

I = find(Burst.S>=Size);
L = length(I);
Burst.Ch = zeros(NCHAN, length(Burst.T_end));
cnt=0;

ID_0  =  find(Spike.clid==1  &  Spike.H<max(thresh)  ) ;
for i = I(1:1000)
    if Burst.T_end(i)>Spike.T(end),  break, end
    %if cnt>1000,                     break, end
    cnt = cnt+1;
    
    ID    =  ID_0(  Spike.T(ID_0)>=Burst.T_start(i) & Spike.T(ID_0)<=Burst.T_end(i)  );
    for ch = 0:NCHAN-1
        %IDch = find(spike.C(ID)==ch);
        IDch = find(Spike.C(ID)==ch & Spike.H(ID)<thresh(ch+1)); % 
        if ~isempty(IDch)
            Burst.Ch(ch+1,i) = length(IDch);
        end
    end
    
    if mod(cnt,10)==0
        fprintf('%i / %i\n',cnt,L), pause(.001)
    end
end


%% orient and plot

burst_Ch  = Burst.Ch;

ID        = find( max(burst_Ch) );      burst_Ch  = burst_Ch(:,ID);  % use bursts that met criterian above
ID        = find( median(burst_Ch') );  burst_Ch  = burst_Ch(ID,:);  % drop channels with few spikes
Sum       = max(burst_Ch');

burst_Norm = zeros(size(burst_Ch)); % Normalize by max FR w/i a burst
for i=1:size(burst_Ch,1)
    if Sum(i)
        burst_Norm(i,:) = burst_Ch(i,:)/Sum(i);
    end    
end

% %%

figure

% burst_ = burst_Norm;
burst_ = burst_Ch;
[b2 id2]=sort(sum(burst_));   % sort in order of burst size
[b1 id1]=sort(sum(burst_'));  % sort in order of channel FR
%[b1 id1]=sort(sum(burst_(:,id2(end-20:end))'));  % sort in order of channel FR
imagesc(burst_(id1,id2))
colorbar

xlabel 'burst number'
ylabel 'channel number'
title(Info.Exptitle)


% modified by me to add more red (perceptually balanced colormaps)
%colormap(mkpj(126,'J_DB'))
colormap(mkpj(126,'J'))
%colormap gray

