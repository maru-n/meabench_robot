function figure_fontsize(size1, weight, size2)
% function figure_fontsize(size1, weight, size2)
%
%   size1   ->  Change font sizes for X and Y Labels and Title 
%   size2   ->  Change font sizes for X and Y Tick Labels
%   weight  ->  Change font weight {'bold' 'demi' 'light' 'normal'}
%
% If size2 is not specified, size1 is used for all sizes.
%

if nargin<3
    size2=size1;
end

if nargin<2
    weight='normal'
end


set(gca,'FontSize',size2);
set(gca,'FontWeight',weight);

h_label = get(gca,'XLabel');
set(h_label,'FontSize',size1);
set(h_label,'FontWeight',weight);

h_label = get(gca,'YLabel');
set(h_label,'FontSize',size1);
set(h_label,'FontWeight',weight);

h_label = get(gca,'ZLabel');
set(h_label,'FontSize',size1);
set(h_label,'FontWeight',weight);

h_label = get(gca,'Title');
set(h_label,'FontSize',size1);
set(h_label,'FontWeight',weight);
