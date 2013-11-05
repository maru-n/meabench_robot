%% generate tiff stack from stimscreen

%this script starts out with the standard stimscreen analysis (averaging
%over trials) but instead of producing a .avi, produces a .tiff stack for
%use in imageJ)
%%   use cpp file to average raw traces

%rtzt notes: expects that the Info.Filename.TrigRawAve, which is produced
%using this command, doesn't exist, and will exit out if it already exists
%Don't expect warnings during this step- if you see warnings, address them

Info_Parameter_NumberStim = 0; % tells code to look at DAC channel to determine epoch changes (as opposed to counting num of stim)
cmd = ['rm ' Info.FileName.TrigRawAve];
system(cmd);
cmd=['/usr/local/hierlemann/meabench/head/bin/cmos_postprocessing -a -o ' Info.FileName.TrigRawAve ' -r ' Info.FileName.Raw ' -s ' int2str(Info.Parameter.TriggerLength) ' -z ' int2str(Info.Parameter.TriggerTimeZero) ' -m ' Info.FileName.Map ' -c ' int2str(Info.Parameter.ConfigNumber) ' -n ' int2str(Info_Parameter_NumberStim)]

system(cmd);


%% load Info.Map info   and   mtraw data

load global_cmos
Info.Map = loadmapfile(Info.FileName.Map,1111); % load Info.FileName.Map and plot elc locations in figure 1111


% position = [0 680 560 420];
position = [1685 450 560 420];
set(0,'DefaultFigurePosition',position);

%%%%% mtraw in digi units ???     normal settings give 0.762uV/digi in Meabench

clear mtraw
mtraw=load(Info.FileName.TrigRawAve,'-ascii');  % !!!! no gain applied !!! USE:   11.7/16 * 1000/958.558; % 11.7mV/8-bit (3V range); meabench uses 12-bit (mcs convention) -- 16=2^12 / 2^8; 1000 to put into uV; 958 is standard CMOS gain (A1-30, A2-30 A3-bypass)
                               % [samples; 12 bit (meabench default)]
mtraw = mtraw * GAIN;          % CONVERT to uV
% mtraw = mtraw * GAIN/10;          % CONVERT to uV

% mtraw = mtraw/10 % * GAIN;          % CONVERT to uV

% cd /home/bakkumd/bel.svn/cmosmea_external/meabench/trunk/matlab/0
[stim_x stim_y] = el2position(Info.Parameter.StimElectrode);


    % remove artifact electrodes
    elc_to_skip = [];
   


