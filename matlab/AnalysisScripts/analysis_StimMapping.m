% > > > > > > > > > > >> >> >>> >> >>>> >>> >>>>>> >>>>>>> >>>>>>>> >>>>> %
%%  analysis_StimMapping.m 
%      Douglas Bakkum 
%      2009-2012
%
%   EXPERIMENT INFO IS AT THE BOTTOM OF THE PAGE
%   (so can more quickly navigate scripts)
%
%%% %% %% %% %% %% %% %% %% %% %% %% %%  %%   %%     %%    %%   %%  %  % %
%% Start of script
%  Stimulation mapping of neurons  
%
%

%%



!!!! if loaded .mat file, skip below


!!!! need to change .mat file storage into Info Spike notation if not done already



%% Load trig Info.Map files
  
 load global_cmos

 % Load Trig
 Info.Trig=loadtrigfile(Info.FileName.Trig);
 
 % Load Map
 Info.Map=loadmapfile(Info.FileName.Map,1111); % load Info.FileName.Map and plot elc locations in figure 1111
        % test how many somas get assigned
        num=size(Info.Map.ch,1)/NCHAN;
        fprintf(' \n\n');
        if exist('soma','var')
        for sm=soma.el
            fprintf('  %i :: %i/%i\n',sm,length(find(Info.Map.el==sm)),num);
        end
        end
        fprintf('  %i/11016 (%.3f%%) electrodes placed\n',length(unique(Info.Map.el)-1),length(unique(Info.Map.el)-1)/11016*100);

        ax=axis; % get axis limits for whole array from figure plotted by loadmapfile.m
        
        


%%


%% format spikes   

    system(['rm ' Info.FileName.SpikeForm])
    %  High res DAC encoding (after March 2010)
    cmd=['`which FormatSpikeData` -a 127 -c -s '  Info.FileName.Spike ' -o ' Info.FileName.SpikeForm]
    %  Low res DAC encoding
    % cmd=['/home/bakkumd/Documents/Code/bin/FormatSpikeData -a 127 -c -L -s ' Info.FileName.Spike ' -o ' Info.FileName.SpikeForm ' -L'] % dAP(PTS) detection + low res DAC encoding
    system(cmd);


%% load formated spike data
% !! if rerun spikeform then need to double check dac_info encoding again !!
% !! FormatSpikeData height currently broken !!!  --> currently uses peak of spike context to set height...
% cd /home/bakkumd/bel.svn/cmosmea_external/meabench/trunk/matlab

spike=loadspikeform(Info.FileName.SpikeForm);
if isempty(spike.T), disp '    !! No spikes loaded !!', return; end     
     
dac_info = 127; % DAC2 - information channel (stim times & channel, epochs)
DI       = find(spike.C==dac_info);
% Info.Parameter.ConfigNumber   = 95;%108;
fprintf(1,'Found %i spikes.\n',length(spike.C));
fprintf(1,'Found %i stim markers on channel %i.\n',length(DI),dac_info);

 % (be sure to CHECK epoch was encoded correctly)
 figure(1112); set(gcf,'position',[ 1685 443 1870 421]);
 plot(spike.T(DI),spike.E(DI),'.')
  
 spike = spikeform_EpochFix(Info,spike);

 hold on;
 plot(spike.T(DI),spike.E(DI),'rs'); hold off % test the epoch fix
 title([Info.Exptitle ' ' Info.Exptype])


% %% fix for B......
% xx=find(spike.C==dac_info & spike.T>8000 & spike.T<13218);
% Etmp=zeros(size(xx));
% last1=0;
% last2=0;
% tmp=diff(spike.T(xx));
% eptmp=0;
% for i=1:tmp;
%     last2=last1;
%     last1=tmp(i);
%     if( last2>.09 & last2<.11 & last1>.15 & last1<.4 )
%         eptmp=eptmp+1;
%     end
%     Etmp(i)=eptmp;
% end


%% use Info.FileName.Map to get electrodes and probe_electrodes

%figure

 spike.ELC  = zeros(size(spike.E))-1; 
 spike.P_el = zeros(size(spike.E))-1; 

 %rng=spike.CLID; %% 
 rng=1:length(spike.E);
 for ee=0:Info.Parameter.ConfigNumber-1;%max(spike.E)
     disp(Info.Parameter.ConfigNumber-1-ee); pause(0.001);
     EE=find(spike.E(rng)==ee);
     %EE=find(spike.E(rng)==ee & spike.L(rng)<tconf*1000 & spike.H(rng)<0);
     xx=Info.Map.px([1:NCHAN]+ee*NCHAN);
     yy=Info.Map.py([1:NCHAN]+ee*NCHAN);
     c=Info.Map.ch([1:NCHAN]+ee*NCHAN);
     e=Info.Map.el([1:NCHAN]+ee*NCHAN);
     
     for cc=0:NCHAN-1
        CC=find(spike.C(rng(EE))==cc);
        ID=find(c==cc,1);
        if ~isempty(CC) && ~isempty(ID)
          if length(CC)>1 
            spike.ELC(rng(EE(CC)))=e(ID);
            %hold on
            %plot(xx(c(ID)+1),yy(c(ID)+1),'.');
          end
        end
        PP=find(spike.P_hw(rng(EE))==cc);
        if ~isempty(PP) && ~isempty(ID)
            spike.P_el(rng(EE(PP)))=e(ID);
        end
     end 
     %drawnow
 end

