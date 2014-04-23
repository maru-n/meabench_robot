function y=loadspikeform(filename, number)
%
% DB 2/2006: Adapted from loadspike.m to load binary formatted spikes from FormatSpikeData.cpp
%
% Spike = LOADSPIKEFORM( Filename, Number ) loads a Number of spikes (default = all)
% from Filename into structure Spike with members:
%   T       time    
%   L       latency
%   C       channel 
%   H       height  
%   W       width   
%   Th      thresh 
%   E       epoch / config number
%   clid    clean spike id [1 / 0]
%   CLID    clid(clid==1)
%   PTS     precise timed spike (i.e. dAP) number
%   P_hw    probe hardware (i.e. channel)
%   P_num   probe number
%   P_t     probe time
%
% Context is not loaded.
%


CHUNK = 10000;
sz    =    48; %% was 44 in Atlanta...; sizeof(SPIKEform)

load global_cmos

fid = fopen(filename,'rb');
if (fid<0)
  error('Cannot open the specified file');
end

if ~exist('number','var')
    fseek(fid,0,1);
    len = ftell(fid);
    fseek(fid,0,-1);
    number = floor(len/sz);
elseif mod(number,CHUNK)
    number = CHUNK*(floor(number/CHUNK)+1); % round up 
end


       
y.T    = zeros(1,number);
y.L    = zeros(1,number);
y.C    = zeros(1,number);
y.H    = zeros(1,number);
y.W    = zeros(1,number);
y.Th   = zeros(1,number);
y.E    = zeros(1,number);
y.clid = zeros(1,number);
y.PTS  = zeros(1,number);
y.P_hw = zeros(1,number);
y.P_num= zeros(1,number);
y.P_t  = zeros(1,number);


n=0;
i=0;
%while 1,
while i<number/CHUNK
%while i<57
  i=i+1;
  [dat, cnt] = fread(fid,[sz/2 CHUNK],'int16');
  
  if cnt 
    now = cnt/(sz/2);
     
     ti0 = dat(1,:); idx = find(ti0<0); ti0(idx) = ti0(idx)+65536;
     ti1 = dat(2,:); idx = find(ti1<0); ti1(idx) = ti1(idx)+65536;
     ti2 = dat(3,:); idx = find(ti2<0); ti2(idx) = ti2(idx)+65536;
     ti3 = dat(4,:); idx = find(ti3<0); ti3(idx) = ti3(idx)+65536;
    y.T(n+[1:now]) = (ti0 + 65536*(ti1 + 65536*(ti2 + 65536*ti3)));
     ti0 = dat(5,:); idx = find(ti0<0); ti0(idx) = ti0(idx)+65536;
     ti1 = dat(6,:); idx = find(ti1<0); ti1(idx) = ti1(idx)+65536;
     ti2 = dat(7,:); idx = find(ti2<0); ti2(idx) = ti2(idx)+65536;
     ti3 = dat(8,:); idx = find(ti3<0); ti3(idx) = ti3(idx)+65536;
    y.L(n+[1:now]) = (ti0+ 65536*(ti1 + 65536*(ti2 + 65536*ti3)));
     ti0 = dat( 9,:); idx = find(ti0<0); ti0(idx) = ti0(idx)+65536;
     ti1 = dat(10,:); idx = find(ti1<0); ti1(idx) = ti1(idx)+65536;
     ti2 = dat(11,:); idx = find(ti2<0); ti2(idx) = ti2(idx)+65536;
     ti3 = dat(12,:); idx = find(ti3<0); ti3(idx) = ti3(idx)+65536;
    y.P_t(n+[1:now]) = (ti0+ 65536*(ti1 + 65536*(ti2 + 65536*ti3)));
    
    y.C(n+[1:now]) = dat(13,:);
    y.H(n+[1:now]) = dat(14,:);
    y.W(n+[1:now]) = dat(15,:);
    y.Th(n+[1:now])= dat(16,:);
    y.E(n+[1:now]) = dat(17,:);
    y.clid(n+[1:now]) = dat(18,:);
    y.PTS(n+[1:now])  = dat(19,:);
    y.P_hw(n+[1:now]) = dat(20,:);
     ti0 = dat(21,:); idx = find(ti0<0); ti0(idx) = ti0(idx)+65536;
     ti1 = dat(22,:); idx = find(ti1<0); ti1(idx) = ti1(idx)+65536;
    y.P_num(n+[1:now])= (ti0+ 65536*ti1);
    
    fprintf(2,'Spikeform read: %i\n',n);
    n = n + now;
  else
        break
  end 
end  
fclose(fid);
clear dat cnt ti0 ti1 ti2 ti3


    
if isnan(FREQ_KHZ)
    FREQ_KHZ = 20.0;
end
    

     uvperdigi = GAIN; %11.7/16 * 1000/958.558; % 11.7mV/8-bit (3V range); meabench uses 12-bit (mcs convention) -- 16=2^12 / 2^8; 1000 to put into uV; 958 is standard CMOS gain (A1-30, A2-30 A3-bypass)
     mvperdigi = 11.7/16; % aux
     isaux = find(y.C >= NCHAN);
     iselc = find(y.C <  NCHAN);
     y.H(iselc)  = y.H(iselc)  .* uvperdigi;
     y.Th(iselc) = y.Th(iselc) .* uvperdigi;
     y.H(isaux)  = y.H(isaux)  .* mvperdigi;
     y.Th(isaux) = y.Th(isaux) .* mvperdigi;
     
 y.T   = y.T   / (FREQ_HZ ); % sec
 y.P_t = y.P_t / (FREQ_HZ ); % sec
 y.W   = y.W   /  FREQ_KHZ;  % ms
 y.L   = y.L   /  FREQ_KHZ;  % ms
 
 y.CLID = find( y.clid == 1 );
 
 
 