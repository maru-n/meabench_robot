function [waveform waveform_vector waveform_vector_times]=plotSpikeShape(Info,spikeIndex,timeOffset,varargin)
%   Douglas Bakkum 2012
%    Plots the waveform of spikes (spikeIndex) from a spike file listed in 
%    Info. timeOffset can be '0' to overlay spikes or a vector of offsets
%    (i.e. from spike.T or spike.L).
%
% [waveform waveform_vector waveform_vector_times]=PLOTSPIKESHAPE(Info,spikeIndex,timeOffset,varargin)
%
%  options include:
%       'figure'    - figure number (default is 'gcf'; value of 0 will not plot)
%       'color'     - plot color (default is blue)
%       'bandpass'  - [0/1] bandpass filter using UltraMegaSort2000 filter (default = 0)
%       'detrend'   - [0/1] use the 'detrend' command to offset the mean (default = 1)
%

% Update of plotspikecontextCMOS.m


BANDPASS   = 0;         % default
COLOR      = [0 0 1];   % default
FIGNO      = gcf;       % default
DETREND    = 1;         % default

numvarargs = 1;
while numvarargs <= length(varargin)
    if     strcmp(varargin{numvarargs},'bandpass' ),        
        % bandpass from UltraMegaSort2000 
        BANDPASS   = 1;
        [bpB, bpA] = ums2000_setup;
    elseif strcmp(varargin{numvarargs},'figure'   ),         
        FIGNO      = varargin{numvarargs+1}; 
        numvarargs = numvarargs+1;
    elseif strcmp(varargin{numvarargs},'color'    ),         
        COLOR      = varargin{numvarargs+1}; 
        numvarargs = numvarargs+1;
    elseif strcmp(varargin{numvarargs},'detrend'  ),   
        DETREND    = varargin{numvarargs+1}; 
        numvarargs = numvarargs+1;
    else
        error('Unrecognized option %s.\n',varargin{numvarargs});
        error('Unrecognized option %i.\n',varargin{numvarargs});
    end
    numvarargs=numvarargs+1;
end

filename   = Info.FileName.Spike;
spikeIndex = spikeIndex - 1; % count from 0 instead of 1
freq       = 20; %kHz
sz         = 84; %% was 82 in Atlanta...; sizeof(spikeinfo) -- due to 64 bit offset

num_spikes = length(spikeIndex);
if length(timeOffset)==1
    timeOffset=repmat(timeOffset,1,num_spikes);
end

% loop through to check for spikes in filename.spike, filename.spike-1, etc.
len=[]; fn_cnt=0; ext='';
while exist([filename ext],'file') 
    fid=fopen([filename ext],'rb');
    fseek(fid,0,1);
    len(fn_cnt+1) = ftell(fid)/(sz*2);%164;
    fseek(fid,0,-1);
    fclose(fid);
    % fprintf(1,'Length of %s is \t%i spikes.\n',[filename ext],len(fn_cnt+1));
    fn_cnt=fn_cnt+1;
    ext=['-' num2str(fn_cnt)];
end


% extract spike waveforms
waveform=zeros(num_spikes,74);
cnt=0;
for id = spikeIndex
    cnt=cnt+1;
    
     % check which spikefile contains the spike, and update filename [filename ext]
    ext='';
    for i=1:length(len) 
        if id < sum(len(1:i))
            break;
        end
        ext=['-' num2str(i)];  
    end
    
    % fprintf(1,' %s   Spike %i  %i/%i\n',[filename ext],id,cnt,num_spikes);
    fid=fopen([filename ext],'rb');
    fseek(fid, (id-sum(len(1:i-1)))*sz*2,'bof');
    spike=fread(fid,[sz 1],'uint16');
    fclose(fid);

    waveform(cnt,:) = spike(8:81);
    ti0 = spike(1,:); idx = find(ti0<0); ti0(idx) = ti0(idx)+65536;
    ti1 = spike(2,:); idx = find(ti1<0); ti1(idx) = ti1(idx)+65536;
    ti2 = spike(3,:); idx = find(ti2<0); ti2(idx) = ti2(idx)+65536;
    ti3 = spike(4,:); idx = find(ti3<0); ti3(idx) = ti3(idx)+65536;
    ti  = (ti0 + 65536*(ti1 + 65536*(ti2 + 65536*ti3))) ;
    
end


range = [-25 48];
if BANDPASS
    % add median values at beginning and end to (mostly) avoid artifacts at edges
    range = [-26 49];
    waveform = [median(waveform,2) waveform median(waveform,2) ] ;
end

%  Change into vector for easier/faster plotting.
l = length([range(1):range(2)+1]);
waveform_vector       = zeros( l*num_spikes , 1);
waveform_vector_times = zeros( l*num_spikes , 1);

for cnt=1:size(waveform,1)
     if DETREND
         waveform_vector( l*(cnt-1) + [range(1):range(end)]-range(1) + 1 ) = detrend( waveform(cnt,:) );
     else
         waveform_vector( l*(cnt-1) + [range(1):range(end)]-range(1) + 1 ) =          waveform(cnt,:)  ;
     end
     waveform_vector( l*(cnt-1) + range(end)-range(1) + 1 + 1) = NaN;
     waveform_vector_times( l*(cnt-1) + [range(1):range(end)]-range(1) + 1 ) = (round(timeOffset(cnt)*freq*1000)+[range(1):range(end)])/freq/1000;
     waveform_vector_times( l*(cnt-1) + range(end)-range(1) + 1 + 1) = NaN;
end

if BANDPASS
    disp 'Running bandpass filter ...'
    waveform_vector(isnan(waveform_vector)) = median(waveform_vector(~isnan(waveform_vector)));
    waveform_vector = detrend(waveform_vector);
    waveform_vector = filtfilt(bpB,bpA,waveform_vector);  % want to run filt on combined data, such that contexts overlap exactly (otherwise detrend or filt gives slight offsets)
                                                          % need to run filt on data w/o NaN's...
    disp '... continuing.'
end

if FIGNO
    figure(FIGNO);
    plot( waveform_vector_times, waveform_vector,'Color',COLOR); 
    hold on
    xlabel('Time [s]');
    ylabel('Digital units');
    title(sprintf('Channel=%i\tTime=%f',spike(5),ti/freq/1000));
    grid on
    drawnow
    pause(.01)      
end