%%

!!!!! --------------------------

 save(Info.FileName.Mat,'Info','spike','soma')

!!!!!  skip to HERE if saved .mat



%% extract dAPs
%  for Info.Parameter.NumberStim=4, use ndap=3 and timing +/-1 sample (0.05ms)

load global_cmos

PRINT=0;

ndap        =    4;%Info.Parameter.NumberStim*.3;    %   min number of daps
bin         =   .15;%.5;%0.15; %   window (ms)
step        = 0.05;  %  1 sample
llat        =   .5;  %  lower lat limit (ms)
ulat        =   10;  %  upper lat limit (ms)
h_min       =  -50;  %  spikes < h_min
art_radius  =   25;  %  dont plot electrodes within artifact radius of soma electrode
clr_scale   =   10;  %  scale color values to get more resolution in overlay plots 

%figos= 0;    % figure numbering offset (in case want to not overwrite previous plots) offset=figno*10^figos

ssize=[0 10 20 20 20 40 70 100 100];  % scatter dot sizes for different reliability levels
ssize=[0 10 20 20 20 20 40  40  40];
ssize=[0  0  0  0 20 20 20  20  20];

% indices of soma electrodes into spike struct. used for finding history dependency of jitter 
HISTORY = 1;
hist_len = 0.5; % [sec] time to look before probe to calculate fr history
SM=[];
%figure
cnt=0;
for sm=soma.el
    cnt=cnt+1;
    xx=find(spike.ELC==sm & spike.L>1 & spike.L<500 & spike.clid & spike.H<0);
    SM=[SM xx];
    %plot(spike.T(xx), ones(size(xx))*cnt, '.'); hold on
    %pause
end



clear DAP
cnt=0;
for sm=soma.el
cnt=cnt+1;
fig=figure;
% figure(sm*10)
% caxis([0 10])
% end
DAP{cnt}.L = zeros(max(spike.ELC)+1,1); % latency
DAP{cnt}.N = zeros(max(spike.ELC)+1,1); % number (%)
DAP{cnt}.J = zeros(max(spike.ELC)+1,1); % jitter
DAP{cnt}.H = zeros(max(spike.ELC)+1,1); % height

DAP{cnt}.Hist    = zeros(max(spike.ELC)+1,1); % firing history before probe for sm
DAP{cnt}.HistAll = zeros(max(spike.ELC)+1,1); % firing history before probe for all soma.el

ss=find(spike.ELC==sm & spike.L<ulat & spike.L>llat & spike.H<h_min & spike.P_el>-1);
%ss=find(spike.ELC==sm & spike.L<ulat & spike.L>llat & spike.H>-400 & spike.H<-120 & spike.P_el>-1);
%ss=find(spike.ELC==sm & spike.L<ulat & spike.L>llat & spike.H<-400 & spike.P_el>-1);

for pe=unique(spike.P_el(spike.P_el>=0))
    %disp(pe); pause(0.001);
    ee=find(spike.P_el(ss)==pe);
    if ~isempty(ee)
 
        if length(unique(spike.E(ss(ee))))>1 % make sure from one epoch only -- may drop good daps though...
            fprintf('\tWarning! multiple epochs!  ')
            disp(spike.E(ss(ee)))
            continue;%return
        end
        for ll=llat:step:ulat-bin
            xx=find(spike.L(ss(ee))>=ll & spike.L(ss(ee))<=ll+bin);
            if length(xx)>=ndap             
