// Douglas Bakkum 2009
// 
//  Tools for dealing with the ThreadedServer program.
//  
//  2009.12.31 :: Stable with rev5573
//  2010.02.21 :: Try with rev8765. Drop some usleep commands.
//
//



#ifndef CMOSSERVERTOOLS_H

#define CMOSSERVERTOOLS_H

#include <base/Sprintf.H>
#include <common/Types.H>
#include <base/Error.H>
#include <math.h>//db
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <stdlib.h>
#include <poll.h>
#include <string.h> 


#define SERVER_PORT 11113 // port to get CMOS data via tcp/ip (localhost)
//#define SERVER_PORT 11112 // port to get CMOS data via tcp/ip (localhost)
#define SERVER_ADDR "127.0.0.1"

#define FPGA_PORT   32125  // better to get these from server when implemented...
#define FPGA_ADDR   "11.0.0.7"

#define FORWARD_PORT 33125
#define MAXPENDING   5    /* Maximum outstanding connection requests */

//#define SERVER_ADDR "129.132.228.46"
//#define SERVER_PORT 21112 // port to get CMOS data via tcp/ip (localhost)
//#define FPGA_ADDR "12.0.0.7"

inline int create_server(int PORT){
  
    int sock;

    struct sockaddr_in ServAddr; /* Local address */

    /* Create socket for incoming connections */

    //sock = socket( PF_INET, SOCK_STREAM, IPPROTO_TCP);
    sock = socket( AF_INET, SOCK_STREAM,  0 );
    if(sock<0){  
         perror("cannot open socket.\n ");
    }


    /* Construct local address structure */
    memset(&ServAddr, 0, sizeof(ServAddr));   /* Zero out structure */
    ServAddr.sin_family      = AF_INET;                /* Internet address family */
    ServAddr.sin_addr.s_addr = htonl(INADDR_ANY); /* Any incoming interface */
    ServAddr.sin_port        = htons(PORT);      /* Local port */

    /* Bind to the local address */
    if (bind(sock, (struct sockaddr *) &ServAddr, sizeof(ServAddr)) < 0){
         perror("cannot bind socket.\n");
    }


    /* Mark the socket so it will listen for incoming connections */
    if (listen(sock, MAXPENDING) < 0){
         perror("cannot bind socket.\n");
    }

    return(sock);    
}




inline int connect_server(const string ADDR, int PORT){ // dont add anything else as this is general purpose (i.e. can connect to fpga, etc. too)
   bool FAIL;
   int rc;
   struct sockaddr_in localAddr, servAddr;
   //struct hostent *h;

   fprintf(stderr,"cmosservertools address %s   port %i\n", ADDR.c_str(), PORT);

   int sock;
   int cnt=0;
   
   do{
       FAIL=false;

       servAddr.sin_family = AF_INET;
       servAddr.sin_addr.s_addr = inet_addr(ADDR.c_str());
       servAddr.sin_port = htons(PORT);

       /* create socket */
       sock = socket(AF_INET, SOCK_STREAM, 0);
       if(sock<0) {
          perror("cannot open socket ");
          FAIL=true;
       }

       /* bind any port number */
       localAddr.sin_family = AF_INET;
       localAddr.sin_addr.s_addr = htonl(INADDR_ANY);
       localAddr.sin_port = htons(0);

       rc = bind(sock, (struct sockaddr *) &localAddr, sizeof(localAddr));
       if(rc<0) {
          printf("cannot bind port TCP %u\n",PORT);
          perror("error ");
          FAIL=true;
       }

       /* connect to server */
       usleep(1000);
       rc = connect(sock, (struct sockaddr *) &servAddr, sizeof(servAddr));
       if(rc<0) {
          perror("cannot connect ");
          FAIL=true;
       }
       usleep(1000);


       if( cnt++>4 ){ perror("Timed out. Cannot open socket"); return(0); }
       if( FAIL ){ fprintf(stderr,"Waiting for server.\n"); sleep(3); }

   }while( FAIL );

   return(sock);
}


inline void close_server(int sock){
   /* close socket */
   sleep(2);
   close(sock);
   //usleep(100000);
}

inline void send_command( int sock, char * cmd ){
   short len;
   if( SERVER_PORT == 11113 ){
   /* append command length */
	//printf("using server port 11113\n");
	len = htons(strlen(cmd)+2);
//	len = strlen(cmd) + 2;
//	send(sock,&len,sizeof(short),0);

	char buf[256];
	memcpy(buf,&len,sizeof(short));
	memcpy(buf+sizeof(short),cmd,strlen(cmd));
	send(sock,buf,strlen(cmd)+sizeof(short),0);
//	printf("CMOSServerTools.H send_command   cmd=%s  len=%i   server port 11113\n",buf+2,len);
   }else{

//	printf("CMOSServerTools.H send_command   cmd=%s  len=%i\n",cmd,len);
	int ret = send(sock,cmd,strlen(cmd),0);
	if( ret < 0 ) {
	     fprintf(stderr,"CMOSServerTools send error for command '%s'.",cmd);
	     perror("CMOSServerTools send error for command.");
	}
   }
   return;
}

