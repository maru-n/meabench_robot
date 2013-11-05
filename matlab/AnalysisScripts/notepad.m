%% notepad %%
%%
%%
%%

%% useful commands


   detrend   to remove mean from vectors
   
   repmat    Replicate. For division of matrix by vector -- need to turn vector into matrix
   reshape   
   
   
   easyspec  davids tool to look at signal freq spectrum
   
   findpeaks
   
   
    imadjust

    % plotting transparent lines using 'patch'   
    clr = [0 0 0];
    y=[NaN y NaN]; % pad with NaN
    x=[NaN x NaN];
    patch(x,y,clr,'edgecolor',clr,'linewidth',2,'edgealpha',.05)
    
    

%% merge image files to create a single movie
Info.Exptitle={'091227-D' '091227-I' '091228-B' '091229-A' '091230-A' '100101-A'}
cmbfn='091227DI-091228B-091229A-091230A-100101A';
cnt=0;
while(cnt<200-28)
clear filename cmd cfilename ofilename
cmd='convert ';
disp(cnt)
  for fn=1:length(Info.Exptitle)
%     if      cnt<10  filename{fn} = ['/home/bakkum/Desktop/movieframes/pics/' Info.Exptitle{fn}     '_00' int2str(cnt),'.jpg'];
%                     ofilename    = ['/home/bakkum/Desktop/movieframes/pics/' cmbfn                 '_00' int2str(cnt),'.jpg'];
%                     cfilename{fn}= ['/home/bakkum/Desktop/movieframes/pics/' Info.Exptitle{fn} 'crop_00' int2str(cnt),'.jpg'];
%     elseif  cnt<100 filename{fn} = ['/home/bakkum/Desktop/movieframes/pics/' Info.Exptitle{fn}      '_0' int2str(cnt),'.jpg'];
%                     ofilename    = ['/home/bakkum/Desktop/movieframes/pics/' cmbfn                  '_0' int2str(cnt),'.jpg'];
%                     cfilename{fn}= ['/home/bakkum/Desktop/movieframes/pics/' Info.Exptitle{fn}  'crop_0' int2str(cnt),'.jpg'];
%     else            filename{fn} = ['/home/bakkum/Desktop/movieframes/pics/' Info.Exptitle{fn}       '_' int2str(cnt),'.jpg'];
%                     ofilename    = ['/home/bakkum/Desktop/movieframes/pics/' cmbfn                   '_' int2str(cnt),'.jpg'];
%                     cfilename{fn}= ['/home/bakkum/Desktop/movieframes/pics/' Info.Exptitle{fn}   'crop_' int2str(cnt),'.jpg'];
%     end
    filename{fn}=sprintf('/home/bakkum/Desktop/movieframes/pics/%s_%03d.jpg',Info.Exptitle{fn},cnt)
    cfilename{fn}=sprintf('/home/bakkum/Desktop/movieframes/pics/%scrop_%03d.jpg',Info.Exptitle{fn},cnt)
    cmd2=['convert ' filename{fn} ' -crop 1243x1490+541+63 ' cfilename{fn}];
    system(cmd2);
    cmd=[cmd cfilename{fn} ' '];
  end
  ofilename=sprintf('/home/bakkum/Desktop/movieframes/pics/%s_%03d.jpg',cmbfn,cnt)
  cmd=[cmd '+append ' ofilename];
  system(cmd);
  pause(.001)
  cnt=cnt+1;
end


% resize
for cnt=0:172
    disp(cnt)
    cmd=sprintf('convert  /home/bakkum/Desktop/movieframes/pics/%s_%03d.jpg  -resize 50%%  /home/bakkum/Desktop/movieframes/pics/%ssmall_%03d.jpg',cmbfn,cnt,cmbfn,cnt);
    system(cmd);    
