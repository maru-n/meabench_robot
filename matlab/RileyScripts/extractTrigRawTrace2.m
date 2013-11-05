function [target_trace]=extractTrigRawTrace2(Info,channels,n)
%    Douglas Bakkum 2012
%    Edited by a rabid nautilus in 2013
%  Extract traces for a target electrode (Electrode) in .raw.trig files.
%  Traces are mean offset (using last half of trace values in order to 
%  avoid influence from artifact) and set to uV units.
%
%  [target_trace] = extractTrigRawTrace(Info,Channel,N)
%
%  Info  - the info structure
%  Channel - array of channels to load data from
%  N - array of trigger numbers to load data from
%  target_trace - samples X channels x triggers array of recorded data

ns = Info.Parameter.TriggerLength;
ne = length(channels);
nt = length(n);

% Load Trig
if ~isfield(Info,'Trig')
    Info.Trig   = loadtrigfile(Info.FileName.Trig);
end
if ~isfield(Info.Trig,'E')
    spike       = loadspikeform(Info.FileName.SpikeForm);
    spike       = spikeform_EpochFix(Info,spike);
    Info.Trig.E = addTrigEpoch(Info,spike);
end

if exist('fh','var')
  fclose(fh);
end

%open the file
fn = Info.FileName.Raw;
fh = fopen(fn,'rb');
fseek(fh,0,1);
len = ftell(fh);%length of the current file
fseek(fh,0,-1);%go to the beginning of the file
crntp = 0;
nfile = 0;
target_trace = NaN(ns,ne,nt);
file_lengths = [0 len];
[bpB, bpA] = ums2000_setup;
hw_channels = Info.Map.ch(channels)+1;

for trig_cnt = 1:length(n)
    target_trace(:,:,trig_cnt) = loadsingletrig(fh,hw_channels,n(trig_cnt),(128),ns);
end

    function singtrig = loadsingletrig(fh,channels,nc,h,w)
        clear trace cnt
        startbyte = (nc-1)*h*w*2;%relative to total recording, not individual file
        
        
        if startbyte ~=crntp %if we aren't at the correct reading location
            while startbyte>sum(file_lengths(1:nfile+2)) %if the correct reading location isn't in this file
                sum(file_lengths(1:nfile+2))
                nfile = nfile+1;               
               fclose(fh);
                fn      = [Info.FileName.Raw '-' num2str(nfile)]
                fh      = fopen(fn,'rb');
                fseek(fh,0,1);
                
                len = ftell(fh);%length of the current file
                file_lengths(nfile+2) = len;
            end
            
            fbyte = startbyte-sum(file_lengths(1:nfile+1));
            fseek(fh,fbyte,-1);%move to the correct start location
            
        end
        [trace, cnt] = fread(fh,[h w],'int16');
        if cnt<h*w
             nfile = nfile+1;               
             fclose(fh);
             fn      = [Info.FileName.Raw '-' num2str(nfile)];
             fh      = fopen(fn,'rb');
             if fh ==-1
                 disp(['cant open file ' fn '. File likely contains ' num2str(len/(128*(length(Info.Trig.N))*2)) ' sample long triggers.']);
                 
             end
             fseek(fh,0,1);
             len = ftell(fh);
             file_lengths(nfile+2) = len;
             fseek(fh,0,-1);
             [tr, cn] = fread(fh,[h w-cnt/h],'int16');
             trace = [trace tr]; 
             
        end
        if length(trace)==0
           disp('hmm');
        end
     %   bndpss = filtfilt(bpB,bpA,trace'); 
      %      trace=bndpss';
            ok = (channels>0);
            singtrig = NaN(w,length(channels));
        singtrig(:,ok) = trace(channels(ok),:)';
        crntp = startbyte+h*w*2;
    end

end
%%
%go through the entire file
% for trig_cnt = 1:length(n)
%    
%     map = Info.Map;
%     clear trace cnt
%     [trace, cnt] = fread(fh,[(NCHAN+NDAC) Info.Parameter.TriggerLength],'int16');
%     
%     %didn't read the number of elements expected
%     if cnt<(NCHAN+NDAC)*Info.Parameter.TriggerLength
%         % check for size trace not long enough, then read off enough data to fill from next
%         if VERBOSE,  disp EndOfFile, end
%         nfile = nfile+1;               
%         fclose(fh);
%         fn      = [Info.FileName.Raw '-' num2str(nfile)];
%         fh      = fopen(fn,'rb');
%         if fh<0
%             if VERBOSE,  disp EndOfData, end
%             return
%         end
%         fseek(fh,0,-1);  % go to start of file
%         
%         % fill rest if needed
%         if cnt==0
%             continue;
%         else
%             [tr, cn] = fread(fh,[(NCHAN+NDAC) Info.Parameter.TriggerLength-cnt/(NCHAN+NDAC)],'int16');    
%             if cn+cnt ~= (NCHAN+NDAC)*Info.Parameter.TriggerLength
%                 disp ERROR
%                 return;
%             end
%             trace = [trace tr];
%             cnt   = cnt+cn;
%         end
%     end
%     
%  
%     
%                  
%     
%     % Skip processing data if Electrode of interest is not in configuration
%     id  = unique( map.ch( map.el==Electrode ) + 1 );
%     if ~isempty(id) || isnan(Electrode)
%         
% 
%         % offset mean and set to [uV]
%         rng = max([1 -2+Info.Parameter.TriggerTimeZero]):2+Info.Parameter.TriggerTimeZero; % fix in case of tzero<=2
%         for i=1:size(trace,1)
%             if DIGI
%                 offset = 0;
%             elseif max(abs(diff(trace(id,rng))))==0  % blanking happened so use value at tzero for offset
%                 offset = trace(i,Info.Parameter.TriggerTimeZero);
%             else
%                 offset = median( trace(i,Info.Parameter.TriggerLength/2:end) );
%             end
%             trace(i,:) = trace(i,:) - offset;
%             
%             if BLANK
%                 trace(i,1:Info.Parameter.TriggerTimeZero+14) = 0;
%                 %trace(i,1:Info.Parameter.TriggerTimeZero+30) = 0;
%             end
%         end
%         %trace_m = detrend(trace','constant')';
%         
% 
%        
%             trace=trace*GAIN;
%         
% 
%                 
%         target_trace_cnt = target_trace_cnt + 1;
%         
%         target_trace(target_trace_cnt,:) = trace(id,:); 
%         
%         mapping = map;
%     end 
% end
% 
% 
% fclose(fh);
% 
% 
% end
