function [context context_vector context_vector_times]=plotspikecontext(fn,spikenr,figno,os,clr,DOFILT)
% Douglas Bakkum
%
%%%%%  USE plotspikeshape() instead %%%%
%
% [context context_vector context_vector_times]=PLOTSPIKECONTEXT(fn,spikenr,figno,os,clr,dofilt)
%    Plots the context of one spike from a spike file. Contexts are filtered using the
%    UltraMegaSorter recommended butterworth filter and filtfilt command, with customized
%    cutoff frequencies (see code).
% FN      is a file name of a spikefile.
% SPIKENR is a spike index
% FIGNO   specifies which figure should be used to plot the context (default current figure).
% OS      is offset for the x-axis (time in sec).
% CLR     is plot color. if clr==0, then do not plot.
% DOFILT  bool flag to run UMS2000 bandpass filter

disp '     '
disp '     !  USE plotSpikeShape.m instead  !'
disp '        See its help page for usage.'
disp '     '

return

spikenr = spikenr - 1; % count from 0 instead of 1

if nargin<6
    DOFILT=0;
end
if nargin<4
  os=0;
elseif isempty(os)
  os=0;
end

num_spikes = length(spikenr);
if length(os)==1
    os=repmat(os,1,num_spikes);
end

ccnd = [.9 .9 .9];
cnow = [.9 .9 .9];
craw = [ 0  0  0];
DOPLOT=1;
if nargin>4
    craw = clr;
end


if sum(craw==0) && length(craw)==1
    DOPLOT=0;
end

if nargin<3 && DOPLOT
  figure;
  os=0;
elseif DOPLOT
    figure(figno);
end

freq=20; %kHz

if DOFILT
    % % bandpass from UltraMegaSort2000
    [bpB, bpA] = ums2000_setup;
    % Wp = [ 200  3000] * 2 / (freq*1000);    % pass band
    % Ws = [ 100  5000] * 2 / (freq*1000);    % transition zone
    % [N,Wn] = buttord(Wp,Ws,3,20);           % determines filter parameters
    % [bpB,bpA]= butter(N,Wn);                % builds filter
    % % data=filtfilt(bpB,bpA,data);          % runs filter
end


sz=84; %% was 82 in Atlanta...; sizeof(spikeinfo) -- due to 64 bit os

len=[]; fn_cnt=0; ext='';
while exist([fn ext],'file') % loop through to check for spikes in filename.spike, filename.spike-1, etc.
    fid=fopen([fn ext],'rb');
    
    fseek(fid,0,1);
    len(fn_cnt+1) = ftell(fid)/(sz*2);%164;
    fseek(fid,0,-1);
    fclose(fid);
    
    % fprintf(1,'Length of %s is \t%i spikes.\n',[fn ext],len(fn_cnt+1));
    
    fn_cnt=fn_cnt+1;
    ext=['-' num2str(fn_cnt)];
end


context=zeros(num_spikes,74);
cnt=0;
for id = spikenr
    cnt=cnt+1;
    
    ext='';
    for i=1:length(len)  % check which spikefile contains the spike, and update filename [fn ext]
        if id < sum(len(1:i))
            break;
        end
        ext=['-' num2str(i)];  
    end
    
    % fprintf(1,' %s   Spike %i  %i/%i\n',[fn ext],id,cnt,num_spikes);
    fid=fopen([fn ext],'rb');
    fseek(fid, (id-sum(len(1:i-1)))*sz*2,'bof');
    spike=fread(fid,[sz 1],'uint16');
    fclose(fid);       
 

    context(cnt,:)=spike(8:81);
    ti0 = spike(1,:); idx = find(ti0<0); ti0(idx) = ti0(idx)+65536;
    ti1 = spike(2,:); idx = find(ti1<0); ti1(idx) = ti1(idx)+65536;
    ti2 = spike(3,:); idx = find(ti2<0); ti2(idx) = ti2(idx)+65536;
    ti3 = spike(4,:); idx = find(ti3<0); ti3(idx) = ti3(idx)+65536;
    ti  = (ti0 + 65536*(ti1 + 65536*(ti2 + 65536*ti3))) ;

    %% add cleancontext constraints
    % parameters
    relthresh=0.5;
    testidx=[[5:13] [40:50]];
    abstestidx=[1:74];
    abstestidx([1:min(testidx)-1])=0;
    abstestidx([max(testidx)+1:74])=0;
    %abstestidx(testidx)=0;
    abstestidx([23:28])=0;
    abstestidx=abstestidx(find(abstestidx));% {5..22, 29..50}
    testidx=(testidx-25)/25;
    abstestidx=(abstestidx-25)/25;
    % calculations
     first=context(1:15);
     last=context(61:74);
     dc1=mean(first);
     dc2=mean(last);
     v1=var(first);
     v2=var(last);
     dc=(dc1*v2+dc2*v1)/(v1+v2+1e-10); % == (dc1/v1 + dc2/v1) / (1/v1 + 1/v2)
     now=context(1:74) - dc;


     %context=context*683/2048; 
     context=context;%*11.7/16 * 1000/958.558;% 11.7mV/8-bit (3V range); meabench uses 12-bit (mcs convention) -- 16=2^12 / 2^8; 1000 to put into uV; 958 is standard CMOS gain (A1-30, A2-30 A3-bypass)

     %now=now*683/2048;
     now=now;%*11.7/16 * 1000/958.558;% 11.7mV/8-bit (3V range); meabench uses 12-bit (mcs convention) -- 16=2^12 / 2^8; 1000 to put into uV; 958 is standard CMOS gain (A1-30, A2-30 A3-bypass)

     peak=mean(now(25:26));

     %os=(ti-25)/25000; %offset to real time
     %os=0;


     % H=spike(6)*683/2048;
     % Th=spike(82)*638/2048;
