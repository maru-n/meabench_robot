function y=loadBURSTinfo(fn,freq)
% Writen by Douglas Bakkum in April 2006
% loads burst data created by BurstDetector.cpp

if nargin<2 || isnan(freq)
  freq=20; % default is 20 kHz
  disp(['Using default frequency ' int2str(freq)])
end

fid = fopen(fn,'rb');
fseek(fid,0,1);
len = ftell(fid);
fseek(fid,0,-1);

CHUNK=100;

linesize = 40;
y.T_start  = zeros(1,ceil(len/linesize));
y.T_end    = zeros(1,ceil(len/linesize));
y.S        = zeros(1,ceil(len/linesize)); % burst size
y.P_num    = zeros(1,ceil(len/linesize));
y.L        = zeros(1,ceil(len/linesize)); % latency
fprintf(2,'Starting to read\n');

n=0;
i=0;
while 1,
%while i<57
  i=i+1;
  [dat, cnt] = fread(fid,[linesize/2 CHUNK],'int16');
  if cnt 
    now = cnt/(linesize/2);
     ti0 = dat(1,:); idx = find(ti0<0); ti0(idx) = ti0(idx)+65536;
     ti1 = dat(2,:); idx = find(ti1<0); ti1(idx) = ti1(idx)+65536;
     ti2 = dat(3,:); idx = find(ti2<0); ti2(idx) = ti2(idx)+65536;
     ti3 = dat(4,:); idx = find(ti3<0); ti3(idx) = ti3(idx)+65536;
    y.T_start(n+[1:now])  = (ti0 + 65536*(ti1 + 65536*(ti2 + 65536*ti3)));
     ti0 = dat(5,:); idx = find(ti0<0); ti0(idx) = ti0(idx)+65536;
     ti1 = dat(6,:); idx = find(ti1<0); ti1(idx) = ti1(idx)+65536;
     ti2 = dat(7,:); idx = find(ti2<0); ti2(idx) = ti2(idx)+65536;
     ti3 = dat(8,:); idx = find(ti3<0); ti3(idx) = ti3(idx)+65536;
    y.T_end(n+[1:now])    = (ti0+ 65536*(ti1 + 65536*(ti2 + 65536*ti3)));
     ti0 = dat(9,:); idx = find(ti0<0); ti0(idx) = ti0(idx)+65536;
     ti1 = dat(10,:); idx = find(ti1<0); ti1(idx) = ti1(idx)+65536;
     ti2 = dat(11,:); idx = find(ti2<0); ti2(idx) = ti2(idx)+65536;
     ti3 = dat(12,:); idx = find(ti3<0); ti3(idx) = ti3(idx)+65536;
    y.L(n+[1:now]) = (ti0+ 65536*(ti1 + 65536*(ti2 + 65536*ti3))); 
     ti0 = dat(13,:); idx = find(ti0<0); ti0(idx) = ti0(idx)+65536;
     ti1 = dat(14,:); idx = find(ti1<0); ti1(idx) = ti1(idx)+65536;
     ti2 = dat(15,:); idx = find(ti2<0); ti2(idx) = ti2(idx)+65536;
     ti3 = dat(16,:); idx = find(ti3<0); ti3(idx) = ti3(idx)+65536;
    y.P_num(n+[1:now])= (ti0+ 65536*(ti1 + 65536*(ti2 + 65536*ti3)));
    y.S(n+[1:now])    = dat( 17,:);
    y.P_hw(n+[1:now]) = dat( 18,:);
    
    fprintf(2,'Burstinfos read: %i\n',n);
    n = n + now;
  else
        break
  end 
clear dat cnt
end  

if isnan(freq)
    freq = 20.0;
end
y.T_start = y.T_start/(freq*1000); % sec
y.T_end   = y.T_end/(freq*1000);   % sec
y.L       = y.L/(freq);            % msec
 
 
fprintf(2,'\t%i probes\n',n);
fclose(fid);
