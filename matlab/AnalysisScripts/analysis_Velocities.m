%%%%% analysis_Velocities.m
%   Douglas Bakkum 02/2013
%   Calculate velocities and statistics.
%
%   Use AxonDistances.m to get Boot.DistanceDist to incorporate errors due 
%   to not knowing axon length.

%% Load saved data

 %  filename = ['mat/130111-967-E2-Boot-Peak.mat'];                 load(filename)
 %  filename = ['mat/130111-967-E1-Boot-Peak.mat'];                 load(filename)
 %  filename = ['mat/090409-D-Boot-Peak.mat'];                      load(filename)
 %  filename = ['mat/090409-C-Boot-Peak.mat'];                      load(filename)
 %  filename = ['mat/120919-100mv-Boot-Peak-EAST2.mat'];  SOUTH=0;  load(filename)
 %  filename = ['mat/120919-100mv-Boot-Peak-SOUTH2.mat']; SOUTH=1;  load(filename)
 %  filename = ['mat/' Info.Exptitle '-Boot-Peak.mat'];             load(filename)

 
 !!!!!!!   for expts w/o images, RUN AxonDistances.m TO GET Boot.DistanceDist field   !!!!!!!!
 
 
 
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%% Velocity plot using linear regression 

bin     = .3;%.32;                  % [mm] bin window for linear regression to get velocity
step    = 17.8/1000;            % [mm] step size  for linear regression to get velocity

speedup = 1;                    % speed up factor, reduces number of bootstrap trials to use


%rng     = find(~isnan(Time));
rng     = 1:size(Boot.Time,1);

D       = Boot.Dist(rng);
if isfield(Boot,'DistanceDist')   % Get this from AxonDistances.m based on RFP axon curvatures (incorporates error due to not knowing true distances)
    DD      = Boot.DistanceDist(rng,:);
    disp 'Using Boot.DistanceDist to estimate distance measurement variability'
end
T       = Boot.Time(rng,:);
E       = Boot.Elc(rng);
[X Y]   = el2position(E);

ending  = max(D)/1000-step*2;
ending  = max(D)/1000-bin/2;
start   = min(D)/1000;


clear Velocity

cnt     = 0;
for i=start:step:ending
    clear t d x p S f delta f2     
    cnt = cnt+1;    
    fprintf('%i/%i\n',cnt,length(0:step:ending));
            
    % Do linear regression
    
    for j=1:size(T,2) / speedup
        
            if isfield(Boot,'DistanceDist')
                rng             = find( DD(:,j)/1000 >= i  &  DD(:,j)/1000 < i+bin );
                d               = DD(rng,j)';          % [um]
            else                
                rng             = find( D/1000 >= i  &  D/1000 < i+bin );
                d               = D(rng);          % [um]   
            end
            t               = T(rng,j)'/20;        % [ms]   
            
            x               = min(t):.01:max(t);   % [ms]
            [p S]           = polyfit(t,d,1);
            [f delta]       = polyval(p,x,S);
            f2              = polyval(p,t,S);      % refit as need same dim as d for corrcoef
            r2              = corrcoef(d,f2);      % get R^2 values --> pretty good :)
            if S.df==0, fprintf(' ERROR!  \n  DOF = 0, may need larger bin or\n  more data points along axon.\n\n'), beep, return, end

            Velocity.Stat.r_sq(cnt,j)     = r2(1,2);
            Velocity.Stat.vel(cnt,j)      = p(1)/1000; % [m/s]    
    end    
            Velocity.Stat.time(cnt)       = median(x); % [ms] time at bin center from start
            Velocity.Stat.dist(cnt)       = i+bin/2;   % [um] axial distance at bin center from start
            Velocity.Stat.count(cnt)      = length(rng);
       
       
    vel_m  = mean(Velocity.Stat.vel(cnt,:));
    vel_sd = std(Velocity.Stat.vel(cnt,:));
    if i==0
        Velocity.Peak.mean(rng)          = vel_m;    
        Velocity.Peak.sd(rng)            = vel_sd;    
    elseif  i>ending-step
        Velocity.Peak.mean(rng(end))     = vel_m;    
        Velocity.Peak.sd(rng(end))       = vel_sd;    
    else
        Velocity.Peak.mean(rng(2:end-1)) = vel_m; 
        Velocity.Peak.sd(rng(2:end-1))   = vel_sd; 
        %Velocity.Peak.clr([-1:1]+ceil(median(rng)))    = Velocity.Stat.vel(cnt);    
    end
    
    