end

    
% make movie
  filename_i = sprintf('/home/bakkum/Desktop/movieframes/pics/%ssmall',cmbfn);
  filename_o = sprintf('/home/bakkum/Desktop/movieframes/%s',cmbfn);  
  cmd=sprintf('ffmpeg -i %s_%%03d.jpg -vcodec libx264 -s vga -b 4096k -threads 0 -vframes %d -f mp4 %s.mp4',filename_i,cnt,filename_o)
  %filename_i = ['/home/bakkum/Desktop/movieframes/pics/' cmbfn]
  %filename_o = ['/home/bakkum/Desktop/movieframes/' cmbfn]
  %cmd=['ffmpeg -i ' filename_i '_%03d.jpg -vcodec libx264 -s vga -b 4096k -threads 0 -vframes ' num2str(cnt) ' -f mp4 ' filename_o '.mp4']
  
  
  system(cmd)
  
  
  
  
  

%% extract stim/soma pairs with nice daps

figure
xx=find(ELC==7871 & P_el==1352 & L>7 & L<20 & H<0)
plot(L(xx),T(xx),'.')

%%

fclose(fid);
fn=['/home/bakkum/spikes/' Info.Exptitle '.spike']
fn=['/home/bakkum/spikes/' Info.Exptitle '.spike-1']

fid=fopen(fn,'rb')
spks=AA;
spks=xx
spks=xx-6391225

clr=jet(200);


%% plot overlaid traces

figure
sz=84;
for i=1:length(spks)
spikenr=spks(i)-1

%fseek(fid,0,-1);

fseek(fid, spikenr*sz*2,'bof');%164,'bof');
spike=fread(fid,[sz 1],'uint16');%[82 1],'int16');

context=spike(8:81);

plot(context,'.-'); pause
%plot(context,'color',clr(round(L(xx(i))*10),:) );  hold on

end
colorbar
caxis([0 20])
hold off


%%




%% extract raw traces for a given electrode/channel



% 090411-B
% recording electrode 5233
% 130um from stim electrode
% raw source, not filtered

fseek(fh,0,-1); c=0;
[dat, cnt] = fread(fh,[128 40*41*tlen],'int16'); % 1 trig raw recording
[dat, cnt] = fread(fh,[128 40*tlen],'int16'); % 1 trig raw recording
tmp=dat(94,:);


traces=zeros(40,tlen);
traces_off=zeros(40,tlen);
for i=1:40
    data=tmp( (i-1)*tlen+1:i*tlen );
    traces(i,:)=data;
    traces_off(i,:)=data - mean(data(100:end)) ;
end



