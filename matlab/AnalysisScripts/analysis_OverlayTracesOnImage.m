%% GFP overlay
%
%  first sections deal with trig raw files
%  final section deals with (spontaneous) spike files


%% 090315-E3   stimulating GFP neuron - 1 config
% trig so raw
clear all
Info.Exptitle='090315-E3'; 
expt=['/home/bakkum/spikes/spikeform/' Info.Exptitle '.spikeform'];
spikefile=['/home/bakkum/spikes/' Info.Exptitle '.spike'];
trigfile=['/home/bakkum/raw/' Info.Exptitle '-0-15.raw.trig'];
rawfile=['/home/bakkum/raw/' Info.Exptitle '-0-15.raw'];
rawavefile=['/home/bakkum/raw/' Info.Exptitle '-0-15.averaged.traw'];
mapfile='/opt/cmosmea_external/configs/090315-gfp-trace/E090315_neuromap.m'
tlen=300; % -10 to 10 ms
tzero=1;
nconf=1;
nstim=153;
stim_el=7427;

%% analysis of 090315-E4
% trig so salpa -- lots blanked
clear all;
Info.Exptitle='090315-E4';       
stim_el=7427;
mapfile = '/opt/cmosmea_external/configs/090315-gfp-trace/E090315_neuromap.m';
trigfile=['/home/bakkum/raw/' Info.Exptitle '-0-15.raw.trig'];
rawfile=['/home/bakkum/raw/' Info.Exptitle '-0-15.raw'];
rawavefile=['/home/bakkum/raw/' Info.Exptitle '-0-15.averaged.traw'];
mapfile='/opt/cmosmea_external/configs/090315-gfp-trace/E090315_neuromap.m'
tlen=300; % -10 to 10 ms
tzero=1;
nconf=1;
nstim=223;
stim_el=7427;

%%


%% mapfile testing
clear map
map=load(mapfile,'-ascii');

ww=find(map(:,3)>100); % find connected chnls
ch=map(:,1);  % use these for re-running code
el=map(:,2);
px=map(:,3);
py=map(:,4);
ww=ww(el(ww)~=stim_el); % remove stim_el from channel mapping (for plotting purposes)

figure
plot(px,py,'.',px(ww),py(ww),'r.')
set(gca,'YDir','reverse','Color',[1 1 1]*1)
axis equal



%%


% %  use cpp file to average raw traces
%  system(['rm ' rawavefile]);
%  cmd=['/home/bakkum/cpp/CMOS/bin/cmos_postprocessing -a -o ' rawavefile ' -r ' rawfile ' -s ' int2str(tlen) ' -z ' int2str(tzero) ' -m ' mapfile ' -c ' int2str(nconf) ' -n ' int2str(nstim)]
%  system(cmd);


