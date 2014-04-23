function map=loadmapfile(mapfile,fig,sampoffset)
% map = LOADMAPFILE(mapfile,plot,sampoffset) 
%          Douglas Bakkum 2012
%      Extract data from neuromap.m text file, and 
%      plot routed electrodes. Returns structure 'map'.
%
%      Input:
%           mapfile     - mapfile name
%           plot        - [optional] figure number for plotting
%                                    if not set, will not plot
%           sampoffset  - [optional] if set to [0], do not offset sampling bias
%                                    default is to calculate offset
%
%      Output;
%           map.ch     - channel
%           map.el     - electrode
%           map.px     - position x [um]
%           map.py     - position y [um]
%           map.ix     - position x [index]
%           map.iy     - position y [index]
%           map.ok     - 1 if electrode was routed
%           map.stim   - 1 if was designated as stim electrode
%           map.offset - offset compensation for sampling bias [samples] (fraction)
%                        (i.e. due to multiplexing)
%   

    if ~exist('sampoffset','var')
        sampoffset = 1; % default
    end

    load global_cmos

    mapping=load(mapfile,'-ascii');

    map.ch=mapping(:,1);  % channel
    map.el=mapping(:,2);  % electrode
    map.px=mapping(:,3);  % x position [um]
    map.py=mapping(:,4);  % y position [um]

if size(mapping,2)>4
    map.ix=mapping(:,5);  % x position [index]
    map.iy=mapping(:,6);  % y position [index]
end

if size(mapping,2)>6
    map.stim=mapping(:,7);        % designated as a stim electrode when creating configuration
end

    map.ok=find(map.px>100);      % connected electrodes
    
    % true offset compensation for sampling bias using emulator values [samples]
    map.offset = zeros(size(map.ch));
    if sampoffset
        offset     = hidens_get_all_sampletime_offsets(2,1);
        map.offset(map.ch>=0) = offset.sample_offset(map.ch(map.ch>=0)+1)*1000*20;
    end
    %map.offset = mod(map.ch,8)/8;  % offset compensation for sampling bias [samples] [estimate]
    

if nargin>1
    figure(fig); hold off
    
    plot( ELC.X,         ELC.Y,         '.','color',[1 1 1]*.8); hold on
    %plot( map.px(map.ok),map.py(map.ok),'.'                   ); hold off
        
    for i = 1:length(map.el)/NCHAN
        clr = [ rand rand rand ];
        %clr = [ 1 1 1 ] * rand ;
        x = map.px([1:NCHAN]+(i-1)*NCHAN);
        y = map.py([1:NCHAN]+(i-1)*NCHAN);
        plot(x,y,'.','color',clr); hold on
    end
    
    figure_size(7,8)
    axis([100 2000 50   2150])
    axis ij equal 
    
    xlabel 'um'
    ylabel 'um'
    
    [pathstr, name, ext] = fileparts(mapfile);
    title(name)
end


