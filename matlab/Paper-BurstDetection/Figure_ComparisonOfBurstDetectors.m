%%  Figure
%   Comparison of burst detectors
%   
%
%   Use data from 121227-F (figure 5)
%


%%    Load pre-saved Burst struct data (can skip detection then)
%           120829-A  --  79% small bursts
%           130520-A  --  12% small bursts
%           130520-C  --   0% small bursts


      filename = [Info.Exptitle '-BurstData.mat']
%     save(filename,'Burst')
      load(filename)



%% Rank Surprise


if strcmp(Info.Exptitle,'121227-F')
    x1 = 47007;
    x2 = 47037;
    textra = 5*60; % [sec]
else
    x1 = min(Spike.T);
    x2 = max(Spike.T);
    textra = 0;
end



% Order channels by FR for plot
N = zeros(1,126); 
for c = 0:125
   N(c+1) = length(find(Sort.C==c));
end
[b cc] = sort(N);
for c = 1:126
   C(c) = find(cc==c);
end


Burst_RankSurprise.T_start = [];
Burst_RankSurprise.T_end   = [];
Burst_RankSurprise.C       = [];

clear RS_burstTrain

% figure
% hold on

mrksz      = 3;


reverseStr = '';
for c = 0:125
    
    msg = sprintf('%i\n',c);
    fprintf([reverseStr, msg]);
    reverseStr = repmat(sprintf('\b'), 1, length(msg));   
    drawnow('update')
    
    GoodSpikes = find(~Spike.tonic & Spike.H<-60 & Spike.clid & Spike.C==c & Spike.T>x1 & Spike.T<x2+textra);
%     plot(Spike.T(GoodSpikes),C(1+Spike.C(GoodSpikes)),'k+','markersize',mrksz)

    if isempty(GoodSpikes),   continue, end
    if length(GoodSpikes)<10, continue, end
    
    Burst_RS                    = RankSurpriseBurstDetector(Spike.T(GoodSpikes));
    Burst_RankSurprise.T_start  = [Burst_RankSurprise.T_start  Spike.T(GoodSpikes( Burst_RS.start ))];
    Burst_RankSurprise.T_end    = [Burst_RankSurprise.T_end    Spike.T(GoodSpikes( Burst_RS.start+Burst_RS.length-1))];
    Burst_RankSurprise.C        = [Burst_RankSurprise.C        Spike.C(GoodSpikes( Burst_RS.start ))];
    
    RS_burstTrain{c+1}.T_start  = Spike.T(GoodSpikes( Burst_RS.start ));                    % additional data struct for compatibility with ISI detection code and plotting
    RS_burstTrain{c+1}.T_end    = Spike.T(GoodSpikes( Burst_RS.start+Burst_RS.length-1));   % additional data struct for compatibility with ISI detection code and plotting
    
        
%     tmp = [];
%     for i=1:length(Burst_RS.RS)
%         st = Spike.T(GoodSpikes(Burst_RS.start(i)));
%         en = Spike.T(GoodSpikes(Burst_RS.start(i)+Burst_RS.length(i)-1));
%         if en-st<.05, en=st+.05; end % Fix for printing plots. Too small causes funny shape.
%         tmp = [tmp st en NaN];
%     end
%     plot(tmp,C(1+c*ones(size(tmp))),'color', [0 1 1]/1.4,'linewidth',2)
%     title(c)
%     drawnow
    
end

Burst.RS.burstTrain = RS_burstTrain;

%%
% % Find overlapping single-channel bursts
% 
%%%% *** Just plot and get 'network' burst detection by hand (i.e. minPercElec = 20% as in Pasquale - although maybe try half?)
% 

minNumElc = 10;