clear mtraw
mtraw=load(rawavefile,'-ascii');  % !!!! no gain applied !!! USE:   11.7/16 * 1000/958.558; % 11.7mV/8-bit (3V range); meabench uses 12-bit (mcs convention) -- 16=2^12 / 2^8; 1000 to put into uV; 958 is standard CMOS gain (A1-30, A2-30 A3-bypass)
figure; plot(mtraw')   

%% try a filter a la salpa
% subtract median value over window of xx samples for each sample
wn=10;
ftraw=zeros(size(mtraw));
for k=wn+1:size(mtraw,2)-wn-1
    ftraw(:,k)=mtraw(:,k)-median(mtraw(:,k-wn:k+wn)')';
%     [mn y]=min(abs(mtraw(:,k-wn:k+wn))');
%     os=zeros(size(mtraw,1),1);
%     for l=1:size(mtraw,1)
%         os(l)=(mtraw(l,y(l)+k-wn-1));
%     end  
%     ftraw(:,k)=mtraw(:,k)-os;
end
%ftraw(:,1:25)=0; % zero first artifact
plot(ftraw')   





%% overlay raw traces

% img=imread('/home/bakkum/Documents/Pictures/090315-gfp/transformed/cmos268-10kCells-090224-19DIV-bf-10x-copy_transformed.jpg');
% img=imread('/home/bakkum/Documents/Pictures/090315-gfp/transformed/cmos268-10kCells-090224-19DIV-GFP-10x_transformed.jpg');
% figure
image(img); hold on


% target=mtraw;
 target=ftraw;
% figure(3)
rng=[47:90];
rng=[110:140];
rng=[18:52];
for e=ww'
    plot(px(e)+(rng-mean(rng))/length(rng)*10,py(e)+target(el(e),rng)/-8, 'k','linewidth',1 ); hold on
end
set(gca,'YDir','reverse','Color',[1 1 1]*1)
axis equal
box off
hold off
clear target




%%
%%
%% compare to individual trig traces
% Go through each trace, and select trials that produced a spike (look at
% mtraw to get timing info to separate from different spikes).


%  fn=['/home/bakkum/raw/tmp.raw']
fn=rawfile
fh = fopen(fn,'rb')
fseek(fh,0,1);
len = ftell(fh);
fseek(fh,0,-1); c=0;


tmp=zeros(size(y)); cc=0;
%%
while(1)
[dat, cnt] = fread(fh,[128 tlen],'int16'); % 1 trig raw recording
if isempty(dat), return; end

c=c+1;
wn=10;
fdat=zeros(size(dat));
for k=wn+1:size(dat,2)-wn-1
    fdat(:,k)=dat(:,k)-median(dat(:,k-wn:k+wn)')';
end
% plot(fdat')
% % figure
% % plot((dat-mm)')
% title(int2str(c))
% axis([20 100 -300 100])


if min(min(fdat(:,40:50)))<-150  % CRITERION  This corresponds to el==5806
    rcnstrct=4;
    y=(reconstruct(fdat(1:126,25:end),rcnstrct)); % reconstruct to get better detail
    plot(y')
    axis([40 200 -300 100])
    tmp=tmp+y; cc=cc+1;
    title(int2str(cc))
    drawnow
    pause(0.01)
end
end
%%
fclose(fh);
  

%% from GFP overlay analysis:
figure
image(img); hold on
target=tmp/cc;
rng=[15:150];
for e=ww'
    plot(px(e)+(rng-mean(rng))/length(rng)*10,py(e)+target(e,rng)/-12, 'k','linewidth',1 ); hold on
end


set(gca,'YDir','reverse','Color',[1 1 1]*1)
hold off
axis equal
box off



%%
%%
%% try spontaneous spike traces
%
%% 090315-E2   spontaneous - 5min on 1 config
clear all
Info.Exptitle='090315-E2'; 
expt=['/home/bakkum/spikes/spikeform/' Info.Exptitle '.spikeform'];
spikefile=['/home/bakkum/spikes/' Info.Exptitle '.spike'];
mapfile='/opt/cmosmea_external/configs/090315-gfp-trace/E090315_neuromap.m'
%spont_el=5806;
spont_el=5808; 
% Pick representative electrode, then will look at nearby spikes (in time) and
% average togther for each channel to get traces to plot.

%  y=loadspikeCMOS(expt)



spont_ch=ch(find(el==spont_el));

XX=find(C==spont_ch & H<-114 & H>-150 & clid);  % H isnt accurate, but approx should be ok for now.
                                  % H<-130 gives 21 largest spikes for el 5806

             
ff=999;
rng=0.001; % 1 ms            
clr=rand(1,3);ID=[];
smpl=20000;
traces=zeros(128,74+2*rng*smpl);
tr_first=rng*smpl;
tr_cnt=zeros(128,1);
for i=XX
    zero=T(i);
    TT=find(H<0 & T>zero-rng & T<zero+rng);
    if ~isempty(TT)
        ID=[ID TT];
        for tt=TT
          cntx=plotspikecontext_CMOS(spikefile,tt,ff,0,0);
          %cntx=plotspikecontext_CMOS(spikefile,tt,ff,T(tt),clr);
          %title(['C::' num2str(C(tt)) '   T::' num2str(T(tt))])
          %pause(.5)
            first=cntx(1:15);    last=cntx(61:74);
            dc1=mean(first);     dc2=mean(last);
            v1=var(first);       v2=var(last);
            dc=(dc1*v2+dc2*v1)/(v1+v2+1e-10);
            cntx=cntx'-dc;
            dt=round((T(tt)-zero)*smpl);
            cntxz=zeros(1,74+2*rng*smpl);
            cntxz(tr_first+dt+2:tr_first+dt+74)=cntx(2:end);
            
          traces(C(tt)+1,:) = traces(C(tt)+1,:)+cntxz;
          tr_cnt(C(tt)+1)   = tr_cnt(C(tt)+1)+1;
        end
    end
end

figure
image(img); hold on
rng2=2:74;
for i=1:126
    if tr_cnt(i)>0
        traces(i)=traces(i)/tr_cnt(i);
        plot(px(i)+(rng2-mean(rng2))/length(rng2)*10,py(i)+traces(i,rng2)/-5000,'k','linewidth',1); hold on
        traces(i)=traces(i)*tr_cnt(i);
    else
        traces(i)=0;
    end
end
set(gca,'YDir','reverse','Color',[1 1 1]*1)
hold off
axis equal
box off




% img=imread('/home/bakkum/Documents/Pictures/090315-gfp/transformed/cmos268-10kCells-090224-19DIV-GFP-10x_transformed.jpg');
% figure
image(img); hold on













%%


%  *** can load trig times from raw.trig file ***
trigl=load(trigfile,'-ascii');
trig.N=trigl(:,1); % number (some may have been dropped)
trig.T=trigl(:,2); % time




%%

