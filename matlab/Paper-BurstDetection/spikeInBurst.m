function BurstNumber = spikeInBurst(burst, spike, varargin)
%
% DB 2012:  Add BurstNumber information to the spike structure. 
%
%  spike.B = spikeInBurst(Burst, SpikeFile)
%
%
%%


% numvarargs = 1;
% while numvarargs <= length(varargin)
%     if 0 %    strcmp(varargin{numvarargs},'figure'   ),         
%        
%     else
%         error('Unrecognized option %s.\n',varargin{numvarargs});
%         error('Unrecognized option %i.\n',varargin{numvarargs});
%     end
%     numvarargs=numvarargs+1;
% end


N           = length( find(burst.T_end<spike.T(end) ));
Size        = length(burst.T_start);
BurstNumber = zeros(1,length(spike.T));
BurstCount  = 0;

% CHUNK = 500; % number of bursts to focus on to reduce find() commands

for i=1:Size
        
    if burst.T_end(i)   > spike.T(end), break, end
    if burst.T_start(i) < spike.T(1), continue, end
    
    BurstCount      = BurstCount+1; 
    Ts              = burst.T_start(i);
    Te              = burst.T_end(i); 
    ID              = spike.T>=Ts & spike.T<=Te ;
    BurstNumber(ID) = BurstCount;
    
    if ~mod(N-BurstCount,10)
        fprintf('%i\n',N-BurstCount)
    end
        
end
