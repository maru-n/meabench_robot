function electrodes = plotelectrodenumbers(varargin) 
%  Douglas Bakkum 2013
%
%  electrodes = PLOTELECTRODENUMBERS( varargin )
%
%  Writes electrode numbers on visible area of a figure.
%  Returns the list of electrodes plotted.
%
%  options include:
%       'figure'        - Figure to plot locations
%                              default = gcf
%                              '0' will return electrodes without plotting
%       'box'           - Draw a box instead of a marker
%       'notext'        - Do not write electrode numbers on the figure
%

load global_cmos

FIGURE   = gcf;
BOX      =   0;
NOTEXT   =   0;

numvarargs = 1;
while numvarargs <= length(varargin);
    if     strcmp(varargin{numvarargs},'box'   ),         BOX        = 1;
    elseif strcmp(varargin{numvarargs},'notext'),         NOTEXT     = 1;
    elseif strcmp(varargin{numvarargs},'figure'),         FIGURE     = varargin{numvarargs+1};
                                                          numvarargs = numvarargs+1;
    else
           error('Unrecognized option %s.\n',varargin{numvarargs});
    end
    numvarargs = numvarargs+1;
end


ax = axis;
id = find( (ELC.X > ax(1) & ELC.X < ax(2) & ELC.Y > ax(3) & ELC.Y < ax(4)) );


if FIGURE
    figure(FIGURE);
    holding = ishold;
    hold on

    clear txt
    for i=1:length(id)
        txt{i}=int2str(id(i)-1);
    end

    if BOX
        for i=1:length(id)
            x = ELC.X(id(i)) + ELC_M_Pt3um.X*[-0.5 -0.5   0.5  0.5 -0.5];
            y = ELC.Y(id(i)) + ELC_M_Pt3um.Y*[-0.5  0.5   0.5 -0.5 -0.5];
            line(x,y,'color',[1 1 1]*.4)
            %fill(x,y,[1 1 1]*.4,'edgecolor','none')
        end
    else
        plot(ELC.X(id),  ELC.Y(id),'s','color',[1 1 1]*.4)
    end

    if ~NOTEXT
        text(ELC.X(id)+ELC_M_Pt3um.X/2+1,ELC.Y(id)+ELC_M_Pt3um.Y/2,[txt],'fontsize',10,'color',[1 1 1]*.3)
    end

    if holding
        hold on
    else
        hold off
    end
    
end

electrodes = id-1; % [0 to 11,015]