%                 if length(unique(spike.E(ss(ee(xx)))))>1 % make sure from one epoch only -- may drop good daps though...
%                     fprintf('\tWarning! multiple epochs!  ')
%                     disp(spike.E(ss(ee(xx))))
%                     %return
%                 elseif length(xx)>DAP{cnt}.N(pe+1) % !! only take data for 1 dap per elc -> use one with most evoked aps
                if length(xx)>DAP{cnt}.N(pe+1) % !! only take data for 1 dap per elc -> use one with most evoked aps
                    if DAP{cnt}.N(pe+1)>1
                        fprintf('\tNOTE: multiple daps! el %i \n',pe) 
                        %continue % use 1st dap instead of most reliable
                    end
                    DAP{cnt}.H(pe+1)=min(spike.H(ss(ee(xx))));
                    DAP{cnt}.L(pe+1)=mean(spike.L(ss(ee(xx))));
                    DAP{cnt}.J(pe+1)=std(spike.L(ss(ee(xx))));
                    DAP{cnt}.N(pe+1)=length(xx);%/Info.Parameter.NumberStim;
                    
                    if HISTORY
                        %if DAP{cnt}.HistAll(pe+1) == 0 && HISTORY
                        %DAP{cnt}.Hist(pe+1)=length(find( spike.ELC(SM) == sm    & ...
                        %                                 spike.T(SM)   <  spike.T(ss(ee(xx(1))))-spike.L(ss(ee(xx(1)))) & ...
                        %                                 spike.T(SM)   >  spike.T(ss(ee(xx(1))))-spike.L(ss(ee(xx(1)))) - hist_len ));
                        %DAP{cnt}.HistAll(pe+1)=length(find( spike.T(SM)   <  spike.T(ss(ee(xx(1))))-spike.L(ss(ee(xx(1))))/1000 & ...
                        %                                    spike.T(SM)   >  spike.T(ss(ee(xx(1))))-spike.L(ss(ee(xx(1))))/1000 - hist_len ));
                        DAP{cnt}.HistAll(pe+1)=length(find( spike.P_el(SM) == pe ));
                    end
                    
                    
                    %fprintf('\t%f\n',DAP(pe+1))
                    %disp(DAP_L(pe+1))
                end
                %break; % !!!!! only get 1 dap this way - drops others if exist
            end
        end
    end
end
%end

%figure(sm*10^figos)
figure(fig)
set(gcf,'Position',[1690 186 762 735])
pause(0.01)
daps=DAP{cnt}.N+1;%/Info.Parameter.NumberStim;
daps(daps>length(ssize))=length(ssize);
[a_ b]=sort(DAP{cnt}.N,'descend');


smmap=zeros(size(Info.Map.el))-1;  % find connected electrodes when sm is in the configuration
for nc=1:Info.Parameter.ConfigNumber
    rng=((nc-1)*NCHAN+1):(nc*NCHAN); tel=Info.Map.el(rng);
    if(sum(find(tel==sm))>0)
        smmap(rng)=tel;
    end
end

dist = electrode_distance(sm,0:11015);
ok   = find(ssize(daps(b))>0 & dist(b)>art_radius);
scatter(ELC.X(unique(smmap(smmap>-1))+1),ELC.Y(unique(smmap(smmap>-1))+1),10,[1 1 1]*.4,'filled'); hold on
scatter(ELC.X(b(ok)),ELC.Y(b(ok)),ssize(daps(b(ok))),DAP{cnt}.L(b(ok))*clr_scale,'filled'); set(gca,'YDir','reverse')
hold off
set(gca,'Color',[1 1 1]*.6)
colorbar
box off
axis equal
axis([100 2000 50 2150])
caxis([0 10]*clr_scale)

[smposx smposy]=el2position(sm);
hold on
%plot(smposx,smposy,'k+','markersize',10); hold off
plot(smposx,smposy,'w+','markersize',10,'linewidth',3);

hold off   
drawnow
title([Info.Exptitle ' ' Info.Exptype ' soma-' num2str(sm)])

%    hold on
%    [tx ty]=el2position(6991);
%    plot(tx,ty,'ko','markersize',10)
%    hold off

if PRINT
    filename=['/home/bakkumd/Desktop/' Info.Exptitle '-testing-soma', int2str(gcf), '.jpg'];
    set(gcf,'inverthardcopy','off')
    print('-djpeg','-r300',filename)
end

end
DAP_Parameters.ndap = ndap; % min number of daps
DAP_Parameters.bin  = bin ; % window (ms)
DAP_Parameters.step = step; % 1 sample
DAP_Parameters.llat = llat; % lower lat limit (ms)
DAP_Parameters.ulat = ulat; % upper lat limit (ms)

%    save(Info.FileName.Mat,'DAP','DAP_Parameters','-append')
 






%% try a movie



ll=0;
ul=10;

figure(sm*100)
pause(0.01)
ssize=[0 0 10 20 40 70 100 130];
daps=DAP{cnt}.N/Info.Parameter.NumberStim;

cut=.3
daps(find(     daps >= cut     ))=6;
daps(find(     daps  < cut     ))=2;
[a b]=sort(DAP{cnt}.N,'descend');


smmap=zeros(size(Info.Map.el))-1;  % find connected electrodes when sm is in the configuration
for nc=1:Info.Parameter.ConfigNumber
    rng=((nc-1)*NCHAN+1):(nc*NCHAN); tel=Info.Map.el(rng);
    if(sum(find(tel==sm))>0)
        smmap(rng)=tel;
    end
