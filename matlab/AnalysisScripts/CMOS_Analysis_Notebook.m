%% CMOS analysis notebook


%% comparing el pos for el2fi vs values returned by server

for i=1:140:11200

rng=i:i+140-1;

hold off
plot(map2.x(rng),map2.y(rng),'.','markersize',20)
hold on
plot(mapT(rng,3),mapT(rng,4),'.r','markersize',5)
 
pause
end





%% testing autoconfig    post 9/2/6

clear all;
pd=pwd;
cd '/opt/cmosmea_external/configs';
testing_neuromap;
cd(pd);

len=length(map.ch); 



xx=find(map.x+map.y~=0);
yy=find(map.x+map.y==0);
disp(['% unique ' num2str(length(unique(map.el))) ' ' num2str(length(xx)) '   ' num2str(length(unique(map.el))/length(xx))])
%length(yy)


plot(map.x,map.y,'.')
set(gca,'YDir','reverse')
axis equal
axis([0 2000 0 2200])


st_id=find(map.stim>0);

if ~isempty( find( diff(map.y(st_id))~=0 | diff(map.x(st_id))~=0 | diff(map.el(st_id))~=0 ) )
    fprintf(1,'\n\n\nERROR decoding stim electrode\n\n')
    return;
end

nconf=length(st_id);
nchan=length(map.ch)/nconf;





%% test auto configuration  -- pre 9/2/6

clear all;
pd=pwd;
cd '/opt/cmosmea_external/configs/';
testing_neuromap;
cd(pd);

nconf=length(map);
nchan=length(map{1}.ch);

ch    = zeros(nconf,nchan);
el    = zeros(nconf,nchan);
px    = zeros(nconf,nchan);
py    = zeros(nconf,nchan);
st    = zeros(nconf,nchan);
st_id = zeros(nconf,nchan);
c=0;
for i=1:nconf
        c=c+1;
        ch(i,:)=map{i}.ch;
        el(i,:)=map{i}.el;
        px(i,:)=map{i}.x;
        py(i,:)=map{i}.y;
        st(i,:)=ones(1,nchan)*map{i}.s;
        st_id(i,:)=find(map{i}.ch==map{i}.s,1)+nchan*(i-1);
        %el(i,st_id(i,1))
end
ch=reshape(ch',1,nconf*nchan);
el=reshape(el',1,nconf*nchan);
px=reshape(px',1,nconf*nchan);
py=reshape(py',1,nconf*nchan);
st=reshape(st',1,nconf*nchan);
st_id=reshape(st_id',1,nconf*nchan);


xx=find(px+py~=0);
yy=find(px+py==0);
disp(['% unique ' num2str(length(unique(el))) ' ' num2str(length(xx)) '   ' num2str(length(unique(el))/length(xx))])
%length(yy)


plot(px,2100-py,'.')
axis([0 2000 0 2200])
axis equal





%% try automate config files
%--- need to do in cpp
% create neuropos file

px=[0:.01:1]*(1900-170)-170;    % suggested x pos  [170 1900]
py=[0:.01:1]*(2100-100)-100;          % suggested y pos  [100 2100]
nsize=px*0+25;  % circle size (25 is default in NeuroDishRouter)
sr=px*0+1;      % ??
st=px*0;        % '1' -> ask to be stimulation electrode
st(1)=1;
dir='/opt/cmosmea_external/configs/';
fn='test_autoconfig';

fnnp = hidens_save_neuropos_db(px,py,nsize,sr,st,[dir fn]);

% 'solve' routing
cmd=['/opt/cmosmea_external/hidens_soft/trunk/bin/NeuroDishRouter -v 2 -n -s ' dir fn ' -l ' fnnp]
%unix(cmd);  %% doesnt work in matlab! works ok in command line....?

fname=['tmp.bat'];
fid = fopen(fname, 'w');
fprintf(fid, ['#!/bin/bash\n\n' cmd '\n']);
fclose(fid)
unix(['chmod u+x ' fname])
system(cmd)



%% test encoding stim channel info on DAC
y=loadspikeCMOS('/home/bakkum/spikes/090130-A-testencoding.spike'); % channel only
y=loadspikeCMOS('/home/bakkum/spikes/090130-B-testepoch.spike'); % epoch+channel
xx=find(y.channel==127);
length(xx)

T=y.time(xx)/25000;
C=y.channel(xx);
Context=128-y.context(:,xx)/16;
plot(diff(T),'.')
plot(Context)


Exptitle={'090130-A-testencoding'};  
Exptitle={'090130-B-testepoch'};   
for i=1:length(Exptitle)
Info.Exptitle=Exptitle{i};   
expt=['/home/bakkum/spikes/spikeform/' Info.Exptitle '.spikeform']    
y=loadspikeform(expt);
end

xx=find(y.C==127);
length(xx)

T=y.T(xx);
C=y.C(xx);
P_hw=y.P_hw(xx);
E=y.E(xx);
plot(diff(T),'.')

plot(P_hw,'.')
unique(P_hw)

plot(sort(E),'.')
plot(diff(unique(E)),'.')
%-- encoding works!!


%% test response vs number of channels stimulated at one time
% A 1col-1stimrow           (3 electrodes; also used in D,E)
% B 1col-NOstimrow 3chanbuf (same 3 electrodes as A)
% C NO col         3chanbuf (same 3 electrodes as A)     
% D 3col-1stimrow           (9 electrodes)
% E NO col         8chanbuf (8 electrodes; all but 1 from D)
% F NO col         1chanbuf (1 electrode; used in all of above)

clear all
fr=[];
Exptitle={'090129-A' '090129-B' '090129-C' '090129-D' '090129-E' '090129-F'};   

for i=1:length(Exptitle)
Info.Exptitle=Exptitle{i};   
Info.Probe=64;
analog=126;
    
expt=['/home/bakkum/spikes/spikeform/' Info.Exptitle '.spikeform']    
y=loadspikeform(expt);

XX=find(y.C~=3 & y.C~=9 &  y.C~=33 & y.C~=38 & y.C~=56 & y.C~=59 & y.C~=102 & y.C~=108 & y.C~=125 );

C=y.C(XX);
T=y.T(XX);
L=y.L(XX);
E=y.E(XX);

PTS  =y.PTS(XX);
P_hw =y.P_hw(XX);
P_num=y.P_num(XX);
P_t  =y.P_t(XX);


%Raster8x8
%figure
LL=find(L<100 & L>0);
fr=[fr length(LL)/max(P_num)];
hist(L(LL),50)
set(gca,'ylim',[0 250])

%pause  

end

figure(99)
bar(fr)
return

fr0_100=fr; % change LL find param to get this
fr0_200=fr;

order=[4 5 1 3 6 2];
bar([fr0_200(order)' fr0_100(order)'],1.5)


%-- (see notebook date 090129) 



%% look at stimulation waveform to see if slopes are steep enough

figure
y=loadspikeCMOS('/home/bakkum/Desktop/090122-B.spike');

xx=find(y.channel==100 & y.height>4000);
length(xx)

m=mean(y.context(:,xx(2:end))')*(11.7/16 * 1000/958.558);
plot(m-m(1))
set(gca,'ylim',[-1100 1100])
ylabel mV
xlabel sample
title AveOf15Stim


for i=1:length(xx)
    plot([1:74]+rand(),y.context(:,xx(i))/(11.7/16 * 1000/958.558)); hold on;
%    pause
end
hold off

%-- stimulation waveform looks good. fast enough transients -> correct stim input to electrode, but still small response

