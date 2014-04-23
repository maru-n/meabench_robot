%%   Estimate the error in using straightline-distances between electrodes
%    instead of knowing the true distance of an axonal pathway.
%
%    Douglas Bakkum, 02.2012
%
%    Given Boot.Dist from analysis_Latencies.m, can calculate Boot.DistanceDist
%    for use in analysis_Velocities.m for error bars and statistics.
%
%




% %% Calculate curvature of axons from imagefiles by clicking on plots
% % 
% %  Load image
% 
% figure
% axes('position',[0 0 1 1])
% figure_size(16,16)
% 
% dir = '/home/bakkumd/130207-lipofection/images/transformed/';
% fn  = '130209-1148-wide-2_ch00_silhouette_transformed';
% fn  = '130209-1148-wide-1_ch00_silhouette_transformed';
% 
% dir = '/home/bakkumd/130107-lipofection/images/transformed/';
% fn  = '130111-967-E-combined-silhouette_transformed';
% fn  = '130110-967-D-combined-axon_transformed';
% fn  = '130109-801-wide-1_ch00_silhouette_transformed';
% 
% im = imread([dir fn '.jpg']);
% imagesc(im)
% axis ij equal fill
% colormap gray
% 
% %% (cont)   Get positions
% position = clickposition('c');
% 
% %% (cont)   Save to .mat file
% %
% %    filename = ['mat/' fn '-positions.mat'];
% %    save(filename, 'position','im')

%% (cont)   Make plots
clear filename Position rng
%r=rng(round(rem(now,1)*1000000))
%r=rng(680946);

cnt = 0;
cnt=cnt+1;    filename{cnt}  = '130111-967-E-combined-silhouette_transformed-positions';    
cnt=cnt+1;    filename{cnt}  = '130110-967-D-combined-axon_transformed-positions';
cnt=cnt+1;    filename{cnt}  = '130209-1148-wide-2_ch00_silhouette_transformed-positions1';
cnt=cnt+1;    filename{cnt}  = '130209-1148-wide-2_ch00_silhouette_transformed-positions2';
cnt=cnt+1;    filename{cnt}  = '130209-1148-wide-1_ch00_silhouette_transformed-positions1';
cnt=cnt+1;    filename{cnt}  = '130209-1148-wide-1_ch00_silhouette_transformed-positions2';
cnt=cnt+1;    filename{cnt}  = '130109-801-wide-1_ch00_silhouette_transformed-positions';

map = colorcube(7*7);
    
figure(199); clf; hold on
figure(198); clf; hold on
    [x y] = el2position(0:11015);   
    x = x(x>0);
    y = y(y>0);
    line([max(x) max(x) min(x) min(x) max(x)],[max(y) min(y) min(y) max(y) max(y)],'color','k','linewidth',1.5)
    
Dist_straightline = [];
Dist_actual       = [];    
Dist_total        = 0;
Total_points      = [];   
cnt  = 0;    
for fn = 1:length(filename)
    load(filename{fn})

    position.dist(1)  = 0;
    for i = 1:length(position.x)-1
        position.dist(i+1)  =  (   diff(position.x([0 1]+i))^2  +  diff(position.y([0 1]+i))^2    )^.5;
    end

    clear Dist_straightline_ Dist_actual_
    for i=1:length(position.x)
        for j=i+1:length(position.x)
            cnt = cnt+1;        
            Dist_straightline_(cnt) = (   diff(position.x([i j]))^2  +  diff(position.y([i j]))^2    )^.5;
            Dist_actual_(cnt)       =     sum(position.dist(i:j));

        end
    end
    Dist_straightline = [Dist_straightline Dist_straightline_];
    Dist_actual       = [Dist_actual Dist_actual_]; 
    Dist_total        = Dist_total + sum(position.dist);
    Total_points      = [Total_points length(position.x)];

    clr = map(fn*3,:);%[rand rand/1.2 rand/1.2];


    figure(198)
    plot(position.x,position.y,'color',clr)
    axis equal ij

    figure(199)
    plot(Dist_straightline_, Dist_actual_ - Dist_straightline_,'.','markersize',1,'color',clr)
    %line([0 min([max(Dist_actual) max(Dist_straightline)])],[0 min([max(Dist_actual) max(Dist_straightline)])])
    %axis equal
    title(filename{fn})
    xlabel 'Dist straightline'
    ylabel 'Error'

    pause(.1)