end
ok=find(ssize(daps(b))>0);
%%
for l=llat:.05:ulat-.05
    
    low=find(DAP{cnt}.L(b(ok))<l);
    low1=find(DAP{cnt}.L(b(ok))<l*2);
    low2=find(DAP{cnt}.L(b(ok))<l*3);
    
    low =find(DAP{cnt}.L(b(ok))<l   & DAP{cnt}.L(b(ok))>=l-1 );
    low1=find(DAP{cnt}.L(b(ok))<l-1 & DAP{cnt}.L(b(ok))>=l-2 );
    low2=find(DAP{cnt}.L(b(ok))<l-2 & DAP{cnt}.L(b(ok))>=l-3 );
    
%     hgh=find(DAP{cnt}.L(b(ok))>l+.1);
    med=find(DAP{cnt}.L(b(ok))<=l+.4 & DAP{cnt}.L(b(ok))>=l );
    
    scatter(ELC.X(unique(smmap(smmap>-1))+1),ELC.Y(unique(smmap(smmap>-1))+1),15,[1 1 1]*.4,'filled'); hold on
    %if ~isempty(hgh), scatter(ELC.X(b(ok(hgh))),ELC.Y(b(ok(hgh))),ssize(daps(b(ok(hgh)))),     [0 0 0]     ,'filled'); set(gca,'YDir','reverse'); end
    
    
    clr = map( floor(DAP{cnt}.L(b(ok(low)))/(ul-ll)*size(map,1)) , : ) * .8;    
    if ~isempty(low), scatter(ELC.X(b(ok(low))),ELC.Y(b(ok(low))),ssize(daps(b(ok(low)))), clr ,'filled'); set(gca,'YDir','reverse'); end
    
    clr = map( floor(DAP{cnt}.L(b(ok(low1)))/(ul-ll)*size(map,1)) , : ) * .5;
    if ~isempty(low1), scatter(ELC.X(b(ok(low1))),ELC.Y(b(ok(low1))),ssize(daps(b(ok(low1)))), clr ,'filled'); set(gca,'YDir','reverse'); end
    
    clr = map( floor(DAP{cnt}.L(b(ok(low2)))/(ul-ll)*size(map,1)) , : ) * .3;
    if ~isempty(low2), scatter(ELC.X(b(ok(low2))),ELC.Y(b(ok(low2))),ssize(daps(b(ok(low2)))), clr ,'filled'); set(gca,'YDir','reverse'); end
    
    
    
    if ~isempty(med), scatter(ELC.X(b(ok(med))),ELC.Y(b(ok(med))),ssize(daps(b(ok(med)))),DAP{cnt}.L(b(ok(med))),'filled'); set(gca,'YDir','reverse'); end
       
    hold off
    set(gca,'Color',[1 1 1]*.6)
    colorbar
    box off
    axis equal
    caxis([ll ul])

    [smposx smposy]=el2position(sm);
    hold on
    plot(smposx,smposy,'+','color',[1 1 1],'markersize',10,'linewidth',2); hold off
    drawnow
end





%% test 
figure
for i=1:length(elc_with_neuron)
    hold on
    [tx ty]=el2position(elc_with_neuron(i));
    plot(tx,ty,'ko','markersize',10)
   hold off
end




%% test how much each P_el evokes cells
xx=find(spike.L>1 & spike.L<10 & spike.H<0 & spike.clid>0 & spike.P_el>-1);
tmp=zeros(11016,1);
for i=0:11015
    tmp(i+1)=length(find(spike.P_el(xx)==i));
end
scatter(ELC.X(unique(Info.Map.el(Info.Map.el>-1))+1),ELC.Y(unique(Info.Map.el(Info.Map.el>-1))+1),30,tmp(unique(Info.Map.el(Info.Map.el>-1))+1),'filled');

set(gca,'Color',[1 1 1]*.6)
colorbar
box off
axis equal
caxis([0 100])




%
%
%
%
%
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%       DATA FILES        %%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% -- 091230-B (339) 44DIV
% P_hw looks OK!
clear all
Info.Exptitle='091230-B'; 
Info.Exptype='StimMap';
Info.FileName.Mat      = ['/home/bakkumd/Data/spikes/mat/' Info.Exptitle '.mat'];
% Info.FileName.SpikeForm = ['/home/bakkumd/Data/spikes/spikeform/' Info.Exptitle '.spikeform'];
% Info.FileName.Spike     = ['/home/bakkumd/Data/spikes/' Info.Exptitle '.spike'];
% Info.FileName.Map       = ['/home/bakkumd/Data/configs/bakkum/091230-stimmap/091230-A_neuromap.m']; % saved wrong letter!
% Info.Parameter.ConfigNumber=268;
% soma.el=[2056 2057 1647 1749 2052 2051 6653 6755 8733 8836];
% Info.Parameter.NumberStim=4; % number of stimuli per stim electrode
load(Info.FileName.Mat); NCHAN=126; % skip past save() section if load


