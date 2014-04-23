function distance = electrode_distance(ElectrodeZero, ElectrodeOthers)
% Douglas Bakkum 2012
% Returns distance to ElectrodeZero of ElectrodeOthers.
%
%   distance = electrode_distance(ElectrodeZero, ElectrodeOthers)
%

distance = NaN;

if nargin < 2
    disp 'Not enough input.'
    return
elseif length(ElectrodeZero)~=1
    disp 'ElectrodeZero must be length = 1.'
    return
end


[xZ yZ] = el2position(ElectrodeZero);
[xO yO] = el2position(ElectrodeOthers);

distance = (xZ-xO).^2+(yZ-yO).^2;
distance = distance.^.5;