inline int recv_answer( int sock, unsigned char * msg, int msg_length ){
   //usleep(1000);
   int ret = recv(sock, msg, msg_length, 0); 
   if(ret<0) {
        fprintf(stderr,"CMOSServerTools recv error for command.");
        perror("CMOSServerTools recv error for command.");
   }//*///
   //printf("returned message = %s\n",msg);
   return(ret);
}

inline int recv_answer( int sock, char * msg, int msg_length ){
   //usleep(1000);
//printf("     recv cmos    flag A  message length allocated %i\n",msg_length);
   int ret = recv(sock, msg, msg_length, 0); 
//printf("     recv cmos    flag B\n");
   if(ret<0 || atoi(msg)<0) {
        fprintf(stderr,"CMOSServerTools recv error for command.");
        perror("CMOSServerTools recv error for command.");
   }//*///
   //printf("returned message = %s\n",msg);
   return(ret);
}

inline void send_recv_cmos( int sock, char * cmd, char * msg , int msg_length ){
//   printf("CMOSServerTools.H send_command   cmd=%s  strlen=%i\n",cmd,(int)strlen(cmd));
   /* send command and recieve reply from hidens server */
   send_command( sock, cmd );
//printf("send recv cmos    flag 2\n");
   recv_answer(  sock, msg, msg_length );
//printf("send recv cmos    flag 3\n");
   return;
} 


/*inline int server_connected(int data_sock){
   // check if socket still connected 
   // from:  http://stefan.buettcher.org/cs/conn_closed.html
   // use the poll system call to be notified about socket status changes
   char msg[64]; 
   struct pollfd pfd;
   pfd.fd = data_sock;
   pfd.events = POLLIN | POLLHUP | POLLRDNORM;
   pfd.revents = 0;

   // call poll with a timeout of 10 ms
   if (poll(&pfd, 1, 10) > 0) {
	// if result > 0, this means that there is either data available on the socket, or the socket has been closed
	if (recv(data_sock, msg, sizeof(msg), MSG_PEEK | MSG_DONTWAIT) == 0) {
		// if recv returns zero, that means the connection has been closed:
		fprintf(stderr,"Cannot select slot: socket closed.\n");
		return(0);
	}
   }
   return(1); //
}*/

inline void send_client_name(int data_sock, const string NAME){
   /* send client name */
   usleep(1000);
   char cmd[64];
   char msg[64];
   memset(&cmd,0,sizeof(cmd));
   sprintf (cmd, "client_name mea-%s:\n",NAME.c_str());
   send_recv_cmos( data_sock, cmd, msg, sizeof(msg) );
}


inline int set_chip_slot(int data_sock, int slot){
   char cmd[64];
   char msg[64];

   /* check if server socket is still connected */
   /*if( !server_connected(data_sock) ){
	return(-2);
   }*/


   /* tell server which slot to read data from */
   usleep(1000); memset(&cmd,0,sizeof(cmd));
   sprintf (cmd, "select %i\n",slot);
   send_recv_cmos( data_sock, cmd, msg, sizeof(msg) );


   /* ask server which chip is connected */
   usleep(1000); memset(&cmd,0,sizeof(cmd));
   sprintf (cmd, "id\n");
   send_recv_cmos( data_sock, cmd, msg, sizeof(msg) );

   //usleep(1000);
   //fprintf(stderr,"CMOSServerTools:   %i  %s\n",atoi(msg),msg);
   //if(atoi(msg)==65535 || atoi(msg)==0) return(0);
   return(atoi(msg)); // returns chip ID
}

inline float ask_for_gain(int data_sock){
   /* ask the server for the gain value */
   usleep(1000);
   char cmd[64];
   char msg[64];
   memset(&cmd,0,sizeof(cmd));
   sprintf (cmd, "gain 0\n");
   send_recv_cmos( data_sock, cmd, msg, sizeof(msg) );

   //usleep(1000);
   //fprintf(stderr,"CMOSServerTools:   %i  %s\n",atoi(msg),msg);
   //if(atoi(msg)==0) return(0);
   return(atof(msg)); // returns chip ID

}