end

fprintf('Total %f [mm] from %i cells.\n',Dist_total/1000,fn)


figure(198)
    line([0  200]+300, [0 0]+2200,'color','k','linewidth',2) % [400 uV] scale bar+
    axis off
    figure_size(8,8)
    if 0
        filename = ['/home/bakkumd/Desktop/Lipofection-DistanceAxonLocations'];
        print('-dpdf','-r250',filename)
    end


% %% (cont)  Make plots

Error = Dist_actual - Dist_straightline;

step     =  2; % [um]
bin      = 10; % [um]
plotstep = 20; % [um] ci bar spacing

clear Distr
cnt = 0;
for i=0:step:max(Dist_straightline)
    cnt = cnt+1;
    tmp = find(Dist_straightline>i & Dist_straightline<=i+bin);
    Distr.mean(cnt)       = mean(Error(tmp));
    Distr.sd(cnt)         = std(Error(tmp));
    Distr.dist(cnt)       = i+bin/2;
    gamma                 = gamfit(Error(tmp));
    Distr.gamma(cnt,:)    = gamma;
end


figure(199)
%errorbar(Distr.dist,Distr.mean,Distr.sd)

    % Horizontal plot
    ci_u = Distr.mean+Distr.sd;
    ci_l = Distr.mean-Distr.sd;
    st   = [1:plotstep/step:length(Distr.dist)];
    clr = 'k';
    plot(Distr.dist,Distr.mean,'-','color',clr,'linewidth',2)
    


    title ''
    xlabel 'Straightline distance [um]'
    ylabel 'Error = (Straightline distance - True distance) [um]'
    figure_size(12,8,'linewidth',1)
    figure_fontsize(9,'bold')
    if 0
        plot(Distr.dist,ci_u,'-','color',clr,'linewidth',1)
        plot(Distr.dist,ci_l,'-','color',clr,'linewidth',1)

        for i = st
            line([0 0]+Distr.dist(i),[ci_l(i) ci_u(i)],'color',clr,'linewidth',1)
        end
        plot(Distr.dist(st),Distr.mean(st),'.','color',clr,'markersize',10)

        set(gca,'xlim',[0 300],'ylim',[0 450])
        filename = ['/home/bakkumd/Desktop/Lipofections-Distr'];
        %print('-dpng','-r300',filename)
        print('-dpdf',filename)
    end

    
    
%% (cont)  Make distribution of Boot.Dist using Distr

Boot.DistanceDist = zeros(size(Boot.Time));

dist  = [0 diff(Boot.Dist)];
    
clear rng; rng('shuffle');

for i=2:length(Boot.Dist)
    [junk id] = min(abs(dist(i)-Distr.dist));

    
    % assuming gaussian distribution
    Boot.DistanceDist(i,:) = Boot.Dist(i) + normrnd(Distr.mean(id),Distr.sd(id),1,size(Boot.Time,2));

    % assuming gamma distribution -- gives same results as gaussian ...
    %Boot.DistanceDist(i,:) = Boot.Dist(i) + gamrnd(Distr.gamma(id,1),Distr.gamma(id,2),1,size(Boot.Time,2));



end









% %% testing distribution types
% 
% bin = 20;
% i   = 10;
% tmp = find(Dist_straightline>i & Dist_straightline<=i+bin);
% figure(99876)
% hist(Error(tmp),100)
% xlim = get(gca,'xlim');
% 
% name = 'rician';
% fitd = fitdist(Error(tmp)',name);
% if length(fitd.Params)==1
%     y = random(name,fitd.Params,1,50000);
% elseif length(fitd.Params)==2
%     y = random(name,fitd.Params(1),fitd.Params(2),1,1000);
% else
%     y = 0
% end
% 
% figure
% hist(y,100);
% set(gca,'xlim',xlim);


