%% -- 100101-B (339) 46DIV
% server stopped due to CPU overload... restarted at config 120 (read prior
% routed elc from el2fi files).
% CREATE NEW Info.FileName.Map from el2fi files of each...
% maybe rename spike files to iterations of -B.spike --> -B.spike-1 etc. ...
% !!!! P_hw errored !!!!
% clear all
% Info.Exptitle='100101-B'; 
% Info.Exptype='StimMap';
% Info.FileName.SpikeForm=['/home/bakkum/spikes/spikeform/' Info.Exptitle '.spikeform'];
% Info.FileName.Spike=['/home/bakkum/spikes/' Info.Exptitle '.spike']
% %Info.FileName.Map='/opt/cmosmea_external/configs/100101-stimmap/100101-B_neuromap.m' % saved wrong letter!
% Info.FileName.Map='/opt/cmosmea_external/configs/100101-stimmap/100101-B3-_neuromap.m' % saved wrong letter!
% Info.Parameter.ConfigNumber=268;
% soma.el=[2056 2057 1647     2052      6653 6755 8733 8836 7871 7768 4749];
% Info.Parameter.NumberStim=6; % number of stimuli per stim electrode

%% -- 100101-C (339) 46DIV
% fpga closed/crashed at config 127!!!!!
% !!!! P_hw errored !!!!
% clear all
% Info.Exptitle='100101-C'; 
% Info.Exptype='StimMap';
% Info.FileName.SpikeForm=['/home/bakkum/spikes/spikeform/' Info.Exptitle '.spikeform'];
% Info.FileName.Spike=['/home/bakkum/spikes/' Info.Exptitle '.spike']
% Info.FileName.Map='/opt/cmosmea_external/configs/100101-stimmap/100101-C_neuromap.m' % saved wrong letter!
% Info.Parameter.ConfigNumber=268;
% soma.el=[2056 2057 1647     2052      6653 6755 8733 8836 7871 7768 4749];
% Info.Parameter.NumberStim=6; % number of stimuli per stim electrode

%% -- 100101-D (339) 46DIV
% !!!! P_hw errored !!!!
% clear all
% Info.Exptitle='100101-D'; 
% Info.Exptype='StimMap';
% Info.FileName.SpikeForm=['/home/bakkum/spikes/spikeform/' Info.Exptitle '.spikeform'];
% Info.FileName.Spike=['/home/bakkum/spikes/' Info.Exptitle '.spike']
% Info.FileName.Map='/opt/cmosmea_external/configs/100101-stimmap/100101-D_neuromap.m' % saved wrong letter!
% Info.Parameter.ConfigNumber=268;
% soma.el=[2056 2057 1647     2052      6653 6755 8733 8836 7871 7768 4749];
% Info.Parameter.NumberStim=10; % number of stimuli per stim electrode

%% -- 100103-B (339) 48DIV -- repeat of 100101-D with lower volt (1000mV->800mV)
%   210 configs -- fpga stopped early!
% !!!! P_hw errored !!!!
% clear all
% Info.Exptitle='100103-B'; 
% Info.Exptype='StimMap';
% Info.FileName.SpikeForm=['/home/bakkum/spikes/spikeform/' Info.Exptitle '.spikeform'];
% Info.FileName.Spike=['/home/bakkum/spikes/' Info.Exptitle '.spike']
% Info.FileName.Map='/opt/cmosmea_external/configs/100103-stimmap/100103-B_neuromap.m' % saved wrong letter!
% Info.Parameter.ConfigNumber=210;
% soma.el=[2056 2057 1647     2052      6653 6755 8733 8836 7871 7768 4749];
% Info.Parameter.NumberStim=10; % number of stimuli per stim electrode


%% -- 100109-B (339) 53DIV 
clear all
 Info.Exptitle='100109-B'; 
 Info.Exptype='StimMap';
 Info.FileName.Mat           = ['/home/bakkumd/Data/spikes/mat/' Info.Exptitle '.mat'];
% Info.FileName.Map           = ['/home/bakkumd/Data/configs/bakkum/100109-stimmap/100109-B_neuromap.m']; % saved wrong letter!
% Info.FileName.SpikeForm     = ['/home/bakkumd/Data/spikes/spikeform/' Info.Exptitle '.spikeform'];
% Info.FileName.Spike         = ['/home/bakkumd/Data/spikes/' Info.Exptitle '.spike'];
% Info.Parameter.ConfigNumber    = 268;
% Info.Parameter.NumberStim      =   8; % number of stimuli per stim electrode
% soma.el=[2057,2056, 7782,8224,3012,2666,1014,9694,8974,5779];
load(Info.FileName.Mat); NCHAN=126; % skip past save() section if load
%% -- 100109-C (339) 53DIV -- repeat with BLOCKERS
clear all
 Info.Exptitle='100109-C'; 
 Info.Exptype='StimMap';
 Info.FileName.Mat           = ['/home/bakkumd/Data/spikes/mat/' Info.Exptitle '.mat'];