inline int ask_for_adc_res(int data_sock){
   /* ask the server for the gain value */
   usleep(1000);
   char cmd[64];
   char msg[64];
   memset(&cmd,0,sizeof(cmd));
   sprintf (cmd, "adc_res\n");
   send_recv_cmos( data_sock, cmd, msg, sizeof(msg) );

   //usleep(1000);
   //fprintf(stderr,"CMOSServerTools:   %i  %s\n",atoi(msg),msg);
   //if(atoi(msg)==0) return(0);
   return(atoi(msg)); // returns chip ID
}

inline float ask_for_adc_range(int data_sock){
   /* ask the server for the gain value */
   usleep(1000);
   char cmd[64];
   char msg[64];
   memset(&cmd,0,sizeof(cmd));
   sprintf (cmd, "adc_range\n");
   send_recv_cmos( data_sock, cmd, msg, sizeof(msg) );
   
   //usleep(1000);
   //fprintf(stderr,"CMOSServerTools:   %i  %s\n",atoi(msg),msg);
   //if(atoi(msg)==0) return(0);
   return(atof(msg)); // returns chip ID
}


inline int dc_offset(int slot, short * centers) {
    
    //fprintf(stderr,"DC Offset entered.\n");
    //fprintf(stderr,"DC Offset not yet implemented on ThreadedServer\n");
    //return;

   /* connect to the ThreadedServer */
   int server_sock = connect_server(SERVER_ADDR,SERVER_PORT);
   send_client_name(server_sock,"DC Offset");

   /* tell server which slot to read data from */
   set_chip_slot(server_sock, slot);

   /* tell server to set DC offsets */
   char cmd[64];
   char msg[64]; 
   usleep(100000);
   for( int i=0;i<NCHANS;i++ ){
	   fprintf(stderr,"center %i %i \n",i,(int)(centers[i]/16));

	   memset(&cmd,0,sizeof(cmd));
	   sprintf (cmd, "comp_dc_send %i %i\n",i,(int)(centers[i]/16)); // begins moving average calculation
   	   send_recv_cmos( server_sock, cmd, msg, sizeof(msg) );

	   usleep(50000); // must wait this long or else get server error that cannot connect to fpga
	   //usleep(1000);

   }

   /* read off any messages on socket such that can close without delay */
   //memset(&cmd,0,sizeof(cmd)); 
   //ret = recv(server_sock, cmd, sizeof(cmd), 0); 
   //if (ret<0) 
   //	throw SysErr("dc_offset","Read failed");
   //fprintf(stderr,"%s\n",cmd);

   /* close socket */
   close_server(server_sock);
   //close(server_sock);
   return(1);

}




inline void reset_buffer(int data_sock) { 
   ///////////////////////////////////////////////////////////////////////////
   // Need to reset buffer in order to get up-to-date electrode mappings. 
   // (This causes the server to reset emulator settings I guess.)
   // When the 'live' command works in the server, it may provide more elegant
   // solution than switching slots as done below.

   char cmd[64];
   char msg[64];

   /* find slot */
   usleep(1000);
   memset(&cmd,0,sizeof(cmd));
   sprintf (cmd, "select\n");
   send_recv_cmos( data_sock, cmd, msg, sizeof(msg) );
   int slot = atoi(msg);//*///
   
   /* switch slot (resets buffer) */
   usleep(1000);
   memset(&cmd,0,sizeof(cmd));
   sprintf (cmd, "select %i\n",(slot+1)%5);
   send_recv_cmos( data_sock, cmd, msg, sizeof(msg) );

   /* switch back slot (now electrode mapping has been updated) */
   usleep(1000);
   memset(&cmd,0,sizeof(cmd));
   sprintf (cmd, "select %i\n",slot);
   send_recv_cmos( data_sock, cmd, msg, sizeof(msg) );

   //usleep(100000);
   ///////////////////////////////////////////////////////////////////////////
}





