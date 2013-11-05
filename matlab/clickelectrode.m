function electrode = clickelectrode(clr,number,figno)
% Douglas Bakkum 2012
% Returns electrodes closest to clicked points.
%
% Usage:
%       electrode = clickelectrode;
%       electrode = clickelectrode(color);
%       electrode = clickelectrode(color,number);   % number of closest electrodes to capture
%       electrode = clickelectrode(color,number,fignumber);
%

electrode   = [];


tmp_filename = '/tmp/clickelectrode_m_electrode_data_tmp.mat';
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


fprintf(2,' Click a location to find its electrode. \n Press a key to stop.\n');


if ~exist('figno','var')
    figno=gcf;  
end
if ~exist('clr','var')
    clr = 'w';
end
if ~exist('number','var')
    number = 1;
end

figure(figno); 

k           = waitforbuttonpress;
src         = gca;
[ex ey]     = el2position([0:11015]);


  
  

while k==0
  b     = axis;
  a     = get(src,'CurrentPoint');
  x     = a(1,1);
  y     = a(1,2);
  
  d     = (ex-x).^2+(ey-y).^2;
  %[dist idx] = min(d);
  [d_   idx] = sort(d);
  idx = idx(1:number);
  
      
%   tolx  = (b(2)-b(1)) * .01;
%   toly  = (b(4)-b(3)) * .01;
%   lox   = x-tolx;   hix = x+tolx;
%   loy   = y-toly;   hiy = y+toly;
%   idx   = find( ex>lox &  ex<hix &  ey>loy &  ey<hiy);
  
  
  if isempty(idx)
     fprintf(2,'Electrode not found near (%g,%g)\n',x,y);
  else
     fprintf(2,'\nElectrode found:\t%i',idx-1);
     electrode = [electrode idx-1];
     [xt yt]   = el2position(idx-1);
     hold on
     plot(xt,yt,'ks','markerfacecolor',clr)
     hold off
     fprintf(2,'\n');
  end
  
  
  save(tmp_filename,'electrode')
  
  k = waitforbuttonpress;
end

