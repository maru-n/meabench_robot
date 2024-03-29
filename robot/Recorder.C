/* record/Recorder.C: part of meabench, an MEA recording and analysis tool
** Copyright (C) 2000-2002  Daniel Wagenaar (wagenaar@caltech.edu)
**
** This program is free software; you can redistribute it and/or modify
** it under the terms of the GNU General Public License as published by
** the Free Software Foundation; either version 2 of the License, or
** (at your option) any later version.
**
** This program is distributed in the hope that it will be useful,
** but WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
** GNU General Public License for more details.
**
** You should have received a copy of the GNU General Public License
** along with this program; if not, write to the Free Software
** Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*/

// Recorder.C

#include "Recorder.H"

#include <common/Types.H>
#include <common/Config.H>
#include <spikesrv/Defs.H>
#include <time.h>

Recorder::Recorder(SFCVoid *source0,
                   string const &fn0) throw(Error): fn(fn0)
{
    source = source0;
    fh = fopen(fn.c_str(), "wb");
    if (!fh)
        throw SysErr("Recorder", "Cannot create file");
    current_file_length = 0;
    file_seq_no = 0;
    saveto = savefrom = last = source->first();

    //####################################
    tcpServer = new TCPDataServer();
    tcpServer->setup(TCP_SERVER_PORT);
    tcpServer->startListening();

    stimSrv = new StimSrv();
    stimSrv->setup();


    receivedDataBuffer = (unsigned char *)malloc(TCP_MAX_MSG_SIZE);

    timeKeepFlag = false;
    //####################################
}

Recorder::~Recorder()
{
    if (fclose(fh))
    {
        SysErr e("Recorder", "Trouble closing file");
        e.report();
    }
    stimSrv->closeServer();
}


timeref_t Recorder::save_some(timeref_t upto) throw(Error)
{
    if (last < savefrom)
        last = savefrom;
    timeref_t end = min(min(saveto, upto), source->latest());
    unsigned int tpsiz = source->datasize();
    timeref_t oldest = min(last, end);


    if (tcpServer->isConnected())
    {
        int receivedSize = tcpServer->receiveRawBytes((char *)receivedDataBuffer, TCP_MAX_MSG_SIZE);
        if (receivedSize == 0)
        {
            std::cout << "Disconected by client." << std::endl;
            tcpServer->startListening();
        }

        for (int i = 0; i < receivedSize; i ++)
        {
            unsigned char data = receivedDataBuffer[i];
            if (data == 0xff)
            {
                printf( "time keep sygnal:%d¥n", clock() );
                timeKeepFlag = true;
                continue;
            }
            int dacNum = (int)(data >> 7);
            int channelNum = (int)(data & 0b01111111);

            if (dacNum < 0 || dacNum > 1 || channelNum < 0 || channelNum > 125)
            {
                break;
            }


            stimSrv->sendStim(dacNum, channelNum);
            //stimSrv->sendStim(2, 127);//for reduction of noise
            //stimSrv->sendStim(3, 127);//for reduction of noise
            std::cout << "DAC#" << dacNum << " channel#" << channelNum << std::endl;
        }
    }

    while (last < end)
    {
        SpikeSFCli *spikeSrc = dynamic_cast<SpikeSFCli *>(source);
        Spikeinfo const &si = (*spikeSrc)[last++];
        char c = (unsigned char)si.channel;

        //###########################

        if (tcpServer->isConnected())
        {
            tcpServer->sendRawBytes(&c, 1);
            if (timeKeepFlag)
            {
                timeKeepFlag = false;
                printf( "clock time:%ld = spike time:%ld¥n", clock(), si.time );
            }
        }
        //###########################

    }
    return oldest;
}

void Recorder::set_bounds(timeref_t t0, timeref_t t1) throw(Error)
{
    sdbx("Recorder::set_bounds %g - %g", t0 / (FREQKHZ * 1000.0), t1 / (FREQKHZ * 1000.0));
    savefrom = t0 + source->first();
    saveto = t1 + source->first();
    if (saveto < t1)
        saveto = INFTY; // correct for evil wrapping!
}
