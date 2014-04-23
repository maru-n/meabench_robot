function [Burst Sort] = burstDetect( Spike, Parameter )
%
% DB 2013:  Make matlab burst detector adapted from C code.
% 
%    [Burst Sort] = burstDetect( spike, parameters)
%
%           'Spike' should be pre-loaded from spikefile.
%
%           'Parameters' should be:   
%                   Param.FRnum         FR condition  [number] FRnum of spikes within FRbin duration satisfies high FR condition.
%                   Param.FRbin         FR condition  [sec]    FRnum of spikes within FRbin duration satisfies high FR condition.
%                   Param.Gap           Gap condition [sec]    Consecutive spikes less than this value satisfies Gap condition
%                   Param.GoodSpikes    IDs of spikes to consider during detection.
%                
%
%           Returns Burst information and additional spike information:
%
%                   Burst.T_start       Burst start time [sec]
%                   Burst.T_end         Burst end time   [sec]
%                   Burst.S             Burst size (number spikes)
%                   Burst.C             Burst size (number channels)
%
%                   Sort.T              Sort by spike times (spikefile not necessarily in correct temporal order).
%                   Sort.C              Spike channels for sorted spikes.
%                   Sort.FRnum          [1] if spike meets FRnum condition.
%                   Sort.Gap            [1] if spike meets Gap condition.
%                   Sort.Burst_N        Burst number of spike ([-1] if not in a burst).
% 
%
%

%% Find when conditions are met

    fprintf('\n');
    
    % Sort spike times as not necessarily in order in spike file
    [Sort.T IX] = sort(Spike.T(Parameter.GoodSpikes) + rand(size(Parameter.GoodSpikes))/20000 ); % Jitter by up to 1 sample to make curve smoother at high frequencies (minimizes bias due to discrete sampling)
     Sort.C     = Spike.C(Parameter.GoodSpikes(IX));

 
    % Look both directions from each spike for FRbin and Gap criteria
    d = zeros(Parameter.FRnum,length(Sort.T))+inf;
    for j = 0:Parameter.FRnum-1
        d(j+1,[Parameter.FRnum:length(Sort.T)-(Parameter.FRnum-1)]) = Sort.T( [Parameter.FRnum:end-(Parameter.FRnum-1)]+j ) - Sort.T( [1:end-(Parameter.FRnum-1)*2]+j ); 
    end 
    dt_FRnum = min(d);
    
%     d = zeros(2,length(Sort.T))+inf;
%     d(1,[ 1:length(Sort.T)-(Parameter.FRnum-1)]) = Sort.T( [Parameter.FRnum:end] ) - Sort.T( [1:end-(Parameter.FRnum-1)] ); 
%     d(2,[ Parameter.FRnum:length(Sort.T)])       = Sort.T( [Parameter.FRnum:end] ) - Sort.T( [1:end-(Parameter.FRnum-1)] ); 
%     dt_FRnum = min(d);
    
    
    d = zeros(2,length(Sort.T))+inf;
    for j = 0:2-1
        d(j+1,[2:length(Sort.T)-1]) = Sort.T( [2:end-1]+j ) - Sort.T( [1:end-2]+j ); 
    end 
    dt_Gap = min(d); % max(d); % Need gap to split bursts?

        
    % Find conditions met
    Sort.FRnum = zeros(size(Sort.T));
    Sort.Gap   = zeros(size(Sort.T));
    
    Sort.FRnum(  dt_FRnum<=Parameter.FRbin ) = 1; % Spike passes condition
    Sort.Gap(      dt_Gap<=Parameter.Gap   ) = 1; % Spike passes condition
    
    
%     figure
%     xx = find(dt_Gap>.05/1000); % skip differences less than 1 sample, as log(0)=-Inf
%     loglog(dt_Gap(xx)*1000,dt_FRnum(xx)*1000,'k.','markersize',5) 
%     line([10^-2 10^4],[1 1]*Parameter.FRbin*1000,'color',[1 1 1]*0)
%     line([1 1]*Parameter.Gap*1000,  [10^-2   10^4],'color',[1 1 1]*0)
        
    


%% Assign burst numbers to spike file

