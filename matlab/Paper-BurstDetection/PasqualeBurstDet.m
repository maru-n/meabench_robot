%% Pasquale [2010] Burst Detector
%  made from psuedo code in Suppl. Material in the paper
%
%  Use data from 121227-F for detector comparison (47007 to 47037 seconds)
%


% Use increasing bin size such that uniform step sizes on a loglog plot
steps  = 10.^[log10(.01):.1:log10(20000)];

FRnum = 2;  % ISI
            % for FRnum=5, need to adjust fixed parameters below (i.e. 100ms max, etc.)


% Sort spike times as not necessarily in order in spike file
 GoodSpikes = find(~Spike.tonic & Spike.H<-60 & Spike.clid);                   % Use only non-tonically firing channels
 clear Sort
[Sort.T IX] = sort(Spike.T(GoodSpikes) + rand(size(GoodSpikes))/20000 ); % Jitter by up to 1 sample to make curve smoother at high frequencies (minimizes bias due to discrete sampling)
 Sort.C     = Spike.C(GoodSpikes(IX));


clr = 'k';

figure(1000)
clf

ISIth  = zeros(1,126)*NaN;
N_spks = zeros(1,126)*NaN;

for c=0:125
    cc = find(Sort.C==c);
    if isempty(cc),   continue, end
    if length(cc)<20, continue, end
    N_spks(c+1) = length(cc);
    
  
    dt         = Sort.T(cc(FRnum:end))-Sort.T(cc(1:end-FRnum+1));    
    [n x]      = histc( dt*1000, steps); 
    n          = smooth(n,'lowess');    
    [pks locs] = findpeaks(n,'minpeakdistance',4);
    pks_ms     = steps(locs);
    
        xx  = find(pks_ms<100);
        if isempty(xx)
            continue
        end
        
        xx  = find(pks_ms<steps(end));
        if length(xx)==1
            continue
        end
        
        xx  = find(pks_ms<100);
        
        [peak_max id] = max( pks(xx) );
        
              
        cla
        hold on
        semilogx(steps,n,'-','color',clr,'linewidth',1)
        figure_size(8,8)
        set(gca,'xscale','log')
        
        plot(steps(locs(id)),peak_max,'o')
        
        %[peak_max2 id2] = max(pks(id+1:end));
        id2 = length(locs)-id;
        peak_max2 = pks(end);
        plot(steps(locs(id2+id)),peak_max2,'rs')
%         void = []; % 'void parameter' doesnt seem to work so good....
%         for i=id+1:length(locs)
%             void = [void   1 - min(n([locs(id):locs(i)])) / (peak_max*pks(i))^.5];
%             plot(steps([locs(i-1):locs(i)]),n([locs(i-1):locs(i)]),'color',[rand rand rand])
%         end
%         max(void)

       [a b] = min(n([locs(id):locs(id+id2)]));
       plot(steps(b+locs(id)-1),a,'o')
       ISIth(c+1) = steps(b+locs(id)-1);

        title(c)
        pause%(.4)
end



%%
% 
% % ISIth from the logISIH of a single recording channel. 
%     xx → bins of the current logISIH
%     yy → logISIH
%     %  Smooth yy by operating a local regression using weighted linear least squares and a 1st degree polynomial model 
%     %  (e.g. using smooth function in MATLAB Curve Fitting Toolbox, method ‘lowess’)
%     Identify local maxima in the logISIH (e.g. using findpeaks function in MATLAB Signal Processing Toolbox, parameter ‘minpeakdistance’ set at 2)
%     if there is at least one peak
%         Look for peaks within 10^2 ms
%         If there is more than one peak within 10^2 ms
%             Consider the biggest one and save the first peak's x- and y-coordinates
%         else if there is no peak identified below 10^2 ms 
%                 return; // the channel is not analyzed
%             end
%         end
%         if there is only one peak
%             return; // no ISIth can be determined if there is only one peak
%         else	// there is more than one peak
%             for each pair of peaks constituted by the first and one of the following
%                 Compute the void parameter: the void parameter is a measure of the degree of separation between the two peaks through the minimum
%             end
%             Look for local minima whose void parameter satisfies a threshold (e.g. 0.7)
%             if there is no minimum that satisfies the threshold
%                 return;	// no ISIth can be determined 
%             else
%                 Save the corresponding ISI value as ISIth
%             end
%         end
%         
%%