% Sort spike times as not necessarily in order in spike file
[Burst_RS.T_start IX]  = sort(Burst_RankSurprise.T_start); % Jitter by up to 1 sample to make curve smoother at high frequencies (minimizes bias due to discrete sampling)
 Burst_RS.C            = Burst_RankSurprise.C(IX);
 Burst_RS.T_end        = Burst_RankSurprise.T_end(IX);

 Burst.RS.T         = [];  % = zeros(size(Burst_RankSurprise.C));
 Burst.RS.T_start   = [];
 Burst.RS.T_end     = [];
 
 
reverseStr = '';
t1  = 0; 
cnt = 0;
cnt_nb = 0;
while t1 < Burst_RS.T_start(end-1) && cnt+1 < length(Burst_RS.T_start)
    cnt = cnt+1;
    t1  = Burst_RS.T_start(cnt);
    t2  = Burst_RS.T_end(cnt);
    %t2  = min([ Burst_RS.T_end(cnt)  t1+0.5 ]); % limit such that tonic channel detected as long burst is avoided
    xx  = find( (Burst_RS.T_start >= t1 & Burst_RS.T_end <= t2)   | ...
                (Burst_RS.T_start <= t1 & Burst_RS.T_end >= t1)   | ...
                (Burst_RS.T_start <= t2 & Burst_RS.T_end >= t2)   ); % within burst, overlaps t1, or overlaps t2
    
            
    if length(xx) >= minNumElc
                
        cnt_nb = cnt_nb+1;
        Burst.RS.T(cnt_nb)       = max(Burst_RS.T_start(xx)) ; % expect this value will be close to burst center, and so included in range of a ISIn burst
        Burst.RS.T_start(cnt_nb) = min(Burst_RS.T_start(xx)) ;
        Burst.RS.T_end(cnt_nb)   = max(Burst_RS.T_end(xx))   ;
        
        cnt = cnt + length(xx) - 1;  % skip ahead to next burst             
        
    end
    
    msg = sprintf('%d/%d\n', round((t1-Burst_RS.T_start(1))/60), round(diff(Burst_RS.T_start([1 end]))/60));
    fprintf([reverseStr, msg]);
    reverseStr = repmat(sprintf('\b'), 1, length(msg));    
    
    
end


    % RS detection
    plot(Burst.RS.T,ones(size(Burst.RS.T))*128,'p','color', [0 1 1]/1.4)

    % logISIn detection
    xx = find(Burst.T_end<max(Spike.T));
    tmp = [];
    for i=xx
        tmp = [tmp Burst.T_start(i) Burst.T_end(i) NaN];
    end
    plot(tmp,130*ones(size(tmp)),'r','linewidth',2)
    





Burst.RS.ID      = zeros(size(Burst.RS.T)); % corresponding ID in Burst structure from logISIn method
for i = 1:length(Burst.T_end)
    xx = find( Burst.RS.T <= Burst.T_end(i) & Burst.RS.T >= Burst.T_start(i) );
    if ~isempty(xx)
        Burst.RS.ID(xx) = i;
    end
end
fprintf('  %.1f %% logISIn bursts also detected by RS\n',100 * length(unique(Burst.RS.ID(Burst.RS.ID>0))) / length(Burst.T_start))
    





%%
% figure
% hold on
% 

        set(gca,'xlim',[x1 x2])
        set(gca,'ylim',[0 130])
        set(gca,'xtick',[x1:5:x2],'xtickLabel',[0:5:(x2-x1)])
        set(gca,'ytick',[0:20:120],'yticklabel',[0:20:120])   
        xlabel 'Time [sec]'
        ylabel 'Channel'
        box on
        
        figure_size(16,6)
        figure_fontsize(8,'bold')
        filename = ['/home/bakkumd/Desktop/' Info.Exptitle '-DetectorComparison_RS'];
%g

        fprintf('num active channels = %i \n',length(unique(Sort.C)))


        
        
        
        
%%
%%
%%
%% FR Histogram detection method
%
%  ***
%  Equivalent to ISIn = bin for n=thresh
%  Therefore, to get more accurate widths of detected bursts, just set FRbin=0.05 sec and FRnum=50 spikes and run logISIn code and plots
%  ***