end





% filter data (makes sense?)
%DOFILT=1;
range = [-25 48];
if DOFILT
    range = [-26 49];
    % add median values at beginning and end to (mostly) avoid artifacts at edges
    %contxt  = filtfilt( bpB, bpA, [median(context,2) context median(context,2)]' )';
    context = [median(context,2) context median(context,2) ] ;
end

%  Change into vector for easier/faster plotting.
l = length([range(1):range(2)+1]);
context_vector       = zeros( l*num_spikes , 1);
context_vector_times = zeros( l*num_spikes , 1);

for cnt=1:size(context,1)
     context_vector( l*(cnt-1) + [range(1):range(end)]-range(1) + 1 ) = detrend( context(cnt,:) );
     context_vector( l*(cnt-1) + range(end)-range(1) + 1 + 1) = NaN;
     context_vector_times( l*(cnt-1) + [range(1):range(end)]-range(1) + 1 ) = (round(os(cnt)*freq*1000)+[range(1):range(end)])/freq/1000;
     context_vector_times( l*(cnt-1) + range(end)-range(1) + 1 + 1) = NaN;
end

if DOFILT
    disp 'Running bandpass filter ...'
    %context_vector(hasdata==0) = median(context_vector(hasdata>0));
    context_vector(isnan(context_vector)) = median(context_vector(~isnan(context_vector)));
    context_vector = detrend(context_vector);
    context_vector = filtfilt(bpB,bpA,context_vector);  % want to run filt on combined data, such that contexts overlap exactly (otherwise detrend or filt gives slight offsets)
                                                         % need to run filt on data w/o NaN's...
    disp '... continuing.'
end





if DOPLOT
    
        plot( context_vector_times, context_vector,'Color',craw); 
        hold on
        
        %   line(os+[-25 48]/25000,-[Th Th],'Color',craw) 
        %   line(os+[-25 48]/25000, [Th Th],'Color',craw) 
        %   line(os+[-25 48]/25000,[0 0],'Color',[.6 .6 .6])
        %   
        %   plot(os+abstestidx,peak*.9,'Color',ccnd)
        %   line(os+([ 5  5]-25)/25000,[peak*.9-1 peak*.9+1],'Color',ccnd)
        %   line(os+([22 22]-25)/25000,[peak*.9-1 peak*.9+1],'Color',ccnd)
        %   line(os+([29 29]-25)/25000,[peak*.9-1 peak*.9+1],'Color',ccnd)
        %   line(os+([50 50]-25)/25000,[peak*.9-1 peak*.9+1],'Color',ccnd)
        % 
        %   plot(os+testidx, peak*relthresh,'Color',ccnd)
        %   %plot(os+testidx,-peak*relthresh,'Color',ccnd)
        %   line(os+([ 5  5]-25)/25000,[peak*relthresh-1 peak*relthresh+1],'Color',ccnd)
        %   line(os+([13 13]-25)/25000,[peak*relthresh-1 peak*relthresh+1],'Color',ccnd)
        %   line(os+([40 40]-25)/25000,[peak*relthresh-1 peak*relthresh+1],'Color',ccnd)
        %   line(os+([50 50]-25)/25000,[peak*relthresh-1 peak*relthresh+1],'Color',ccnd)

          %axis([-.001 .002 (min(now))-2 (max(now))+2])
          %axis([-.001 .002 -abs(Th)-25 abs(Th)+25])
          %saveas(gcf,name,'tiff')

        xlabel('Time [s]');
        ylabel('Digital units');
        title(sprintf('Channel=%i\tTime=%f',spike(5),ti/freq/1000));
        grid on
        drawnow
        pause(.01)
      
end

disp ''
disp 'USE plotspikeshape() instead!'
disp ''
