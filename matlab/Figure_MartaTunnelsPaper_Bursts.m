

%% -- 130705-Marta    For her tunnels paper       (1 config)
%      ~ 1 hour of data
%
clear all; 
Info.Exptype='SpontScan';
Info.Exptitle='soma';
Info.FileName.SpikeForm = ['/home/bakkumd/Data/spikes/130705-Marta/' Info.Exptitle '.spikeform'];
Info.FileName.Spike     = ['/home/bakkumd/Data/spikes/130705-Marta/' Info.Exptitle '.Spike'];
Info.FileName.Map       =  '/home/bakkumd/Data/spikes/130705-Marta/soma_neuromap.m';
Info.Parameter.ConfigDuration      = NaN; % [sec] configuration duration -- 5trigs per config, trig scan
Info.Parameter.ConfigNumber        =   1;    % number of configs



%% load Info.Map info

% %  if not created during the experiment, create Info.FileName.Map using Stim Expt tab in CmdGui
%  cmd=['el2fi_to_neuromap -i ' Info.Exptitle '.el2fi.nrk2 -o ' Info.FileName.Map]
%  cmd=['el2fi_to_neuromap -i /home/bakkumd/Data/configs/bakkum/' Info.Exptitle(1:6) '/' Info.Exptitle '.el2fi.nrk2 -o ' Info.FileName.Map]
%  system(cmd)

Info.Map=loadmapfile(Info.FileName.Map,1111); % load Info.FileName.Map and plot elc locations in figure 1111

load global_cmos


%% load formated Spike data
%  High res DAC encoding (after March 2010)
    
%    system(['rm ' Info.FileName.SpikeForm])
%    cmd=['`which FormatSpikeData` -a 127 -c -s '        Info.FileName.Spike ' -o ' Info.FileName.SpikeForm]
%
%    system(cmd);

% !! if rerun spikeform then need to double check dac_info encoding again !!

% !!!!! FormatSpikeData height currently broken !!!  --> currently uses peak of Spike context to set height...

% cd /home/bakkumd/bel.svn/cmosmea_external/meabench/trunk/matlab
Spike = loadspikeform(Info.FileName.SpikeForm);
if isempty(Spike.T), disp '    !! No spikes loaded !!', return; end
  
     
dac_info = 127; % DAC2 - information channel (stim times & channel, epochs)
DI       = find(Spike.C==dac_info);
% Info.Parameter.ConfigNumber   = 95;%108;
fprintf(1,'Found %i spikes.\n',length(Spike.C));
fprintf(1,'Found %i stim markers on channel %i.\n',length(DI),dac_info);


 % fixes (be sure to CHECK epoch was encoded correctly)
 figure
 plot(Spike.T(DI),Spike.E(DI),'.')
 
 Spike = spikeform_EpochFix(Info,Spike);
 
 hold on;
 plot(Spike.T(DI),Spike.E(DI),'ro'); hold off % test the epoch fix

 
%% Set tonic channels

tonic = [94 95 0 90 25 105 33 85 115 71 6 96 79];

% Set spike.tonic
Spike.tonic = zeros(size(Spike.C));
for c = tonic
    Spike.tonic(Spike.C==c) = 1;
end    
 
 
%%  Order channels by FR for plot

GoodSpikes  = find(Spike.H<-60 & Spike.clid & ~Spike.tonic);
         
N = zeros(1,126); 
for c = 0:125
   N(c+1) = length(find(Spike.C(GoodSpikes)==c));
end
[b CC] = sort(N);
for c = 1:126
   C(c) = find(CC==c);
end

%%

figure
plot(Spike.T(GoodSpikes),C(1+Spike.C(GoodSpikes)),'.')

%% 
 
figure(6789)
cla
hold on
 
ChnTop    = Info.Map.ch(Info.Map.py>1000);  ChnTop=unique(ChnTop);
ChnBot    = Info.Map.ch(Info.Map.py<1000 & Info.Map.py>0); 
 
Spike.top = zeros(size(Spike.C))-1;

cnt_top = 1;
cnt_bot =-1;
for c=fliplr(CC)-1
    GS  = find(Spike.C==c & Spike.H<-60 & Spike.clid & ~Spike.tonic);
    yoff = 0;
    if isempty(GS), continue, end
    if ~isempty(find(ChnTop==c))
        cnt_top = cnt_top+1;
        yoff    = cnt_top;
        Spike.top(GS) = 1;
    elseif ~isempty(find(ChnBot==c))
        cnt_bot = cnt_bot-1;
        yoff    = cnt_bot;
        Spike.top(GS) = 0;
    else
        disp('Error')
    end
    plot(Spike.T(GS),yoff*ones(size(GS)),'.')
end
line(Spike.T([1 end]),[0 0],'color','k')

    




%% FR Histogram detection method
%
%  ***
%  Equivalent to ISIn = bin for n=thresh
%  Therefore, to get more accurate widths of detected bursts, just set FRbin=0.05 sec and FRnum=50 spikes and run logISIn code and plots
%  ***