//inline void ch2el_mapping(int slot, int el[], int x_pos[], int y_pos[], int x_num[], int y_num[]) { 
inline int ch2el_mapping(int data_sock, int el[], int x_pos[], int y_pos[], int x_num[], int y_num[]) { 
// :: chip slot, electrode, column pos (x), row pos (y), column num (x), row num (y)

  //fprintf(stderr,"NOT USING ARRANGE\n");
  //return;


   reset_buffer(data_sock);


   int rr=0, cc=30;
   char cmd[64];
   char elc[256];


   /* ask for electrode data */
   for( int hw=0; hw<NCHANS; hw++ ){
	   memset(&cmd,0,sizeof(cmd));
	   memset(&elc,0,sizeof(elc)); 
	   sprintf (cmd, "ch %i\n",hw);
 	   send_recv_cmos( data_sock, cmd, elc, sizeof(elc) );

   	   //fprintf(stderr,"    channel    ret=%i    elc=%s el[%i]=%i  length elc = %i \n",ret,elc,hw,el[hw],strlen(elc));
	   if( strlen(elc)==1 || strlen(elc)>10 ){ 
	   //if(ret==1 || ret>10){
		// either not connected or invalid channel
		//fprintf(stderr,"bad channel    ret=%i    elc=%s el[%i]=%i\n",ret,elc,hw,el[hw]);
		el[hw]=-1;
		x_pos[hw]=cc;		x_num[hw]=0;
		y_pos[hw]=rr*35; rr++;	y_num[hw]=0;
		if( rr>NCHANS/3 ){ rr=0; cc+=30; }
	   }else{
	   	el[hw] = atoi(elc);
		memset(&cmd,0,sizeof(cmd));
		memset(&elc,0,sizeof(elc)); 
		sprintf (cmd, "el %i\n",el[hw]);
		send_recv_cmos( data_sock, cmd, elc, sizeof(elc) );

		//fprintf(stderr,"returned: %s \n",elc);
	   	sscanf (elc,"%d %d %*c %i %*c %i",&x_pos[hw],&y_pos[hw],&x_num[hw],&y_num[hw]); // returns location in [nm]
	   	x_pos[hw]=int(x_pos[hw]/1000); // convert to [um] from [nm]
	   	y_pos[hw]=int(y_pos[hw]/1000);
	
	   }

	  //if( el[hw]>0 ) fprintf(stderr,"map(%i,:)=[%i %i %i %i %i %i];\n",hw+1,hw,el[hw],x_pos[hw],y_pos[hw],x_num[hw],y_num[hw]);//for matlab electrode mapping -- OFFSET BY 1!
	  //else	     fprintf(stderr,"map(%i,:)=[%i -1 -1 -1 -1 -1];\n",hw+1,hw);//for matlab electrode mapping -- OFFSET BY 1!

   }
   
   //for( int hw=NCHANS; hw<TOTALCHANS; hw++ ){ // invalid channels currently
   for( int hw=NCHANS; hw<TOTALCHANS; hw++ ){ // DAC channels currently
	x_pos[hw] = 30; 			x_num[hw]=0;
	y_pos[hw] = hw==126 ? 1780:1950;	y_num[hw]=0;
   }

return(0);
}




inline int save_start_ntk_commands(int data_sock, int slot, int saveraw){ // db: tell the ThreadedServer to save ntk commands
  //fprintf(stderr,"save_start_ntk_commands  %i %i\n",data_sock,slot);
  //return;

   char cmd[64];
   char msg[64];

   /* tell server which slot to read data from */
   set_chip_slot(data_sock, slot);

   /* saving raw ntk data */
   usleep(100);
   memset(&cmd,0,sizeof(cmd));
   if(saveraw==0) // do not save
       sprintf (cmd, "save_data off\n");
   else            // save
       sprintf (cmd, "save_data on\n");
   send_recv_cmos( data_sock, cmd, msg, sizeof(msg) );

   /* begin saving ntk commands */
   usleep(100);
   memset(&cmd,0,sizeof(cmd));
   sprintf (cmd, "save_start\n");
   send_recv_cmos( data_sock, cmd, msg, sizeof(msg) );

   return(1);
}

inline int save_stop_ntk_commands(int data_sock){ // db: tell the ThreadedServer to save ntk commands
  //fprintf(stderr,"save_stop_ntk_commands  %i \n",data_sock);
  //return;

   /* stop recording ntk command data */
   usleep(100);
   char cmd[64];
   char msg[64];
   memset(&cmd,0,sizeof(cmd));
   sprintf (cmd, "save_stop\n");
   send_recv_cmos( data_sock, cmd, msg, sizeof(msg) );

  //fprintf(stderr,"select: %i\n",atoi(msg));
  return(1);
}


// copied from cpp/sub/median.c by DB April 2009
// returns the median value in an array 'context' between the array indices 'start' and 'end'
#include <iostream>
#include <algorithm>
#include <vector>

inline float median(float *context, int start, int end)
{  

  int size=end-start;
  if(size<1){
	fprintf(stderr,"median.c: Bad indices to array\n");
	return( 0 );
  }
  
  float myarray[size];
  for( int i=start;i<end;i++ ){
  	myarray[i-start]=context[i];
  }

  vector<float> myvector (myarray,myarray+size);   
  sort(myvector.begin(), myvector.end());

  vector<float>::iterator it;
  it=myvector.begin()+(int)(size/2);
  float ret= *it;
  //fprintf(stderr,"%i \n",ret);
  return( ret );
}



#endif
