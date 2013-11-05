%  - - - - - - - - - - - %
%% analysis_SpontScan.m %%
%      Douglas Bakkum 
%      2008-2012
%
%   EXPERIMENT INFO IS AT THE BOTTOM OF THE PAGE
%   (so can more quickly navigate scripts)
%
%% %% %% %% %% %% %% %% %% %% %% %% %%  %%   %%     %%     %%    %%  %  % %
%% Start of script



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
 
if ~exist(Info.FileName.SpikeForm,'file')
    cmd=['`which FormatSpikeData` -a 127 -c -s '        Info.FileName.Spike ' -o ' Info.FileName.SpikeForm]
    system(cmd);
else
    %disp 'Error: File exists'
end
 
%% load spikeform


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
     
     
 %% find Spike peaks, using minimum of Spike heights (valleys in uV)
 %  also fill Spike.ELC info
 
 
%  CONDITIONS for good spikes:
min_num     =   5;  %* Info.Parameter.ConfigDuration/60      % minimum number of detected spikes to consider for calculating 'height' variable
min_epoch   =  -1;
min_hgt     = -60;                   % minimum Spike height
min_lat     =   0;%1200;                % [ms] avoid false Spike after configuration changes
                                     %  -- will not work for stim scan... blank in spikeform.cpp ?
                                     %  -- will not work for trig scan...    
                                     
% range of spikes to consider

good_spikes = find( Spike.clid==1  &  Spike.E>=min_epoch  &  Spike.H<=min_hgt  &  Spike.L>=min_lat ); % maybe using epoch is good to avoid false spikes after config change?

% max_lat=100;  disp 'WARNING: using max_lat. Press a button to continue.'; pause
% good_spikes = find( Spike.clid==1  &  Spike.E>=0  &  Spike.H<=min_hgt  &  Spike.L>min_lat & Spike.L<max_lat );

% good_spikes = find( Spike.clid==1  &  Spike.L>min_lat );
% good_spikes= find( Spike.clid==1  &  Spike.L>min_lat & Spike.L<Info.Parameter.ConfigDuration*1000-100 & Spike.H<0);
% good_spikes= find( Spike.clid==1  &  Spike.L>min_lat & Spike.L<Info.Parameter.ConfigDuration*1000-100);
% good_spikes = find( Spike.clid==1  &  Spike.E>=min_epoch  &  Spike.H<=-60  &  Spike.L>=1  &  Spike.L<=10 );
 

 % check if only 1 config (i.e. Spike.E is always -1)
 if max(Spike.E)==-1
     SINGLECONF=1;
     epoch_range=0;
 else
     SINGLECONF=0;
     epoch_range=0:max(Spike.E);
 end
 
 Spike.ELC  = zeros(size(Spike.E))-1;    
 height     = zeros(1,11016);
 max_height = zeros(1,11016);
 min_height = zeros(1,11016);
 nmbr       = zeros(1,11016); % FR = number/duration
 dur        = zeros(1,11016); % FR = number/duration
 for ee=epoch_range
     if ~SINGLECONF
         %eee=ee; 
         EE=find( Spike.E(good_spikes)==ee );
         AA=find( Spike.E             ==ee );
     else
         %eee=-1;
         EE=find( Spike.E(good_spikes)==-1 );
         AA=find( Spike.E             ==-1 );
     end
     
     
     xx=Info.Map.px([1:NCHAN]+ee*NCHAN);
     yy=Info.Map.py([1:NCHAN]+ee*NCHAN);
     c=Info.Map.ch([1:NCHAN]+ee*NCHAN);
     e=Info.Map.el([1:NCHAN]+ee*NCHAN);
     
     
     if ee==epoch_range(end) || SINGLECONF
         duration=Spike.T(AA(end))-Spike.T(AA(1)); 
     else
         duration=Spike.T(AA(end)+1)-Spike.T(AA(1));
     end
     
     for cc=0:NCHAN-1
        CC=find(Spike.C(good_spikes(EE))==cc);
        ID=find(c==cc,1);
        if ~isempty(CC) && ~isempty(ID)
          if length(CC)>min_num
            max_height(e(ID)+1) =    max([ Spike.H(good_spikes(EE(CC)))  repmat( height(e(ID)+1), 1, nmbr(e(ID)+1) )  ]);
            min_height(e(ID)+1) =    min([ Spike.H(good_spikes(EE(CC)))  repmat( height(e(ID)+1), 1, nmbr(e(ID)+1) )  ]);
                height(e(ID)+1) = median([ Spike.H(good_spikes(EE(CC)))  repmat( height(e(ID)+1), 1, nmbr(e(ID)+1) )  ]);
            %hold on
            %plot(xx(c(ID)+1),yy(c(ID)+1),'.');
          end
          Spike.ELC(good_spikes(EE(CC))) = e(ID);
          nmbr(e(ID)+1)          = nmbr(e(ID)+1) + length(CC);
          dur(e(ID)+1)           = dur(e(ID)+1)  + duration;
        end
     end 
     disp([int2str(ee)])
     %drawnow
 end
     
     
    spacingx=(max(ELC.X)-min(ELC.X))/length(unique(ELC.X))/4;
    spacingy=(max(ELC.Y)-min(ELC.Y))/length(unique(ELC.Y))/2;
    sx=min(ELC.X):spacingx:max(ELC.X);
    sy=min(ELC.Y):spacingy:max(ELC.Y);
    [sx,sy]=meshgrid(sx,sy);  
    
    

    
figure             % FIRING RATE
fr=zeros(1,11016); % firing rate
ID=find(dur>0);    % 
fr(ID)=nmbr(ID)./dur(ID);
scatter(ELC.X,ELC.Y,24,[1 1 1]*.8,'filled'); hold on
ID=unique(Info.Map.el(Info.Map.ok))+1;
scatter(ELC.X(ID),ELC.Y(ID),24,fr(ID),'filled'); hold off
    set(gca,'YDir','reverse','Color',[1 1 1]*.6)
    colorbar
    axis equal
    xlabel 'um'
    ylabel 'um'
    title([Info.Exptitle ' firing rate [Hz]'])    
    c=caxis; 
    ul=10; if ul>c(end), ul=c(end); end
    ll=0;  if ll<c(1),   ll=c(1);   end
    clr=[repmat([0 0 .5],ceil((ll-c(1))*10),1) ;  jet((ul-ll)*10) ; repmat([.5 0 0],ceil((c(end)-ul)*10),1)]; 
    colormap(clr)
    set(gcf,'position',[1800 350 500 370])
%     filename=['/home/bakkumd/Desktop/' Info.Exptitle '-fr']
%     print('-djpeg','-r128',filename)

    
figure             % HEIGHT
scatter(ELC.X,ELC.Y,24,[1 1 1]*.8,'filled'); hold on
ID=unique(Info.Map.el(Info.Map.ok))+1;%find(height~=0);
 scatter(ELC.X(ID),ELC.Y(ID),24,height(ID),'filled')
% scatter(ELC.X(ID),ELC.Y(ID),24,min_height(ID),'filled')
% scatter(ELC.X,ELC.Y,50,height,'filled')
% scatter(ELC.X,ELC.Y,50,min_height,'filled')
% scatter(ELC.X,ELC.Y,50,max_height,'filled')
    set(gca,'YDir','reverse','Color',[1 1 1]*.6)
    colorbar
    axis equal
    xlabel 'um'
    ylabel 'um'
    title([Info.Exptitle ' height [uV]'])    
    c=caxis; 
    ul= 100; if ul>c(end), ul=c(end); end
    ll=-300; if ll<c(1),   ll=c(1);   end
    clr=[repmat([0 0 .5],ceil((ll-c(1))*10),1) ;  jet((ul-ll)*10) ; repmat([.5 0 0],ceil((c(end)-ul)*10),1)]; 
    colormap(clr)
    set(gcf,'position',[1800 350 500 370])
%     filename=['/home/bakkumd/Desktop/' Info.Exptitle '-aveheight']
%     print('-djpeg','-r128',filename)
    
    
%% get valleys (~ neuron centers)


     
% ## need to not use unconnected or railed electrodes when forming z !!
    
    ll = -400;
    ul = -170;

    figure
    xx = find(ELC.X>0);
    z  = zeros(size(sx))-.0001;
    z  = griddata(ELC.X(xx),ELC.Y(xx),height(xx),sx,sy,'cubic');  
    z(isnan(z))=-0.0001;
    %zz=z-max(height(height<0)); zz(zz>=0)=-.0001;
    %  zz=z-max(height(:)); zz(zz>=0)=-.0001;
    %zz=log(-z); zz=-zz;
    z(find(z>ul))=ul; % avoid noise at low voltages (i.e. values < 5std)
    
    imagesc(sx(1,:),sy(:,1),z); hold on
    %imagesc(sx(1,:),sy(:,1),img); hold on
    
    %set(gcf,'Position',[1 257 671 691])
    colorbar%('location','east')
    box off
    axis equal

    caxis([ll ul])
    title(Info.Exptitle)
    
    
%% get valleys for firing rate    
    ll =  5;
    ul = 40;

    figure
    xx = find(ELC.X>0);
    z  = zeros(size(sx))-.0001;
    %z  = griddata(ELC.X(xx),ELC.Y(xx),fr(xx),sx,sy,'cubic');  
    z  = griddata(ELC.X(xx),ELC.Y(xx),nmbr(xx),sx,sy,'cubic');  
    z(isnan(z))=0;
    z(find(z>ul))=ul; % avoid
    z(find(z<ll))=ll; % avoid
    
    imagesc(sx(1,:),sy(:,1),z); hold on
    
    colorbar%('location','east')
    box off
    axis equal

    %caxis([ll ul])
    title(Info.Exptitle)
    
    
    
%% create an interpolated grid and find voltage peaks and valleys - step 2


img=gaussianblur(z,1);
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
            

% 
% %% plot Spike context for each found soma
% for e=elc_with_neuron
%     xx=find(Spike.ELC(good_spikes)==e);
%     plotspikecontext_CMOS(Info.FileName.Spike,good_spikes(xx),808,Spike.L(good_spikes(xx))/1000,[0 0 1],0); hold on
%     plot(Spike.L(good_spikes(xx))/1000,Spike.H(good_spikes(xx)),'.r'); hold off
%     title([Info.Exptitle ' elc' num2str(e)])
%     pause
% end


%% -- optimize figure

    %set(gcf,'Position',[1 257 671 691])
    colorbar%('location','east')
    box off
    axis equal
    
    ll= -400;
    ul=  0;
    caxis([ll ul])


    
%% make neuropos file 
% % if too many, randomly choose
%   neurons=elc_with_neuron;
%   rp=randperm(length(neurons));
%   elc_with_neuron=neurons(rp(1:150));
%neuroposfile=['/home/bakkumd/Data/configs/bakkum/bakkum/' Info.Exptitle '.neuropos.nrk']


% % make random spaced configuration
clear elc_with_neuron
spacing          =              100; % number of electrodes to be spaced apart
elc_with_neuron  = round(rand*NELC); % initialize first value
e_               = round(rand*NELC); % initialize
[x y]            = el2position(e_);  % initialize
for el=1:60
    d = 0;
    while min(d)<spacing % ||  y + (max(ELC.X) - x ) > 3000
        e_    = round(rand*NELC); 
        [x y] = el2position(e_);
        d     = electrode_distance(e_,elc_with_neuron);
    end
    elc_with_neuron(end+1) = e_;
end
figure
[x y]=el2position(elc_with_neuron);
plot(x,y,'.')
axis equal ij


    %%