minNumSpikes = 5;

clear burstTrain


% Order channels by FR for plot
N = zeros(1,126); 
for c = 0:125
   N(c+1) = length(find(Sort.C==c));
end
[b cc] = sort(N);
for c = 1:126
   C(c) = find(cc==c);
end


% 
% A pseudo-code illustrates here the proposed algorithm for burst detection (newBD algorithm) provided in the associated paper. 
%     Compute ISIth from the logISIH of this channel (see above)
%     Fix a minimum number of spikes per burst: minNumSpikes
%     Load the timestamps (sample number) of each spike in the train in an array: timestamp
%     if ISIth > 100 ms
%         maxISI1 = 100 ms;
%         maxISI2 = ISIth;
%         extendFlag = 1;
%     else 
%         maxISI1 = ISIth; 
%         extendFlag = 0;
%     end

maxISI1=nan(size(ISIth));
maxISI2=nan(size(ISIth));
extendFlag=nan(size(ISIth));

xx = find(ISIth<=100);
    maxISI1(xx)    = ISIth(xx);
    maxISI2(xx)    = NaN;
    extendFlag(xx) =  0;
    
xx = find(ISIth>100);
if ~isempty(xx)
    maxISI1(xx)    = 100;
    maxISI2(xx)    = ISIth(xx);
    extendFlag(xx) =  1;
end


%     Detect the edges of burst cores using maxISI1: identify time intervals in which ISIs < maxISI1


    
    figure(1001)
    clf
    hold on
    
for c=0:125
    if isnan(maxISI1(c+1)), continue, end
    cc = find(Sort.C==c);   

        % Parameters
    P.FRnum         = FRnum;           
    P.FRbin         = maxISI1(c+1)/1000;
    P.Gap           = P.FRbin ;
    P.GoodSpikes    = cc;    
  
    [B S]  = BurstDetect(Sort,P);  
    
    
%     if there is at least one burst core
%         Compute the numSpikesInBurst for each burst
%         Identify the validBursts	//bursts whose number of spikes is higher than minNumSpikes
%         if there is at least one valid burst core      

    xx = find(B.S>=minNumSpikes);
    if isempty(xx), continue, end
        
    B.S       = B.S(xx);
    B.T_end   = B.T_end(xx);
    B.T_start = B.T_start(xx);

    
    tmp = [];
    for i=1:length(B.T_end)
        tmp = [tmp B.T_start(i) B.T_end(i) NaN];
    end
    plot(tmp,C(1+c*ones(size(tmp))),'color', [0 1 0]/1.2,'linewidth',2)
    %plot(B.T_start,C(1+c),'bo')
    
    
    
    
%             if extendFlag		//case1: ISIth > 100 ms
%                 if two burst cores are separated by less than maxISI2, they are joined end
%                 Detect the edges of burst boundaries using maxISI2: identify time intervals in which ISIs < maxISI2
%                  Build a matrix allEdgeSort (size: [n x 3], n = number of edges) containing all edges obtained with two different thresholds (i.e. maxISI1 & maxISI2) sorted in temporal order
% allEdgeSort = [	timestamp	type of edge	threshold used
%                	        ...            	...             	...    	             ]    
% where:    	timestamp: timestamp of edge
% 		type of edge: 1 rising, -1 falling
% 		threshold used: 1 maxISI1, 2 maxISI2
%                 Identify burstBegin as rising edges of maxISI2 burst train	//first spikes of bursts
%                 for ii = 1:length(burstBegin)   // for each element of burstBegin, i.e. for each putative burst
%                     if the following edge is a falling edge of maxISI2 train
%                         continue;	// no burst is detected
%                     else
%                         Look for next falling edge of maxISI2 train and save it in thisBurstEnd
%                         Look for rising/falling edge pair of maxISI1 train inside the window [burstBegin(ii),thisBurstEnd]
%                         if there's more than one burst core inside current window
%                              Split the putative burst into sub-bursts according to the maxISI1 train: each burst core should correspond to a separate burst
%                              Save in burstTrain the features of each sub-burst
%                         else
%                             Save in burstTrain the features of current burst
%                         end
%                     end
%                 end


    [     ];
    [     ];  % ignore case one for now
    [     ];