% figure; hold on

Sort.Burst_N  = zeros(size(Sort.T))-1;

INBURST  =  0; % [Boolean]
NUMBER   =  0; % Burst Number iterator
N        = -1; % Burst Number assigned
BL       =  0; % Burst Length

reverseStr = '';
%for i = 2:length(Sort.T)
for i = Parameter.FRnum:length(Sort.T)
   
    if INBURST == 0                               % Am not in burst 
        if  Sort.FRnum(i)*Sort.Gap(i)             % But conditions met, so now in burst
            INBURST  = 1;                         %  - update -
            NUMBER   = NUMBER+1;
            N        = NUMBER;
            BL       = 1;
        else                                      % Still not in burst, so continue  
        	% continue;
        end
        
    else                                          % Am in burst
        if  ~ (Sort.FRnum(i)*Sort.Gap(i))         % Conditions no longer met
            INBURST  =  0;                        %  - update -
            if BL<Parameter.FRnum                 % Check if burst is big enough, if not erase. (may be too small due to conditions below)
                Sort.Burst_N(Sort.Burst_N==N) = -1;
                NUMBER = NUMBER-1;
            end
            N        = -1;
        elseif diff(Sort.T([i-1 i])) > Parameter.Gap  &&  BL >= Parameter.FRnum
                                                  % Don't update if at start of burst (BL<FRnum)
            NUMBER   = NUMBER+1;                  % New burst, update burst number
            N        = NUMBER;
            BL       = 1;
        elseif diff(Sort.T([i-(Parameter.FRnum-1) i])) > Parameter.FRbin  &&  BL >= Parameter.FRnum
                                                  % Don't update if at start of burst (BL<FRnum)
            NUMBER   = NUMBER+1;                  % New burst, update burst number
            N        = NUMBER;
            BL       = 1;
        else                                      % Conditions still met, so continue
            BL       = BL + 1;
            % continue
        end
    end
    
    Sort.Burst_N(i)  = N;
    
    if(~mod(i,100000)), 
        msg = sprintf('%2.0f%% assigned to Sort.Burst_N.\n',100*i/length(Sort.T));
        fprintf([reverseStr, msg]);
        reverseStr = repmat(sprintf('\b'), 1, length(msg));    
        drawnow('update')
    end    
end
        
    
%% Assign Burst info


NB            = max(Sort.Burst_N);
Burst.T_start = zeros(1,NB);
Burst.T_end   = zeros(1,NB);
Burst.S       = zeros(1,NB); % Size (total spikes)
Burst.C       = zeros(1,NB); % Size (total channels)

for i = 1:NB
    xx = find(Sort.Burst_N==i);
    
    if length(xx)<Parameter.FRnum % Not possible to have burst smaller than FRnum ... 
        Sort.Burst_N(xx) = -10;   % Erase burst
        beep
        disp 'Error: burst too small'
        %continue;
    end        
    
    Burst.T_start(i) = Sort.T(xx(1));
    Burst.T_end(i)   = Sort.T(xx(end));
    Burst.S(i)       = length(xx);
    Burst.C(i)       = length(unique(Sort.C(xx)));
    
    if(~mod(i,200))
        msg = sprintf('%2.0f%% assigned to Sort.Burst_N.\n',100*i/length(Sort.T)); 
        fprintf([reverseStr, msg]);
        reverseStr = repmat(sprintf('\b'), 1, length(msg));    
        drawnow('update')
    end
    
end

fprintf('Finished burst detection using %0.2f minutes of spike data.\n',diff(Sort.T([1 end]))/60);

% 
% 
% %%
% 
% figure
% 
% ID = find( Sort.FRnum.*Sort.Gap );
% 
% plot(Sort.T,Sort.C,'k.')
% hold on
% plot(Sort.T(ID),Sort.C(ID),'.')
% plot(Sort.T(ID),ones(size(ID))+130,'r.')
% 
% ID = find(Sort.Burst_N>-1);
% plot(Sort.T(ID),ones(size(ID))+130,'go')
% 
% 
% %%
% figure
% plot(diff(Sort.T(ID)),'.')
        
    






























