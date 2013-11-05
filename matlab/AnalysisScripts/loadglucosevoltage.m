function volt=loadglucosevoltage(fn)

% DB 12/2009
% Reads the voltages [volt] from the csv file [fn] created by Akira
% Matsumoto's glucose sensor, equipement, and software.


fh = fopen(fn,'rb');
fseek(fh,0,1);
len = ftell(fh);
fseek(fh,0,-1); cc=0;
volt=zeros(1,ceil(len/79)); % approximate length
y=fscanf(fh, '%s"%s,"'); % read off headers
y=fscanf(fh, '%s"%s,"'); % read off headers
y=fscanf(fh, '%s"%s,"'); % read off headers
y=fscanf(fh, '%s"%s,"'); % read off headers

while(1)
cc=cc+1;
    %[y cnt]=fscanf(fh, '%s"%s,"'); % get one line
    [y cnt]=fscanf(fh, '%*s%f',6);
    if cnt==0, break; end
    volt(cc)=y(4);
    %[a b c d volt(cc) f ]=strread(y,'%*s%f,"%*s%f,"%*s%f,"%*s%f,"%*s%f,"%*s%f,"%*s',1,'delimiter','"');
    if(mod(cc,10000)==0) disp(cc); end
end
volt=volt(1,1:(cc-1)); % clip any extra zeros
fclose(fh);