bin     = 0.05; % [sec] historgram bin width
thresh  = 50;   % [spikes] threshold to detect a burst
                %           use 10 for consistency with ISIn code? 10 is same for this case (i.e. ok if low tonic rates, and 50/64 channels is twice 50/126 channels)


figure(456)
clf
hold on

x1 = min(Spike.T); % for whole range
x2 = max(Spike.T);


GoodSpikes  = find(~Spike.tonic & Spike.H<-60 & Spike.clid & Spike.T>x1 & Spike.T<x2);


% Get estimate of widths using ISIn=50 = 50ms
P.FRnum         = 50;           
P.FRbin         = 50/1000;
P.Gap           = inf;
P.GoodSpikes    = GoodSpikes;    
[Burst.FRH  S]  = BurstDetect(Spike,P);  



[n x]       = hist(Spike.T(GoodSpikes),ceil(diff(Spike.T(GoodSpikes([1 end]))))/bin);
[p l]       = findpeaks(n,'minpeakheight',thresh,'minpeakdistance',4);

Burst.FRH.Peak    = p;
Burst.FRH.Peak_T  = x(l);
Burst.FRH.ID      = zeros(size(p)); % corresponding ID in Burst structure from logISIn method
for i = 1:length(Burst.T_end)
    xx = find( Burst.FRH.Peak_T <= Burst.T_end(i) & Burst.FRH.Peak_T >= Burst.T_start(i) );
    if ~isempty(xx)
        Burst.FRH.ID(xx) = i;
    end
end
%fprintf('  %.1f %% ISIn bursts also detected by FRH\n',100 * length(find(Burst.FRH.ID>0)) / length(Burst.T_end))
fprintf('  %.1f %% ISIn bursts also detected by FRH\n',100 * length(unique(Burst.FRH.ID(Burst.FRH.ID>0))) / length(Burst.T_start))
    

plot(x,n)
plot(x(l),p,'ok')

line([x1 x2], [0 0]+thresh,'color','k','linewidth',1) 

xx = find(x(l)>x1 & x(l)<x2);
for i=xx
    line([-bin bin]+x(l(i)),[0 0]+p(i)*0.25,'color','k','linewidth',4)
end


    

        set(gca,'xlim',[x1 x2])
        set(gca,'xtick',[x1:5:x2],'xtickLabel',[0:5:(x2-x1)])
        %set(gca,'ytick',[0:20:120],'yticklabel',[0:20:120])   
        xlabel 'Time [sec]'
        ylabel 'Spikes [#]'
        
        figure_size(16,6)
        figure_fontsize(8,'bold')
        filename = ['/home/bakkumd/Desktop/' Info.Exptitle '-DetectorComparison_FRH_bars'];
%         print('-dpdf','-r250',filename)






%%
%%
%% Plot which bursts were detected for each method (FRH, ISI, Rank Surprise) vs ISIn method
%  Need to first load the Burst.FRH, Burst.ISI, and Burst.RS data
% 

fig = figure;

ID1 = Burst.FRH.ID;    clr1 = [0 0 1];
ID2 = Burst.ISI.ID;    clr2 = [0 1 0]/1.2;
ID3 = Burst.RS.ID;     clr3 = [0 1 1]/1.4;
ID1 = unique(ID1(ID1>0)); 
ID2 = unique(ID2(ID2>0));
ID3 = unique(ID3(ID3>0));

ID  = ID1;
clr = 'k';
clr0 = [1 0 0];

bst  = Burst.S+rand(size(Burst.S));
chn  = Burst.C+rand(size(Burst.S));

SAVE = 1;

% %% Scatterplot of Burst Size vs Num Channels
figure(fig+4); clf; hold on

semilogx(bst,chn,'kd','markersize',2)
semilogx(bst(ID),chn(ID),'d','color',clr,'markersize',2)

        %set(gca,'xlim',[Parameter.FRnum  max(bst)])
        set(gca,'xlim',[1  max(bst)])
        set(gca,'ylim',[0 130])
        set(gca,'xscale','log')
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


