function [target_trace epoch mapping]=extractTrigRawTrace(Info,Electrode,varargin)
%    Douglas Bakkum 2012
%  Extract traces for a target electrode (Electrode) in .raw.trig files.
%  Traces are mean offset (using last half of trace values in order to 
%  avoid influence from artifact) and set to uV units.
%
%  [target_trace epoch map] = extractTrigRawTrace(Info,Electrode,varargin)
%
%  options include:
%       'epoch'       - [epoch] Filter extraction by epoch. Set Electrode
%                       to NaN (and must use 'fulltrace') to not filter
%                       extraction by a specific electrode.
%       'bandpass'    - bandpass filter using UltraMegaSort2000 filter
%       'fulltrace'   - returns traces for all channels
%       'blank'       - blank artifact (until 0.7ms after tzero)
%       'digi'        - do not mean offset and keep in digi units
%       'probetime'   - [time(s)] extract by a specific probe time
%       'verbose'     - print information to screen


load global_cmos

BANDPASS   = 0;
FULLTRACE  = 0;
BLANK      = 0;
DIGI       = 0;
VERBOSE    = 0;
BYEPOCH    = 0;
BYPROBE    = 0;

Epoch      = NaN;
Probe      = NaN;

numvarargs = 1;
while numvarargs <= length(varargin);
    if     strcmp(varargin{numvarargs},'bandpass' ),         BANDPASS   = 1;
    elseif strcmp(varargin{numvarargs},'fulltrace'),         FULLTRACE  = 1;
    elseif strcmp(varargin{numvarargs},'blank'    ),         BLANK      = 1;
    elseif strcmp(varargin{numvarargs},'digi'     ),         DIGI       = 1;
    elseif strcmp(varargin{numvarargs},'verbose'  ),         VERBOSE    = 1;
    elseif strcmp(varargin{numvarargs},'epoch'    ),         BYEPOCH    = 1; 
                                                             Epoch      = varargin{numvarargs+1}; 
                                                             numvarargs = numvarargs+1;
    elseif strcmp(varargin{numvarargs},'probetime'),         BYPROBE    = 1; 
                                                             Probe      = varargin{numvarargs+1}; 
                                                             numvarargs = numvarargs+1;
    else
           error('Unrecognized option %s.\n',varargin{numvarargs});
    end
    numvarargs = numvarargs+1;
end


if isnan(Electrode) && (~FULLTRACE || ~BYEPOCH) && ~BYPROBE
    disp 'Please use 'fulltrace' and 'epoch' options if not using Electrode. EXITING!'
    target_trace = -1;
    epoch        = -1;
    mapping      = -1;
    return;
end

% Load Trig
if ~isfield(Info,'Trig')
    Info.Trig   = loadtrigfile(Info.FileName.Trig);
end
if ~isfield(Info.Trig,'E')
    spike       = loadspikeform(Info.FileName.SpikeForm);
    spike       = spikeform_EpochFix(Info,spike);
    Info.Trig.E = addTrigEpoch(Info,spike);
end

% Bandpass setup, from UltraMegaSort2000
if BANDPASS
    [bpB, bpA] = ums2000_setup;
end

if BYEPOCH, nc   =   Epoch;
else        nc   = floor(find(Info.Map.el==Electrode)/NCHAN);  % use this to find config of elc of interest
end
ep               = min(nc); 
ep_last          = min(nc);
target_trace     =      []; % use to extract full raw traces for all channels - will skip footprint calculations
target_trace_cnt =       0;
epoch            =      -1;
mapping          =      -1;

if isempty(nc) && ~BYPROBE
    disp 'Electrode not in a configurations. EXITING!'
    target_trace = -1;
    epoch        = nc;
    mapping      = -1;
    return;
elseif length(nc)~=1
%     disp 'Electrode in more than one or no configurations. EXITING!'
%     target_trace = -1;
%     epoch        = nc;
%     return;
    if ~BYPROBE,  disp 'Electrode in more than one configuration. USING FIRST config!', end
    nc = min(nc);
    epoch = nc;
elseif nc>Info.Parameter.ConfigNumber-1 && Info.Parameter.ConfigNumber~=1
    disp 'Electrode exceeds number of configurations. EXITING!'
    target_trace = -1;
    epoch        = nc;
    mapping      = -1;
    return;
end


% %% Go to desired config number in Info.FileName.Raw 
%    Open raw file and go to config num / epoch of interest

if exist('fh','var')
  fclose(fh);
end

fn = Info.FileName.Raw;
fh = fopen(fn,'rb');
fseek(fh,0,1);
len = ftell(fh);
fseek(fh,0,-1);



if Info.Parameter.ConfigNumber == 1
    trig_cnt  = 0;
    startbyte = 0;
elseif BYPROBE
    xx        = find(Info.Trig.T==Probe(1));
    trig_cnt  = xx - 1; % go to one before desired config, so that next read is correct config number
    startbyte = trig_cnt*Info.Parameter.TriggerLength*(NCHAN+NDAC)*2;
    nc        = Info.Trig.E(xx);
    ep        = nc;
    ep_last   = nc;