% Info.FileName.SpikeForm     = ['/home/bakkumd/Data/spikes/spikeform/' Info.Exptitle '.spikeform'];
% Info.FileName.Spike         = ['/home/bakkumd/Data/spikes/' Info.Exptitle '.spike'];
% Info.FileName.Map           = ['/home/bakkumd/Data/configs/bakkum/100109-stimmap/100109-C_neuromap.m']; % saved wrong letter!
% Info.Parameter.ConfigNumber    = 268;
% Info.Parameter.NumberStim      =   8; % number of stimuli per stim electrode
% soma.el=[2057,2056, 7782,8224,3012,2666,1014,9694,8974,5779];

load(Info.FileName.Mat); NCHAN=126; % skip past save() section if load


% Info.FileName.Trig              = ['/home/bakkumd/Data/raw/' Info.Exptitle '.raw.trig'];
% Info.FileName.Raw               = ['/home/bakkumd/Data/raw/' Info.Exptitle '.raw'];
% Info.FileName.TrigRawAve        = ['/home/bakkumd/Data/raw/' Info.Exptitle '.averaged.traw'];
% Info.Parameter.TriggerTimeZero  =  ;
% Info.Parameter.TriggerLength    =  ;





%% -- 110312-I (707) 40DIV 
clear all
Info.Exptitle='110312-I'; 
Info.Exptype='StimMap';
Info.FileName.Mat           = ['/home/bakkumd/Data/spikes/mat/' Info.Exptitle '.mat'];
% Info.FileName.SpikeForm     = ['/home/bakkumd/Data/spikes/spikeform/' Info.Exptitle '.spikeform'];
% Info.FileName.Spike         = ['/home/bakkumd/Data/spikes/' Info.Exptitle '.spike'];
% Info.FileName.Map           = '/home/bakkumd/Data/configs/bakkum/110312/110312-I_neuromap.m';
% Info.FileName.Trig          = ['/home/bakkumd/Data/raw/' Info.Exptitle '.raw.trig'];
% Info.FileName.Raw           = ['/home/bakkumd/Data/raw/' Info.Exptitle '.raw'];
% Info.FileName.TrigRawAve    = ['/home/bakkumd/Data/raw/' Info.Exptitle '.averaged.traw'];
% Info.Parameter.ConfigNumber    = 268;
% Info.Parameter.TriggerTimeZero =   1;
% Info.Parameter.ConfigDuration  =   4;
% Info.Parameter.TriggerLength   =  80;
% Info.Parameter.NumberStim      =   8; % number of stimuli per stim electrode
% soma.el=[10640 10326 10933 7858 9181 5828 292 8151 2298 8589];
load(Info.FileName.Mat);




%% -- 110404-E (691) 40DIV  -- Pt Black
clear all
 Info.Exptitle='110404-E'; 
 Info.Exptype='StimMap';
 Info.FileName.Mat           = ['/home/bakkumd/Data/spikes/mat/' Info.Exptitle '.mat'];
% Info.FileName.SpikeForm     = ['/home/bakkumd/Data/spikes/spikeform/' Info.Exptitle '.spikeform'];
% Info.FileName.Spike         = ['/home/bakkumd/Data/spikes/' Info.Exptitle '.spike'];
% Info.FileName.Map           = ['/home/bakkumd/Data/configs/bakkum/110404/110404-E_neuromap.m'];
% Info.FileName.Trig          = ['/home/bakkumd/Data/raw/' Info.Exptitle '.raw.trig'];
% Info.FileName.Raw           = ['/home/bakkumd/Data/raw/' Info.Exptitle '.raw'];
% Info.FileName.TrigRawAve    = ['/home/bakkumd/Data/raw/' Info.Exptitle '.averaged.traw'];
% Info.Parameter.ConfigNumber    = 268;
% Info.Parameter.TriggerTimeZero =  61;
% Info.Parameter.ConfigDuration  =  15;
% Info.Parameter.TriggerLength   = 300;
% Info.Parameter.NumberStim      =   8; % number of stimuli per stim electrode
% soma.el=[1093,990,1816,5457,4397,8239,6609,4499,7959,5552];
load(Info.FileName.Mat); NCHAN=126; % skip past save() section if load



%% -- 110405-A (691) 40DIV  -- increased volt from +-218 to +-300
clear all
 Info.Exptitle='110405-A'; 
 Info.Exptype='StimMap';
 Info.FileName.Mat           = ['/home/bakkumd/Data/spikes/mat/' Info.Exptitle '.mat'];