end

%% (cont) Plot velocities (mean ± s.d.)


figure
V  = Velocity.Stat.vel;
Vm = mean(Velocity.Stat.vel');
Vs = std(Velocity.Stat.vel');
d  = Velocity.Stat.dist;

% errorbar(d,Vm,Vs,'.')
    
ci_l = Vm-Vs;
ci_u = Vm+Vs;
m    = Vm;

    if strcmp(Info.Exptitle,'090409-D') 
        clr = [1 0 0];
    elseif strcmp(Info.Exptitle,'090409-C')
        clr = [0 0 0];
    elseif strcmp(Info.Exptitle,'120919-100mv')
        if SOUTH,  clr = [0 0 1]; else
                   clr = [0 0 0]; end
    else
        clr = [1 0 1]*0;
    end
    
%     fill([d d(end:-1:1)],[ci_l ci_u(end:-1:1)],clr,'edgecolor',clr); 
    % Horizontal plot
    plot(d,m,'.','color',clr,'markersize',8*.667)
    for i = 1:length(d)
        line([0 0]+d(i),[ci_l(i) ci_u(i)],'color',clr,'linewidth',.5)
    end


            title(Info.Exptitle)
            if strcmp(Info.Exptitle,'090409-D') || strcmp(Info.Exptitle,'090409-C')
                axis([0 1.5 0.4 1.2])
                figure_size(12*.667,4*.667,'linewidth',1)
                
            elseif strcmp(Info.Exptitle,'120919-100mv')
                axis([0 2.75 0.2 1.8])
                figure_size(18*.667,10*.667,'linewidth',1)
                
            end
            xlabel 'Axial distance [mm]'
            ylabel 'Velocity [m/s]'
            if 1 
                 title ''
                 box off
                 figure_fontsize(9,'bold')
                 filename = ['/home/bakkumd/Desktop/' Info.Exptitle 'Velocity-stickSOUTH'];
                 filename = ['/home/bakkumd/Desktop/' Info.Exptitle 'Velocity-stick'];
                 print('-dpdf',filename)
            end
    
            
            
            
%% (cont) Scatter plot
            
figure
clr_scale = 1;
rng     = 1:size(Boot.Time,1);
scatter(X(rng),Y(rng),40,Velocity.Peak.mean(rng)*clr_scale,'filled')
    axis ij equal
    set(gca,'Color',[1 1 1]*.5)
    title([Info.Exptitle ' ' Info.Exptype ' velocity [m/s]'])
    xlabel '[um]'
    ylabel '[um]'    
    box off
    line([0 100]+1800,[0 0]+2120,'color','k','linewidth',4) % scale bar - 100 um
    
    figure_size(12,12)
    figure_fontsize(8,'bold')
    
    
    if strcmp(Info.Exptitle,'090409-D') || strcmp(Info.Exptitle,'090409-C')
        caxis([.5 1.1])
    elseif strcmp(Info.Exptitle,'120919-100mv')
        caxis([.2 1.8])
    else
        colorbar
    end
    
    if 0
         axis off
         filename = ['/home/bakkumd/Desktop/' Info.Exptitle 'East-VelocityXYtmp'];
         print('-dpdf','-r250',filename)
    end
    

   
%% (cont) Get p-values (red is not significant)
clear p_value
for i=1:size(V,1)
    for j=i:size(V,1)
        p_value(i,j) = ranksum(V(i,:),V(j,:)); % ranksum = Mann-Whitney U-test
    end
end

figure
imagesc(p_value)
colorbar
caxis([0 .01])



    
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%% Velocity plots (without linear regression)

%rng     = find(~isnan(Time));
rng     = 1:size(Boot.Time,1);
D       = Boot.Dist(rng);
T       = Boot.Time(rng,:);
E       = Boot.Elc(rng);
[X Y]   = el2position(E);
V       = zeros(size(T));
step    = 4;



figure
hold on
if strcmp(Info.Exptitle,'130111-967-E2')
    axis([0 1 -20 1066])
elseif strcmp(Info.Exptitle,'130111-967-E1')
    T = -T;
    set(gca,'ylim',[-20 1066])
    set(gca,'xtick',[0 .5 1])
end

            
for i=step:length(D);
    V(i-round(step/2),:) = (D(i)-D(i-step+1))/1000./(T(i,:)-T(i-step+1,:)+.01)*20;
end

Vm = mean(V');
Vs = std(V');

T_boot = mean(T');
V_boot = zeros(size(T_boot));
V_boot(1:end-step+1) = (D(step:end)-D(1:end-step+1))./(T_boot(step:end)-T_boot(1:end-step+1))/1000*20;


rng = round(step/2):length(Vm)-round(step/2);%find(E==3283); % up to soma?
ci_l = Vm(rng)-Vs(rng);
ci_u = Vm(rng)+Vs(rng);
m    = Vm(rng);
d    = D(rng);

clr = 'k';
%fill([ci_l ci_u(end:-1:1)],[d d(end:-1:1)],clr,'edgecolor',clr); 
%errorbar(D,Vm,Vs,'.')

if 1
    % Vertical plot
    plot(m,d,'.','color',clr,'markersize',10)
    for i = 1:length(d)
        line([ci_l(i) ci_u(i)],[0 0]+d(i),'color',clr,'linewidth',1)
    end
    figure_size(4,12,'linewidth',1)
    ylabel 'Distance [um]'
    xlabel 'Velocity [m/s]'
else
    % Horizontal plot
    plot(d,m,'.','color',clr,'markersize',10)
    for i = 1:length(d)
        line([0 0]+d(i),[ci_l(i) ci_u(i)],'color',clr,'linewidth',1)
    end
    figure_size(16,6,'linewidth',1)
    xlabel 'Distance [um]'
    ylabel 'Velocity [m/s]'
end


            title(Info.Exptitle)
            figure_fontsize(9,'bold')
            title ''
            if 0
                 set(gca,'ytick',[],'ycolor',[1 1 1]*.999)
                 ylabel ''
                 filename = ['/home/bakkumd/Desktop/' Info.Exptitle '-Velocity'];
                 print('-dpdf',filename)
            end
            
%% (cont) Scatter plot

figure
clr_scale = 1;
rng     = 1:size(Boot.Time,1);
scatter(X(rng),Y(rng),60,Vm(rng)*clr_scale,'filled')
    axis ij equal
    set(gca,'Color',[1 1 1]*.5)
    colorbar
    title([Info.Exptitle ' ' Info.Exptype ' velocity [m/s]'])
    xlabel '[um]'
    ylabel '[um]'    
    box off
    line([0 100]+1800,[0 0]+2120,'color','k','linewidth',4) % scale bar - 100 um
    caxis([.2 1.8])
    
%     if 0
%         Info.Stat.V         = V;
%         Info.Stat.Parameter = P;
%         filename            = ['mat/' Info.Exptitle '_Stat.mat'];
%         save(filename,'Info')
%     end


%% (cont) Get p-values  (red is not significant)
clear p_value
for i=1:size(V,1)
    for j=i:size(V,1)
        p_value(i,j) = ranksum(V(i,:),V(j,:)); % ranksum = Mann-Whitney U-test
    end
end

figure
imagesc(p_value)
colorbar
caxis([0 .01])



%%
%%
%%
%%
%%
%%
