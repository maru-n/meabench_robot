%% code to stimulate cmos chip using custom test.c stim server socket (stimulate_cmos.m in svn)
%  Douglas Bakkum 09/2012
%


 fpga_sock = tcpip('11.0.0.7',32125); %fpga server sock
 fopen(fpga_sock) 
%  pause(.5)

%%
 
  chipaddress        =    1;		%// "slot" where chip is plugged [0-4]
  dacselection       =    0;    	%// 0->DAC1.  1->DAC2. 2->[DAC1 without DAC2 encoding]. This is the DAC used to stimulate. The other DAC is then used for encoding stimulation channel and epoch.
  volt               =  400;    	%// [+/-mV; millivolt]   [current: 0 to 450 allowed -->> 0 to +/-4.12uA ONLY! for low current mode]
  stim_mode          =    1;        %// [previous==0; voltage==1; current==2] 
  phase              =  200;    	%// [us; microseconds]
  delay              =  400;		%// [0->3,000; milliseconds] delay until stimulating sent to fpga (can change limits in test.c)
  epoch 			 =    0;    	%// User defined optional tag. [0->512] for high res DAC encoding 
  channel			 =  15;    	%// Stimulation channel.
   
  repeats            =   15;
      
 %%%% network byte order, as used on the Internet, is Most Significant Byte first. 
 %%%% matlab is little endian
 %%%% the least significant byte is stored first (little endian)
 %%%% the most significant byte is stored first (big endian). 

 % input 0)chipaddress, 1)dacselection, 2)channel, 3)volt/curr(digi), 4)pulsephase(samples), 5)epoch, 6)epoch sign (1 -> negative) 7)delay[msec] 8)stim mode[previous==0; volt==1; curr==2]
 
 
 
 
    % Stim pulse	
      stimulation  =[(chipaddress),(dacselection),(channel),(ceil(volt/2.9)),((ceil(phase/50))),(epoch),(0),(round(delay*20)),(stim_mode)];
      %stimulation  =[(chipaddress),(dacselection),(channel),(ceil(volt/2.9)),((ceil(phase/50))),(epoch),(0),((delay)),(stim_mode),(repeats)];
      stimulation  = (int16(stimulation));
 
    % Send stim commands  
    for i = 1:repeats
      fwrite(fpga_sock,stimulation,'int16');    % send stimulation  
      ret = fread(fpga_sock, 1,'int16');        % 1==success   0==fail
      if( ~ret )
          disp('Stim fail error!')
      end
    end
 
 
    %%
% pause(.5)
fclose(fpga_sock);
%   fclose('all'); % Use this if for some reason too many 'files' are open






%%
% for i=1:60
%  
%     % DAC2 encoding pulse
%     delay        =   150;	
%     volt         =   50;
%     dacselection =    0;	
%       stimulation  =[(chipaddress),(dacselection),(channel),(ceil(volt/2.9)),((ceil(phase/50))),(epoch),(0),(round(delay*20)),(stim_mode)];
%       stimulation  = (int16(stimulation));
%  
%     % Sub threshold pulse
%     delay        =    1;	
%     volt         =   50;
%     dacselection =    2; 
%       stimulation_sub =[(chipaddress),(dacselection),(channel),(ceil(volt)/2.9),((ceil(phase/50))),(epoch),(0),(round(delay*20)),(stim_mode)];
%       stimulation_sub = (int16(stimulation_sub));
%     
%     % Supra threshold pulse
%     delay        =   .3;	
%     volt         =  200;
%     dacselection =    2; 
%       stimulation_sup =[(chipaddress),(dacselection),(channel),(ceil(volt)/2.9),((ceil(phase/50))),(epoch),(0),(round(delay*20)),(stim_mode)];
%       stimulation_sup = (int16(stimulation_sup));
%    
%     % Send stim commands  
%       fwrite(fpga_sock,stimulation,    'int16');            % send stimulation  
%       fwrite(fpga_sock,stimulation_sub,'int16');            % send stimulation  
%       fwrite(fpga_sock,stimulation_sup,'int16');            % send stimulation  
%     
% %     % Receive replies on success / failure
% %       ret0 = fread(fpga_sock, 1,'int16');        % 1==success   0==fail
% %       ret1 = fread(fpga_sock, 1,'int16');        % 1==success   0==fail
% %       ret2 = fread(fpga_sock, 1,'int16');        % 1==success   0==fail
% %       if( ~ret0 + ~ret1 + ~ret2 )
% %           disp('Stim fail error!')
% %       end
%     
% end
    

