%             else	//case2: ISIth < 100 ms
%                  Save in burstTrain the features of detected bursts

    burstTrain{c+1} = B;
    title(c)


%             end
%         else	// there is no valid burst, i.e. no burst core is composed of more than minNumSpikes
%             burstTrain = [];
%         end
%     else	// there is no burst core
%         burstTrain = [];
%     end


   %pause(.4)
end

    Burst.ISI.burstTrain = burstTrain;


%         set(gca,'xlim',[x1 x2])
%         set(gca,'xtick',[x1:5:x2],'xtickLabel',[0:5:(x2-x1)])
        set(gca,'ylim',[0 130])
        set(gca,'ytick',[0:20:120],'yticklabel',[0:20:120])   
        xlabel 'Time [sec]'
        ylabel 'Channel'
        box on
        
        figure_size(16,6)
        figure_fontsize(8,'bold')
        filename = ['/home/bakkumd/Desktop/' Info.Exptitle '-DetectorComparison_logISI'];
        title ''
%         print('-dpdf','-r250',filename)



%% Plot burstTrain info


clear SB
burstTrainSorted.T       = [];
burstTrainSorted.T_start = [];
burstTrainSorted.T_end   = [];
burstTrainSorted.C       = [];
for c=1:length(burstTrain)
    if isempty(burstTrain{c}), continue, end
%     burstTrainSorted.T_start = [burstTrainSorted.T  burstTrain{c}.T_start ];
%     burstTrainSorted.T_end   = [burstTrainSorted.T  burstTrain{c}.T_end   ];
%     burstTrainSorted.T       = [burstTrainSorted.T (burstTrain{c}.T_start+burstTrain{c}.T_end)/2 ];
%     burstTrainSorted.C       = [burstTrainSorted.C ones(size(burstTrain{c}.S))*(c-1) ];
    burstTrainSorted.T       = [burstTrainSorted.T burstTrain{c}.T_start burstTrain{c}.T_end ]; % hack such that get correct endings in plots... may affect detection though...
    burstTrainSorted.C       = [burstTrainSorted.C ones(1,2*length(burstTrain{c}.S))*(c-1) ];
end
    
% Sort by time

    % Sort spike times as not necessarily in order in spike file
    [burstTrainSorted.T IX]   = sort(burstTrainSorted.T); % Jitter by up to 1 sample to make curve smoother at high frequencies (minimizes bias due to discrete sampling)
     burstTrainSorted.C       = burstTrainSorted.C(IX);
     %burstTrainSorted.T_start = burstTrainSorted.T_start(IX);
     %burstTrainSorted.T_end   = burstTrainSorted.T_end(IX);
     
    


%%
% Repeat above ISI method for burstTrain

    dt    = diff(burstTrainSorted.T); 
    [n x] = histc( dt*1000, steps); 
    
    %n(n==0) = 1; % fix for loglog plotting
    n = smooth(n,'lowess');    
    [pks locs] = findpeaks(n,'minpeakdistance',4);
    pks_ms     = steps(locs);
    xx         = find(pks_ms<100);
    
        [peak_max id] = max( pks(xx) );
        
              
        figure
        cla
        hold on
        semilogx(steps,n,'-','color',clr,'linewidth',1)
        figure_size(8,8)
        set(gca,'xscale','log')
        
        plot(steps(locs(id)),peak_max,'o')
        
        %[peak_max2 id2] = max(pks(id+1:end));
        id2 = length(locs)-id;
        peak_max2 = pks(end);
        plot(steps(locs(id2+id)),peak_max2,'rs')
%         void = []; % 'void parameter' doesnt seem to work so good....
%         for i=id+1:length(locs)
%             void = [void   1 - min(n([locs(id):locs(i)])) / (peak_max*pks(i))^.5];
%             plot(steps([locs(i-1):locs(i)]),n([locs(i-1):locs(i)]),'color',[rand rand rand])
%         end
%         max(void)

       [a b] = min(n([locs(id):locs(id+id2)]));
       plot(steps(b+locs(id)-1),a,'o')
       B_ISIth = steps(b+locs(id)-1);


