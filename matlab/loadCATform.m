function y=loadCATform(fn,freq)

%
% DB 2/2006: Adapted from loadspike.m to load binary formatted spikes from FormatSpikeData.cpp
% DB 4/2006: Adapted from loadspikeform.m to load binary CAT data from FormatCAT.cpp
%


if nargin<2 || isnan(freq)
  freq=25; % default is 25 kHz
  disp(['Using default frequency ' int2str(freq)])
end

fid = fopen(fn,'rb');
if (fid<0)
  error('Cannot open the specified file');
end
fseek(fid,0,1);
len = ftell(fid);
fseek(fid,0,-1);

CHUNK=100;


linesize = 6012;
binsize  = 1000;
y.T    = zeros(1,ceil(len/linesize));
y.E    = zeros(1,ceil(len/linesize));
y.P_hw = zeros(1,ceil(len/linesize));
y.CATX = zeros(binsize,ceil(len/linesize));
y.CATY = zeros(binsize,ceil(len/linesize));
y.A    = zeros(binsize,ceil(len/linesize));
fprintf(2,'Starting to read\n');

n=0;
i=0;
while 1,
%while i<len/linesize
  i=i+1;
  [dat, cnt] = fread(fid,[linesize/2 CHUNK],'int16');
  if cnt 
    now = cnt/(linesize/2);
     ti0 = dat(1,:); idx = find(ti0<0); ti0(idx) = ti0(idx)+65536;
     ti1 = dat(2,:); idx = find(ti1<0); ti1(idx) = ti1(idx)+65536;
     ti2 = dat(3,:); idx = find(ti2<0); ti2(idx) = ti2(idx)+65536;
     ti3 = dat(4,:); idx = find(ti3<0); ti3(idx) = ti3(idx)+65536;
    y.T(n+[1:now])       = (ti0 + 65536*(ti1 + 65536*(ti2 + 65536*ti3)));
    y.E(n+[1:now])       = dat( 5,:);
    y.P_hw(n+[1:now])    = dat( 6,:);
    y.CATX(:,n+[1:now])  = dat([          7:  binsize+6],:)/10;
    y.CATY(:,n+[1:now])  = dat([  binsize+7:2*binsize+6],:)/10;
    y.A(:,n+[1:now])     = dat([2*binsize+7:3*binsize+6],:);
    
    fprintf(2,'CATforms read: %i\n',n);
    n = n + now;
  else
        break
  end 
clear dat cnt
end  

if isnan(freq)
    freq = 25.0;
end
y.T = y.T/(freq*1000); % sec
 
 
fprintf(2,'\t%i probes\n',n);
fclose(fid);
