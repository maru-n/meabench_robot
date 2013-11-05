%[electrode st_electrode] = electrode_placer(immat,ELC,mtraw,Info,electrode, st_electrode)
%using a immat structure built using the tiffmaker script, this script
%allows you to choose recording and stimulation electrodes. 
%inputs:
%immat - 3d movie matrix of [x-coord, y-coord,frame number]
%ELC- from global cmos
%mtraw- 2d matrix of [electrode, frame number]
%Info- info structure from tiffmaker script
%electrode- the list of recording electrodes (you can start with some
%electrodes already selected)
%st_electrode-the list of stimulation electrodes (you can start with some
%electrodes already selected
%commands:
%left arrow: back a frame
%right arrow: forward a frame
%up arrow: forward 10 frames
%down arrow: backward 10 frames
%spacebar: attempt to route current configuration
%'s' key: switch between choosing recording electrodes (magenta) and
%stimulation electrodes (green)
function [electrode st_electrode] = electrode_placer(immat,ELC,mtraw,Info,electrode, st_electrode)
stop = 0;
maxf = size(immat,3);
figure(34);
close(34);
c = figure(34);

[ex ey]     = el2position([0:11015]);
 
%electrode = [];
%st_electrode = [];
frame = 1;
ul = max(max(max(immat)));
ll = min(min(min(immat)));
clr = 'm';

spacingx=(max(ELC.X)-min(ELC.X(ELC.X>0)))/(length(unique(ELC.X(ELC.X>0)))-1);
    spacingy=(max(ELC.Y)-min(ELC.Y(ELC.Y>0)))/(length(unique(ELC.Y(ELC.Y>0)))-1);
    %note that there are twice as many unique y values as there are in a column
    sx=min(ELC.X(ELC.X>0)):spacingx:max(ELC.X);
    sy=min(ELC.Y(ELC.Y>0)):spacingy:max(ELC.Y);
    [sx,sy]=meshgrid(sx,sy);
    startind = Info.Parameter.TriggerTimeZero-1 + 10;
    
    drawframe(frame,electrode,st_electrode);
    number = 1;
    mode = 1;
while (stop==0);
    k           = waitforbuttonpress;
    while k==0
          b     = axis;
          a     = get(h,'CurrentPoint');
          x     = a(1,1);
          y     = a(1,2);

          d     = (ex-x).^2+(ey-y).^2;
          %[dist idx] = min(d);
          [d_   idx] = sort(d);
          idx = idx(1:number);
          if mode
              ne = (electrode ==idx-1);
              if sum(ne)==0
                electrode = [electrode idx-1];
              else
                electrode = electrode(~ne);
              end
          else
              ne = (st_electrode ==idx-1);
              if sum(ne)==0
                st_electrode = [st_electrode idx-1];
              else
                st_electrode = st_electrode(~ne);
              end
          end
          drawframe(frame,electrode,st_electrode);
          
          k = waitforbuttonpress;
    end
    x = double(get(c,'CurrentCharacter'));
   
    
    if x ==28 % go back
        frame = frame-1;
        if frame<1
            frame = 1; beep;
        end
        drawframe(frame,electrode,st_electrode);
    end
    if x ==31 % go back 10
        frame = frame-10;
        if frame<1
            frame = 1; beep;
        end
        drawframe(frame,electrode,st_electrode);
    end
    if x== 29
        frame = frame+1;
        if frame>maxf
            frame = maxf; beep;
        end
        drawframe(frame,electrode,st_electrode);
    end
     if x ==30 % go forward 10
        frame = frame+10;
        if frame>maxf
            frame = maxf; beep;
        end
        drawframe(frame,electrode,st_electrode);
    end
    
    if x ==32
    stop =1;
    end
    
    if x ==115
        mode = ~mode;
    end
end
%nested function drawframe
function drawframe(frame,electrode,st_electrode)
    h = subplot(5,5,[1:4,6:9,11:14,16:19]);%subplot(5,1,[1:4]);
    imagesc(sx(1,:),sy(:,1),immat(:,:,frame));   
    axis([sx(1,[1 end]) sy([1 end],1)']);
    axis([100 2000 50 2150])
    colormap(gray);
    caxis([ll ul]);axis equal;axis tight;
    title(['sample ' num2str(frame) '/' num2str(maxf)]);
    [xte yte]   = el2position(electrode);
    hold on
    plot(xte,yte,'ks','MarkerEdgeColor',clr)
    [xte yte]   = el2position(st_electrode);
    plot(xte,yte,'ks','MarkerEdgeColor','g')
    hold off
    subplot(5,1,5);
    plot(mtraw(electrode+1,startind:end)');ylim([ll ul]);
    ylabel([num2str(length(electrode)) ' electrodes chosen']);
    xlabel('samples');
    hold on; plot([frame frame], [ll ul],'k');hold off;
    
    %fun stuff
    subplot(5,5,[5,10,15,20]);imagesc(mtraw(electrode+1,startind:end));
    colormap(gray);
    caxis([ll ul]);
end
end