% %% Histogram of Burst Size        
figure(fig+1); clf; hold on
cutoff_bs = 0;  % for finding firing rate of large bursts only             
%steps     = [1:.075:log10(ax1(2))+.1]; 
steps     = [1:.15:log10(ax1(2))+.1]; 
[n0 ix]    = histc(log10(bst), steps);
[n1 ix]    = histc(log10(bst(ID1)), steps);
[n2 ix]    = histc(log10(bst(ID2)), steps);
[n3 ix]    = histc(log10(bst(ID3)), steps);

n = [n0; n1; n2; n3]';

h=bar3(steps,n,1);
        map = [clr0; clr1; clr2; clr3];
        colormap(map)
        view(62,18)
        %view(87,12)

        % dont color zero values (or ones) 
        for i = 1:numel(h)
          index = logical(kron(n(:,i) <= 1,ones(6,1)));
          zData = get(h(i),'ZData');
          zData(index,:) = nan;
          set(h(i),'ZData',zData);
        end

        %set(gca,'ylim',[.95 log10(ax1(2))])
        set(gca,'ylim',[.95 3.475])
        set(gca,'ytick',[1 2 3 4],'yticklabel',{'10' '100' '1000' '10000' })
        set(gca,'xtick',[])
        ylabel 'ISI_{N=10} burst size [spikes]'
        zlabel 'Count'
        title([Info.Exptitle])
        
        
        if SAVE
            title ''
            figure_fontsize(8,'bold')
            filename = ['/home/bakkumd/Desktop/' Info.Exptitle 'BurstSizeHist_Comparison'];
            
            figure_size(7,4)
            print('-dpdf',filename)
        end
     
        

% % %% Historgram of Num Channels in a burst
% figure(fig+0); clf
% cutoff_nc = 0;  % for finding firing rate of large bursts only
% steps     = [0:4:125]; 
% [n ix]    = histc(chn(ID), steps);
%             bar(steps,n,'barwidth',1)
%             
%         h = findobj(gca,'Type','patch');
%         set(h,'FaceColor',clr,'EdgeColor',clr)
%         set(gca,'xlim',ax1([3 4]))
%         title 'Number Channels'
%         if SAVE
%             title ''
%             axis square
%             figure_size(8,8)
%             figure_fontsize(8,'bold')
%             axis off
%             filename = ['/home/bakkumd/Desktop/' Info.Exptitle '-BurstSizeVsNumChan_NumChanHist'];
%             print('-dpdf','-r250',filename)
%         else
%             hold on
%             sm = smooth(n);
%             plot(steps,sm)
%             [xx ii] = min(sm(3:end-12)); % avoid edges
%             cutoff_nc = steps(ii+3-1);
%             if strcmp(Info.Exptitle,'110518-N') || strcmp(Info.Exptitle,'121227-F') 
%                 [xx ii] = min(sm(20:end-2)); 
%                 cutoff_nc = steps(ii+20-1);
%             end
%             line([0 0]+cutoff_nc,[0 50])
%         end

%% Histogram of Burst Widths  

figure

%steps     = [0:.02:1]*1000; %[ms]
steps     = [0:.04:1]*1000; %[ms]

[n0 ix]    = histc(1000*(Burst.T_end-Burst.T_start),         steps);
[n1 ix]    = histc(1000*(Burst.FRH.T_end-Burst.FRH.T_start), steps);
[n2 ix]    = histc(1000*(Burst.ISI.T_end-Burst.ISI.T_start), steps);
[n3 ix]    = histc(1000*(Burst.RS.T_end-Burst.RS.T_start),   steps);

n = [n0; n1; n2; n3]';