% cmos_postprocessing file removes non connected electrodes (sets values to zero), so can extract these here:
zz=find(sum(abs(mtraw(:,50:end))')==0);
ok=find(sum(abs(mtraw(:,50:end))')~=0);
%zz=find(sum(mtraw(:,50:250)')==0);
%ok=find(sum(mtraw(:,50:250)')~=0);

   figure
plot(([1:Info.Parameter.TriggerLength]-Info.Parameter.TriggerTimeZero)*.05,mtraw')
title(Info.Exptitle)

%% necessary preprocessing for movie frames
clear target
% %%
% target = tgaus;
% target = ftraw;
  target = mtraw;

    spacingx=(max(ELC.X)-min(ELC.X(ELC.X>0)))/(length(unique(ELC.X(ELC.X>0)))-1);
    spacingy=(max(ELC.Y)-min(ELC.Y(ELC.Y>0)))/(length(unique(ELC.Y(ELC.Y>0)))-1);%note that there are twice as many unique y values as there are in a column
    sx=min(ELC.X(ELC.X>0)):spacingx:max(ELC.X);
    sy=min(ELC.Y(ELC.Y>0)):spacingy:max(ELC.Y);
    [sx,sy]=meshgrid(sx,sy);








%%   save movie frames- generates movie frames from mraw

cnt=0;
i = Info.Parameter.TriggerTimeZero-1 + 10;
%%%   movie

ll      =  -35;   % -35; %-45; % [uV]    -40;%-50 ; % cutoff   -50 [samples]  --- lower color bar limit
ul      =   10;    % 10; % [uV]     12;% 15 ; % cutoff    15 [samples]   ---- upper color bar limit

% electrode sizes.  default v2 is type "M Pt3um default" 8.2x5.8um
elc_dimx = 16.2-1; % um
elc_dimy = 19.588; % um  % from unique(diff(ELC.Y))




immat = zeros(size(sx,1),size(sx,2),size(mtraw,2)-i+1);
id=ELC.X>0; % ignor dummy electrodes

 while i<=(size(mtraw,2))
    cla
    
    disp(i)
    tar = target(:,i);
    
    z=(griddata(ELC.X(id),ELC.Y(id),tar(id),sx,sy,'nearest'));
    %z = (z-ll)./(ul-ll);
    z(z>ul) = ul;
    z(z<ll) = ll;
    immat(:,:,cnt+1) = z;
    cnt = cnt+1;
     i=i+1;  

 end
 save([Info.FileName.Immat],'immat');
%% with electrodes 
figure;imagesc(sx(1,:),sy(:,1),rand(size(sx,1),size(sx,2)));hold on;plot(ELC.X,ELC.Y,'.k')
%figure out where the electodes were

cmd = ['rm ' Info.FileName.Map];
system(cmd);
 cmd=['el2fi_to_neuromap -i ' Info.FileName.el2fi   ' -o ' Info.FileName.Map];
 
 system(cmd);
 load global_cmos
Info.Map = loadmapfile(Info.FileName.Map,1111);
figure(1);hold on;plot(Info.Map.px,Info.Map.py,'ms')
[x y]=el2position(5448);
plot(x,y,'+g', 'markersize',20)
%% make normalized array
nrmmat = immat-ones(size(immat))*ll;
nrmmat = nrmmat./(ul-ll);
%% write to tiff stack

imwrite(nrmmat(:,:,1), Info.FileName.Tiff,'tiff','Resolution',[spacingx spacingy])
for k = 2:size(nrmmat,3)
    imwrite(nrmmat(:,:,k), Info.FileName.Tiff, 'writemode', 'append','Resolution',[spacingx spacingy]);

end


%% write to gif stack
imwrite(nrmmat(:,:,1)*256, Info.FileName.Gif,'gif','DelayTime',0.03);%,'Resolution',[spacingx spacingy])
for k = 2:size(nrmmat,3)
    imwrite(nrmmat(:,:,k)*256, Info.FileName.Gif, 'writemode', 'append','DelayTime',0.03);%,'Resolution',[spacingx spacingy]);

end

%%  EXPERIMENT INFO

 %  Plating date: 15 Jun 2103;     Chip ID:       1393;       Gain:     a3buffer;              Synaptic blockers: Yes
 %  Rec date:     07 Aug 2013;     Stim elc:      0;       MOSR:     M=160; V2=160;         Trigg rec length:  15ms;
 %  Age:          50 DIV;          Stim voltage:  300mv;      StimScan: Cmd GUI;

Info.Exptype='stimscan1';
Info.Exptitle='13_10_25_gal';
Info.Path = '/home/zriley/Data';
Info.Analysis_directory = ['/home/zriley/Documents/Analysis/' Info.Exptitle];
Info.Path = Info.Analysis_directory;%'/home/zriley/Data';
%system(['mkdir ' Info.Analysis_directory]);
Info.Parameter.StimElectrode=2098;
Info.FileName.Spike            = [Info.Path '/' Info.Exptype '.spike'];
Info.FileName.SpikeForm        = [Info.Path '/' Info.Exptype '.spikeform'];
Info.FileName.Map =             [Info.Path '/configs/' Info.Exptype '_neuromap.m'];
Info.FileName.Trig             = [Info.Path '/' Info.Exptype '.raw.trig'];
Info.FileName.Raw              = [Info.Path '/' Info.Exptype '.raw'];
Info.FileName.TrigRawAve       = [Info.Path '/' Info.Exptype '.averaged.traw'];
Info.FileName.Tiff             = [Info.Path '/' Info.Exptype '.tiff'];
Info.FileName.Gif             = [Info.Path '/' Info.Exptype '.gif'];
Info.FileName.el2fi            = [Info.Path '/configs/' Info.Exptype '.el2fi.nrk2'];
Info.FileName.Immat            = [Info.Path '/' Info.Exptype '_immat.mat'];
Info.Parameter.NumberStim      = 30;      % tells cpp code to look at epochs for averaging
Info.Parameter.ConfigNumber    = 95;     % random
Info.Parameter.TriggerTimeZero = 61;     % [samples] stimulation center (time zero)
Info.Parameter.ConfigDuration  = 43;     % [ms] length of triggered rec
Info.Parameter.TriggerLength   = (Info.Parameter.ConfigDuration)*20;    % [samples] length of triggered recording