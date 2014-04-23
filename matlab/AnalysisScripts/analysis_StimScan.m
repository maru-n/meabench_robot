% - - - - - - - - - - - %
%% analysis_StimScan.m %%
%      Douglas Bakkum 
%      2008-2012
%
%   EXPERIMENT INFO IS AT THE BOTTOM OF THE PAGE
%   (so can more quickly navigate scripts)
%
%%% %% %% %% %% %% %% %% %% %% %% %% %%  %%   %%     %%    %%   %%  %  % %
%
%   Start of script
%
%
%

%% %  use cpp file to average raw traces 
%  High res DAC encoding (after March 2010)
% 
% 
%  %%%%%%  TO TRY --> put bandpass filtfilt into c code....
%  
%  Info_Parameter_NumberStim = 0; % tells code to look at DAC channel to determine epoch changes (as opposed to counting num of stim)
%  
% %    system(['rm ' Info.FileName.TrigRawAve]);
% 
% % %  LOW RES
% % %   cmd=['/home/bakkumd/Documents/Code/CMOS/bin/cmos_postprocessing -a -L -o ' Info.FileName.TrigRawAve ' -r ' Info.FileName.Raw ' -s ' int2str(Info.Parameter.TriggerLength) ' -z ' int2str(Info.Parameter.TriggerTimeZero) ' -m ' Info.FileName.Map ' -c ' int2str(Info.Parameter.ConfigNumber) ' -n ' int2str(Info.Parameter.NumberStim)]
% 

if ~exist(Info.FileName.TrigRawAve,'file')
%   cmd=['/home/bakkumd/Documents/Code/CMOS/bin/cmos_postprocessing -a -o ' Info.FileName.TrigRawAve ' -r ' Info.FileName.Raw ' -s ' int2str(Info.Parameter.TriggerLength) ' -z ' int2str(Info.Parameter.TriggerTimeZero) ' -m ' Info.FileName.Map ' -c ' int2str(Info.Parameter.ConfigNumber) ' -n ' int2str(Info_Parameter_NumberStim)]
    cmd=['`which cmos_postprocessing`                               -a -o ' Info.FileName.TrigRawAve ' -r ' Info.FileName.Raw ' -s ' int2str(Info.Parameter.TriggerLength) ' -z ' int2str(Info.Parameter.TriggerTimeZero) ' -m ' Info.FileName.Map ' -c ' int2str(Info.Parameter.ConfigNumber) ' -n ' int2str(Info.Parameter.NumberStim)]
    system(cmd);
else
    disp 'Error: File exists'
end
 
% 
% 
%% Alternative to c code to get mtraw
% %  Extract triggered raw traces for electrodes of interest
% 
% nstim       = Info.Parameter.NumberStim;
% 
% mtraw       = zeros(11016,Info.Parameter.TriggerLength);        % [elc x samp]
% filled      = zeros(1,11016);                                   % set when trace for an electrode gets filled
% raw_matrix  = zeros(nstim,11016,Info.Parameter.TriggerLength);  % [nxtim x elc x samp]
% 
% for elc = unique(Info.Map.el(Info.Map.el>-1))'
%     
%     if filled(elc+1), continue, end
%     [trc ep map]        = extractTrigRawTrace(Info,elc,'fulltrace','digi');
%     
%     fprintf('epoch:%i  elc:%i \n',ep,elc);
%     
%     for e=map.el'
%         if e<0, continue, end    
%         if strcmp(Info.Exptitle(1:6),'090409') && e==0, continue, end % hack to fix nonconnected channels setting map.el=0 in Info.Map file
%         chn                             = map.ch(map.el==e,1);
%         mtraw(e+1,:)                    = median(squeeze(trc(:,chn+1,:)));
%         raw_matrix(1:size(trc,1),e+1,:) =                trc(:,chn+1,:);
%         filled(e+1)                     = 1;
%     end      
% end




%% Load map and trigger information

load global_cmos

Info.Map    = loadmapfile(Info.FileName.Map,1111); % load Info.FileName.Map and plot elc locations in figure 1111
Info.Trig   = loadtrigfile(Info.FileName.Trig);

if ~isfield(Info.Trig,'E')
    spike       = loadspikeform(Info.FileName.SpikeForm);
    spike       = spikeform_EpochFix(Info,spike);
    Info.Trig.E = addTrigEpoch(Info,spike);
end




%% Load mtraw (median triggered raw traces formated by C code)

% position = [0 680 560 420];
position = [1685 450 560 420];
set(0,'DefaultFigurePosition',position); 

clear mtraw
mtraw=load(Info.FileName.TrigRawAve,'-ascii');  % !!!! no gain applied !!! USE:   11.7/16 * 1000/958.558; % 11.7mV/8-bit (3V range); meabench uses 12-bit (mcs convention) -- 16=2^12 / 2^8; 1000 to put into uV; 958 is standard CMOS gain (A1-30, A2-30 A3-bypass)
                               % [samples; 12 bit (meabench default)] 
mtraw = mtraw * GAIN;          % CONVERT to uV                               
                               
[stim_x stim_y] = el2position(Info.Parameter.StimElectrode);


    % remove artifact electrodes
    elc_to_skip = [];
    if strcmp(Info.Exptitle,'100926-A2'),         elc_to_skip = [8471 8477 8483 8489 8495 8501 8513 8733 8531 8537 8543 8549 8555 8561 8567 203 202 404 401 193  92 391 186    385    383    179    177    174    169    366    159    147    145    343    136    329    123    117    322    325    335    103 158    19      27    127    315    106   8680   8480 183         402        9518        5905        5607          63         371          52          57           5  77 24];
    elseif strcmp(Info.Exptitle,'091123-A'),      elc_to_skip = [ 9912   9978     9914        9918        9920        9924        9926        9930        9932        9936       9938        9942        9944        9948        9954        9956        9960        9962        9966        9968        9972        9974        9980        9984        9986        9990        9992        9908        9906        9894        9896        4443        7760        9291        9950   ];
    elseif strcmp(Info.Exptitle,'091120-B'),      elc_to_skip = [ 5307 5319 5131 5325 5331 5337 5343 5349 5355 5361 5367 5373 5379 5385 5391 5397 5403 ];
    end
    if ~isempty(elc_to_skip)
        mtraw(elc_to_skip+1,:) = 0;
        disp 'Removed artifact electrodes'
    end
    
    