h=bar3(steps,n,1);
        
        % dont color zero values (or ones) 
        for i = 1:numel(h)
          index = logical(kron(n(:,i) <= 1,ones(6,1)));
          zData = get(h(i),'ZData');
          zData(index,:) = nan;
          set(h(i),'ZData',zData);
        end

        map = [clr0; clr1; clr2; clr3];
        colormap(map)
        view(60,30)
        set(gca,'PlotBoxAspectRatio',[50 100 60])
        
        set(gca,'ylim',[steps([1 end])])
        %set(gca,'ytick',[1 2 3 4],'yticklabel',{'10' '100' '1000' '10000' })
        set(gca,'xtick',[])
        ylabel 'Network burst width [ms]'
        zlabel 'Count'
        title([Info.Exptitle])
        grid off
        
        if SAVE
            title ''
            figure_size(7,4)
            figure_fontsize(8,'bold')
            filename = ['/home/bakkumd/Desktop/' Info.Exptitle 'BurstWidthHist_Comparison'];
            print('-dpdf',filename)
            
        end



         
         
%% Plot detected bursts for all methods        
%  Example rasters with bars for detected bursts
%

SAVE = 1;

x1 = min(Spike.T); % for whole range
x2 = max(Spike.T);

x1 = 7689.7; % for whole range
x2 = x1+1.4;

if strcmp(Info.Exptitle,'130520-A')

    % - 130520-A  1764 spikes
    x1=7947.15;
    x2=x1+.6;
    
%     % - 130520-A  20 spikes
%     x1=8510.5;
%     x2=x1+.6;

    
elseif strcmp(Info.Exptitle,'130520-C')
    x1=22887.3;
    x2=x1+1;
    
else 
    x1 = min(Spike.T); % for whole range
    x2 = max(Spike.T);
end

GoodSpikes  = find(~Spike.tonic & Spike.H<-60 & Spike.clid & Spike.T>x1 & Spike.T<x2);
%GoodSpikes  = find(~Spike.tonic & Spike.H<-60 & Spike.clid);



% Order channels by FR for plot
N = zeros(1,126); 
for c = 0:125
   N(c+1) = length(find(Spike.C(:)==c));
end
[b cc] = sort(N);
for c = 1:126
   C(c) = find(cc==c);
end
        

mrksz =  3;
lnw1  =  4;
offs  =  1;

figure; hold on


%%% Plot raster %%%
%  plot(Spike.T(GoodSpikes),C(1+Spike.C(GoodSpikes))+offs/2,'+','color',[1 1 1]*0,'markersize',2)        
for s=GoodSpikes
    line([0 0]+Spike.T(s),[0 offs]+C(1+Spike.C(s)),'color','k','linewidth',1.5);
end


%%% ISIn detection replot %%%
    xx = find(Burst.T_end<max(Spike.T));    tmp = [];
    for i=xx, tmp = [tmp Burst.T_start(i) Burst.T_end(i) NaN];    end
    plot(tmp,138*ones(size(tmp)),'r','linewidth',lnw1)


    