% Info.FileName.SpikeForm     = ['/home/bakkumd/Data/spikes/spikeform/' Info.Exptitle '.spikeform'];
% Info.FileName.Spike         = ['/home/bakkumd/Data/spikes/' Info.Exptitle '.spike'];
% Info.FileName.Map           = ['/home/bakkumd/Data/configs/bakkum/110404/110405-A_neuromap.m'];
% Info.FileName.Trig          = ['/home/bakkumd/Data/raw/' Info.Exptitle '.raw.trig'];
% Info.FileName.Raw           = ['/home/bakkumd/Data/raw/' Info.Exptitle '.raw'];
% Info.FileName.TrigRawAve    = ['/home/bakkumd/Data/raw/' Info.Exptitle '.averaged.traw'];
% Info.Parameter.ConfigNumber    = 268;
% Info.Parameter.TriggerTimeZero =  61;
% Info.Parameter.ConfigDuration  =  15;
% Info.Parameter.TriggerLength   = 300;
% Info.Parameter.NumberStim      =   8; % number of stimuli per stim electrode
% soma.el=[1093,990,1816,5457,4397,8239,6609,4499,7959,5552];
load(Info.FileName.Mat); NCHAN=126; % skip past save() section if load

% %% -- 110405-B (691) 40DIV  -- increased volt            to +-350
% clear all
%  Info.Exptitle='110405-B'; 
%  Info.Exptype='StimMap';
%  Info.FileName.Mat           = ['/home/bakkumd/Data/spikes/mat/' Info.Exptitle '.mat'];
% % Info.FileName.SpikeForm     = ['/home/bakkumd/Data/spikes/spikeform/' Info.Exptitle '.spikeform'];
% % Info.FileName.Spike         = ['/home/bakkumd/Data/spikes/' Info.Exptitle '.spike'];
% % Info.FileName.Map           = ['/home/bakkumd/Data/configs/bakkum/110405/110405-B_neuromap.m'];
% % Info.FileName.Trig          = ['/home/bakkumd/Data/raw/' Info.Exptitle '.raw.trig'];
% % Info.FileName.Raw           = ['/home/bakkumd/Data/raw/' Info.Exptitle '.raw'];
% % Info.FileName.TrigRawAve    = ['/home/bakkumd/Data/raw/' Info.Exptitle '.averaged.traw'];
% % Info.Parameter.ConfigNumber    = 268;
% % Info.Parameter.TriggerTimeZero =  61;
% % Info.Parameter.ConfigDuration  =  15;
% % Info.Parameter.TriggerLength   = 300;
% % Info.Parameter.NumberStim      =   8; % number of stimuli per stim electrode
% % soma.el=[1093,990,1816,5457,4397,8239,6609,4499,7959,5552];
% load(Info.FileName.Mat); NCHAN=126; % skip past save() section if load

%% -- 110405-C (691) 40DIV  -- increased volt            to +-400
clear all
 Info.Exptitle='110405-C'; 
 Info.Exptype='StimMap';
 Info.FileName.Mat           = ['/home/bakkumd/Data/spikes/mat/' Info.Exptitle '.mat'];
% Info.FileName.SpikeForm     = ['/home/bakkumd/Data/spikes/spikeform/' Info.Exptitle '.spikeform'];
% Info.FileName.Spike         = ['/home/bakkumd/Data/spikes/' Info.Exptitle '.spike'];
% Info.FileName.Map           = ['/home/bakkumd/Data/configs/bakkum/110405/110405-C_neuromap.m'];
% Info.FileName.Trig          = ['/home/bakkumd/Data/raw/' Info.Exptitle '.raw.trig'];
% Info.FileName.Raw           = ['/home/bakkumd/Data/raw/' Info.Exptitle '.raw'];
% Info.FileName.TrigRawAve    = ['/home/bakkumd/Data/raw/' Info.Exptitle '.averaged.traw'];
% Info.Parameter.ConfigNumber    = 268;
% Info.Parameter.TriggerTimeZero =  61;
% Info.Parameter.ConfigDuration  =  15;
% Info.Parameter.TriggerLength   = 300;
% Info.Parameter.NumberStim      =   8; % number of stimuli per stim electrode
% soma.el=[1093,990,1816,5457,4397,8239,6609,4499,7959,5552];
load(Info.FileName.Mat); NCHAN=126; % skip past save() section if load



%% -- 130109-K (967) 19DIV 
clear all
 Info.Exptitle='130109-K'; 
 Info.Exptype='StimMap';
 Info.FileName.Mat           = ['/home/bakkumd/Data/spikes/mat/' Info.Exptitle '.mat'];
% Info.FileName.SpikeForm     = ['/home/bakkumd/Data/spikes/spikeform/' Info.Exptitle '.spikeform'];
% Info.FileName.Spike         = ['/home/bakkumd/Data/spikes/' Info.Exptitle '.spike'];
% Info.FileName.Map           = ['/home/bakkumd/Data/configs/bakkum/130109/130109-K_neuromap.m'];
% Info.FileName.Trig          = ['/home/bakkumd/Data/raw/' Info.Exptitle '.raw.trig'];
% Info.FileName.Raw           = ['/home/bakkumd/Data/raw/' Info.Exptitle '.raw'];
% Info.FileName.TrigRawAve    = ['/home/bakkumd/Data/raw/' Info.Exptitle '.averaged.traw'];
% Info.Parameter.ConfigNumber    = 268;
% Info.Parameter.TriggerTimeZero =  61;
% Info.Parameter.ConfigDuration  =  15;
% Info.Parameter.TriggerLength   = 300;
% Info.Parameter.NumberStim      =   8; % number of stimuli per stim electrode
% soma.el=[100,7145,3077];
 load(Info.FileName.Mat); NCHAN=126;  % skip past save() section if load

 