plot(traces')
plot(traces_off')

save('/home/bakkum/Desktop/090411-B-el5233-traces.mat','traces','traces_off')

%% 090411-A
% recording electrode 9710 (ch 114 on config 093)
% 
% raw source, not filtered


fseek(fh,0,-1); c=0;
[dat, cnt] = fread(fh,[128 1000*tlen],'int16');
[dat, cnt] = fread(fh,[128 1000*tlen],'int16');
[dat, cnt] = fread(fh,[128 1000*tlen],'int16');
[dat, cnt] = fread(fh,[128  720*tlen],'int16');
[dat, cnt] = fread(fh,[128   40*tlen],'int16'); % 1 trig raw recording
tmp=dat(1+114,:);

traces=zeros(40,tlen);
traces_off=zeros(40,tlen);
for i=1:40
    data=tmp( (i-1)*tlen+1:i*tlen );
    traces(i,:)=data;
    traces_off(i,:)=data - mean(data(100:end)) ;
end


plot(tmp)
plot(traces')
plot(traces_off')

save('/home/bakkum/Desktop/090411-A-el9710-traces.mat','traces','traces_off')



%% modify above for diff rec elc
% 
% raw source, not filtered

fclose(fh);
%  fn=['/home/bakkum/raw/' Info.Exptitle '.raw']
%  fn=['/home/bakkum/spikes/' Info.Exptitle '.raw-1']

fh=fopen(rawfile,'rb')
elc   =     519  ;
nstim =      29  ;
nchan = 126;


xx=find(el==elc);  % electrode of interest
c=ch(xx)           % channel
e=floor(xx/nchan)  % config number


fseek(fh,0,-1);
for i=1:e
[dat, cnt] = fread(fh,[128 nstim*tlen],'int16'); % run off data from earlier configs
end
[dat, cnt] = fread(fh,[128 nstim*tlen],'int16'); % 1 trig raw recording

tmp=dat(1+c,:);

traces=zeros(nstim,tlen);
traces_off=zeros(nstim,tlen);
for i=1:nstim
    data=tmp( (i-1)*tlen+1:i*tlen );
    traces(i,:)=data;
    traces_off(i,:)=data - mean(data(29:38)) ;
end


plot(tmp)
plot(traces')
plot(traces_off')

%   save('/home/bakkum/Desktop/tmp.mat','traces','traces_off')


mtrace=mean(traces);
for i=1:nstim
    hold off
    plot(mtrace,'k','linewidth',2)
    hold on
    plot(traces(i,:))
    title(int2str(i))
    grid on
    pause
end


 




%%
%%


figure
scatter(mposx,mposy,50,h,'filled')
set(gca,'YDir','reverse','Color',[1 1 1]*.6)
colorbar
axis equal



x = (0:10)'; 
y = sin(x); 

xi = (0:.25:10)'; 
yi = interp1q(x,y,xi); 
plot(x,y,'o',xi,yi,'.')

plot(xi,yi,'.')
plot(x,y,'.')





y=( median(context) );
y=(context(8,:));

%%
 n=6;
 Wn = .25; % 1==Nyquist freq // sampling rate = 20kHz, want 5kHz filter

% Transfer Function design
[b,a] = butter(n,Wn);
h1=dfilt.df2(b,a);      % This is an unstable filter.

yf = filter(b,a,y);
plot(x,y,'.',x,y,'b',x,yf,'r')



%%
% Zero-Pole-Gain design
[z, p, k] = butter(n,Wn);
[sos,g]=zp2sos(z,p,k);
h2=dfilt.df2sos(sos,g);

% Plot and compare the results
hfvt=fvtool(h1,h2,'FrequencyScale','log');
legend(hfvt,'TF Design','ZPK Design')








%% sorting neurons

% nmbr=zeros(size(elc_with_neuron));
% wdth=zeros(size(elc_with_neuron));
% hght=zeros(size(elc_with_neuron)); % max value of signal
% vlly=zeros(size(elc_with_neuron)); % valley == peak of AP (neg uV)
% bisi=zeros(size(elc_with_neuron)); % ISI in bursts 


figure
plot( ((wdth80+.0001)./(wdth20+.0001))', ((wdth80+.0001)./(wdth60+.0001))','.' )


X=[hght' wdth' bisi'];
X=[((wdth80+.0001)./(wdth20+.0001))' ((wdth80+.0001)./(wdth60+.0001))'];

opts = statset('Display','final');
[idx,ctrs] = kmeans(X,2,'Distance','city','Replicates',5, 'Options',opts);


plot(X(idx==1,1),X(idx==1,2),'r.','MarkerSize',12)
hold on
plot(X(idx==2,1),X(idx==2,2),'b.','MarkerSize',12)
hold off

plot3(X(idx==1,1),X(idx==1,2),X(idx==1,3),'r.','MarkerSize',12)
hold on
plot3(X(idx==2,1),X(idx==2,2),X(idx==2,3),'b.','MarkerSize',12)
hold off

XX=nmbr;
XX=bisi;
XX=hght;
XX=vlly;
XX=wdth;
plot(XX(idx==1),'r.','MarkerSize',12); hold on
plot(XX(idx==2),'b.','MarkerSize',12); hold off




    
    
    
    
    
%% instantaneous energy (SNEO in Meabench)

%Ec(t) = Vc'(t)^2 − Vc(t)Vc''(t).

Vc1=[0 diff(y)];
Vc2=[0 diff(Vc1)];
Ec=Vc1.^2-y.*Vc2;

%% moving window power (rms; Buzsaki method)
bin=2;
Pc=zeros(size(y));
for n=1:74-bin;
    Pc(n+bin/2)=std(y(n:n+bin));
end

plot(x,y,'ko',x2,y2,'k',x,Ec,'r',x,Pc,'b')




%% low pass filter from Filters.H in meabench
%  /*:D Lowpass filter: first order RC filter.
%    .  dy/dt = (1/tau) (x-y), i.e.
%    .    y'  = y + (1/tau) (x-y)
%  */
%    /*:A tau0 is the time constant of the filter. */

HIGHCUTOFF = 2500; %// Hz (f_3dB, not omega_3dB)
HIGHTAU = 20*1000 / (2*3.14159265 * HIGHCUTOFF);
tau0=HIGHTAU;
eps=1/tau0;

yf=zeros(size(cntx));
yf(1)=cntx(1);%0;
for n=2:length(cntx)
 lasty=yf(n-1);
 yf(n) = lasty + eps * (cntx(n)-lasty);
end



%% high pass filter from Filters.H in meabench
%  /*:D Highpass filter: first order RC filter.
%    .  dy/dt = dx/dt - (1/tau) y, i.e.
%    .     y' = x' - x + (1-1/tau) y. */

LOWCUTOFF = 150; %// Hz (f_3dB, not omega_3dB!)
LOWTAU = 20*1000 / (2*3.14159265 * LOWCUTOFF);
tau0=LOWTAU;
mul=1-1/tau0;

yf=zeros(size(cntx));
yf(1)=0;%cntx(1);
for n=2:length(cntx)
    lasty=yf(n-1);
    lastx=cntx(n-1);
    dxdt=cntx(n)-lastx;
    %yf(n)= lasty + dxdt - lastx + mul * lasty;
    yf(n)= cntx(n) - lastx + mul * lasty;
end
%float operator()(float x) { lasty = x-lastx + mul*lasty; lastx=x;   return lasty; }
%float operator()() const { return lasty; }
%void reset(float x=0) { lastx=x; lasty=0; }



%% loop through ntk file extracting data

%%% clear all

% base  = 'Trace_id763_2011-07-26T'
% ending= '.stream.ntk'
% 
% 
% % events
% spikefile='/home/bakkumd/tmp2.spike'
% fname = [base '14_55_41_0' ending];
% 
% 
% 
% 
% 
% % events + info
% spikefile='/home/bakkumd/tmp3.spike'
% fname = [base '15_10_25_1' ending];

fname = ['Trace_id763_2011-07-26T19_20_55_0' ending];


ntk=initialize_ntkstruct(fname)     ;
%ntk=initialize_ntkstruct(fname, 'hpf', hpf, 'lpf', lpf);


dat=[];
frm=[];
dac=[];
f=0;
while(f<600)    
    
    [ntk2 ntk]=ntk_load(ntk, 300000);
    dat=[dat ntk.data(1:126,:)];
    frm=[frm double(ntk.frame_no)];
    dac=[dac ; ntk2.dac2];
    f=frm(end)/20000    ;      
    ntk.dacs{1}     ;
    disp(['time ' num2str(f)])
end
plot (dat')
plot (dac)



y=loadspikeCMOS(spikefile)



%%
figure(1); 
os=frm(1) + 629069 + 134110;
plot(frm-os,dac-512,'-o'); hold on
plot(y.time*20000-os,y.channel,'r.')
grid on
hold off









%% junk


i=100;
r=16;
xx=find(C<126 & E>0 & H<0);
x=[-25+1/r:1/r:49]+26-1; % x axis points [msec]
%%
i=i+1; cntx=plotspikecontext_CMOS(spikefile,xx(i),1,0,0); 

figure(14)
plot([1:74]/20,cntx,'-o','linewidth',2)

y=reconstruct(cntx',r);
hold on; plot(x/20,y,'k','linewidth',2); hold off
xlabel Time[ms]
ylabel Voltage[digi]
title([Info.Exptitle ' reconstructed signal'])




%%











d=0:1023;

Vin=d*2.99/1024;
I=-76.2*(Vin-2.5)+4.2;

plot(d,I,'.')

grid on





I=-9.4*(Vin-2.5)+.46;

plot(d,I,'.')
grid on






