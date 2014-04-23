function Centers = burstCenters(burst, spike, varargin)
%
% DB 2012:  Get Centers of bursts (found from burst detector .cpp code) as 
%           measured from the center of the firing rate histogram across 
%           all channels. 
%
%  Center = burstCenters(Burst, Spike)
%
%           Looks only at clean (clid==1) and negative spikes (H<0).
%           Uses bin = 0.05sec and step = 0.01sec.
%           
%
%  options include:
%       'figure'  [figno]   - Figure number (default is no plot)
%       'number'  [num]     - Skip for bursts with burst.S < number. 
%       'bin'     [sec]     - Bin  size for calculation FRH. [default = 0.05]
%       'step'    [sec]     - Step size for calculation FRH. [default = 0.01]
%       'upsample'          - Upsample to get a resolution of msec.
%       'channel' [int]     - Calculate for 1 Channel instead of network burst.
%       'height'  [int]     - Spike heights must be less than [height].
%
%%

Bin     = 0.050; % [sec]
Step    = 0.010; % [sec]
FIGNO   = 0;    
UPSAMP  = 0;
Number  = 0;
NETWORK = 1;     % Network burst [1], Channel burst [0]
Channel = NaN;
Height  = 0;

numvarargs = 1;
while numvarargs <= length(varargin)
    if     strcmp(varargin{numvarargs},'figure'   ),         
        FIGNO      = varargin{numvarargs+1}; 
        numvarargs = numvarargs+1;
    elseif strcmp(varargin{numvarargs},'number'     ),   
        Number       = varargin{numvarargs+1}; 
        numvarargs = numvarargs+1;
    elseif strcmp(varargin{numvarargs},'bin'      ),   
        Bin        = varargin{numvarargs+1}; 
        numvarargs = numvarargs+1;
    elseif strcmp(varargin{numvarargs},'step'     ),   
        Step       = varargin{numvarargs+1}; 
        numvarargs = numvarargs+1;
    elseif strcmp(varargin{numvarargs},'height'     ),   
        Height     = varargin{numvarargs+1}; 
        numvarargs = numvarargs+1;
    elseif strcmp(varargin{numvarargs},'channel'     ),   
        Channel    = varargin{numvarargs+1}; 
        NETWORK    = 0;
        numvarargs = numvarargs+1;
    elseif strcmp(varargin{numvarargs},'upsample' ),         
        UPSAMP     = 1;
    else
        error('Unrecognized option %s.\n',varargin{numvarargs});
        error('Unrecognized option %i.\n',varargin{numvarargs});
    end
    numvarargs=numvarargs+1;
end

CHUNK   = 100; % number of bursts to chunk - speeds up performance
N       = length(find(burst.T_end<spike.T(end) & burst.S>=Number));
Size    = length(burst.T_start);
Centers = zeros(1,Size);
Count   = 0;

%ID_0_ = find( spike.clid==1  &  spike.H<Height );
for chunk = 1:CHUNK:ceil(N/CHUNK)*CHUNK
    
    T_chunk_start = burst.T_start(chunk);
    T_chunk_end   = burst.T_end( min([chunk+CHUNK-1 length(burst.T_end)]) );
    
    if NETWORK
        %ID_0 = ID_0_( spike.T(ID_0_)<=T_chunk_end  &  spike.T(ID_0_)>=T_chunk_start );
        ID_0 = find( spike.clid==1  &  spike.H<Height  &  spike.T<=T_chunk_end  &  spike.T>=T_chunk_start );
    else
        %ID_0 = ID_0_( spike.T(ID_0_)<=T_chunk_end  &  spike.T(ID_0_)>=T_chunk_start  &  spike.C(ID_0_)==Channel);
        ID_0 = find( spike.clid==1  &  spike.H<Height  &  spike.T<=T_chunk_end  &  spike.T>=T_chunk_start  &  spike.C==Channel);
    end
    for i_ = 1:CHUNK%Size
        i = i_+chunk-1;
        if i > length(burst.T_end),     break, end
        if burst.T_end(i)>spike.T(end), break, end
        if burst.T_start(i)<spike.T(1), continue, end
        if burst.S(i)<Number,           continue, end
        Count = Count+1; 

        frh = [];
        T   = burst.T_start(i)-Bin:Step:burst.T_end(i)+Bin; % look a little before and after just in case
        for t = T
            %ID    = ID_0( spike.T(ID_0)>=t & spike.T(ID_0)<=t+Bin );
            %frh   = [frh length(ID)];
            frh   = [frh length(find( spike.T(ID_0)>=t & spike.T(ID_0)<=t+Bin ))];
        end
        [m,id]    = max(frh);

        if m==0
            Centers(i)        = NaN;
        elseif UPSAMP
            % Get better peak time by upsampling
            upsample_factor   = Step*1000;                                     % set to 1 ms resolution (? - ask felix)
            [frh_up x_up]     = reconstruct( frh, upsample_factor );           % upsample
            [m id_up]         = max(frh_up);                                   % find max 
            T_up              = min(T) + (x_up - x_up(upsample_factor))*Step ; % align to spike.T time values
            Centers(i)        = T_up(id_up);
        else
            Centers(i)        = T(id); 
        end

        if FIGNO && ~isnan(Centers(i))
            figure(FIGNO);
            plot(T-Centers(i),frh,'b'),                
            hold on
            if UPSAMP 
                plot(T_up-Centers(i),frh_up,'r'),
                %hold off
            end
            grid on
            title(Size-i)
            pause(1)
        else
            fprintf('%i\n',N-Count)
        end

    end
end