%% -- 130111-967-E1 (967) 21DIV -- GOOD
clear all
 Info.Exptitle='130111-967-E1'; 
 Info.Exptype='StimMap';
 Info.FileName.Mat           = ['/home/bakkumd/Data/spikes/mat/' Info.Exptitle '.mat'];
% Info.FileName.SpikeForm     = ['/home/bakkumd/Data/spikes/spikeform/' Info.Exptitle '.spikeform'];
% Info.FileName.Spike         = ['/local0/bakkumd/spikes/' Info.Exptitle '.spike'];
% Info.FileName.Map           = ['/home/bakkumd/Data/configs/bakkum/130111/130111-967-E1_neuromap.m'];
% Info.FileName.Trig          = ['/local0/bakkumd/raw/' Info.Exptitle '.raw.trig'];
% Info.FileName.Raw           = ['/local0/bakkumd/raw/' Info.Exptitle '.raw'];
% Info.FileName.TrigRawAve    = ['/local0/bakkumd/raw/' Info.Exptitle '.averaged.traw'];
% Info.Parameter.ConfigNumber    = 268;
% Info.Parameter.TriggerTimeZero =  61;
% Info.Parameter.ConfigDuration  =  15;
% Info.Parameter.TriggerLength   = 300;
% Info.Parameter.NumberStim      =   8; % number of stimuli per stim electrode
% soma.el                        = [2974,3283,3282,3487];
 load(Info.FileName.Mat); NCHAN=126;  % skip past save() section if load
 
 
 
%% -- 130111-K (966) 21DIV 
clear all
 Info.Exptitle='130111-K'; 
 Info.Exptype='StimMap';
 Info.FileName.Mat           = ['/home/bakkumd/Data/spikes/mat/' Info.Exptitle '.mat'];
% Info.FileName.SpikeForm     = ['/home/bakkumd/Data/spikes/spikeform/' Info.Exptitle '.spikeform'];
% Info.FileName.Spike         = ['/home/bakkumd/Data/spikes/' Info.Exptitle '.spike'];
% Info.FileName.Map           = ['/home/bakkumd/Data/configs/bakkum/130111/130111-K_neuromap.m'];
% Info.FileName.Trig          = ['/home/bakkumd/Data/raw/' Info.Exptitle '.raw.trig'];
% Info.FileName.Raw           = ['/home/bakkumd/Data/raw/' Info.Exptitle '.raw'];
% Info.FileName.TrigRawAve    = ['/home/bakkumd/Data/raw/' Info.Exptitle '.averaged.traw'];
% Info.Parameter.ConfigNumber    = 268;
% Info.Parameter.TriggerTimeZero =  61;
% Info.Parameter.ConfigDuration  =  15;
% Info.Parameter.TriggerLength   = 300;
% Info.Parameter.NumberStim      =   8; % number of stimuli per stim electrode
% soma.el                        = [811,914,10716,10820,10077,10381];
 load(Info.FileName.Mat); NCHAN=126;  % skip past save() section if load
 
 


%% -- 130111-801-E1 (801) 22DIV 
clear all
 Info.Exptitle='130112-801-F'; 
 Info.Exptype='StimMap';
 Info.FileName.Mat           = ['/home/bakkumd/Data/spikes/mat/' Info.Exptitle '.mat'];
% Info.FileName.SpikeForm     = ['/home/bakkumd/Data/spikes/spikeform/' Info.Exptitle '.spikeform'];
% Info.FileName.Spike         = ['/local0/bakkumd/spikes/' Info.Exptitle '.spike'];
% Info.FileName.Map           = ['/home/bakkumd/Data/configs/bakkum/130112/130112-801-F_neuromap.m'];
% Info.FileName.Trig          = ['/local0/bakkumd/raw/' Info.Exptitle '.raw.trig'];
% Info.FileName.Raw           = ['/local0/bakkumd/raw/' Info.Exptitle '.raw'];
% Info.FileName.TrigRawAve    = ['/local0/bakkumd/raw/' Info.Exptitle '.averaged.traw'];
% Info.Parameter.ConfigNumber    = 268;
% Info.Parameter.TriggerTimeZero =  61;
% Info.Parameter.ConfigDuration  =  15;
% Info.Parameter.TriggerLength   = 300;
% Info.Parameter.NumberStim      =   8; % number of stimuli per stim electrode
% soma.el                        = [3585,3883,1914,4746,9580];
 load(Info.FileName.Mat); NCHAN=126;  % skip past save() section if load
 
 
 
 
 