%%% FRH detection replot %%%  (estimated using ISIn=50 = 50
    xx = find(Burst.FRH.T_end<max(Spike.T));    tmp = [];
    for i=xx, tmp = [tmp Burst.FRH.T_start(i) Burst.FRH.T_end(i) NaN];    end
    plot(tmp,136*ones(size(tmp)),'b','linewidth',lnw1)

        

%%% ISI detector replot %%%
clr = [0 1 0]/1.2;
for c=1:126
    if isempty(Burst.ISI.burstTrain{c}), continue, end
    B = Burst.ISI.burstTrain{c};
    tmpx = [];
    tmpy = [];
    xx = find( B.T_start>x1 & B.T_end<x2);
%     for i=xx %1:length(B.T_end)        
%         oo = find(( Spike.T(GoodSpikes)<B.T_start(i)  |  Spike.T(GoodSpikes)>B.T_end(i))  &  Spike.C(GoodSpikes)==c-1 );
%         plot(Spike.T(GoodSpikes(oo)),C(1+Spike.C(GoodSpikes(oo)))+offs/2,'k+','markersize',2)     
%     end
    
    for i=xx
%         tmpx = [ B.T_start(i)  B.T_end(i)  B.T_end(i)   B.T_start(i)   B.T_start(i) ];
%         tmpy = [ C(c)          C(c)        C(c)+offs    C(c)+offs      C(c)         ];
%         patch(tmpx,tmpy,clr,'edgecolor',clr)
        tmpx = [ B.T_start(i)-.01  B.T_end(i)+.01  B.T_end(i)+.01   B.T_start(i)-.01   B.T_start(i)+.01 ];
        tmpy = [ C(c)          C(c)        C(c)+offs    C(c)+offs      C(c)         ];
        patch(tmpx,tmpy,'w','edgecolor','w')
        
        ss = find( Spike.T(GoodSpikes)>=B.T_start(i)-.001  &  Spike.T(GoodSpikes)<=B.T_end(i)  &  Spike.C(GoodSpikes)==c-1 );
        %plot(Spike.T(GoodSpikes(ss)),C(1+Spike.C(GoodSpikes(ss)))+offs/2,'w+','markersize',3); % cover previously plotted +'s
        for s=ss
            line([0 0]+Spike.T(GoodSpikes(s)),[0 offs]+C(1+Spike.C(GoodSpikes(s))),'color',ceil(clr)*.75,'linewidth',1.5);
        end
        
    end
    %plot(tmp,C(c*ones(size(tmp)))-offs,'color', [0 1 0]/1.2,'linewidth',2)
end
    xx = find(Burst.ISI.T_end<max(Spike.T));    tmp = [];
    for i=xx, tmp = [tmp Burst.ISI.T_start(i) Burst.ISI.T_end(i) NaN];    end
    plot(tmp,134*ones(size(tmp)),'color',clr,'linewidth',lnw1)
 
    
    
%%% RS detector replot %%%
clr = [0 1 1]/1.4;
for c=1:126
    if isempty(Burst.RS.burstTrain{c}), continue, end
    B = Burst.RS.burstTrain{c};
    tmpx = [];
    tmpy = [];
    xx = find( B.T_start>x1 & B.T_end<x2);
    for i=xx %1:length(B.T_end)
        tmpx = [ B.T_start(i)  B.T_end(i)  B.T_end(i)   B.T_start(i)   B.T_start(i) ];
        tmpy = [ C(c)          C(c)        C(c)+offs    C(c)+offs      C(c)         ];
        patch(tmpx,tmpy,clr,'edgecolor',clr)
        
%         line([B.T_start(i) B.T_end(i)],[0 0]+C(c)+offs/2,'color',clr,'linewidth',.5);
        
        ss = find( Spike.T(GoodSpikes)>=B.T_start(i)  &  Spike.T(GoodSpikes)<=B.T_end(i)  &  Spike.C(GoodSpikes)==c-1 );
        for s=ss
            line([0 0]+Spike.T(GoodSpikes(s)),[0 offs]+C(1+Spike.C(GoodSpikes(s))),'color',ceil(clr)*.6,'linewidth',.75);
        end
%         plot(Spike.T(GoodSpikes(ss)),C(1+Spike.C(GoodSpikes(ss))),'+','color',ceil(clr),'markersize',2);
            
        
        
    end
    %plot(tmp,C(c*ones(size(tmp)))+offs,'color', [0 1 1]/1.4,'linewidth',2)
    
end
    xx = find(Burst.RS.T_end<max(Spike.T));    tmp = [];
    for i=xx, tmp = [tmp Burst.RS.T_start(i) Burst.RS.T_end(i) NaN];    end
    plot(tmp,132*ones(size(tmp)),'color',clr,'linewidth',lnw1)


    

drawnow

    xlabel 'Time [ms]'
    ylabel 'Channel'

    figure_fontsize(8,'bold')
    title([Info.Exptitle '   ' int2str(Burst.S(find(Burst.T_end>x1,1))) ' spikes'])
    set(gca,'xlim',[x1 x2])
    
    if strcmp(Info.Exptitle,'130520-A')
        y1=6;
        y2=140;
        set(gca,'ylim',[y1 y2])
        set(gca,'ytick',[y1:20:126],'yticklabel',[0:20:120])
        %plot(Spike.T(GoodSpikes),C(1+Spike.C(GoodSpikes))+offs/2,'+','color',[1 1 1]*.4,'markersize',2)
    end
    
    if SAVE
        %figure_size(6,20)
        figure_size(12,10)
        set(gca,'xtick',[x1:.2:x2],'xtickLabel',[0:.2:(x2-x1)]*1000)
        filename = ['/home/bakkumd/Desktop/' Info.Exptitle '-DetectorComparison_CloseUps-'  int2str(Burst.S(find(Burst.T_end>x1,1)))];
        print('-dpdf',filename)
    end    
    

%% percentage of burst width with respect to ISIn width

ID = find( Burst.RS.ID); 
W  = mean( Burst.RS.T_end(ID)-Burst.RS.T_start(ID) )*1000; % [ms] width
W0 = mean( Burst.T_end(Burst.RS.ID(ID))-Burst.T_start(Burst.RS.ID(ID)) )*1000; % [ms] width
fprintf('RS  burst widths are %.1f%% of ISIn widths.\n',W/W0*100);


ID = find( Burst.FRH.ID); 
W  = mean( Burst.FRH.T_end(ID)-Burst.FRH.T_start(ID) )*1000; % [ms] width
W0 = mean( Burst.T_end(Burst.FRH.ID(ID))-Burst.T_start(Burst.FRH.ID(ID)) )*1000; % [ms] width
fprintf('FRH burst widths are %.1f%% of ISIn widths.\n',W/W0*100);


ID = find( Burst.ISI.ID); 
W  = mean( Burst.ISI.T_end(ID)-Burst.ISI.T_start(ID) )*1000; % [ms] width
W0 = mean( Burst.T_end(Burst.ISI.ID(ID))-Burst.T_start(Burst.ISI.ID(ID)) )*1000; % [ms] width
fprintf('ISI burst widths are %.1f%% of ISIn widths.\n',W/W0*100);



    
%%
%%       
%% Coin flipping
%  using 'discharge density' + logISIn methods to iteratively find 'optimal' thresholds for N and ISIn

                
% Sort spike times as not necessarily in order in spike file
GoodSpikes  = find(~Spike.tonic & Spike.H<-60 & Spike.clid);
[Sort.T IX] = sort(Spike.T(GoodSpikes) + rand(size(GoodSpikes))/20000 ); % Jitter by up to 1 sample to make curve smoother at high frequencies (minimizes bias due to discrete sampling)
 Sort.C     = Spike.C(GoodSpikes(IX));
                
                
%%
figure(4567)
clf
hold off



bin         = 0.15; % starting value from logISIn=10 method
% bin         = 1 / (length(GoodSpikes)/diff(Spike.T(GoodSpikes([1 end])))); % [sec] 1 / (average network FR)

[fr x]       = hist(Sort.T,ceil(diff(Sort.T([1 end])))/bin);
  
fr = fr(fr>0); % drop zero values


% Use increasing bin size such that uniform step sizes on a loglog plot
steps  = 10.^[log10(1):.05:log10(2000)];
%steps  = 1:2000;

[n x]       = histc( fr, steps); 

    if 1 %SMOOTH
        n = smooth(n,'lowess');    
    end
    clr = 'k';
    width = 1;
%      loglog(steps,n/sum(n),'-','color',clr,'linewidth',width)
    plot(steps,n/sum(n),'-o','color',clr,'linewidth',width)
    set(gca,'yscale','log')
    set(gca,'xscale','log')
    xlabel 'N [spikes]'
    ylabel 'Probability [%]'
    title(bin)
    










