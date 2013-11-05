%% interactive config builder
%using a immat structure built using the tiffmaker script, this script
%allows you to choose recording and stimulation electrodes.  After choosing
%electrodes, you can attempt to route the chosen electrodes, and the
%resulting configuration is shown.  if the routing didnt go as well as
%hoped for, you can reject the configuration and edit your electrode
%choices until you get a routing you like
%this script uses the electrode_placer and electrode_config functions
%commands:
%left arrow: back a frame
%right arrow: forward a frame
%up arrow: forward 10 frames
%down arrow: backward 10 frames
%spacebar: attempt to route current configuration
%'s' key: switch between choosing recording electrodes (magenta) and
%stimulation electrodes (green)
fn = 'myscan1';
neuroposfile=[Info.Path '/configs/' fn '.neuropos.nrk'];

electrode = [];
st_electrode = [5460];
%%
finished = 0;
[electrode st_electrode ] = electrode_placer(immat,ELC,mtraw,Info,electrode, st_electrode);
c = figure(34);
while (~finished)
title('routing...');drawnow;
[fname elidx]= electrode_config(electrode,st_electrode,neuroposfile);
title('routed! accept (y) or reject (n) config?');
[mposx mposy]=el2position([0:11015]);
    %els=hidens_get_all_electrodes(2);
    h = subplot(5,5,[1:4,6:9,11:14,16:19]);
    hold on;
plot(mposx(elidx), mposy(elidx), 'b+');

k           = waitforbuttonpress;
x = double(get(c,'CurrentCharacter'));
if x==121
    finished = 1;
    disp('config accepted');beep;
end
if x==110
    [electrode st_electrode ] = electrode_placer(immat,ELC,mtraw,Info,electrode, st_electrode);
end
end
save([Info.Path '/' fn '.mat'],'st_electrode','electrode')