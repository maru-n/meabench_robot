% Jan's stimloop test.c interface
% (can do high freq stim)
% 
% ** NEED to RUN run_lvds_2.0.sh  on FPGA **
%
%
% See:
% https://wiki-bsse.ethz.ch/display/DBSSECMOSMEA/StimLoops
%

% Connect socket magic
s = stimloop;
s.setTimeout(1000); % to avoid blocking sockets [msec]

%% Connect the specified channel to its stimulation buffer
chipAddr    = 4;
enable      = 1; % connect or disconnect [0]
dacSel      = 0; % 0==DAC0, 1==DAC1
cLarge      = 0; % small or large current range
broadcast	= 0; % configure all channels at once

channel     = [3]; % channel number (-1==disconnect all)

for ch = channel
    s.push_connect_channel(chipAddr, enable, dacSel, cLarge, ch, broadcast);
    s.flush
    pause(.1)
end

%%
% Stimulate a biphasic pulse
volt        = 400;      % amplitude in volt (divided by 2.9 internally to get bits)
pulsePhase	=   4;      % duration of one pulse [samples]
epoch       =  50;      % gets encoded on DAC2 (no further effect)
delay       =  10*20;  % delay in [samples] before pulse gets emitted
stimMode	=   1;      % 0==keep previous, 1==voltage, 2==current (current is not implemented)

loop        =  50;

for i=1:loop
    s.push_biphasic_pulse(chipAddr, 0, channel, volt, pulsePhase, epoch, delay, stimMode)    
end

s.flush
    
    
%% Disconnect channel
enable      = 0;

for ch = channel
    s.push_connect_channel(chipAddr, enable, dacSel, cLarge, ch, broadcast);
    s.flush
    pause(.1)
end




%%
f = stimloop;
for i = 1:50
    amp = sin((2*pi)/50.0*i)*50;
    f.push_simple_pulse(4, 0, 100+amp, 4)
    f.push_simple_delay(30*20); % 30 ms delay
end
g = stimloop;
for i = 1:50
    delay = -sin((1*pi)/50.0*i)*20*28;
    g.push_simple_pulse(4, 0, 100, 4)
    g.push_simple_delay(30*20 + delay); % 20 ms delay
end

f.setTimeout(1000); % necessary to avoid blocking if socket communication not running (i.e. test.c not started)
g.setTimeout(1000);

for j = 1:2
    f.send();
    g.send();
end

