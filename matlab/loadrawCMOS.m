function raw = loadrawCMOS(fn) 
% DB
% function raw = loadrawCMOS(filename) 
%


if nargin<1
    error('Not enough input parameters.')
end

fh = fopen(fn,'rb');
fseek(fh,0,1);
len = ftell(fh);
fseek(fh,0,-1);

CHUNK=20000; % read 1 sec at a time
raw = zeros(128,len/128/2);
n=0;

while n<=len/128,
   [dat, cnt] = fread(fh,[128 CHUNK],'int16');
   if cnt 
     fprintf(2,'Seconds read: %i\n',ceil(n/20000));
     now = cnt/128;
     raw(:,n+[1:now]) = dat;
     n = n + now;
   else
     break
   end
 end  

fclose(fh);