% cmos_postprocessing file removes non connected electrodes (sets values to zero), so can extract these here:
zz=find(sum(abs(mtraw(:,50:end))')==0);
ok=find(sum(abs(mtraw(:,50:end))')~=0);

   figure
plot(([1:Info.Parameter.TriggerLength]-Info.Parameter.TriggerTimeZero)*.05,mtraw')
title(Info.Exptitle)



%% Suppress artifact using fit.m

if strcmp(Info.Exptitle,'130110-D') || strcmp(Info.Exptitle,'130111-967-D3') || strcmp(Info.Exptitle,'130112-967-D7') || strcmp(Info.Exptitle,'130112-967-D8') 
    
    BLANK           = Info.Parameter.TriggerTimeZero + 10; % [samples] Time to blank before and after tzero

    filename = ['mat/' Info.Exptitle '-ftraw'];
    if exist([filename '.mat'],'file')
        clear ftraw;
        load(filename)
        disp 'Loaded existing ftraw from file.'
    else
        ftraw            = mtraw;
        ftraw(:,1:BLANK) = 0;
        x_sa             = BLANK+1:Info.Parameter.TriggerLength;

        cnt = 0;
        xx  = find(sum(ftraw')); % use only electrodes with signals (i.e. sum > 0)
        for i = xx
            y             = ftraw(i,x_sa); if sum(abs(y)) == 0, continue, end
            cnt           = cnt+1;
            [yfit, gof]   = fit(x_sa',y','fourier7');
            yfit          = feval(yfit,x_sa);
            ftraw(i,x_sa) = y - yfit';
            if ~mod(cnt,100), fprintf('%i\n',length(xx)-cnt); end
        end    
        %bndpss      = filtfilt(bpB,bpA,ftraw)';

        save(filename,'ftraw')

    end
    
end

%% Set plotting limits for experiments that did not scan whole array (increases plotting speed)
%  limits [um] to plotting for FILL scatter plot

clear limit
if strcmp(Info.Exptitle(1:8),'130829-D') 
        limit.x_min   =   200;
        limit.x_max   =   700;
        limit.y_min   =   700;
        limit.y_max   =  1500;
elseif length(Info.Exptitle)>=12 
    % dish 967 Neuron D,E
    if strcmp(Info.Exptitle(8:12),'967-D')
        limit.x_min   =  1530;
        limit.x_max   =   Inf;
        limit.y_min   =     1;
        %limit.y_max   =   700;
        limit.y_max   =   740;
    elseif strcmp(Info.Exptitle(8:12),'967-E')
        limit.x_min   =   183;
        limit.x_max   =   570;
        limit.y_min   =   410;
        limit.y_max   =  1074;
        %ax_ = [1500 2000 50 800];
    elseif strcmp(Info.Exptitle,'130829-B-ntk')
        limit.x_min   =   280;
        limit.x_max   =   410;
        limit.y_min   =   800;
        limit.y_max   =  1250;
    end
elseif strcmp(Info.Exptitle,'130110-D') % Neuron D so copy values from above
        limit.x_min   =  1530;
        limit.x_max   =   Inf;
        limit.y_min   =     1;
        limit.y_max   =   740;
end
if ~exist('limit','var')
        limit.x_min   =    1;
        limit.x_max   =  Inf;
        limit.y_min   =    1;
        limit.y_max   =  Inf;
end


%% Set some variables

    clear target

    if strcmp(Info.Exptitle,'130110-D') || strcmp(Info.Exptitle,'130111-967-D3') || strcmp(Info.Exptitle,'130112-967-D7') || strcmp(Info.Exptitle,'130112-967-D8') 
       target      = ftraw;
       ax_         = [1500 2000 50 800];
       titlestart  = 700;   
    elseif strcmp(Info.Exptitle,'130111-967-E2')
       target      = mtraw;
       ax_         = [100 570 350 1100];
       titlestart  = 700;   
    elseif strcmp(Info.Exptitle,'130829-D4')
       target      = mtraw;
       ax_         = [220 700 750 1500];
       titlestart  = 700;   
    elseif strcmp(Info.Exptitle,'130829-B-ntk') || strcmp(Info.Exptitle,'130829-D1-ntk') || strcmp(Info.Exptitle,'130829-D4') 
       target      = mtraw;
       ax_         = [limit.x_min limit.x_max limit.y_min limit.y_max];
       titlestart  = 700;   
    else
       target      = mtraw;
       ax_         = ([100 2000 50 2150]);  % Whole array
       titlestart  = 200;
    end
    
    spacingx    = (max(ELC.X)-min(ELC.X(ELC.X>0)))/length(unique(ELC.X(ELC.X>0)))/4;
    spacingy    = (max(ELC.Y)-min(ELC.Y(ELC.Y>0)))/length(unique(ELC.Y(ELC.Y>0)))/2;
    sx          = min(ELC.X(ELC.X>0)):spacingx:max(ELC.X);
    sy          = min(ELC.Y(ELC.Y>0)):spacingy:max(ELC.Y);
    [sx,sy]     = meshgrid(sx,sy);  
    %ax_         = ([sx(1,[1 end]) sy([1 end],1)']);
 
    
    elc_dimx    = 16.2;%-1; % [um]  Electrode sizes for plotting with FILL option. 
    elc_dimy    = 19.588;   % [um]  Electrode sizes for plotting with FILL option. 
    fillall_rng =   25;     % [um]  Range around non-connected electrodes used to average (FILLALL) value for that electrode
                            %       25um corresponds to 1st neighboring ring of electrodes.

%     % settings for NatComm cover art
%     elc_dimx    = 18.5;%%%16.2;%-1; % [um]  Electrode sizes for plotting with FILL option. 
%     elc_dimy    = 22;%%%19.588;   % [um]  Electrode sizes for plotting with FILL option. 
%     fillall_rng =   25;     % [um]  Range around non-connected electrodes used to average (FILLALL) value for that electrode
%                             %       25um corresponds to 1st neighboring ring of electrodes.



%%  Make movie frames

i   = Info.Parameter.TriggerTimeZero + 10 - 2; % First samples to plot

if strcmp(Info.Exptitle,'090409-C')
    i = 24-1;
elseif strcmp(Info.Exptitle,'100926-A2')
    i = 75-1;
elseif strcmp(Info.Exptitle,'091123-A')
    i = 35-1;
elseif strcmp(Info.Exptitle,'091120-B')
    i = 35-1;    
elseif strcmp(Info.Exptitle,'130110-D') || strcmp(Info.Exptitle,'130111-967-D3') || strcmp(Info.Exptitle,'130112-967-D7') || strcmp(Info.Exptitle,'130112-967-D8') 
    i = 70-1;
elseif strcmp(Info.Exptitle,'130111-967-E2')
    i = 75-1;
elseif strcmp(Info.Exptitle,'130829-B-ntk') || strcmp(Info.Exptitle,'130829-D1-ntk')
    i = 25;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%     Options      %%%%%%%%
SAVE     =    1 ; % print figures to file
FILL     =    0 ; % plot using 'fill' (HIGH QUALITY; longer to run)
PLOTMIN  =    0 ; % write text at valleys
FILLALL  =    1 ; % fill non-connected electrodes with average of connected neighbors
FILLGRAY =    0 ; % fill non-connected electrodes gray
GAUS     =    1 ; % spatial blur with a gaussian
OVERLAY  =    0 ; % overlay an image 'im' (load 'im' seperately using analysis_ImageAlignment.m)
NOTATE   =    0 ; % add notation on side of figure for published supplemental videos; also changes axis
PAUSE    =    0 ; % pause between figures

DIR      = '/home/bakkumd/Movies/'; % directory to print figures
% DIR      = '/home/bakkumd/Movies/ToPublish/'; % directory to print figures

LowerLim =  -40 ; % [uV]  % Limit voltage range plotted (to better see axons)
UpperLim =   10 ; % [uV]  
% LowerLim = -100 ;
% UpperLim =   20 ;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



figure(22), 
    hold off
    colorbar('delete')
    clf
   
    
if NOTATE     
     % Add signature
     sig = imread('/home/bakkumd/Documents/PPT/O-Pictures/logos/signature.png');        
     sig_axes = axes('Position',[.875 .0 .11 .03]);
     imagesc(sig), axis equal off
     
     % Set up axes for text
     TEXT_AX = axes('Position',[.28 .09 .8 .9]);
     axis([100 2000 50 2150]);
     axis ij equal off
     
     % Set up plot axes and figure dimensions
     paper_w = 825;
     paper_h = 690;
     AX = axes('Position',[.28 .09 .8 .9]);
else
     paper_w = 670;
     paper_h = 690;
     AX = axes('Position',[.1  .15  .8 .8]);    
end
%      set(gcf,'Position',[1700 150 paper_w paper_h])
%      set(gcf,'PaperPosition',[0 0 [paper_w paper_h]/70/3])
%      set(gcf,'PaperSize',[paper_w paper_h]/70/3)
     
     figure_size(paper_w/75,paper_h/75,'linewidth',1)
     
     fontsize = 5; 

       
    % Set up colorbar
    cpos  = [.365 .07 .625 .02];  
    CB_AX = axes('Position',cpos);
    depth = 64;
    
    map   = mkpj(depth,'J_DB');              % modified by me to add more red (perceptually balanced colormaps)
    
    
    for c=1:depth
            fill( ([0 0 1 1 0]/depth+(c-1)/depth)*(UpperLim-LowerLim)+LowerLim,[0 1 1 0 0],map(c,:),'edgecolor',map(c,:)); hold on
    end
    set(gca,'ytick',[],'xtick',[LowerLim:5:UpperLim])
    %xlabel 'Voltage [uV]                 '
    figure_fontsize(fontsize,'bold')
    axes(AX)



    clr1    =  mkpj(UpperLim-LowerLim+1,'J_DB');              % modified by me to add more red (perceptually balanced colormaps)
    %clr1    =  mkpj(ul-ll+1,'JetI');             % perceptually balanced colormaps
    %  colormap(flipud( lbmap(128,'RedBlue') ))   % colormaps for the colorblind

            

% ----------------------------------------------------------------------- %    
    
cnt = 0; % Loop count for numbering saved pictures in order

while i<=size(mtraw,2)-1
   i=i+1;    

% %%
% i=130
% for iii = i
   
    cla % clear fig objects
    hold off
    tar=target(:,i);
    tar(tar<LowerLim)=LowerLim;
    tar(tar>UpperLim)=UpperLim;
        
    % Fill non-connected elc with average of connected neighbors
    if FILLALL
        for j=zz 
            [x y]    = el2position(j-1);
            if x==-1,   continue; end % dummy electrode
            xx       = find( (ELC.X(ok)-x).^2+(ELC.Y(ok)-y).^2 < fillall_rng^2 ); % get neighbor electrodes
            tar(j,:) = mean( tar(ok(xx),:) );
        end
    end
    
    % Smooth with a gaussian-like function
    if GAUS
        gaus_rng = 25; % [um] - corresponds to 1st neighboring ring of electrodes
        for j=0:11015 
            [x y]    = el2position(j);
            if x==-1, continue; end % dummy electrode
            d_sq     = (ELC.X-x).^2+(ELC.Y-y).^2;
            xx       = find( d_sq < gaus_rng^2  &  d_sq > 0); % get neighbor electrodes
            tar(j+1,:) = ( mean( tar(xx,:) ) + tar(j+1,:) )/2;
        end
    end
        
        
    % Plot
    if FILL      
        % Use 'FILL' to plot electrodes at high resolution
        %for j=0:11015
        for j= unique(Info.Map.el(Info.Map.el>-1))'  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            [x y]=el2position(j);  
            if x==-1;           continue, end % dummy electrode
            if isnan(tar(j+1))  continue, end % not sure problem here ...
            cc = clr1(round(tar(j+1))-LowerLim+1,:);
            if x>limit.x_max || x<limit.x_min, if FILLGRAY, cc = [1 1 1]*.4; else, continue; end, end
            if y>limit.y_max || y<limit.y_min, if FILLGRAY, cc = [1 1 1]*.4; else, continue; end, end
            h=fill([ -elc_dimx -elc_dimx  elc_dimx  elc_dimx ]/2+x, [ -elc_dimy elc_dimy elc_dimy -elc_dimy]/2+y, cc, 'edgecolor', 'none' , 'linewidth', 1); 
            %set(h,'facealpha',.5)
            hold on
        end
        
    else
        % Use 'IMAGESC' to plot electrodes quickly
        id = find(ELC.X>0); % ignor dummy electrodes
        z  = griddata(ELC.X(id),ELC.Y(id),tar(id),sx,sy,'cubic');  
        imagesc(sx(1,:),sy(:,1),z);  
        axis(ax_)

        % hold on
        % plot(x,y,'k')

        %  scatter(ELC.X(ok),ELC.Y(ok),40,tar(ok),'filled'); set(gca,'YDir','reverse')
        %    z=griddata(ELC.X,ELC.Y,target(:,i),sx,sy);  
        %    z=griddata(ELC.X(ok),ELC.Y(ok),min( target(ok,max([34 i-40]):i)'),sx,sy,'cubic');                          % binned to see trajectories of axons
        %    z=griddata(ELC.X(id),ELC.Y(id),min( target(id,(Info.Parameter.TriggerTimeZero+10):end)' ),sx,sy,'cubic');  % overall evoked
        %    z=griddata(ELC.X(ok),ELC.Y(ok),max( target((ok),i:i+3 )' ) - min( target((ok),i:i+2 )' ),sx,sy,'cubic');  
        %    z=griddata(ELC.X(ok),ELC.Y(ok),min( target((ok),120:i)' )-max( target((ok),120:i)' ),sx,sy,'cubic');  
        %    scatter(ELC.X(ok),ELC.Y(ok),13,target(ok,i),'filled'); set(gca,'YDir','reverse')
        %    scatter(ELC.X(ok),ELC.Y(ok),30,target(ok,i),'filled'); set(gca,'YDir','reverse')
        %    scatter(ELC.X(ok),ELC.Y(ok),30,min( target(ok,32:80)'  ),'filled'); set(gca,'YDir','reverse')
              %axis([min(ELC.X(ok)) max(ELC.X(ok)) min(ELC.Y(ok)) max(ELC.Y(ok))])

    end
    
    
    % Overlay an image stored in 'im' variable
    if OVERLAY 
        im_m=max(max(im));
        imagesc(im-im_m+LowerLim-1)
        axis equal
        axis ij
        alpha(.55)

        clr0=gray(im_m);
        clr=[clr0; clr1];
        colormap(clr)
        caxis([-im_m+LowerLim UpperLim])
    else    
        colormap(clr1)
        caxis([LowerLim UpperLim])
    end


    if exist('stim_x','var')
        hold on
        plot(stim_x,stim_y,'w+','markersize',10,'linewidth',3)
        hold off
    end
    titlename = ['Time since stimulation: ' num2str((i-Info.Parameter.TriggerTimeZero)/20,'%3.2f') ' msec.  Sample: ' num2str(i,'%3.0f')];
    title(titlename)
    disp(titlename)
       
    if NOTATE,
        axis off
        title off          
        notateMovie(Info,TEXT_AX,AX);
    end
        
        
        
%         %%
    box on
    axis equal ij %off
    axis(ax_);
    ylabel 'Position [um]'

    if SAVE
        set(gca,'xTickLabel',{})
        figure_fontsize(fontsize,'bold')
        desc = '';
        if FILL,     desc = [desc '-scatter']; end
        if FILLALL,  desc = [desc '-fillall']; end
        if GAUS,     desc = [desc '-gaus'];    end
        if NOTATE,   desc = [desc '-notate'];  end
        if OVERLAY,  desc = [desc '-overlay']; end

        filename=sprintf('%spics/%s%s_2_%03d',DIR,Info.Exptitle,desc,cnt);
        % filename=sprintf('%spics/blank', DIR )
        % filename=sprintf('%spics/blank_white_%s', DIR, Info.Exptitle   )
        cnt=cnt+1;
        set(gcf,'inverthardcopy','off')
        set(gcf,'color','w')
        print('-dpng','-r300',[filename '.png']) 
        disp 'Saved.'
    end
    
    drawnow
    if PLOTMIN || PAUSE, pause; end
    
end
% 
% hold on
% [x y]=el2position(elct);
% plot(x,y,'ks')
% elct = clickelectrode;



%% Make movie from still images saved above


   filename_i = [DIR 'pics/' Info.Exptitle desc '_']
   filename_o = [DIR  Info.Exptitle desc '_']

   mencoder = '/usr/local/hierlemann/mplayer/bin/mencoder';


    %%%%  2 pass encoding
    %%%%  http://mariovalle.name/mencoder/mencoder.html

    opt = 'vbitrate=2160000:mbd=2:keyint=132:vqblur=1.0:cmp=2:subcmp=2:dia=2:mv0:last_pred=3'
    % opt = 'vbitrate=2160000:mbd=2:keyint=132:v4mv:vqmin=3:lumi_mask=0.07:dark_mask=0.2:mpeg_quant:scplx_mask=0.1:tcplx_mask=0.1:naq'

    cmd1 = [ mencoder ' -ovc lavc -lavcopts vcodec=msmpeg4v2:vpass=1:' opt ' "mf://' filename_i '*.png"  -mf fps=20 -nosound -o /dev/null  ']
    cmd2 = [ mencoder ' -ovc lavc -lavcopts vcodec=msmpeg4v2:vpass=2:' opt ' "mf://' filename_i '*.png"  -mf fps=20 -nosound -o ' filename_o '.avi ']

    system(cmd1)
    system(cmd2)

    
%    cmd=['/usr/local/hierlemann/mplayer/bin/mencoder "mf://' filename_i '*.png" -mf fps=20 -o ' filename_o '.avi -ovc lavc -lavcopts vcodec=msmpeg4v2:vbitrate=800']
%    % To scale, use the '-vf scale=width:height' option.
%  
%    system(cmd)


%   PLAY using
%               system('mplayer filename')
%               system(['mplayer ' filename_o '.avi'])

%% Combine images using imagemagick montage command line tool

DIR      = '/home/bakkumd/Movies/';
FOLD     = 'pics/';
frameIn1 = ['130626-B-fillall-gaus_2'];
frameIn2 = ['130626-I-fillall-gaus_2'];
frameOut = ['130626-BI'];

SCALE    = 100;  % [percent]

for c = 15:250
    cmd = sprintf('montage -geometry %i%% %s%s%s_%03d.png %s%s%s_%03d.png %s%s%s_%03d.png ', ...
                           SCALE,               ...
                           DIR,FOLD,frameIn1,c, ...
                           DIR,FOLD,frameIn2,c, ...
                           DIR,FOLD,frameOut,c);
    system(cmd);
    if ~mod(c,10), fprintf('%i\n',c); end
end



%% ... next make a movie.



filename_i = [DIR FOLD frameOut '_'];
filename_o = [DIR frameOut];

cmd=['/usr/local/hierlemann/mplayer/bin/mencoder "mf://' filename_i '*.png" -mf fps=20 -o ' filename_o '.avi -ovc lavc -lavcopts vcodec=msmpeg4v2:vbitrate=800']
% To scale, use the '-vf scale=width:height' option.
  
system(cmd)



%% Plot overall to find evoked soma - step 1

figure

range = 250; % [um] 
id = find(ELC.X>0 & electrode_distance(Info.Parameter.StimElectrode,0:11015)>range); % ignor dummy electrodes and elc close to stim
%id = find(ELC.X>0 & electrode_distance(Info.Parameter.StimElectrode,0:11015)>range & ELC.Y>400); 
z  = griddata(ELC.X(id),ELC.Y(id),min( target(id,(Info.Parameter.TriggerTimeZero+10):end)' ),sx,sy,'cubic');  % overall evoked
z(isnan(z))=0;
imagesc(sx(1,:),sy(:,1),z);
axis equal ij
colorbar

ul = -80;
ll = -300;
caxis([ll ul])
hold on
plot(stim_x,stim_y,'w+','markersize',10,'linewidth',3)

%z(z<ll)=ll;
z(z>ul)=ul;




 %% create an interpolated grid and find voltage peaks and valleys - step 2

hold on

img=z;%gaussianblur(z,1);
%img=ones(4)
clr=[1 1 1]*.3;
    
rng=2;
vllys=zeros(size(img)); clear elc_with_neuron; n_cnt=0;
peaks=zeros(size(img));
img=padarray(img,[rng rng]);
[i j]=size(img);
for ii=rng+1:i-rng
    disp([num2str(ii) '/' num2str(i-rng)])
    for jj=rng+1:j-rng
        tst=img(ii-rng:ii+rng, jj-rng:jj+rng);  
        tst(rng+1,rng+1)=0;
        if img(ii,jj)<min(min(tst))
            vllys(ii-rng,jj-rng)=1;
            %plot(ii-rng+300,jj-rng+300,'*k')
            xxx=sx(1,jj-rng);
            yyy=sy(ii-rng,1);
            plot(xxx,yyy,'.k','color',clr)
   
            n_cnt=n_cnt+1;         
            [m m_id]=min((ELC.X-xxx).^2+(ELC.Y-yyy).^2);
            plot(ELC.X(m_id),ELC.Y(m_id),'ok','color',clr)
            elc_with_neuron(n_cnt)=m_id-1;
             text(ELC.X(m_id),ELC.Y(m_id),[int2str( m_id-1 )],'fontsize',10,'horizontalalignment','left','color',clr)
        end
        if img(ii,jj)>max(max(tst))
            peaks(ii-rng,jj-rng)=1;
            %plot(ii-rng+300,jj-rng+300,'*k')
            xxx=sx(1,jj-rng);
            yyy=sy(ii-rng,1);
            plot(xxx,yyy,'.k','color',clr)
   
            n_cnt=n_cnt+1;         
            [m m_id]=min((ELC.X-xxx).^2+(ELC.Y-yyy).^2);
            plot(ELC.X(m_id),ELC.Y(m_id),'ok','color',clr)
            elc_with_neuron(n_cnt)=m_id-1;
             text(ELC.X(m_id),ELC.Y(m_id),[int2str( m_id-1 )],'fontsize',10,'horizontalalignment','left','color',clr)
        end
    end
end
hold off
%imagesc(sx(1,:),sy(:,1),vllys)
disp(['Number of neurons: ' num2str(n_cnt)])
            


% Print to screen
fprintf('Tmp = [')
for i = elc_with_neuron, fprintf('%i ',i), end
fprintf('];\n\n')

title(Info.Exptitle)



%%

% % % make random spaced configuration
% clear elc_with_
% spacing          =              100; % number of electrodes to be spaced apart
% elc_with_        = round(rand*NELC); % initialize first value
% e_               = round(rand*NELC); % initialize
% [x y]            = el2position(e_);  % initialize
% for el=1:100-length(Tmp)
%     d = 0;
%     while min(d)<spacing % ||  y + (max(ELC.X) - x ) > 3000
%         e_    = round(rand*NELC); 
%         [x y] = el2position(e_);
%         d     = electrode_distance(e_,elc_with_);
%     end
%     elc_with_(end+1) = e_;
% end

% % % 130628-A
% % Tmp = [153 203 1581 1937 1917 1986 2291 2396 2879 3556 4224 4236 4319 4678 4881 7733 8175 8443 8593 8737 9391 9692 9763 10205 10232 10247 10451 10878 10987 ];
% % % 130628-B
% % Tmp = [1717 1733 2018 3599  9390 ];
% Tmp = [1717 1733 2018 3599  9390   153 203 1581 1937 1917 1986 2291 2396 2879 3556 4224 4236 4319 4678 4881 7733 8175 8443 8593 8737 9391 9692 9763 10205 10232 10247 10451 10878 10987];
% elc_with_neuron = unique([elc_with_  Tmp]);
% stim_elc = [ 7376 9123 ];
% elc_with_neuron = [Tmp elc_with_];


% % % 130716-A
% TmpStim  = [171 375 4091 6078 6813 7018 7491 7833 8170 8369 8516 9229 9636 9609 10286 ];
% TmpSpont = [313 797 840 2162 2867 3962 3981 4747 4785 4753 4846 5041 4909 5262 5266 5205 5315 5578 5775 6309 6432 6827 6825 7051 6950 7218 7565 8005 8243 8265 8456 8518 8820 8871 9050 9178 9311 9909 10100 10286 10961 ];
% elc_with_neuron = [TmpStim TmpSpont];
% stim_elc        = 10439;

% % 130721-A
elc_with_neuron = [210 501 782 918 1022 1133 1439 1361 1577 1692 1863 1841 2091 1998 2056 2081 2203 2278 2275 2311 2381 2515 2569 2587 2669 2675 2691 2672 2695 2667 2785 2897 2886 3102 3100 3286 3422 3511 3487 3509 3624 3752 3711 3744 3796 3895 4225 4239 4306 4472 4530 4514 4713 4728 4635 4813 4819 4817 4967 4908 4912 5013 5215 5421 5345 5535 5519 5521 5619 6103 6256 6126 6242 6244 6254 6447 6556 6630 6558 6664 6646 6785 6733 6765 6767 7032 6884 7172 7196 7398 7476 7489 7499 7662 7803 7801 7975 8408 8534 8532 8607 8678 9359 9339 9811 9995 10013 10015 10080 10119 10131 10295 10400 10602 10434 10563 ];
stim_elc = 6063;


figure; hold on
[x y]=el2position(stim_elc);
plot(x,y,'rs')
[x y]=el2position(TmpStim);
plot(x,y,'g+')
[x y]=el2position(TmpSpont);
plot(x,y,'k.')
axis equal ij




%% make neuropos file


%   system(['rm -f ' neuroposfile])
%   system(['rm -f ' fnames{1} '*'])

Info.Exptitle = '130721-B'

neuroposfile=['/home/bakkumd/Data/configs/bakkum/neuroposFromMlab/' Info.Exptitle '.neuropos.nrk']
%neuroposfile=['/local0/bakkumd/configs/bakkum/neuroposFromMlab/' Info.Exptitle '.neuropos.nrk']
fid = fopen(neuroposfile, 'wt')
for i=1:length(elc_with_neuron)
    e=elc_with_neuron(i);
    [x y]=el2position(e);
    x=round(x);
    y=round(y);
    fprintf(fid, 'Neuron matlab%i: %i/%i, 10/10\n',i,x,y);
end
    
% stimulation electrodes    
for i=1:length(stim_elc)
    e=stim_elc(i);
    [x y]=el2position(e);
    x=round(x);
    y=round(y);
    fprintf(fid, 'Neuron matlab%i: %i/%i, 10/10, stim\n',i,x,y);
end
fclose(fid);
%  fclose('all')

%% execute NeuroDishRouter
    
ndr_exe='`which NeuroDishRouter`';

[pathstr, name, ext] = fileparts(neuroposfile);
[tmp, name]          = fileparts(name);
fnames{1}            = [pathstr '/' name];
neurs_to_take{1}     = [elc_with_neuron stim_elc];

cmd=sprintf('%s -n -v 2 -l %s -s %s\n', ndr_exe, neuroposfile, [pathstr '/' name])
system(cmd);


%% reload & visualize configuration

for fn=1:length(fnames)
    fname=[fnames{fn} '.el2fi.nrk2'];
    fid=fopen(fname);
    elidx=[];
    tline = fgetl(fid);
    while ischar(tline)
        [tokens] = regexp(tline, 'el\((\d+)\)', 'tokens');
        elidx(end+1)=str2double(tokens{1});
        tline = fgetl(fid);
    end
    fclose(fid);
    
    %els=hidens_get_all_electrodes(2);

    figure; % plot selected vs routed
    box on,    hold on;
    axis ij,   axis equal

    plot(ELC.X,ELC.Y,'.','color',[1 1 1]*.8)
    plot(ELC.X(neurs_to_take{fn}+1),ELC.Y(neurs_to_take{fn}+1),'sk')
    plot(ELC.X(elidx+1), ELC.Y(elidx+1), 'rx');
    
    title(fname)
    fprintf('Placed %i electrodes. Asked for %i electrodes. May have mismatches.\n', length(elidx), length(neurs_to_take{fn}))
end



[x y]=el2position(stim_elc);
plot(x,y,'rs')
[x y]=el2position(TmpStim);
plot(x,y,'g+')
axis equal ij


legend('all','requested','routed')











%
%
%% put into format to send to others for analysis

clear data
data.traces = mtraw;
data.x      = zeros(size(ELC.X));
data.y      = zeros(size(ELC.X));
data.x(ok)  = ELC.X(ok);            % use only connected electrodes
data.y(ok)  = ELC.Y(ok);

if 0,    
    save([Info.Exptitle '-' Info.Exptype '-DataForCSD.mat'],'data')
end











%%   %%    %%    OLD CODE   %%%     %%%    %%%%%%


%%  
%   ffmpeg -i ClumpSlowFast.mov -vcodec mpeg1video -s vga -b 4096k -r 2 ClumpSlow.mpg
%   ffmpeg -i ClumpSlowFast.moccv -r 2 -f image2 Clump-pics/images%05d.png
%   ffmpeg -i Clump-pics/images%05d.png -vcodec mpeg1video -s vga -b 4096k -vframes 28 ClumpFast.mpg
%   cat ClumpSlow.mpg ClumpFast.mpg > ClumpSlowFast.mpg 
%   ffmpeg -i ClumpSlowFast.mov -vcodec libx264 -s vga -b 4096k -threads 0 -f mp4 ClumpSlowFast.mp4
%   ffmpeg -i ClumpSlowFast.mpg -vcodec libx264 -s vga -b 4096k -threads 0 -f mp4 ClumpSlow.mp4
% 
% ffmpeg -i ClumpSlowFast.mov -vcodec libx264 -s vga -b 4096k -threads 0 -f mp4 ClumpSlowFast.mp4
  
% resize
%    cmd=' find . -name "110516-C_*.jpg" | xargs -i convert -scale 50% {} ./resized/{} '

%  After creating image files, use ffmpeg
%
%  http://ubuntuforums.org/showthread.php?t=786095
%  "HOWTO: Install and use the latest FFmpeg and x264"
%
% %ffmpeg -i filename_%03d.jpg -vcodec libx264 -b 512k -bt 512k -r 25 -s vga -threads 0 -f mp4 filename.mp4
% cmd=['ffmpeg -y -i ' filename '_%03d.jpg -pass 1 -vcodec libx264 -vpre fastfirstpass -s vga -b 512k -bt 512k -threads 0 -f mp4 -an /dev/null && ffmpeg -i ' filename '_%03d.jpg -pass 2 -vcodec libx264 -vpre hq -b 512k -bt 512k -threads 0 -f mp4 ' filename '.mp4']

  %  cmd=['ffmpeg -i ' filename_i '_%03d.jpg -vcodec libtheora -s vga -b 4096k -threads 0 -vframes ' num2str(cnt) ' -f ogg ' filename_o '.ogg']
  %cmd=['ffmpeg -i ' filename_i '_%03d.jpg -vcodec libx264 -s vga -b 4096k -threads 0 -vframes ' num2str(cnt) ' -f mp4 ' filename_o '.mp4']
  %cmd=['ffmpeg -r 10 -i ' filename_i '_%03d.jpg -vcodec libx264 -b 4096k -threads 0 -vframes ' num2str(cnt) ' -f mp4 ' filename_o '.mp4']
  
  %  Jan's method to make movies:
%  mencoder "mf://*.png"                    -mf fps=10 -o   test.avi         -ovc lavc -lavcopts vcodec=msmpeg4v2:vbitrate=800
%  mencoder "mf://pics/110519-C_*.jpg"      -mf fps=10 -o   test.avi         -ovc lavc -lavcopts vcodec=msmpeg4v2:vbitrate=800
  %cmd=['mencoder "mf://' filename_i '*.jpg" -mf fps=20 -o ' filename_o '.avi -ovc lavc -lavcopts vcodec=msmpeg4v2:vbitrate=800']

  
%% create neuropos file for electrodes over an axon
% 
% 
%  
%     z=griddata(ELC.X(ok),ELC.Y(ok),min( target(ok,Info.Parameter.TriggerTimeZero+15:end)' ),sx,sy);  
%     imagesc(sx(1,:),sy(:,1),z);   axis([sx(1,[1 end]) sy([1 end],1)'])
% 
% 
% 
% 
% % 091120-B
% elc_with_neuron=[5441 5544 5545 5546 5753 5650 5754 5858 5859 6170 6168 6477 6783 6684 6993 7198 7401 6992 6995 7097 7714 7405 7710 8223 8221 8220 8421 8422 8323 8619 8515 8514];
% 
% %091123-A,B,D,E (from D) axon 1 (horizontal)
% elc_with_neuron=[7039 7142 7144 7247 7657     8079 7774 8081 7879 7778 7881 7885 7867 8094 7888 8097 8510 8511 8516 8518 5420 8422 8426 8529 8636 8637 8742  8639 8849 8750 8649 8651 8653 8770 8567];
% start_s=65; start_t=(start_s-Info.Parameter.TriggerTimeZero)*.05;
% 
% %091206-D
% elc_with_neuron=[8027 7823 7822 7209 6902 6595 6391 6084 5880 5777 5677 5268 5267 5062 4960 4756 4451 4348 4349 3942 3941 3634 3632 3117 3119     2806 2703 2498 2188 2290 2091 ];
% start_s=35; start_t=(start_s-Info.Parameter.TriggerTimeZero)*.05;
% stimsites=[Info.Parameter.StimElectrode 4396 8562 8178 ];
% 
% %091227-Dtest (named 091227-C)
% elc_with_neuron=[2057];
% stimsites=[Info.Parameter.StimElectrode  9135 6991 ];
% 
% %091227-D
% elc_with_neuron=[4950 4951 4851 4541 4134 3929 3522 3317 3114 3115 3012 3011 2601 2298 1990 1888 1682 1884 1469 1468 1568 1567 1666 1764 1763 1762 1962 1960 1857 2161 2057     1755 1453 1353 1456 1457 1356 1358 1359 1565 1667 1973 1872 1977 2181 2182 2387 2593 2798 2900 3005 3003 3007];
% stimsites=[3007 6991 2057];
% 
% %100109-B,C
% elc_with_neuron=[2057 2056 2666 3012 5779];
% stimsites=[9637 3545 4585 3583 10819];
% 
% %101012-A3
% % dap   rawH< -60mV
% % dap   rawH<-200mV
% % sap spikeH<-200mV
% dap_60 =[         76          41          19         142         230         364         567         857         957         978        1157        1286        1579        1871        1923        2121        2072        2205        2127        2535        2508        2510        2548        2600        2753        2917        3002        3208        3334        3417        3434        3564        3521        3508        3646        3729        3957        3966        3988        4161        4265        4644        5072        5046        5172        5264        5261        5243        5368        5362        5644        5543        5873        5860        5863        6686        6727        6903        7034        7106        7430        7472        7611        7736        8041        8019        8120        8337        8978        9091        9079        9280        9380        9572        9654        9883       10294       10685       10683];
% dap_200=[         41         229         261         856        1769        1922        2071        2102        2025        2507        2509        2497        3207        3461        3405        3728        3885        4643        4943        5161        5441        5771        5757        5862        6685        6931        7328        7508        8019        8018        8875        8989        9279        9379      10191    ];
% sap_200=[         376         494         632         640         935        1128        1048        1681        1867        1967        2033        2036        2251        2450        2563        2599        3011        3259        3309        3444        3471        3698        3873        3813        4058        4087        4102        4442        4624        4686        4902        4914        5012        5185        5466        5603        5515        5679        5865        6124        6207        6200        6269        6500        6470        6876        7254        7463        7403        7607        7811        7968        7987        8135        8416        8796        8914        8992        9115        9477        9649        9839       10074       10163       10328       10446       10460       10509       10511       10666       10694       10737       10674       10831       10856];
% elc_with_neuron=unique([dap_200 sap_200]);
% stimsites=[3124];
% 
% 
% %101121
% elc_with_neuron=[1520 2495 2636 5191 10586 10686 8802 9262];
% stimsites=[3224];
% 
% 
% %101122
% elc_with_neuron=[928 1134 1865 1968 1869 1668 4333 5240 4256 4456 4659 6281 6970 10042 6031 4310 3018 269 3882 514];
% stimsites=[1867];
% 
% %110312
% elc_with_neuron=[9808 9616 9830 10521 10933 10732 10124 10136 10640 10435];
% stimsites=[10019];
% 
% 
% 
% 
% [x y]=el2position(elc_with_neuron);
% figure
% %plot(x,y,'.')
% scatter(x,y,15,1:length(x),'filled')
% set(gca,'YDir','reverse','Color',[1 1 1]*.6)
%     hold on
% [x y]=el2position(stimsites);
%     plot(x,y,'k+','markersize',10)
%     hold off
%     box off
%     axis equal
% 
% 
% neuroposfile=['/home/bakkumd/Data/configs/bakkum/neuroposFromMlab/' Info.Exptitle '.neuropos.nrk']
% fid = fopen(neuroposfile, 'wt');
% 
% for i=1:length(elc_with_neuron)
%     e=elc_with_neuron(i);
%     [x y]=el2position(e);
%     fprintf(fid, 'Neuron matlab%i: %i/%i, 10/10\n',i,x,y);
% end
% for i=1:length(stimsites)
%     e=stimsites(i);
%     [x y]=el2position(e);
%     fprintf(fid, 'Neuron matlab%i: %i/%i, 10/10, stim\n',i+1,x,y);
% end
%     
% fclose(fid);


%%
%%
%%
%%
% ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
%%
%%
%%
%%
%%
%%
% %%  plot block and non-block on same figure and save 
% %   comparing C to D
% 
% %   mm=0;
%     mm=mm+1;
% mtraw_multi{mm}=ftraw;
% 
% 
% 
% %%  Do for comparison of N data sets
% N=2;
% %set(gcf,'Position',[1 257 300*N+300 500])
% %set(gcf,'Position',[1 257 1200 500])
% %%
% %figure(111)
% %set(gcf,'visible','off');
% SAVE= 0 ;
% ll = -50; % cutoff
% ul = 15;  % cutoff
% cnt = 0;
% for i=100:210%size(mtraw,2)
%     disp(i)
%     
%     
%     subplot(1,N,1)
%     %z=griddata(ELC.X(:),ELC.Y(:),tgaus_non(:,i),sx,sy); 
%     %z=griddata(ELC.X(:),ELC.Y(:),mtraw_multi{1}(:,i),sx,sy); 
%     z=griddata(ELC.X(ok),ELC.Y(ok),mtraw_multi{1}(ok,i)',sx,sy);  
%     imagesc(sx(1,:),sy(:,1),z)
% %    scatter(ELC.X(ok),ELC.Y(ok),75,mtraw_block1(ok,i),'filled');
%     set(gca,'YDir','reverse')    
%     caxis([ll ul])
%     axis equal
%     hold on; plot(stim_x,stim_y,'k+','markersize',4);  hold off
%     set(gca,'Color',[1 1 1]*.6)
%     box off
%     %axis([sx(1,[1 end]) sy([1 end],1)'])
%     title(['090409   ' num2str((i-Info.Parameter.TriggerTimeZero)/20,'%3.2f') ' msec.  Sample: ' num2str(i,'%3.0f')])
%    
%     colorbar
%     
%     for n=2:N
%     subplot(1,N,n)
%     %z=griddata(ELC.X(:),ELC.Y(:),tgaus_blk(:,i),sx,sy);  
%     %z=griddata(ELC.X(:),ELC.Y(:),mtraw_multi{n}(:,i),sx,sy);  
%     z=griddata(ELC.X(ok),ELC.Y(ok),min( mtraw_multi{n}(ok,max([28 i-40]):i)' ),sx,sy);  
%     imagesc(sx(1,:),sy(:,1),z)
% %    scatter(ELC.X(ok),ELC.Y(ok),75,mtraw_block2(ok,i),'filled'); 
%     set(gca,'YDir','reverse')
%     caxis([ll ul])
%     axis equal
%     hold on; plot(stim_x,stim_y,'k+','markersize',4);  hold off
%     set(gca,'Color',[1 1 1]*.6)
%     box off
%     %axis([sx(1,[1 end]) sy([1 end],1)'])
%     %title(['+blockers'])
%     title(['090409']) 
%     
%     colorbar
%     
%     end
%     
%     
%     
% %     subplot(1,4,3)
% %     %z=griddata(ELC.X(:),ELC.Y(:),tgaus_blk(:,i),sx,sy);  
% %     z=griddata(ELC.X(:),ELC.Y(:),mtraw_3(:,i),sx,sy);  
% %     imagesc(sx(1,:),sy(:,1),z)
% % %    scatter(ELC.X(ok),ELC.Y(ok),75,mtraw_block3(ok,i),'filled'); 
% %     set(gca,'YDir','reverse')
% %     caxis([ll ul])
% %     axis equal
% %     hold on; plot(stim_x,stim_y,'k+','markersize',4);  hold off
% %     set(gca,'Color',[1 1 1]*.6)
% %     box off
% %     %axis([sx(1,[1 end]) sy([1 end],1)'])
% %     %title(['+blockers'])
% %     title(['091123-D']) 
% %     
% %     subplot(1,4,4)
% %     %z=griddata(ELC.X(:),ELC.Y(:),tgaus_blk(:,i),sx,sy);  
% %     z=griddata(ELC.X(:),ELC.Y(:),mtraw_4(:,i),sx,sy);  
% %     imagesc(sx(1,:),sy(:,1),z)
% % %    scatter(ELC.X(ok),ELC.Y(ok),75,mtraw_block4(ok,i),'filled'); 
% %     set(gca,'YDir','reverse')
% %     caxis([ll ul])
% %     axis equal
% %     hold on; plot(stim_x,stim_y,'k+','markersize',4);  hold off
% %     set(gca,'Color',[1 1 1]*.6)
% %     box off
% %     %axis([sx(1,[1 end]) sy([1 end],1)'])
% %     %title(['+blockers'])
% %     title(['091123-E'])
%     
%     
%     
%     
%     
%     drawnow
%     pause(.005)
%     
%    if SAVE
%     if      cnt<10  filename = ['/home/bakkumd/Data/movies/pics/multi' Info.Exptitle '_00',int2str(cnt),'.jpg'];
%     elseif  cnt<100 filename = ['/home/bakkumd/Data/movies/pics/multi' Info.Exptitle '_0',int2str(cnt),'.jpg'];
%     else            filename = ['/home/bakkumd/Data/movies/pics/multi' Info.Exptitle '_',int2str(cnt),'.jpg'];
%     end
%     cnt=cnt+1;
%     set(gcf,'inverthardcopy','off')
%     %print('-djpeg','-r300',filename)
%     print('-djpeg','-r256',filename)
%    end
%     
% end
% 




%% try a median filter
% % subtract median value over window of xx samples for each sample
% wn=10;
% ftraw=zeros(size(mtraw));
% for k=wn+1:size(mtraw,2)-wn-1
%     ftraw(:,k)=mtraw(:,k)-median(mtraw(:,k-wn:k+wn)')';
% end
% 


%% try salpa to remove artifact
% %sraw=zeros(size(mtraw));
% sraw=mtraw;
% N=10;    % window to fit polynomial [samples]
% hold off
% %for N=5:15
% deg=3;   % polynomial order
% lim=Info.Parameter.TriggerLength; % [samples] limit of polynomial fit after starting
% start=-2*lim;
% for c=ok%1:size(mtraw,1)
% %for i=N+1:Info.Parameter.TriggerLength-N-1
% for i=N+1:Info.Parameter.TriggerLength-N-1
%     if( i>=start && i-start<=lim )
%         x=i-N:i+N;
%         y=mtraw(c,x);
%         p = polyfit(x,y,deg);
%         f = polyval(p,x);
%         if i==start
%             sraw(c,i-N:i)=mtraw(c,i-N:i)-f(1:N+1);
%         else
%             sraw(c,i)=mtraw(c,i)-f(N+1);
%         end
%         %disp(int2str(i))
%     end
%     if( sum(abs(mtraw(c,i-10:i)))==0 && mtraw(c,i+1)~=0 )
%         start=i;%+N;
%         %disp(['start ' int2str(i)])
%     end
% 
%         
% end
% disp(int2str(c))
% end
% %plot(sraw(c,:)','color',[1 1 1]*N/20); hold on
% %end






%% -- 131014-B                  - RFP neuron but stim scan   configs
%       
clear all; 
Info.Exptype                   = 'StimScan';
Info.Exptitle                  = '131014-B';
Info.Parameter.StimElectrode   = [4585];
Info.FileName.Trig             = ['/home/bakkumd/Data/raw/'              Info.Exptitle '.raw.trig'];
Info.FileName.Raw              = ['/home/bakkumd/Data/raw/'              Info.Exptitle '.raw'];
Info.FileName.TrigRawAve       = ['/home/bakkumd/Data/raw/'              Info.Exptitle '.averaged.traw'];
Info.FileName.SpikeForm        = ['/home/bakkumd/Data/spikes/spikeform/' Info.Exptitle '.spikeform'];
Info.FileName.Spike            = ['/home/bakkumd/Data/spikes/'           Info.Exptitle '.spike'];
Info.FileName.Map              = ['/home/bakkumd/Data/configs/bakkum/'   Info.Exptitle(1:6) '/' Info.Exptitle '_neuromap.m'];
Info.Parameter.NumberStim      = 30; % tells cpp code to look at epochs for averaging 
Info.Parameter.ConfigNumber    = 95; % *********
Info.Parameter.TriggerTimeZero = 61;
Info.Parameter.ConfigDuration  = 15;
Info.Parameter.TriggerLength   = Info.Parameter.ConfigDuration*20; % [samples]

