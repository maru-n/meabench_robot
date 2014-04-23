function trig_E = addTrigEpoch(Info,spike)
%  trig_E = addTrigEpoch(Info,spike)
%       Douglas Bakkum 2012
%    For old trig files that do not have Trig.E variable, use the 
%    spike file to reconstruct the Trig.E information (trig_E).
%


len = length(Info.Trig.N);
trig_E = zeros(size(Info.Trig.N));
dac_info = 127; % DAC2 - information channel (stim times & channel, epochs)
DI       = find(spike.C==dac_info);


for i=1:len
    % seems to be rounding errors so ignore last sig digits - go to ms resolution
    xx = find(    floor(spike.T(DI)*1000) <= ceil(Info.Trig.T(i)*1000)   & spike.E(DI)>=0 );
    if ~isempty(xx)
        trig_E(i) = spike.E(DI(xx(end)));
    else
        trig_E(i) = -1;
    end
    %disp(i/len)
end