% % if too many, choose largest spikes
%   [a b]= sort(height(elc_with_neuron+1));
%   elc_with_neuron = elc_with_neuron(b(1:130));

%   system(['rm -f ' neuroposfile])
%   system(['rm -f ' fnames{1} '*'])

%   elc_with_neuron = [ 10393 ];
%   stim_elc        = [ 8764 ];

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
legend('all','requested','routed')








%
%%
%
%
%
%%       old below      %%
%
%
%
%


%%
%     
%     %%
%     %% plot Spike context // sort spikes
%     
% 
%    
%     
% %     yyy=loadspikeCMOS(Info.FileName.Spike)
% %     yyy.time=yyy.time/25000;
% %     xx=find(yyy.time>250 & yyy.time<291 & yyy.channel==3);
%     
% %     for i=xx
% %     plot(yyy.context(:,i)-median(yyy.context(:,i))); hold on
% %     end
% %     hold off
%     
% nmbr    = zeros(size(elc_with_neuron));
% wdth20  = zeros(size(elc_with_neuron)); % width @ xx % of peak 
% wdth60  = zeros(size(elc_with_neuron));
% wdth80  = zeros(size(elc_with_neuron));
% wdth20h = zeros(size(elc_with_neuron)); % half width (from peak to point on return to baseline)
% wdth60h = zeros(size(elc_with_neuron));
% wdth80h = zeros(size(elc_with_neuron));
% hght    = zeros(size(elc_with_neuron)); % max value of signal
% vlly    = zeros(size(elc_with_neuron)); % valley == peak of AP (neg uV)
% bisi    =  ones(size(elc_with_neuron)); % ISI in bursts 
% stat_cnt=0;
% rcnstrct=4; % signal reconstruction factor (4->80kHz=20kHz*4)
% x=[-25:1/rcnstrct:48]/20; % x axis points [msec]
% 
% set(0,'DefaultFigurePosition',[30 512 400 400])
% for elc=6702%elc_with_neuron(11:end)
%     ff=figure(elc);
%     xx=find(Spike.ELC==elc & Spike.H<0);
%     clr=rand(1,3);
%     stat_cnt=stat_cnt+1;    
%     
%     if ~isempty(xx)
%     %context=zeros(length(xx),length(x));
%     context=zeros(length(xx),74); c_cnt=0;
%     nmbr(stat_cnt)=length(xx);   
%     
%     b=diff(Spike.T(xx));
%     bb=find(b<.2);
%     
%     if ~isempty(bb)
%     %bbb=hist(diff(Spike.T(xx)),[[0:.005:.25]]);
%     %[n id]=max(bbb(1:end-1));
%     %bisi(stat_cnt)=(id-1)*.005; 
%     bisi(stat_cnt)=mean(b(bb)); 
%     end
%     
%     for i=xx
%         hold on
%         c_cnt=c_cnt+1;
%         cntx=plotspikecontext_CMOS(Info.FileName.Spike,i,ff,Spike.T(i),clr);
%         %cntx=plotspikecontext_CMOS(Info.FileName.Spike,i,ff,0,clr);
%         %cntx=plotspikecontext_CMOS(Info.FileName.Spike,i,ff,0,0);
%         
%             % dc offset
%             first=cntx(1:15);
%             last=cntx(61:74);
%             dc1=mean(first);
%             dc2=mean(last);
%             v1=var(first);
%             v2=var(last);
%             dc=(dc1*v2+dc2*v1)/(v1+v2+1e-10);
%         context(c_cnt,:)=cntx-dc;%mean(cntx(5:10));
%         hold off
%     end
%     end
%     hold on
% 
%     plot(x/1000,y/abs(min(y)),'color',[1 1 1]*.7)%,'linewidth',2)
%     % % % reconstruct signal at 80kHz using Nyquist-Shannon sampling theorem
%     y=(reconstruct(context,rcnstrct));
%     % % % now need to align peaks
%     pkid=26*rcnstrct-1; % peak index
%     tmp=zeros(size(y));
%     for i=1:size(y,1)
%         [v id]=min(y(i,[20*rcnstrct:30*rcnstrct]));
%         id=id+20*rcnstrct-1;
%         if pkid-id>0
%             tmp(i,:)=[zeros(1,pkid-id) y(i,1:end-(pkid-id))];
%         elseif pkid-id<0
%             tmp(i,:)=[y(i,id-pkid+1:end) zeros(1,id-pkid)];
%         end
%     end
%     y=mean(tmp);
%     %y=y/abs(min(y)); %y=-y/y(26);
%     plot(x/1000,y/abs(min(y)),'k')%,'linewidth',2)
%         
%     hold off
%     drawnow
%     
%     disp([num2str(elc) ' ' num2str(length(xx))])
%     
%     pause(1)
%     
%     
%     % find half-height width
%     int=.005;
%     xi = [-25:int:48]'/20; 
%     yi = interp1q(x',y',xi); 
%     st=round(length(yi)*.2);
%     fn=round(length(yi)*.5);
%     [pk pk_xi]=min(yi(st:fn)); 
%     pk_xi=pk_xi+st-1;
%       hh=pk*0.20;
%       [jnk w_pre] = min( (yi(1:pk_xi)-hh).^2 );
%       [jnk w_post]= min( (yi(pk_xi+1:end)-hh).^2 );
%       w_post=w_post+pk_xi;
%     wdth20(stat_cnt)  = (xi(w_post)-xi(w_pre)); % [ms]
%     wdth20h(stat_cnt) = (xi(w_post)-xi(pk_xi)); % [ms]
%     
%       hh=pk*0.60;
%       [jnk w_pre] = min( (yi(1:pk_xi)-hh).^2 );
%       [jnk w_post]= min( (yi(pk_xi+1:end)-hh).^2 );
%       w_post=w_post+pk_xi;
%     wdth60(stat_cnt)  = (xi(w_post)-xi(w_pre)); % [ms]
%     wdth60h(stat_cnt) = (xi(w_post)-xi(pk_xi)); % [ms]
%     
%       hh=pk*0.80;
%       [jnk w_pre] = min( (yi(1:pk_xi)-hh).^2 );
%       [jnk w_post]= min( (yi(pk_xi+1:end)-hh).^2 );
%       w_post=w_post+pk_xi;
%     wdth80(stat_cnt)  = (xi(w_post)-xi(w_pre)); % [ms]
%     wdth80h(stat_cnt) = (xi(w_post)-xi(pk_xi)); % [ms]
%     
%     vlly(stat_cnt)=-pk;
%     hght(stat_cnt)=max(y);
%     
%     
% end
%     
%     
%     
% %
% %
% %% 1 config movie
% 
% tbin  = 180; % sec
% tstep = 60; % sec
% colormap pink;
% 
% steps=[0:tstep:Spike.T(end)-tbin];
% PLOT=1;
% SAVE=1;
% step_height=zeros(length(ELC.X),length(steps));
% cnt=0;
% for t=steps
%     tt=find(Spike.T>t & Spike.T<t+tbin & Spike.H<0);
%     cnt=cnt+1;
%      ee=Spike.E(1);
%      xx=Info.Map.px([1:NCHAN]+ee*NCHAN);
%      yy=Info.Map.py([1:NCHAN]+ee*NCHAN);
%      c=Info.Map.ch([1:NCHAN]+ee*NCHAN);
%      e=Info.Map.el([1:NCHAN]+ee*NCHAN);
%      
%      for cc=0:NCHAN-1
%         CC=find(Spike.C(tt)==cc);
%         ID=find(c==cc,1);
%         if ~isempty(CC) && ~isempty(ID)
%           if length(CC)>5 
%              step_height(e(ID)+1,cnt)=mean( Spike.H(tt(CC)) );
%           end
%         end
%      end 
%      
%      if PLOT
% %        z=zeros(size(sx));
% %        z=griddata(ELC.X,ELC.Y,step_height(:,cnt),sx,sy);  
% %        z(isnan(z))=0;
% %        imagesc(sx(1,:),sy(:,1),z);
%         rng=find(ELC.X<700 & ELC.X>500 & ELC.Y<400 &ELC.X>200);
%         scatter(ELC.X(rng),ELC.Y(rng),650,-step_height(rng,cnt),'filled')
%         set(gca,'YDir','reverse','Color',[1 1 1]*.4)
%     
%         axis([500 710 200 400])
%         colorbar
%         caxis([-250 -80])
%         caxis([80 240])
%         title([ int2str(round(t/60)) ' [min]' ])
%         
%         if SAVE
%             if      cnt<10  filename = ['/home/bakkumd/Data/Desktop/movieframes/spont' Info.Exptitle '_00',int2str(cnt),'.jpg'];
%             elseif  cnt<100 filename = ['/home/bakkumd/Data/Desktop/movieframes/spont' Info.Exptitle '_0',int2str(cnt),'.jpg'];
%             else            filename = ['/home/bakkumd/Data/Desktop/movieframes/spont' Info.Exptitle '_',int2str(cnt),'.jpg'];
%             end
%             set(gcf,'inverthardcopy','off')
%             %%%5print('-dtiff','-r150',filename) 
%             print('-djpeg','-r300',filename) 
%             % convert to jpg and use ffmpeg
%         else
%             pause(.3)
%         end
%      end
% end
% 
% %
% %%
% figure
% tmp=find(min(step_height')<0);
% % imagesc(step_height(tmp,:))
% plot(step_height(tmp,:)','.')
% 
% cnt=0; clear step_height_interp xxx step_height_smooth
% for i=tmp;
%   y=step_height(i,:);
%   if length(find(y<0))>10
%     cnt=cnt+1;
%     x=1:length(y);
%     xi=find(y<0);
%     y=y(xi);
%     step_height_interp(cnt,:)=interp1(xi,y,x);
%     step_height_smooth(cnt,:)=smooth(step_height(i,:),10);
%     step_height_smooth(cnt,:)=smooth(interp1(xi,y,x),10);
%     xxx(cnt)=i;
%   end
% end
% 
% 
% plot(steps/60/60,step_height_smooth','.')
% xlabel Time[hrs]
% ylabel Height[uV]
% title(Info.Exptitle)
% 
% 
% %
% %%
% figure
% xx=find(Spike.clid==1 & Spike.H<0 & (Spike.C==111 | Spike.C==107 | Spike.C==51 | Spike.C==46));
% scatter(Spike.T(xx),Spike.C(xx),5,Spike.H(xx))












%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%% %%%%%%%%%%%%%    EXPERIMENT INFORMATION BELOW   %%%%%%%%%%%%%%%%%%%%% %%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%
%% Spontaneous Scan
%



%%

clear all; 
pack;

%% -- 090423-B (291) 16DIV, 5k seeding
% !! MAY NOT have had amps set right -- A2 may have had 14kHz cutoff
% instead of 3.7kHz which may affect recordings with 20kHz sampling and
% affect Spike shape !!
clear all; Info.Exptype='SpontScan';
Info.Exptitle='090423-B'; 
% Info.Exptitle='090423-B-test';
% Info.Exptitle='090423-C-test';
Info.FileName.SpikeForm=['/home/bakkumd/Data/spikes/spikeform/' Info.Exptitle '.spikeform'];
Info.FileName.Spike=['/home/bakkumd/Data/spikes/' Info.Exptitle '.Spike'];
Info.FileName.Map='/home/bakkumd/Data/configs/bakkum/090423-spont-closeblock/seq090423_A__s_neuromap.m';
Info.Parameter.ConfigDuration=60; % configuration duration [sec]
%% -- 090423-C (253) 16DIV, 10k seeding
clear all; Info.Exptype='SpontScan';;
Info.Exptitle='090423-C'; 
Info.FileName.SpikeForm=['/home/bakkumd/Data/spikes/spikeform/' Info.Exptitle '.spikeform'];
Info.FileName.Spike=['/home/bakkumd/Data/spikes/' Info.Exptitle '.Spike'];
Info.FileName.Map='/home/bakkumd/Data/configs/bakkum/090423-spont-closeblock/seq090423_A__s_neuromap.m';
Info.Parameter.ConfigDuration=60; % configuration duration [sec]


%% -- 090526-A (291) 49DIV, 5k seeding
%  INCUBATOR CO2 ERROR!
%  Repeat of 090423-B
%  used higher resolution:
%       ADC  -> 65digi->1.04V range
%       Mosr -> 220/220
%       V2   -> 160
%       a1gain30fc20
%       a2gain30fc5
%       a3 buffer
clear all; Info.Exptype='SpontScan';
Info.Exptitle='090526_A'; 
Info.FileName.SpikeForm=['/home/bakkumd/Data/spikes/spikeform/' Info.Exptitle '.spikeform'];
Info.FileName.Spike=['/home/bakkumd/Data/spikes/' Info.Exptitle '.Spike'];
Info.FileName.Map='/home/bakkumd/Data/configs/bakkum/090423-spont-closeblock/seq090423_A__s_neuromap.m';
Info.Parameter.ConfigDuration=60; % configuration duration [sec]
  
%% -- 090528-A (253) 51DIV, 10k seeding
%  INCUBATOR CO2 ERROR!  --cells dying by end of Info.FileName.SpikeForm
%  Repeat of 090423-C
%  used higher resolution:
%       ADC  -> 65digi->1.04V range
%       Mosr -> 220/220
%       V2   -> 160
%       a1gain30fc20
%       a2gain30fc5
%       a3 buffer
clear all; Info.Exptype='SpontScan';
Info.Exptitle='090528-A'; 
Info.FileName.SpikeForm=['/home/bakkumd/Data/spikes/spikeform/' Info.Exptitle '.spikeform'];
Info.FileName.Spike=['/home/bakkumd/Data/spikes/' Info.Exptitle '.Spike'];
Info.FileName.Map='/home/bakkumd/Data/configs/bakkum/090423-spont-closeblock/seq090423_A__s_neuromap.m';
Info.Parameter.ConfigDuration=60; % configuration duration [sec]
  
%% -- 090529-A (253) 52DIV, 10k seeding
%  INCUBATOR CO2 ERROR!
%  used higher resolution:
%       ADC  -> 65digi->1.04V range
%       Mosr -> 220/220
%       V2   -> 160
%       a1gain30fc20
%       a2gain30fc5
%       a3 buffer
clear all; Info.Exptype='SpontScan';
Info.Exptitle='090529-A'; 
Info.FileName.SpikeForm=['/home/bakkumd/Data/spikes/spikeform/' Info.Exptitle '.spikeform'];
Info.FileName.Spike=['/home/bakkumd/Data/spikes/' Info.Exptitle '.Spike'];
Info.FileName.Map='/home/bakkumd/Data/configs/bakkum/090423-spont-closeblock/seq090423_A__s_neuromap.m';
Info.Parameter.ConfigDuration=60; % configuration duration [sec]
  

%% -- 090529-B (253) 52DIV, 10k seeding
%  * INCUBATOR CO2 ERROR!
%  * EPOCH ENCODING ERROR!
%  -- Can see neurite AP for couple ms before runs off grid. But have lots
%  of noise. Could be an EN considering the differences in FR per config...
%  -- Records from at least 2 neurons (based on diff in waveforms)
%  -- only 15sec per config, but Spike trig averaged also
%  used higher resolution:
%       ADC  -> 65digi->1.04V range
%       Mosr -> 220/220
%       V2   -> 160
%       a1gain30fc20
%       a2gain30fc5
%       a3 buffer
clear all
Info.Exptitle='090529-B';  
Info.Exptype='TrigScan'; 
Info.FileName.SpikeForm=['/home/bakkumd/Data/spikes/spikeform/' Info.Exptitle '.spikeform'];
Info.FileName.Spike=['/home/bakkumd/Data/spikes/' Info.Exptitle '.Spike'];
Info.FileName.Raw=['/home/bakkumd/Data/raw/' Info.Exptitle '.raw'];
Info.FileName.Trig=['/home/bakkumd/Data/raw/' Info.Exptitle '.raw.trig'];
Info.FileName.Map='/home/bakkumd/Data/configs/bakkum/090529-Spike-trig-ave/seq090529_A_s_neuromap.m';
%Info.FileName.Map='/home/bakkumd/Data/configs/bakkum/090529-Spike-trig-ave/seq090529_A_s_neuromap_el2fi.m'
Info.FileName.TrigRawAve       = ['/home/bakkumd/Data/raw/' Info.Exptitle '.averaged.traw'];
Info.Parameter.TriggerLength=200; % 0 to 10 ms (peaks not aligned in rawsrv...)
Info.Parameter.TriggerTimeZero=0;
Info.Parameter.StimElectrode=0;
Info.Parameter.ConfigDuration=15; %config duration seconds  !!
Info.Parameter.ConfigNumber=108;
Info.Parameter.NumberStim=0; % tells cpp code to look at epochs for averaging

%% -- 090606-A (204) 23DIV, 5k seeding
%  * INCUBATOR CO2 ERROR!
%  Good number of cells present.
%
%  used higher resolution:
%       ADC  -> 65digi->1.04V range
%       Mosr -> 220/220
%       V2   -> 160
%       a1gain30fc20
%       a2gain30fc5
%       a3 buffer
clear all; Info.Exptype='SpontScan';;
Info.Exptitle='090606-A'; 
Info.FileName.SpikeForm=['/home/bakkumd/Data/spikes/spikeform/' Info.Exptitle '.spikeform'];
Info.FileName.Spike=['/home/bakkumd/Data/spikes/' Info.Exptitle '.Spike'];
Info.FileName.Map='/home/bakkumd/Data/configs/bakkum/090423-spont-closeblock/seq090423_A__s_neuromap.m';
Info.Parameter.ConfigDuration=55; % configuration duration [sec]


%% -- 090606-B (204) 23DIV, 5k seeding
%  !! GARBAGE DATA !! --error with trig timing due to overlapping trig windows
%  used higher resolution:
%       ADC  -> 65digi->1.04V range
%       Mosr -> 220/220
%       V2   -> 160
%       a1gain30fc20
%       a2gain30fc5
%       a3 buffer
clear all
Info.Exptitle='090606-B';  
Info.Exptype='TrigScan'; 
Info.FileName.SpikeForm=['/home/bakkumd/Data/spikes/spikeform/' Info.Exptitle '.spikeform'];
Info.FileName.Spike=['/home/bakkumd/Data/spikes/' Info.Exptitle '.Spike']
Info.FileName.Raw=['/home/bakkumd/Data/raw/' Info.Exptitle '.raw.fixepoch']
Info.FileName.Trig=['/home/bakkumd/Data/raw/' Info.Exptitle '.raw.trig']
%Info.FileName.Map='/home/bakkumd/Data/configs/bakkum/090606-Spike-trig-ave/seq090606-B_s_neuromap.m'
Info.FileName.Map='/home/bakkumd/Data/configs/bakkum/090606-Spike-trig-ave/seq090606-B_s_neuromap_el2fi.m'
Info.Parameter.TriggerLength=400; % -10 to 10 ms
Info.Parameter.TriggerTimeZero=201;
Info.Parameter.StimElectrode=6978;


%% -- 090609-A (300) 26DIV, 1k (?) seeding
%  ~~ ONLY 1 NEURON! ~~
%  used higher resolution:
%       ADC  -> 100digi->1.6V range  ~~NEW~~
%       Mosr -> 220/220
%       V2   -> 160
%       a1gain30fc20
%       a2gain30fc5
%       a3 buffer
clear all; Info.Exptype='SpontScan';
Info.Exptitle='090609-A'; 
Info.FileName.SpikeForm=['/home/bakkumd/Data/spikes/spikeform/' Info.Exptitle '.spikeform'];
Info.FileName.Spike=['/home/bakkumd/Data/spikes/' Info.Exptitle '.Spike'];
Info.FileName.Map='/home/bakkumd/Data/configs/bakkum/090423-spont-closeblock/seq090423_A__s_neuromap.m';
Info.Parameter.ConfigDuration=55; % configuration duration [sec]

%% -- 090609-B (206) 26DIV, 1k (?) seeding
%  ~~ NO NEURONS ~~
%  used higher resolution:
%       ADC  -> 100digi->1.6V range  ~~NEW~~
%       Mosr -> 220/220
%       V2   -> 160
%       a1gain30fc20
%       a2gain30fc5
%       a3 buffer
clear all; Info.Exptype='SpontScan';
Info.Exptitle='090609-B'; 
Info.FileName.SpikeForm=['/home/bakkumd/Data/spikes/spikeform/' Info.Exptitle '.spikeform'];
Info.FileName.Spike=['/home/bakkumd/Data/spikes/' Info.Exptitle '.Spike'];
Info.FileName.Map='/home/bakkumd/Data/configs/bakkum/090423-spont-closeblock/seq090423_A__s_neuromap.m';
%% -- 090609-E (300) 26DIV, 1k (?) seeding
%  ONLY 1 NEURON   %   FPGA closed itself at config 86
%  *Too noisy* to see neurites. Good soma pulse.
%  used higher resolution:
%       ADC  -> 100digi->1.60V range  NEW
%       Mosr -> 220/220
%       V2   -> 160
%       a1gain30fc20
%       a2gain30fc5
%       a3 buffer
clear all
Info.Exptitle='090609-E';  
Info.Exptype='TrigScan'; 
Info.FileName.SpikeForm=['/home/bakkumd/Data/spikes/spikeform/' Info.Exptitle '.spikeform'];
Info.FileName.Spike=['/home/bakkumd/Data/spikes/' Info.Exptitle '.Spike']
Info.FileName.Raw=['/home/bakkumd/Data/raw/' Info.Exptitle '.raw']
Info.FileName.Trig=['/home/bakkumd/Data/raw/' Info.Exptitle '.raw.trig']
Info.FileName.TrigRawAve       = ['/home/bakkumd/Data/raw/' Info.Exptitle '.averaged.traw'];
Info.FileName.Map='/home/bakkumd/Data/configs/bakkum/090609-Spike-trig-ave/seq090609-C_s_neuromap.m'
Info.Parameter.TriggerLength=360; % -9 to 9 ms
Info.Parameter.TriggerTimeZero=181;
Info.Parameter.StimElectrode=944;
Info.Parameter.ConfigDuration=120; %config duration seconds
Info.Parameter.ConfigNumber=86;
Info.Parameter.ConfigNumber=108;
Info.Parameter.NumberStim=0; % tells cpp code to look at epochs for averaging



%% -- 090611-A (300) 28DIV, 1k (?) seeding
%  Noisy at end but neuron is at start so OK. Some responses within 2ms --
%  are these EPSPs or axon stuff? No traveling APs apparent.
%  ONLY 1 NEURON  in dish
%  used higher resolution:
%       ADC  -> 100digi->1.60V range  NEW
%       Mosr -> 220/220
%       V2   -> 160
%       a1gain30fc20
%       a2gain30fc5
%       a3 buffer
clear all
Info.Exptitle='090611-A';  
Info.Exptype='TrigScan'; 
Info.FileName.SpikeForm=['/home/bakkumd/Data/spikes/spikeform/' Info.Exptitle '.spikeform'];
Info.FileName.Spike=['/home/bakkumd/Data/spikes/' Info.Exptitle '.Spike']
Info.FileName.Raw=['/home/bakkumd/Data/raw/' Info.Exptitle '.raw']
Info.FileName.Trig=['/home/bakkumd/Data/raw/' Info.Exptitle '.raw.trig']
Info.FileName.TrigRawAve       = ['/home/bakkumd/Data/raw/' Info.Exptitle '.averaged.traw'];
Info.FileName.Map='/home/bakkumd/Data/configs/bakkum/090611-Spike-trig-ave/seq090611-A_s_neuromap.m'
Info.Parameter.TriggerLength=360; % -9 to 9 ms
Info.Parameter.TriggerTimeZero=181;
Info.Parameter.StimElectrode=1148;
Info.Parameter.ConfigDuration=55; %config duration seconds


%% -- 090611-B (300) 28DIV, 1k (?) seeding
%  1 NEURON -- 1 config only (not a scan)  -- See '1 config movie' section
%  for analysis.   Overnight recording.
%  used higher resolution:
%       ADC  -> 100digi->1.6V range  
%       Mosr -> 220/220
%       V2   -> 160
%       a1gain30fc20
%       a2gain30fc5
%       a3 buffer
clear all; Info.Exptype='SpontScan';
Info.Exptitle='090611-B'; 
Info.FileName.SpikeForm=['/home/bakkumd/Data/spikes/spikeform/' Info.Exptitle '.spikeform'];
Info.FileName.Spike=['/home/bakkumd/Data/spikes/' Info.Exptitle '.Spike'];
Info.FileName.Map='/home/bakkumd/Data/configs/bakkum/090611-Spike-trig-ave/seq090611-A_s_neuromap.m';

%% -- 090612-A (291) 66DIV, 
%  Overnight recording.
%  used higher resolution:
%       ADC  -> 100digi->1.6V range  
%       Mosr -> 220/220
%       V2   -> 160
%       a1gain30fc20
%       a2gain30fc5
%       a3 buffer
clear all; Info.Exptype='SpontScan';
Info.Exptitle='090612-A'; 
Info.FileName.SpikeForm=['/home/bakkumd/Data/spikes/spikeform/' Info.Exptitle '.spikeform'];
Info.FileName.Spike=['/home/bakkumd/Data/spikes/' Info.Exptitle '.Spike'];
Info.FileName.Map='/home/bakkumd/Data/configs/bakkum/090423-spont-closeblock/seq090423_A__s_neuromap.m';
Info.Parameter.ConfigDuration=4*60; % configuration duration
%% -- 090613-A (291) 67DIV -- repeat of 090612
clear all; Info.Exptype='SpontScan';
Info.Exptitle='090613-A'; 
Info.FileName.SpikeForm=['/home/bakkumd/Data/spikes/spikeform/' Info.Exptitle '.spikeform'];
Info.FileName.Spike=['/home/bakkumd/Data/spikes/' Info.Exptitle '.Spike']; %#ok<*NASGU>
Info.FileName.Map='/home/bakkumd/Data/configs/bakkum/090423-spont-closeblock/seq090423_A__s_neuromap.m';
Info.Parameter.ConfigDuration=4*60; % configuration duration
%% -- 090614-A (291) 68DIV -- repeat of 090612
clear all; Info.Exptype='SpontScan';
Info.Exptitle='090614-A'; 
Info.FileName.SpikeForm=['/home/bakkumd/Data/spikes/spikeform/' Info.Exptitle '.spikeform'];
Info.FileName.Spike=['/home/bakkumd/Data/spikes/' Info.Exptitle '.Spike'];
Info.FileName.Map='/home/bakkumd/Data/configs/bakkum/090423-spont-closeblock/seq090423_A__s_neuromap.m';
Info.Parameter.ConfigDuration=4*60; % configuration duration



%% -- 090615-A (291) 69DIV
%  used higher resolution:
%       ADC  -> 100digi->1.60V range  NEW
%       Mosr -> 220/220
%       V2   -> 160
%       a1gain30fc20
%       a2gain30fc5
%       a3 buffer
clear all
Info.Exptitle='090615-A';  
Info.Exptype='TrigScan'; 
Info.FileName.SpikeForm=['/home/bakkumd/Data/spikes/spikeform/' Info.Exptitle '.spikeform'];
Info.FileName.Spike=['/home/bakkumd/Data/spikes/' Info.Exptitle '.Spike'];
Info.FileName.Raw=['/home/bakkumd/Data/raw/' Info.Exptitle '.raw'];
Info.FileName.TrigRawAve       = ['/home/bakkumd/Data/raw/' Info.Exptitle '.averaged.traw'];
Info.FileName.Trig=['/home/bakkumd/Data/raw/' Info.Exptitle '.raw.trig'];
Info.FileName.Map='/home/bakkumd/Data/configs/bakkum/090615-Spike-trig-ave/seq090615-A_s_neuromap.m';
Info.Parameter.TriggerLength=360; % -9 to 9 ms
Info.Parameter.TriggerTimeZero=181;
Info.Parameter.StimElectrode=7358;
Info.Parameter.ConfigDuration=2*60; %config duration seconds


%% -- 090618-A (334) 35DIV 
%       ADC  -> 187digi->2.99V range  (default)
%       Mosr -> 220/220
%       V2   -> 160
%       a1gain30fc20
%       a2gain30fc5
%       a3 buffer
clear all; Info.Exptype='SpontScan';
Info.Exptitle='090618-A'; 
Info.FileName.SpikeForm=['/home/bakkumd/Data/spikes/spikeform/' Info.Exptitle '.spikeform'];
Info.FileName.Spike=['/home/bakkumd/Data/spikes/' Info.Exptitle '.Spike'];
Info.FileName.Map='/home/bakkumd/Data/configs/bakkum/090423-spont-closeblock/seq090423_A__s_neuromap.m';
Info.Parameter.ConfigDuration=1*60; % configuration duration

%% -- 090618-B (264) 35DIV 
%  used higher resolution:
%       ADC  -> 100digi->1.60V range
%       Mosr -> 220/220
%       V2   -> 160
%       a1gain30fc20
%       a2gain30fc5
%       a3 buffer
clear all; Info.Exptype='SpontScan';
Info.Exptitle='090618-B'; 
Info.FileName.SpikeForm=['/home/bakkumd/Data/spikes/spikeform/' Info.Exptitle '.spikeform'];
Info.FileName.Spike=['/home/bakkumd/Data/spikes/' Info.Exptitle '.Spike'];
Info.FileName.Map='/home/bakkumd/Data/configs/bakkum/090618-B-spont-closeblock/rand090618_B_s_neuromap.m';
Info.Parameter.ConfigDuration=6*60; % configuration duration


%% -- 090622-A (334) 39DIV 
%       ADC  -> 187digi->2.99V range  (default)
%       Mosr -> 220/220
%       V2   -> 160
%       a1gain30fc20
%       a2gain30fc5
%       a3 buffer
clear all; Info.Exptype='SpontScan';
Info.Exptitle='090622-A'; 
Info.FileName.SpikeForm=['/home/bakkumd/Data/spikes/spikeform/' Info.Exptitle '.spikeform'];
Info.FileName.Spike=['/home/bakkumd/Data/spikes/' Info.Exptitle '.Spike'];
Info.FileName.Map='/home/bakkumd/Data/configs/bakkum/090622-A-spont-closeblock/rand090622_A_s_neuromap.m';
Info.Parameter.ConfigDuration=2*60; % configuration duration


%% -- 090623-A (334) 40DIV  -- spontaneous 1 config - long term
%  network activity
%  Overnight recording.
%  used higher resolution:
%       ADC  -> 187digi->2.99V range  (default)
%       Mosr -> 220/220
%       V2   -> 160
%       a1gain30fc20
%       a2gain30fc5
%       a3 buffer
clear all; Info.Exptype='SpontScan';
Info.Exptitle='090623-A'; 
Info.FileName.SpikeForm=['/home/bakkumd/Data/spikes/spikeform/' Info.Exptitle '.spikeform'];
Info.FileName.Spike=['/home/bakkumd/Data/spikes/' Info.Exptitle '.Spike'];
Info.FileName.Map='/home/bakkumd/Data/configs/bakkum/090622-A-spont-closeblock/090622-A-foundneurons_neuromap.m';
Info.Parameter.ConfigDuration=28485; % configuration duration
%%
%% -- 090803-A (267) 20DIV 
% <20 neurons. although more if look at positive spikes...
%       ADC  -> 187digi->2.99V range  (default)
%       Mosr -> 220/220
%       V2   -> 160
%       a1gain30fc20
%       a2gain30fc5
%       a3 buffer
clear all; Info.Exptype='SpontScan';
Info.Exptitle='090803-A'; 
Info.FileName.SpikeForm=['/home/bakkumd/Data/spikes/spikeform/' Info.Exptitle '.spikeform'];
Info.FileName.Spike=['/home/bakkumd/Data/spikes/' Info.Exptitle '.Spike'];
Info.FileName.Map='/home/bakkumd/Data/configs/bakkum/bakkum/090803-spont/rand090803_A_s_neuromap.m';
Info.Parameter.ConfigDuration=6*60; % configuration duration%%

%% -- 090805-A (267) 22DIV -- 1 config only
%  used higher resolution:
%       ADC  -> 187digi
%       Mosr -> 220/220
%       V2   -> 160
%       a1gain30fc20
%       a2gain30fc5
%       a3 buffer
clear all
Info.Exptitle='090805-A';  
Info.Exptype='TrigScan'; 
Info.FileName.SpikeForm=['/home/bakkumd/Data/spikes/spikeform/' Info.Exptitle '.spikeform'];
Info.FileName.Spike=['/home/bakkumd/Data/spikes/' Info.Exptitle '.Spike'];
Info.FileName.Raw=['/home/bakkumd/Data/raw/' Info.Exptitle '.raw'];
Info.FileName.Trig=['/home/bakkumd/Data/raw/' Info.Exptitle '.raw.trig'];
Info.FileName.TrigRawAve       = ['/home/bakkumd/Data/raw/' Info.Exptitle '.averaged.traw'];
Info.FileName.Map  = '/home/bakkumd/Data/configs/bakkum/090805-spont/090805-A_neuromap.m';
Info.FileName.El2fi= '/home/bakkumd/Data/configs/bakkum/090805-spont/090805-A-el9817.el2fi.nrk2';
Info.Parameter.TriggerLength=200; % -5 to 5 ms
Info.Parameter.TriggerTimeZero=101;
Info.Parameter.StimElectrode=9817;
Info.Parameter.ConfigDuration=8*60; %config duration seconds
%length(Info.Trig.N)=960; % num trigs 


%% -- 090805-B (267) 22DIV -- 1 config only
%  used higher resolution:
%       ADC  -> 187digi
%       Mosr -> 220/220
%       V2   -> 160
%       a1gain30fc20
%       a2gain30fc5
%       a3 buffer
clear all
Info.Exptitle='090805-B'; 
Info.Exptype='TrigScan'; 
Info.FileName.SpikeForm=['/home/bakkumd/Data/spikes/spikeform/' Info.Exptitle '.spikeform'];
Info.FileName.Spike=['/home/bakkumd/Datad/Data/spikes/' Info.Exptitle '.Spike'];
Info.FileName.Raw=['/home/bakkumd/Data/raw/' Info.Exptitle '.raw'];
Info.FileName.Trig=['/home/bakkumd/Data/raw/' Info.Exptitle '.raw.trig'];
Info.FileName.TrigRawAve       = ['/home/bakkumd/Data/raw/' Info.Exptitle '.averaged.traw'];
Info.FileName.Map  = '/home/bakkumd/Data/configs/bakkum/090805-spont/090805-B_neuromap.m';
Info.FileName.El2fi= '/home/bakkumd/Data/configs/bakkum/090805-spont/090805-B-el5288.el2fi.nrk2';
Info.Parameter.TriggerLength=200; % -5 to 5 ms
Info.Parameter.TriggerTimeZero=101;
Info.Parameter.StimElectrode=5288;
Info.Parameter.ConfigDuration=8*60; %config duration seconds
%length(Info.Trig.N)=497; % num trigs 

%% -- 091227-H (339) 41DIV -- 1 config only
clear all
Info.Exptitle='091227-H'; 
Info.Exptype='TrigScan';  
Info.FileName.SpikeForm=['/home/bakkumd/Data/spikes/spikeform/' Info.Exptitle '.spikeform'];
Info.FileName.Spike=['/home/bakkumd/Data/spikes/' Info.Exptitle '.Spike'];
Info.FileName.Raw=['/home/bakkumd/Data/raw/' Info.Exptitle '.raw'];
Info.FileName.Trig=['/home/bakkumd/Data/raw/' Info.Exptitle '.raw.trig'];
Info.FileName.TrigRawAve       = ['/home/bakkumd/Data/raw/' Info.Exptitle '.averaged.traw'];
Info.FileName.Map  = '/home/bakkumd/Data/configs/bakkum/091227-stimscan/091227-E_neuromap.m';
Info.FileName.El2fi= '/home/bakkumd/Data/configs/bakkum/091227-stimscan/091227-E-el5288.el2fi.nrk2';
Info.Parameter.TriggerLength=300; % -5 to 10 ms
Info.Parameter.TriggerTimeZero=101;
Info.Parameter.StimElectrode=2057;
Info.Parameter.ConfigDuration=3*60; %config duration seconds
%length(Info.Trig.N)=338; % num trigs 

%% -- 100409-A (339) 149DIV 
%       ADC  -> 187digi->2.99V range  (default)
%       Mosr -> 220/220
%       V2   -> 160
%       a1gain30fc20
%       a2gain30fc5
%       a3 buffer
clear all; Info.Exptype='SpontScan';
Info.Exptitle='100409-A'; 
Info.FileName.SpikeForm=['/home/bakkumd/home/Data/spikes/spikeform/' Info.Exptitle '.spikeform'];
Info.FileName.Spike=['/home/bakkumd/home/Data/spikes/' Info.Exptitle '.Spike'];
Info.FileName.Map='/home/bakkumd/home/Data/configs/bakkum/100409/100409-A_neuromap.m';
Info.Parameter.ConfigDuration=1*60; % configuration duration



%% -- 100413-C (339) 154DIV  -- spontaneous 1 config - long term
%       ADC  -> 187digi->2.99V range  (default)
%       Mosr -> 220/220
%       V2   -> 160
%       a1gain30fc20
%       a2gain30fc5
%       a3 buffer
clear all; Info.Exptype='SpontScan';
Info.Exptitle='100413-C'; 
Info.FileName.SpikeForm=['/home/bakkumd/Data/spikes/spikeform/' Info.Exptitle '.spikeform'];
Info.FileName.Spike=['/home/bakkumd/Data/spikes/' Info.Exptitle '.Spike'];
Info.FileName.Map='/home/bakkumd/Data/configs/bakkum/100413/100413-B_neuromap.m';
Info.Parameter.ConfigDuration=[]; % configuration duration


%% -- 101121-E (588) -- spontaneous 1 config
clear all; Info.Exptype='SpontScan';
Info.Exptitle='101121-E'; 
Info.FileName.SpikeForm=['/home/bakkumd/Data/spikes/spikeform/' Info.Exptitle '.spikeform'];
Info.FileName.Spike=['/home/bakkumd/Data/spikes/' Info.Exptitle '.Spike'];
%Info.FileName.Map='/home/bakkumd/Data/configs/bakkum/101121/101121-C_neuromap.m';
Info.FileName.Map='/home/bakkumd/Data/configs/bakkum/101121/101121-C_neuromap.m';
Info.Parameter.ConfigDuration=37*60; % configuration duration

%% -- 101122-L (588) -- spontaneous 1 config
clear all; Info.Exptype='SpontScan';
Info.Exptitle='101122-L'; 
Info.FileName.SpikeForm=['/home/bakkumd/Data/spikes/spikeform/' Info.Exptitle '.spikeform'];
Info.FileName.Spike=['/home/bakkumd/Data/spikes/' Info.Exptitle '.Spike'];
Info.FileName.Map='/home/bakkumd/Data/configs/bakkum/101122/101122-E_neuromap.m'; 
Info.Parameter.ConfigDuration = NaN; % configuration duration



%% -- 101231-A (460) 17DIV  -- spontaneous stopped early around 5 configs
%% -- 101231-B (460) 17DIV  -- spontaneous stopped early around 14configs
%% -- 101231-C (460) 17DIV  -- spontaneous 
%       ADC  -> 187digi->2.99V range  (default)
%       Mosr -> 255/255
%       V2   -> 160
%       a1gain30fc20
%       a2gain30fc5
%       a3 buffer
clear all; Info.Exptype='SpontScan';
Info.Exptitle='101231-C'; 
Info.FileName.SpikeForm=['/home/bakkumd/Data/spikes/spikeform/' Info.Exptitle '.spikeform'];
Info.FileName.Spike=['/home/bakkumd/Data/spikes/' Info.Exptitle '.Spike'];
Info.FileName.Map='/home/bakkumd/Data/configs/bakkum/101231/101231-C_neuromap.m';
Info.Parameter.ConfigDuration=1*40; % configuration duration

%% -- 101231-R (460) 17DIV  -- spontaneous 2 hours
clear all; Info.Exptype='SpontScan';
Info.Exptitle='101231-R'; 
Info.FileName.SpikeForm=['/home/bakkumd/Data/spikes/spikeform/' Info.Exptitle '.spikeform'];
Info.FileName.Spike=['/home/bakkumd/Data/spikes/' Info.Exptitle '.Spike'];
Info.FileName.Map='/home/bakkumd/Data/configs/bakkum/101231/101231-H_neuromap.m';
Info.Parameter.ConfigDuration=NaN; % configuration duration



%% -- 110201-C (687) 18DIV  -- spontaneous 1 hour
clear all; Info.Exptype='SpontScan';
Info.Exptitle='110201-C'; 
Info.FileName.SpikeForm=['/home/bakkumd/Data/spikes/spikeform/' Info.Exptitle '.spikeform'];
Info.FileName.Spike=['/home/bakkumd/Data/spikes/' Info.Exptitle '.Spike'];
Info.FileName.Map='/home/bakkumd/Data/configs/bakkum/110201/110201-B_neuromap.m';
Info.Parameter.ConfigDuration=NaN; % configuration duration

%% -- 110201-U (687) 18DIV  -- spontaneous 1 hour
clear all; Info.Exptype='SpontScan';
Info.Exptitle='110201-U'; 
Info.FileName.SpikeForm=['/home/bakkumd/Data/spikes/spikeform/' Info.Exptitle '.spikeform'];
Info.FileName.Spike=['/home/bakkumd/Data/spikes/' Info.Exptitle '.Spike'];
Info.FileName.Map='/home/bakkumd/Data/configs/bakkum/110201/110201-K_neuromap.m';
Info.Parameter.ConfigDuration=NaN; % configuration duration






%% -- 110311-A (707) 40DIV  -- spontaneous scan
%       ADC  -> 187digi->2.99V range  (default)
%       Mosr -> 255/255
%       V2   -> 160
%       a1gain30fc20
%       a2gain30fc5
%       a3 buffer
clear all; Info.Exptype='SpontScan';
Info.Exptitle='110311-A'; 
Info.FileName.SpikeForm=['/home/bakkumd/Data/spikes/spikeform/' Info.Exptitle '.spikeform'];
Info.FileName.Spike    =['/home/bakkumd/Data/spikes/' Info.Exptitle '.Spike'];
Info.FileName.Map      =['/home/bakkumd/Data/configs/bakkum/110311/110311_A_neuromap.m'];
Info.Parameter.ConfigDuration=1*60; % configuration duration


%% -- 110311-B (707) 40DIV  -- spontaneous 1 config 10.7 hours 
clear all; Info.Exptype='SpontScan';
Info.Exptitle='110311-B'; 
Info.FileName.SpikeForm=['/home/bakkumd/Data/spikes/spikeform/' Info.Exptitle '.spikeform'];
Info.FileName.Spike=['/home/bakkumd/Data/spikes/' Info.Exptitle '.Spike'];
Info.FileName.Map='/home/bakkumd/Data/configs/bakkum/110311/110311_B_neuromap.m';
Info.Parameter.ConfigDuration=642*60; % configuration duration

%% -- 110312-E (707) 41DIV  -- spontaneous 1 config 3.3 hours 
clear all; Info.Exptype='SpontScan';
Info.Exptitle='110312-E'; 
Info.FileName.SpikeForm=['/home/bakkumd/Data/spikes/spikeform/' Info.Exptitle '.spikeform'];
Info.FileName.Spike=['/home/bakkumd/Data/spikes/' Info.Exptitle '.Spike'];
Info.FileName.Map='/home/bakkumd/Data/configs/bakkum/110312/110312-E_neuromap.m';
Info.Parameter.ConfigDuration=197*60; % configuration duration

%% -- 110312-G (707) 41DIV  -- spontaneous 1 config 4 hours
%
%
%   (saw in notes so added placemarker)
%
%

%% -- 110404-A (691) 28DIV  -- spontaneous 
%       ADC  -> 187digi->2.99V range  (default)
%       Mosr -> 255/255
%       V2   -> 150
%       a1gain30fc20
%       a2gain30fc5
%       a3 buffer
clear all; Info.Exptype='SpontScan';
Info.Exptitle='110404-A'; 
Info.FileName.SpikeForm=['/home/bakkumd/Data/spikes/spikeform/' Info.Exptitle '.spikeform'];
Info.FileName.Spike=['/home/bakkumd/Data/spikes/' Info.Exptitle '.Spike'];
Info.FileName.Map='/home/bakkumd/Data/configs/bakkum/110404/110404-A_neuromap.m';
Info.Parameter.ConfigDuration=1*60; % configuration duration

%% -- 110408-B (691) 28DIV  -- get all soma from stim scan
%       ADC  -> 187digi->2.99V range  (default)
%       Mosr -> 255/255
%       V2   -> 150
%       a1gain30fc20
%       a2gain30fc5
%       a3 buffer
clear all; Info.Exptype='SpontScan';
Info.Exptitle='110408-B'; 
Info.FileName.SpikeForm=['/home/bakkumd/Data/spikes/spikeform/' Info.Exptitle '.spikeform'];
Info.FileName.Spike=['/home/bakkumd/Data/spikes/' Info.Exptitle '.Spike'];
Info.FileName.Map='/home/bakkumd/Data/configs/bakkum/110407/110407-H_neuromap.m';
Info.Parameter.ConfigDuration=9; % configuration duration



%% -- 110513-A (707) 33DIV  
%       Mosr -> 200/200  !!!!
%       V2   -> 160
clear all; Info.Exptype='SpontScan';
Info.Exptitle='110513-A'; 
Info.FileName.SpikeForm=['/home/bakkumd/Data/spikes/spikeform/' Info.Exptitle '.spikeform'];
Info.FileName.Spike=['/home/bakkumd/Data/spikes/' Info.Exptitle '.Spike'];
Info.FileName.Map='/home/bakkumd/Data/configs/bakkum/110513/110513-A_neuromap.m';
Info.Parameter.ConfigDuration=1*60; % [sec] configuration duration

%% -- 110513-B (707) 33DIV     1 CONFIG   14.5 hours (lots spikes)
%       Mosr -> 200/200  !!!!
%       V2   -> 160
clear all; Info.Exptype='SpontScan';
Info.Exptitle='110513-B'; 
Info.FileName.SpikeForm=['/home/bakkumd/Data/spikes/spikeform/' Info.Exptitle '.spikeform'];
Info.FileName.Spike=['/home/bakkumd/Data/spikes/' Info.Exptitle '.Spike'];
Info.FileName.Map='/home/bakkumd/Data/configs/bakkum/110513/110513-B_neuromap.m';
Info.Parameter.ConfigDuration=14.5*60*60; % [sec] configuration duration

%% -- 110513-C (707) 33DIV      (spont trig ave data) (bursting cell)
%%%%  when Info.Parameter.TriggerElectrode detected, sent DAC encoding with Spike.clid==0; 
%%%%  config changes have Spike.clid==127 --- FIX applied below.
clear all; 
Info.Exptype  = 'SpontScan';
Info.Exptitle = '110513-C_s'; 
Info.FileName.SpikeForm         = ['/home/bakkumd/Data/spikes/spikeform/' Info.Exptitle '.spikeform'];
Info.FileName.Spike             = ['/home/bakkumd/Data/spikes/' Info.Exptitle '.Spike'];
Info.FileName.Raw               = ['/home/bakkumd/Data/raw/' Info.Exptitle '.raw'];
Info.FileName.Trig              = ['/home/bakkumd/Data/raw/' Info.Exptitle '.raw.trig'];
Info.FileName.TrigRawAve        = ['/home/bakkumd/Data/raw/' Info.Exptitle '.averaged.traw'];
%Info.FileName.Map = '/home/bakkumd/Data/configs/bakkum/110513/110513-C_s_neuromap.m';
%Info.FileName.Map = '/home/bakkumd/Data/configs/bakkum/110513/110513-C_s_neuromap-server.m';
Info.FileName.Map = '/home/bakkumd/Data/configs/bakkum/110513/110513-C_s_neuromap-el2fi.m';

Info.Parameter.ConfigDuration   =  NaN; % [sec] configuration duration -- 10trigs per config, 1sec per trig -- but latency reset each trig...
Info.Parameter.TriggerElectrode = 1094;                            % electrode used for triggering
Info.Parameter.ConfigNumber     =  108;    % number of configs
Info.Parameter.TriggerTimeZero  = 2001;    % [samples]
Info.Parameter.TriggerLength    = 1000*20; % [samples]
Info.Parameter.StimElectrode = Info.Parameter.TriggerElectrode;


%% -- 110515-C (707) 35DIV     1 CONFIG   12.5 hours 
%       Mosr -> 200/200  !!!!
%       V2   -> 160
clear all; Info.Exptype='SpontScan';
Info.Exptitle='110515-C'; 
Info.FileName.SpikeForm=['/home/bakkumd/Data/spikes/spikeform/' Info.Exptitle '.spikeform'];
Info.FileName.Spike=['/home/bakkumd/Data/spikes/' Info.Exptitle '.Spike'];
Info.FileName.Map='/home/bakkumd/Data/configs/bakkum/110513/110513-B_neuromap.m';
%Info.Parameter.ConfigDuration=12.5*60*60; % [sec] configuration duration


%% -- 110516-A (707) 33DIV     1 CONFIG   2 hours - post media change
%       Mosr -> 200/200  !!!!
%       V2   -> 160
clear all; Info.Exptype='SpontScan';
Info.Exptitle='110516-A'; 
Info.FileName.SpikeForm=['/home/bakkumd/Data/spikes/spikeform/' Info.Exptitle '.spikeform'];
Info.FileName.Spike=['/home/bakkumd/Data/spikes/' Info.Exptitle '.Spike'];
Info.FileName.Map='/home/bakkumd/Data/configs/bakkum/110513/110513-B_neuromap.m';
%Info.Parameter.ConfigDuration=14.5*60*60; % [sec] configuration duration



%% -- 110516-C (707) 36DIV      (spont trig ave data) (bursting cell)
%       Mosr -> 200/200  !!!!
%       V2   -> 160
%%%%  when Info.Parameter.TriggerElectrode detected, sent DAC encoding with Spike.clid==0; 
%%%%  config changes have Spike.clid==127 --- FIX applied below.
clear all; 
Info.Exptype='SpontScan';
Info.Exptitle='110516-C'; 
Info.FileName.SpikeForm=['/home/bakkumd/Data/spikes/spikeform/' Info.Exptitle '.spikeform'];
Info.FileName.Spike=['/home/bakkumd/Data/spikes/' Info.Exptitle '.Spike'];
Info.FileName.Map='/home/bakkumd/Data/configs/bakkum/110516/110516-B_s_neuromap.m';
Info.Parameter.ConfigDuration=NaN; % [sec] configuration duration -- 10trigs per config, 1sec per trig -- but latency reset each trig...

Info.Parameter.TriggerElectrode    = 1094;                            % electrode used for triggering
Info.FileName.Raw   = ['/home/bakkumd/Data/raw/' Info.Exptitle '.raw'];
Info.FileName.Trig  = ['/home/bakkumd/Data/raw/' Info.Exptitle '.raw.trig'];
Info.Parameter.ConfigNumber     =  147;    % number of configs
Info.Parameter.TriggerTimeZero  = 2001;    % [samples]
Info.Parameter.TriggerLength    = 1000*20; % [samples]
Info.Parameter.StimElectrode    = Info.Parameter.TriggerElectrode;
Info.Parameter.TrigPerConfig    = 10;       % number of triggers per config for burst trig scan

%% -- 110517-A (707) 37DIV      (spont trig ave data) (tonic cell)
%       Mosr -> 200/200  !!!!
%       V2   -> 160
clear all; 
Info.Exptype='SpontScan';
Info.Exptitle='110517-A'; 

Info.FileName.SpikeForm         = ['/home/bakkumd/Data/spikes/spikeform/' Info.Exptitle '.spikeform'];
Info.FileName.Spike             = ['/home/bakkumd/Data/spikes/' Info.Exptitle '.Spike'];
Info.FileName.Raw               = ['/home/bakkumd/Data/raw/' Info.Exptitle '.raw'];
Info.FileName.Trig              = ['/home/bakkumd/Data/raw/' Info.Exptitle '.raw.trig'];
Info.FileName.TrigRawAve        = ['/home/bakkumd/Data/raw/' Info.Exptitle '.averaged.traw'];
Info.FileName.Map = '/home/bakkumd/Data/configs/bakkum/110517/110517-A_neuromap.m';

Info.Parameter.ConfigDuration=NaN; % [sec] configuration duration -- 40trigs per config, 1sec per trig -- but latency reset each trig...
Info.Parameter.TriggerElectrode = 2182;                            % electrode used for triggering
Info.Parameter.ConfigNumber     =  147;    % number of configs
Info.Parameter.TriggerTimeZero  =  181;    % [samples]
Info.Parameter.TriggerLength    =  360;    % [samples]
Info.Parameter.StimElectrode = Info.Parameter.TriggerElectrode;


%% -- 110517-B (707) 37DIV      (spont trig ave data) (bursting cell)
%       Mosr -> 200/200  !!!!
%       V2   -> 160
clear all; 
Info.Exptype='SpontScan';
Info.Exptitle='110517-B'; 
Info.FileName.SpikeForm = ['/home/bakkumd/Data/spikes/spikeform/' Info.Exptitle '.spikeform'];
Info.FileName.Spike     = ['/home/bakkumd/Data/spikes/' Info.Exptitle '.Spike'];
Info.FileName.Map       =  '/home/bakkumd/Data/configs/bakkum/110517/110517-B_neuromap.m';
Info.Parameter.ConfigDuration=NaN; % [sec] configuration duration -- 10trigs per config, 1sec per trig -- but latency reset each trig...

Info.Parameter.TriggerElectrode    = 6991;                            % electrode used for triggering
Info.FileName.Raw       = ['/home/bakkumd/Data/raw/' Info.Exptitle '.raw'];
Info.FileName.Trig      = ['/home/bakkumd/Data/raw/' Info.Exptitle '.raw.trig'];
Info.Parameter.ConfigNumber        =  147;    % number of configs
Info.Parameter.TriggerTimeZero     = 2001;    % [samples]
Info.Parameter.TriggerLength       = 1000*20; % [samples]


%% -- 110518-N (707) 38DIV     1 CONFIG   9.5 hours
clear all; 
Info.Exptype='SpontScan';
Info.Exptitle='110518-N'; 
Info.FileName.SpikeForm=['/home/bakkumd/Data/spikes/spikeform/' Info.Exptitle '.spikeform'];
Info.FileName.Spike=['/home/bakkumd/Data/spikes/' Info.Exptitle '.Spike'];
Info.FileName.Map='/home/bakkumd/Data/configs/bakkum/110518/110518-N_neuromap.m';
Info.Parameter.ConfigDuration=NaN; % [sec] configuration duration

%% -- 110519-G (707) 39DIV     1 CONFIG   5 minutes
clear all; 
Info.Exptype='SpontScan';
Info.Exptitle='110519-G'; 
Info.FileName.SpikeForm=['/home/bakkumd/Data/spikes/spikeform/' Info.Exptitle '.spikeform'];
Info.FileName.Spike=['/home/bakkumd/Data/spikes/' Info.Exptitle '.Spike'];
Info.FileName.Map='/home/bakkumd/Data/configs/bakkum/110518/110518-N_neuromap.m';
Info.Parameter.ConfigDuration=5*60; % [sec] configuration duration


%% -- 110907-A (905) 31DIV      %% THALAMIC CELLS %%
%       Mosr -> 200/200  !!!!
%       V2   -> 128
%       Amp 30fc20; 30fc20; buffer
clear all; 
Info.Exptype='SpontScan';
Info.Exptitle='110907-A'; 
Info.FileName.SpikeForm=['/home/bakkumd/Data/spikes/spikeform/' Info.Exptitle '.spikeform'];
Info.FileName.Spike=['/home/bakkumd/Data/spikes/' Info.Exptitle '.Spike'];
Info.FileName.Map='/home/bakkumd/Data/configs/bakkum/110907/110907-A_neuromap.m';
Info.Parameter.ConfigDuration=NaN; % [sec] configuration duration -- 10trigs per config, 1sec per trig -- but latency reset each trig...
Info.Parameter.ConfigNumber=95; % random

%% -- 110907-B (905) 31DIV      %% THALAMIC CELLS %%   1 config
%       Mosr -> 200/200  !!!!
%       V2   -> 128
%       Amp 30fc20; 30fc20; buffer
clear all; 
Info.Exptype='SpontScan';
Info.Exptitle='110907-B'; 
Info.FileName.SpikeForm=['/home/bakkumd/Data/spikes/spikeform/' Info.Exptitle '.spikeform'];
Info.FileName.Spike=['/home/bakkumd/Data/spikes/' Info.Exptitle '.Spike'];
Info.FileName.Map='/home/bakkumd/Data/configs/bakkum/110907/110907-B_neuromap.m';
Info.Parameter.ConfigDuration=NaN; % [sec] configuration duration -- 10trigs per config, 1sec per trig -- but latency reset each trig...
Info.Parameter.ConfigNumber=95; % random



%% -- 111209-B (912) 21DIV      %% GFP CORTICAL CELLS %%
%       Mosr -> 180 
%       V2   -> 160
%       Amp 30fc20; 30fc5; buffer
clear all; 
Info.Exptype='SpontScan';
Info.Exptitle='111209-B'; 
Info.FileName.SpikeForm=['/home/bakkumd/Data/spikes/spikeform/' Info.Exptitle '.spikeform'];
Info.FileName.Spike=['/home/bakkumd/Data/spikes/' Info.Exptitle '.Spike'];
Info.FileName.Map='/home/bakkumd/Data/configs/bakkum/111209/111209-B_neuromap.m';
Info.Parameter.ConfigDuration=60; % [sec] configuration duration -- 10trigs per config, 1sec per trig -- but latency reset each trig...
Info.Parameter.ConfigNumber=95; % random

%% -- 111209-C (912) 21DIV      %% GFP CORTICAL CELLS %%  - 1-config network activity recording
%       Mosr -> 180 
%       V2   -> 160
%       Amp 30fc20; 30fc5; buffer
clear all; 
Info.Exptype='Spont';
Info.Exptitle='111209-C'; 
Info.FileName.SpikeForm=['/home/bakkumd/Data/spikes/spikeform/' Info.Exptitle '.spikeform'];
Info.FileName.Spike=['/home/bakkumd/Data/spikes/' Info.Exptitle '.Spike'];
Info.FileName.Map='/home/bakkumd/Data/configs/bakkum/111209/111209-C_neuromap.m';
Info.Parameter.ConfigDuration=NaN; % [sec] configuration duration
Info.Parameter.ConfigNumber=1; % 





%% -- 120826-A 34DIV      (trig scan) (bursting cell)
%     v3 chip (FPGA not updated for v3 though, so gain is off)
%       Mosr -> 120/120 
%       V2   -> 130
%       
clear all; 
Info.Exptype='SpontScan';
Info.Exptitle='120826-A'; 
Info.FileName.SpikeForm = ['/local0/bakkumd/spikes/spikeform/' Info.Exptitle '.spikeform'];
Info.FileName.Spike     = ['/local0/bakkumd/spikes/' Info.Exptitle '.Spike'];
Info.FileName.Map       =  '/local0/bakkumd/configs/bakkum/120826/120826-A_s_neuromap.m';
Info.Parameter.ConfigDuration=NaN; % [sec] configuration duration -- 5trigs per config, trig scan
Info.Parameter.TriggerElectrode    = 1730;                            % electrode used for triggering
Info.FileName.Raw       = ['/local0/bakkumd/raw/' Info.Exptitle '.raw'];
Info.FileName.Trig      = ['/local0/bakkumd/raw/' Info.Exptitle '.raw.trig'];
Info.Parameter.ConfigNumber        =  147;    % number of configs
Info.Parameter.TriggerTimeZero     = 2001;    % [samples]
Info.Parameter.TriggerLength       = 1000*20; % [samples]
Info.Parameter.TrigPerConfig       = 5;       % number of triggers per config for burst trig scan

%% -- 120829-A 37DIV      (long term spont, 1 config based on 120826-A)
%     v3 chip (FPGA not updated for v3 though, so gain is off)
%       Mosr -> 120/120 
%       V2   -> 130
%       
clear all; 
Info.Exptype='SpontScan';
Info.Exptitle='120829-A'; 
Info.FileName.SpikeForm = ['/home/bakkumd/Data/spikes/spikeform/' Info.Exptitle '.spikeform'];
Info.FileName.Spike     = ['/home/bakkumd/Data/spikes/' Info.Exptitle '.Spike'];
Info.FileName.Map       =  '/home/bakkumd/Data/configs/bakkum/120829/120826-A_neuromap.m';
Info.Parameter.ConfigDuration=NaN; % [sec] configuration duration -- 5trigs per config, trig scan
Info.Parameter.ConfigNumber        =  1;    % number of configs


%% -- 120830-A 38DIV      (trig scan) (bursting cell, new dish)
%     v3 chip (FPGA not updated for v3 though, so gain is off)
%       Mosr -> 120/120 
%       V2   -> 130
%       
clear all; 
Info.Exptype='SpontScan';
Info.Exptitle='120830-A'; 
Info.FileName.SpikeForm = ['/local0/bakkumd/spikes/spikeform/' Info.Exptitle '.spikeform'];
Info.FileName.Spike     = ['/local0/bakkumd/spikes/' Info.Exptitle '.Spike'];
Info.FileName.Map       =  '/local0/bakkumd/configs/bakkum/120830/120830-A_s_neuromap.m';
Info.Parameter.ConfigDuration=NaN; % [sec] configuration duration -- 5trigs per config, trig scan
Info.Parameter.TriggerElectrode    = 1021;                            % electrode used for triggering
Info.FileName.Raw       = ['/local0/bakkumd/raw/' Info.Exptitle '.raw'];
Info.FileName.Trig      = ['/local0/bakkumd/raw/' Info.Exptitle '.raw.trig'];
Info.Parameter.ConfigNumber        =  147;    % number of configs
Info.Parameter.TriggerTimeZero     = 2001;    % [samples]
Info.Parameter.TriggerLength       = 1000*20; % [samples]
Info.Parameter.TrigPerConfig       = 5;       % number of triggers per config for burst trig scan


%% -- 120830-B 38DIV      (long term spont, 1 config based on 120830-A)
%     v3 chip (FPGA not updated for v3 though, so gain is off)
%       Mosr -> 200/200 [increased due to ELECTROL developing]
%       V2   -> 130
%       
clear all; 
Info.Exptype            = 'SpontScan';
Info.Exptitle           = '120830-B'; 
Info.FileName.SpikeForm = ['/home/bakkumd/Data/spikes/spikeform/' Info.Exptitle '.spikeform'];
Info.FileName.Spike     = ['/home/bakkumd/Data/spikes/' Info.Exptitle '.Spike'];
Info.FileName.Map       =  '/home/bakkumd/Data/configs/bakkum/120830/120830-A-2_neuromap.m';
Info.Parameter.ConfigDuration      = NaN;    % [sec] configuration duration -- 5trigs per config, trig scan
Info.Parameter.ConfigNumber        =   1;    % number of configs



%% -- 120902-A 41DIV      (1 config, focused on RFP cell, full raw recording)
%     v3 chip (FPGA not updated for v3 though, so gain is off)
%       Mosr -> 200
%       V2   -> 130
%       
clear all; 
Info.Exptype='SpontScan';
Info.Exptitle='120902-A'; 
Info.FileName.SpikeForm = ['/home/bakkumd/Data/spikes/spikeform/' Info.Exptitle '.spikeform'];
Info.FileName.Spike     = ['/home/bakkumd/Data/spikes/' Info.Exptitle '.Spike'];
Info.FileName.Map       =  '/home/bakkumd/Data/configs/bakkum/120902/120902-A_neuromap.m';
Info.Parameter.ConfigDuration=NaN; % [sec] configuration duration -- 5trigs per config, trig scan
Info.Parameter.TriggerElectrode    = NaN;                            % electrode used for triggering
Info.FileName.Raw       = ['/home/bakkumd/Data/raw/' Info.Exptitle '.raw'];
Info.FileName.Trig      = ['/home/bakkumd/Data/raw/' Info.Exptitle '.raw.trig'];
Info.Parameter.ConfigNumber        =  1;    % number of configs
Info.Parameter.TriggerTimeZero     = NaN;    % [samples]
Info.Parameter.TriggerLength       = NaN; % [samples]
Info.Parameter.TrigPerConfig       = NaN;       % number of triggers per config for burst trig scan



%% -- 121227-A 32DIV      (trig scan)
%     v3 chip (FPGA not updated for v3 so gain is off ??)
%       Mosr -> 120/120 
%       V2   -> 128
%       
clear all; 
Info.Exptype='SpontScan';
Info.Exptitle='121227-A'; 
Info.FileName.SpikeForm = ['/local0/bakkumd/spikes/spikeform/' Info.Exptitle '.spikeform'];
Info.FileName.Spike     = ['/local0/bakkumd/spikes/' Info.Exptitle '.Spike'];
Info.FileName.Map       =  '/local0/bakkumd/configs/bakkum/121227/121227-A_s_neuromap.m';
Info.FileName.Raw       = ['/local0/bakkumd/raw/' Info.Exptitle '.raw'];
Info.FileName.Trig      = ['/local0/bakkumd/raw/' Info.Exptitle '.raw.trig'];
Info.Parameter.ConfigDuration      =  NaN;    % [sec] configuration duration -- 5trigs per config, trig scan
Info.Parameter.TriggerElectrode    = 3044;    % electrode used for triggering
Info.Parameter.ConfigNumber        =  147;    % number of configs
Info.Parameter.TriggerTimeZero     = 2001;    % [samples]
Info.Parameter.TriggerLength       = 1000*20; % [samples]
Info.Parameter.TrigPerConfig       = 5;       % number of triggers per config for burst trig scan


%% -- 121227-F 32DIV      (long term spont, 1 config based on 121227-A )
%     v3 chip (FPGA not updated for v3 though, so gain is off)
%       
clear all; 
Info.Exptype            = 'SpontScan';
Info.Exptitle           = '121227-F'; 
Info.FileName.SpikeForm = ['/home/bakkumd/Data/spikes/spikeform/' Info.Exptitle '.spikeform'];
Info.FileName.Spike     = ['/home/bakkumd/Data/spikes/' Info.Exptitle '.Spike'];
Info.FileName.Map       =  '/home/bakkumd/Data/configs/bakkum/121227/121227-B_neuromap.m';
Info.Parameter.ConfigDuration      = NaN;    % [sec] configuration duration -- 5trigs per config, trig scan
Info.Parameter.ConfigNumber        =   1;    % number of configs




%% -- 130103-A 39DIV      (trig scan)
%     v3 chip (FPGA not updated for v3 so gain is off ??)
%       Mosr -> 140/140 
%       V2   -> 128
%       
clear all; 
Info.Exptype='SpontScan';
Info.Exptitle='130103-A'; 
Info.FileName.SpikeForm = ['/home/bakkumd/Data/spikes/spikeform/' Info.Exptitle '.spikeform'];
Info.FileName.Spike     = ['/home/bakkumd/Data/spikes/' Info.Exptitle '.Spike'];
Info.FileName.Map       =  '/home/bakkumd/Data/configs/bakkum/130103/130103-A_s_neuromap.m';
Info.FileName.Raw       = ['/home/bakkumd/Data/raw/' Info.Exptitle '.raw'];
Info.FileName.Trig      = ['/home/bakkumd/Data/raw/' Info.Exptitle '.raw.trig'];
Info.Parameter.ConfigDuration      =  NaN;    % [sec] configuration duration -- 5trigs per config, trig scan
Info.Parameter.TriggerElectrode    = 9275;    % electrode used for triggering
Info.Parameter.ConfigNumber        =  147;    % number of configs
Info.Parameter.TriggerTimeZero     = 2001;    % [samples]
Info.Parameter.TriggerLength       = 1000*20; % [samples]
Info.Parameter.TrigPerConfig       = 5;       % number of triggers per config for burst trig scan



%% -- 130104-A __DIV      (long term spont, 1 config based on ____)
%     v3 chip (FPGA not updated for v3 though, so gain is off)
%       
clear all; 
Info.Exptype='SpontScan';
Info.Exptitle='130104-A'; 
Info.FileName.SpikeForm = ['/home/bakkumd/Data/spikes/spikeform/' Info.Exptitle '.spikeform'];
Info.FileName.Spike     = ['/home/bakkumd/Data/spikes/' Info.Exptitle '.Spike'];
Info.FileName.Map       =  '/home/bakkumd/Data/configs/bakkum/130104/130104-A_neuromap.m';
Info.Parameter.ConfigDuration=NaN; % [sec] configuration duration -- 5trigs per config, trig scan
Info.Parameter.ConfigNumber        =  1;    % number of configs



%% -- 130111-967-all 21DIV      (1 config, focused on RFP cell, full raw recording in ntk)
%     v3 chip (FPGA not updated for v3 though, so gain is off)
%       
clear all; 
Info.Exptype='SpontScan';
Info.Exptitle='130111-967-all'; 
Info.FileName.SpikeForm = ['/home/bakkumd/Data/spikes/spikeform/' Info.Exptitle '.spikeform'];
Info.FileName.Spike     = ['/home/bakkumd/Data/spikes/' Info.Exptitle '.Spike'];
Info.FileName.Map       =  '/home/bakkumd/Data/configs/bakkum/130111/130111-967-all_neuromap.m';
Info.Parameter.ConfigDuration      = NaN; % [sec] configuration duration -- 5trigs per config, trig scan
Info.Parameter.ConfigNumber        =   1;    % number of configs


%% -- 130520-A  1202   29DIV      (1 config; 2 hours)
%       
clear all; 
Info.Exptype='SpontScan';
Info.Exptitle='130520-A'; 
Info.FileName.SpikeForm = ['/home/bakkumd/Data/spikes/spikeform/' Info.Exptitle '.spikeform'];
Info.FileName.Spike     = ['/home/bakkumd/Data/spikes/' Info.Exptitle '.Spike'];
Info.FileName.Map       =  '/home/bakkumd/Data/configs/bakkum/130520/130520-A_neuromap.m';
Info.Parameter.ConfigDuration      = NaN; % [sec] configuration duration -- 5trigs per config, trig scan
Info.Parameter.ConfigNumber        =   1;    % number of configs


%% -- 130520-B  1199   29DIV      (1 config)
%       
clear all; 
Info.Exptype='SpontScan';
Info.Exptitle='130520-B'; 
Info.FileName.SpikeForm = ['/home/bakkumd/Data/spikes/spikeform/' Info.Exptitle '.spikeform'];
Info.FileName.Spike     = ['/home/bakkumd/Data/spikes/' Info.Exptitle '.Spike'];
Info.FileName.Map       =  '/home/bakkumd/Data/configs/bakkum/130520/130520-B_neuromap.m';
Info.Parameter.ConfigDuration      = NaN; % [sec] configuration duration -- 5trigs per config, trig scan
Info.Parameter.ConfigNumber        =   1;    % number of configs


%% -- 130520-C  806    29DIV      (1 config)
%       
clear all; 
Info.Exptype='SpontScan';
Info.Exptitle='130520-C';
Info.FileName.SpikeForm = ['/home/bakkumd/Data/spikes/spikeform/' Info.Exptitle '.spikeform'];
Info.FileName.Spike     = ['/home/bakkumd/Data/spikes/' Info.Exptitle '.Spike'];
Info.FileName.Map       =  '/home/bakkumd/Data/configs/bakkum/130520/130520-C_neuromap.m';
Info.Parameter.ConfigDuration      = NaN; % [sec] configuration duration -- 5trigs per config, trig scan
Info.Parameter.ConfigNumber        =   1;    % number of configs




%% -- 130705-Marta    For her tunnels paper       (1 config)
%       
clear all; 
Info.Exptype='SpontScan';
Info.Exptitle='soma';
Info.FileName.SpikeForm = ['/home/bakkumd/Data/spikes/130705-Marta/' Info.Exptitle '.spikeform'];
Info.FileName.Spike     = ['/home/bakkumd/Data/spikes/130705-Marta/' Info.Exptitle '.Spike'];
Info.FileName.Map       =  '/home/bakkumd/Data/spikes/130705-Marta/soma_neuromap.m';
Info.Parameter.ConfigDuration      = NaN; % [sec] configuration duration -- 5trigs per config, trig scan
Info.Parameter.ConfigNumber        =   1;    % number of configs





%% -- 130716-B    58DIV      (1 config)
%       
clear all; 
Info.Exptype='SpontScan';
Info.Exptitle='130716-B';
Info.FileName.SpikeForm            = ['/home/bakkumd/Data/spikes/spikeform/' Info.Exptitle '.spikeform'];
Info.FileName.Spike                = ['/home/bakkumd/Data/spikes/'           Info.Exptitle '.spike'];
Info.FileName.Map                  = ['/home/bakkumd/Data/configs/bakkum/'   Info.Exptitle(1:6) '/' Info.Exptitle '_neuromap.m'];
Info.Parameter.ConfigDuration      = NaN; % [sec] configuration duration -- 5trigs per config, trig scan
Info.Parameter.ConfigNumber        =   1;    % number of configs


%% -- 130717-A    59DIV      (1 config)
%       
clear all; 
Info.Exptype='SpontScan';
Info.Exptitle='130717-A';
Info.FileName.SpikeForm            = ['/home/bakkumd/Data/spikes/spikeform/' Info.Exptitle '.spikeform'];
Info.FileName.Spike                = ['/home/bakkumd/Data/spikes/'           Info.Exptitle '.spike'];
Info.FileName.Map                  = ['/home/bakkumd/Data/configs/bakkum/130716/130716-B_neuromap.m'];
Info.Parameter.ConfigDuration      = NaN; % [sec] configuration duration -- 5trigs per config, trig scan
Info.Parameter.ConfigNumber        =   1;    % number of configs


%% -- 130717-B    59DIV      (1 config)     **  OPEN LOOP Stim experiment
%       
clear all; 
Info.Exptype='SpontScan';
Info.Exptitle='130717-B';
Info.FileName.SpikeForm            = ['/home/bakkumd/Data/spikes/spikeform/' Info.Exptitle '.spikeform'];
Info.FileName.Spike                = ['/home/bakkumd/Data/spikes/'           Info.Exptitle '.spike'];
Info.FileName.Map                  = ['/home/bakkumd/Data/configs/bakkum/130716/130716-B_neuromap.m'];
Info.Parameter.ConfigDuration      = NaN; % [sec] configuration duration -- 5trigs per config, trig scan
Info.Parameter.ConfigNumber        =   1;    % number of configs


%% -- 130721-B    59DIV      (1 config)    
%       
clear all; 
Info.Exptype='SpontScan';
Info.Exptitle='130721-B';
Info.FileName.SpikeForm            = ['/home/bakkumd/Data/spikes/spikeform/' Info.Exptitle '.spikeform'];
Info.FileName.Spike                = ['/home/bakkumd/Data/spikes/'           Info.Exptitle '.spike'];
Info.FileName.Map                  = ['/home/bakkumd/Data/configs/bakkum/'   Info.Exptitle(1:6) '/' Info.Exptitle '_neuromap.m'];
Info.Parameter.ConfigDuration      = NaN; % [sec] configuration duration -- 5trigs per config, trig scan
Info.Parameter.ConfigNumber        =   1;    % number of configs
%% -- 130717-C    59DIV      (1 config)     **  OPEN LOOP Stim experiment
%       
clear all; 
Info.Exptype='SpontScan';
Info.Exptitle='130721-C';
Info.FileName.SpikeForm            = ['/home/bakkumd/Data/spikes/spikeform/' Info.Exptitle '.spikeform'];
Info.FileName.Spike                = ['/home/bakkumd/Data/spikes/'           Info.Exptitle '.spike'];
Info.FileName.Map                  = ['/home/bakkumd/Data/configs/bakkum/'   Info.Exptitle(1:6) '/130721-B_neuromap.m'];
Info.Parameter.ConfigDuration      = NaN; % [sec] configuration duration -- 5trigs per config, trig scan
Info.Parameter.ConfigNumber        =   1;    % number of configs
%% -- 130721-D    59DIV      (1 config)    
%       
clear all; 
Info.Exptype='SpontScan';
Info.Exptitle='130721-D';
Info.FileName.SpikeForm            = ['/home/bakkumd/Data/spikes/spikeform/' Info.Exptitle '.spikeform'];
Info.FileName.Spike                = ['/home/bakkumd/Data/spikes/'           Info.Exptitle '.spike'];
Info.FileName.Map                  = ['/home/bakkumd/Data/configs/bakkum/'   Info.Exptitle(1:6) '/130721-B_neuromap.m'];
Info.Parameter.ConfigDuration      = NaN; % [sec] configuration duration -- 5trigs per config, trig scan
Info.Parameter.ConfigNumber        =   1;    % number of configs
%% -- 130717-E    59DIV      (1 config)     **  OPEN LOOP Stim experiment
%       
clear all; 
Info.Exptype='SpontScan';
Info.Exptitle='130721-E';
Info.FileName.SpikeForm            = ['/home/bakkumd/Data/spikes/spikeform/' Info.Exptitle '.spikeform'];
Info.FileName.Spike                = ['/home/bakkumd/Data/spikes/'           Info.Exptitle '.spike'];
Info.FileName.Map                  = ['/home/bakkumd/Data/configs/bakkum/'   Info.Exptitle(1:6) '/130721-B_neuromap.m'];
Info.Parameter.ConfigDuration      = NaN; % [sec] configuration duration -- 5trigs per config, trig scan
Info.Parameter.ConfigNumber        =   1;    % number of configs



%% -- 130829-B     (1 block config)     footprint with ntk data
%       
clear all; 
Info.Exptype='Spont';
Info.Exptitle='130829-B';
Info.FileName.SpikeForm            = ['/home/bakkumd/Data/spikes/spikeform/' Info.Exptitle '.spikeform'];
Info.FileName.Spike                = ['/home/bakkumd/Data/spikes/'           Info.Exptitle '.spike'];
Info.FileName.Map                  = ['/home/bakkumd/Data/configs/bakkum/'   Info.Exptitle(1:6) '/' Info.Exptitle '_neuromap.m'];
Info.Parameter.ConfigDuration      = NaN; % [sec] configuration duration -- 5trigs per config, trig scan
Info.Parameter.ConfigNumber        =   1;    % number of configs
%% -- 130829-C     (1 block config)     footprint with ntk data
%       
clear all; 
Info.Exptype='Spont';
Info.Exptitle='130829-C';
Info.FileName.SpikeForm            = ['/home/bakkumd/Data/spikes/spikeform/' Info.Exptitle '.spikeform'];
Info.FileName.Spike                = ['/home/bakkumd/Data/spikes/'           Info.Exptitle '.spike'];
Info.FileName.Map                  = ['/home/bakkumd/Data/configs/bakkum/'   Info.Exptitle(1:6) '/' Info.Exptitle '_neuromap.m'];
Info.Parameter.ConfigDuration      = NaN; % [sec] configuration duration -- 5trigs per config, trig scan
Info.Parameter.ConfigNumber        =   1;    % number of configs