%% Now detect network burst (burst of burst events) as above

    minNumElc = 10;    % Post hoc condition of minNumChan in a burst

        % Parameters
    P.FRnum         = 2;           
    P.FRbin         = B_ISIth/1000;
    P.Gap           = P.FRbin ;
    P.GoodSpikes    = 1:length(burstTrainSorted.T);
  
    [Burst_ISI S]  = BurstDetect(burstTrainSorted,P);  
    
    xx = find(Burst_ISI.C>=minNumElc);
    Burst.ISI.C        = [];    Burst.ISI.C        = Burst_ISI.C(xx);
    Burst.ISI.S        = [];    Burst.ISI.S        = Burst_ISI.S(xx);
    Burst.ISI.T_start  = [];    Burst.ISI.T_start  = Burst_ISI.T_start(xx);
    Burst.ISI.T_end    = [];    Burst.ISI.T_end    = Burst_ISI.T_end(xx);
    
    Burst.ISI.T_median = zeros(size(Burst.ISI.T_end)); % use to see if correlates to a burst from logISIn method


    figure(1002)
    clf
    hold on
    
    
    yy = xx(find(Burst.ISI.S>=10));
    tmp = [];
    cnt=0;
    for i=yy
        cnt=cnt+1;
        xx  = find(S.Burst_N==i);
        Burst.ISI.T_median(cnt) = median(S.T(xx));
        tmp = [tmp min(burstTrainSorted.T(xx)) max(burstTrainSorted.T(xx)) NaN];
    end
    plot(tmp,134*ones(size(tmp)),'color', [0 1 0]/1.2,'linewidth',2)
    plot(Burst.ISI.T_median,134*ones(size(Burst.ISI.T_median)),'o','color', [0 1 0]*0)
    
    % logISIn detection
    xx = find(Burst.T_end<max(Spike.T));
    tmp = [];
    for i=xx
        tmp = [tmp Burst.T_start(i) Burst.T_end(i) NaN];
    end
    plot(tmp,138*ones(size(tmp)),'r','linewidth',2)
    


        %plot(Spike.T(Parameter.GoodSpikes),C(1+Spike.C(Parameter.GoodSpikes)),'k.','markersize',2)

        if strcmp(Info.Exptitle,'121227-F')
            x1 = 47007;
            x2 = x1+30;
            set(gca,'xtick',[x1:5:x2],'xtickLabel',[0:5:(x2-x1)])
        else
            x1 = min(Spike.T);
            x2 = max(Spike.T);
        end
        set(gca,'xlim',[x1 x2])
        
        
        set(gca,'ytick',[0:20:120],'yticklabel',[0:20:120])   
        xlabel 'Time [sec]'
        ylabel 'Channel'
        
        figure_size(16,6)
        figure_fontsize(8,'bold')
        filename = ['/home/bakkumd/Desktop/' Info.Exptitle '-DetectorComparison_all'];
%         print('-dpdf','-r250',filename)

    
    
% %% How many of these bursts are same / different than logISIn detector?    
    
    
    Burst.ISI.ID = zeros(size(Burst.ISI.T_end));
    for i=1:length(Burst.T_end)
        xx = find(  (Burst.ISI.T_median >= Burst.T_start(i)  &  Burst.ISI.T_median <= Burst.T_end(i)) );
%         xx = find(  (Burst.ISI.T_start >= Burst.T_start(i)  &  Burst.ISI.T_start <= Burst.T_end(i)) | ...
%                     (Burst.ISI.T_end   >= Burst.T_start(i)  &  Burst.ISI.T_end   <= Burst.T_end(i)) );
        if ~isempty(xx)
            
            if length(xx)>1
                xx
                pause
            end
            
            Burst.ISI.ID(xx) = i; % burst number
        end
    end
            
    fprintf('  %.1f %% ISIn bursts also detected by ISI\n',100 * length(unique(Burst.ISI.ID(Burst.ISI.ID>0))) / length(Burst.T_start))
    
    
    
    
    
    
    
    
    
    
    
