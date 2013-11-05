function figure_size(xSize,ySize,varargin)
%
% DB 2012:  Setup figure printing sizes in centimeters. A4 is 21 × 29.7 cm.
%           For Nature Comm. 1 column is 8.5cm wide; 2 columns are 18cm wide.
%           xSize and ySize are in [cm].
%
%  figure_size(xSize,ySize,varargin)
%
%  options include:
%       'scale' [factor]    - Scaling of figure on screen relative to 
%                             print size. Default = 2.
%       'linewidth'  [#]    - Set axes linewidths to #. 
%                             Default = 1.0.
%       'ticklength' [%]    - Set tick lengths to percent of max axes 
%                             length for 2D plot. Matlab default = 0.01.
%
%%

Scale      =   2;
LineWidth  = 1.0;
TickLength = NaN;

numvarargs = 1;
while numvarargs <= length(varargin)
    if     strcmp(varargin{numvarargs},'scale'   ),         
        Scale      = varargin{numvarargs+1}; 
        numvarargs = numvarargs+1;
    elseif strcmp(varargin{numvarargs},'linewidth'   ),   
        LineWidth  = varargin{numvarargs+1}; 
        numvarargs = numvarargs+1;
    elseif strcmp(varargin{numvarargs},'ticklength'   ),   
        TickLength = varargin{numvarargs+1}; 
        numvarargs = numvarargs+1;
    else
        error('Unrecognized option %s.\n',varargin{numvarargs});
        error('Unrecognized option %i.\n',varargin{numvarargs});
    end
    numvarargs=numvarargs+1;
end

xMargin = 0;                        %# left/right margins
yMargin = 0;                        %# bottom/top margins
xPaperSize = xSize + 2*xMargin;     %# figure size on paper (widht & hieght)
yPaperSize = ySize + 2*yMargin;     %# figure size on paper (widht & hieght)


%# figure size on screen 
set(gcf, 'Units','centimeters')
pos = get(gcf, 'Position');
set(gcf, 'Position',[   pos([1 2])    [xPaperSize yPaperSize]*Scale ])
%set(gca, 'Units','centimeters', 'Position',[xMargin yMargin  xAxisSize  yAxisSize ]*Scale)


set(gcf, 'PaperUnits','centimeters')
set(gcf, 'PaperSize',[xPaperSize yPaperSize])
set(gcf, 'PaperPosition',[0 0 xPaperSize yPaperSize])
set(gca, 'linewidth',LineWidth)

if ~isnan(TickLength)
    set(gca,'ticklength',[TickLength .025])
end


            