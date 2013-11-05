%% Script to start and stop ntk data streams 
%  Douglas Bakkum 09/2012
%  TCP/IP communication with server
%
%
 %% Parameters
 
 chip_slot   =     4; % [0-4] 
 record_wait =  5*60; % [sec] Time to record.
 wait        = 25*60; % [sec] Time to wait between recordings.
 

 %% Open port

 fpga_sock = tcpip('11.0.0.1',11112); %fpga server sock
 fopen(fpga_sock) 

 % Send client name
 command = sprintf('client_name Long_term_recording\n');
 fwrite(fpga_sock, command,'char');

 % Set chip slot
 command = sprintf('select %i\n', chip_slot);
 fwrite(fpga_sock, command,'char'); 
 
 
 %% Run
 while 1   % loop forever
   
     % Send start command
     command = sprintf('save_start\n');
     fwrite(fpga_sock, command, 'char');            % send
     pause( record_wait );
     
     % Send stop command
     command = sprintf('save_stop\n');
     fwrite(fpga_sock, command, 'char');            % send
     pause( wait )
      
 end
 
 
 %% Close socket
 fclose(fpga_sock);

 
 %% Clean up sockets if having tcp/ip communication problems
 fclose('all')






