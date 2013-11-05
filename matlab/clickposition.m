function position = clickposition(clr,figno)
% Douglas Bakkum 2012
% Returns position(s) [x y] for clicks in the figure.
%
% Usage:
%       position = clickposition;
%       position = clickposition(color);
%       position = clickposition(color,fignumber);

if ~exist('figno','var')
    figno=gcf;  
end
if ~exist('clr','var')
    clr = 'k';
end

position.x = [];
position.y = [];

tmp_filename = '/tmp/clickposition_m_position_data_tmp.mat';
if exist(tmp_filename,'file')
    reply='';
    while 1
        reply = input('Do you want to load the existing temp position file? Y/N [Y]: ', 's');
        if isempty(reply)
            reply = 'Y';
        end
        reply = lower(reply);
        if(     strcmp(reply,'y') || strcmp(reply,'yes') )
            load(tmp_filename);
            fprintf(2,'File loaded.\n');
            break;
        elseif( strcmp(reply,'n') || strcmp(reply,'no') )
            system(['rm ' tmp_filename]);
            fprintf(2,'File deleted.\n');
            break;
        end
    end
end
            
            
fprintf(2,'Click a location to find its position. Press a key to stop.\n');

k=waitforbuttonpress;
src=gca;
figure(figno); 


while k==0
  b=axis;
  a=get(src,'CurrentPoint');
  x=a(1,1);
  y=a(1,2);
  position.x = [position.x x];
  position.y = [position.y y];
  
  
  fprintf(2,'Position is (%g,%g)\n',x,y);
  
  hold on
  plot(x,y,'s','color',clr)%,'markerfacecolor',clr)
  plot(position.x,position.y,'-','color',clr)
  hold off
  
  save(tmp_filename,'position')
  
  k=waitforbuttonpress;
end