figure(6789)
hold on

bin     = 0.05; % [sec] historgram bin width
thresh  = 30;   % [spikes] threshold to detect a burst
                    
                    
                    
x1 = min(Spike.T); % for whole range
x2 = max(Spike.T);

clear BurstTop BurstBot

for iii = 1:2
    if iii==1
        GoodSpikes  = find(Spike.top==1); % Top channels
        yoff        = cnt_top+1;
        inverse     =  1;
        clr         = 'b';
    else
        GoodSpikes  = find(Spike.top==0); % Bottom channels
        yoff        = cnt_bot-1;
        inverse     = -1;
        clr         = 'r';
    end
    
    clear Burst

    % Get estimate of widths using ISIn=thresh(count) = bin(ms)
    P.FRnum         = thresh;           
    P.FRbin         = bin;
    P.Gap           = inf;
    P.GoodSpikes    = GoodSpikes;    
    [Burst  S]      = BurstDetect(Spike,P);  



    [n x]       = hist(Spike.T(GoodSpikes),ceil(diff(Spike.T(([1 end]))))/bin);
    [p l]       = findpeaks(n,'minpeakheight',thresh,'minpeakdistance',4);

    plot(x,inverse*n/thresh+yoff,'k')
    plot(x(l),inverse*p/thresh+yoff,'o','color',clr)

    
    xx = find(Burst.T_end<max(Spike.T));    tmp = [];
    for i=xx, 
        tmp                = [tmp Burst.T_start(i) Burst.T_end(i) NaN];  
         
        pp                 = find(x>=Burst.T_start(i) & x<=Burst.T_end(i));
        if isempty(pp), continue, end
        [Burst.Peak(i) id] = max(n(pp));
        Burst.Peak_T(i)    = x(pp(id));
        
    end
    plot(tmp,yoff*ones(size(tmp)),clr,'linewidth',4)


    if iii==1
        BurstTop = Burst;
    else
        BurstBot = Burst;
    end
    
end


    

        set(gca,'xlim',[x1 x2])
        xlabel 'Time [sec]'
        ylabel 'Spikes [#]'
        
        figure_size(26,6)
        figure_fontsize(8,'bold')

 
 
 
 %% Find overlapped bursts and burst order
 
 
 BurstTop.overlap = zeros(size(BurstTop.S)); % do bursts overlap?
 BurstTop.first   = zeros(size(BurstTop.S)); % is Top peak first?
 BurstTop.equal   = zeros(size(BurstTop.S)); % are burst peaks at same time?
 
 tolerance        = bin;                   % join close bursts
 
 for i = 1:length(BurstTop.S)
     
     % This conditional isnt perfect but seems to give reliable numbers (i.e. close enough)
     xx = find( ( BurstBot.T_start > BurstTop.T_start(i)-tolerance  &  BurstBot.T_start < BurstTop.T_end(i) +tolerance ) | ...
                ( BurstBot.T_end   > BurstTop.T_start(i)-tolerance  &  BurstBot.T_end   < BurstTop.T_end(i) +tolerance ) | ...
                ( BurstBot.Peak_T  > BurstTop.T_start(i)-tolerance  &  BurstBot.Peak_T  < BurstTop.T_end(i) +tolerance ) | ...
                ( BurstBot.T_start < BurstTop.Peak_T(i) +tolerance  &  BurstBot.T_end   > BurstTop.Peak_T(i)-tolerance ) );
 
     if ~isempty(xx)
         BurstTop.overlap(i) = 1;
         line([0 0]+BurstBot.T_start(xx),[cnt_bot-5 cnt_top+5],'color','k')
         if BurstTop.Peak(i)<BurstBot.Peak(xx)
             BurstTop.first(i) = 1;
         elseif BurstTop.Peak(i)==BurstBot.Peak(xx)
             BurstTop.equal(i) = 1;
         end         
     end
     
 end
     
 
 fprintf('Overlapped bursts:   %i out of %i (top), %i (bottom) bursts.\n',      length(find(BurstTop.overlap)), ...
                                                                                length(BurstTop.S), ...
                                                                                length(BurstBot.S) );
 fprintf('Top was first burst  %.1f%% of time.\n', length(find(BurstTop.first)) / length(find(BurstTop.overlap)) * 100 );
 fprintf('Bursts at same time  %.1f%% of time.\n', length(find(BurstTop.equal)) / length(find(BurstTop.overlap)) * 100 );
 
 
 
 
 %% Try to reverse order to test above code for consistency
 BurstTop_=BurstTop; % save old
 BurstBot_=BurstBot; % save old
 
 BurstTop=BurstBot_;
 BurstBot=BurstTop_;
 
 
 BurstTop_=BurstTop;
 BurstBot_=BurstBot;
 
 
 
 
 
 
 
 
 
 
 
 
