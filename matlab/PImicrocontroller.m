%% DB 7/2011 -- control Physik Instrumente microcontrollers
%               to use to pattern laminen on CMOS MEAs
%
%               ref DB 7/2006 -- controlled stimulation time of Jim/Edgar board via rtlinux and Daniel's board
%
%
%               Currently did not figure out how to read back information, 
%               so therefore use 'minicom' program from a terminal to do this.
%

%% connect 
% /dev/ttyS0 permissions need to be rw (read/write) 

controller = serial('/dev/ttyS0','BaudRate',9600,'DataBits',8,'StopBits',1,'Parity','odd','Terminator','CR','ByteOrder','bigEndian')

fopen(controller)



%% initialize and zero position


%   fprintf(controller,'3mf,4mf')       % turn off motors

% fprintf(controller,'3sv5000000,4sv5000000')    % set velocity

fprintf(controller,'3mn,4mn')       % turn on motors

% fprintf(controller,'3fe0,4fe0') % find edge (move to edge)
% fprintf(controller,'4mr-20000,3mr-20000') % move relative

% fprintf(controller,'st') % stop movement
% fprintf(controller,'dh') % set as home (zero position)



%% 

fprintf(controller,'3gh,4gh') % go home  ** MAY NEED TO RUN THIS MULTIPLE TIMES IF PRIOR CMD PRODUCED ERRORED MOVEMENT **


%%

st4 =  -6000; % motor 4 step
zr3 =      0; % motor 3 zero
st3 = -28000; % motor 3 step

cmd=[ '3MA' num2str(st3)    ',3WP' num2str(st3)   ','   ...
      '4MA' num2str(st4*1)  ',4WP' num2str(st4*1) ','   ...
      '3MA' num2str(zr3)    ',3WP' num2str(zr3)   ','   ...
      '4MA' num2str(st4*2)  ',4WP' num2str(st4*2) ','   ...
      '3MA' num2str(st3)    ',3WP' num2str(st3)   ','   ...
      '4MA' num2str(st4*3)  ',4WP' num2str(st4*3) ','   ...
      '3MA' num2str(zr3)    ',3WP' num2str(zr3)   ','   ...
      '4MA' num2str(st4*4)  ',4WP' num2str(st4*4) ','   ...
      '3MA' num2str(st3)    ',3WP' num2str(st3)    ]%    ** MAXIMUM SIZE APPEARS TO BE 18 comma separated commands **


fprintf(controller,cmd)





%% feedback

fprintf(controller,'3tp')        % get positions
pause(.1)
size=controller.BytesAvailable
A = [char( fread(controller,size,'schar') )']



%% close port
fclose(controller)