else
    trig_cnt  = find(Info.Trig.E==nc,1) - 1; % go to one before desired config, so that next read is correct config number
    startbyte = trig_cnt*Info.Parameter.TriggerLength*(NCHAN+NDAC)*2;
end

nfile=0;
while len<startbyte    % check if in next raw file
    fclose(fh);
    startbyte=startbyte-len;
    nfile=nfile+1;
    fn=[Info.FileName.Raw '-' int2str(nfile)];
    fh = fopen(fn,'rb');
    fseek(fh,0,1);
    len = ftell(fh);
    fseek(fh,0,-1);
end
fseek(fh,startbyte,-1);  % go to correct config number 
if VERBOSE, fprintf(1,'  File name %s, handle %i, index %i\n',fn,fh,ftell(fh)); end


if BYPROBE, 
    End = trig_cnt+1+length(Probe);
else
    End = length(Info.Trig.N);
end



%%
while trig_cnt+1 < End
    
    trig_cnt  =              trig_cnt+1;
    ep        =   Info.Trig.E(trig_cnt);
    
    if( ep~=ep_last )
        if VERBOSE, disp 'New epoch.', end
        %if ep>max(nc)
        if isempty( find(Info.Trig.E(trig_cnt:end)<=max(nc)) )
            if VERBOSE, disp 'No more configurations have the electrode of interest. Ending.', end
            return
        end
    end
    
    
    if Info.Parameter.ConfigNumber == 1
        map = Info.Map;
    else
        map.ch  = Info.Map.ch(ep*NCHAN+1:(ep+1)*NCHAN);
        map.el  = Info.Map.el(ep*NCHAN+1:(ep+1)*NCHAN);
        map.px  = Info.Map.px(ep*NCHAN+1:(ep+1)*NCHAN);
        map.py  = Info.Map.py(ep*NCHAN+1:(ep+1)*NCHAN);
    end
    ep_last = ep;    % update
    
    clear trace cnt
    [trace, cnt] = fread(fh,[(NCHAN+NDAC) Info.Parameter.TriggerLength],'int16');
    if cnt<(NCHAN+NDAC)*Info.Parameter.TriggerLength
        % check for size trace not long enough, then read off enough data to fill from next
        if VERBOSE,  disp EndOfFile, end
        nfile = nfile+1;               
        fclose(fh);
        fn      = [Info.FileName.Raw '-' num2str(nfile)];
        fh      = fopen(fn,'rb');
        if fh<0
            if VERBOSE,  disp EndOfData, end
            return
        end
        fseek(fh,0,-1);  % go to start of file
        
        % fill rest if needed
        if cnt==0
            continue;
        else
            [tr, cn] = fread(fh,[(NCHAN+NDAC) Info.Parameter.TriggerLength-cnt/(NCHAN+NDAC)],'int16');    
            if cn+cnt ~= (NCHAN+NDAC)*Info.Parameter.TriggerLength
                disp ERROR
                return;
            end
            trace = [trace tr];
            cnt   = cnt+cn;
        end
    end
    
 
    
    % Skip processing data if not Epoch of interest
    if BYEPOCH && ep~=Epoch, continue, end                 
    
    % Skip processing data if Electrode of interest is not in configuration
    id  = unique( map.ch( map.el==Electrode ) + 1 );
    if ~isempty(id) || isnan(Electrode)
        if VERBOSE, fprintf('\t%i/%i ep %i  \n',trig_cnt,length(Info.Trig.N),ep); end
        epoch = ep;

        % offset mean and set to [uV]
        rng = max([1 -2+Info.Parameter.TriggerTimeZero]):2+Info.Parameter.TriggerTimeZero; % fix in case of tzero<=2
        for i=1:size(trace,1)
            if DIGI
                offset = 0;
            elseif max(abs(diff(trace(id,rng))))==0  % blanking happened so use value at tzero for offset
                offset = trace(i,Info.Parameter.TriggerTimeZero);
            else
                offset = median( trace(i,Info.Parameter.TriggerLength/2:end) );
            end
            trace(i,:) = trace(i,:) - offset;
            
            if BLANK
                trace(i,1:Info.Parameter.TriggerTimeZero+14) = 0;
                %trace(i,1:Info.Parameter.TriggerTimeZero+30) = 0;
            end
        end
        %trace_m = detrend(trace','constant')';
        

        if BANDPASS
            bndpss = filtfilt(bpB,bpA,trace'); 
            trace=bndpss';
        end
        
        if ~DIGI
            trace=trace*GAIN;
        end

                
        target_trace_cnt = target_trace_cnt + 1;
        if FULLTRACE
            target_trace(target_trace_cnt,:,:)  =    trace; 
        else
            target_trace(target_trace_cnt,:) = trace(id,:); 
        end
        mapping = map;
    end 
end


fclose(fh);
