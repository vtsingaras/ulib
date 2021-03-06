//
//  UMSleeper.m
//  ulib
//
//  Copyright: © 2016 Andreas Fink (andreas@fink.org), Basel, Switzerland. All rights reserved.
//

#import "UMSleeper.h"
#import "UMFileTrackingMacros.h"

#include <unistd.h>
#include <fcntl.h>
#include <poll.h>

#import "UMThroughputCounter.h"

static void socket_set_blocking(int fd, int blocking)
{
    int flags, newflags;
	
    flags = fcntl(fd, F_GETFL);
    if (blocking)
    {
        newflags = flags & ~O_NONBLOCK;
    }
    else
    {
        newflags = flags | O_NONBLOCK;
    }
    if (newflags != flags)
    {
		fcntl(fd, F_SETFL, newflags);
    }
}

#define RXPIPE 0
#define	TXPIPE 1

@implementation UMSleeper

- (UMSleeper *)initFromFile:(const char *)file line:(long)line function:(const char *)function
{
    self = [super init];
    if(self)
    {
        isPrepared = NO;
        ifile = file;
        iline = line;
        ifunction = function;
    }
    return self;
    
}

- (UMSleeper *)init
{
    return [self initFromFile:__FILE__ line:__LINE__ function:__func__ ];
}

- (void) prepare
{
    @synchronized (self)
    {
        if(isPrepared==YES)
        {
            return;
        }
        if(pipe(pipefds)< 0)
        {
            int eno = errno;

            switch(eno)
            {
                case EMFILE:
                    NSLog(@"ERROR: EMFILE Too many file descriptors are in use by the process (Sleeper init)");
                    break;
                case ENFILE:
                    NSLog(@"ERROR: ENFILE The system file table is full. (Sleeper init)");
                    break;
                default:
                    NSLog(@"ERROR: %d Cannot allocate wakeup pipe (Sleeper init)",eno);
                    break;
            }
            return;
        }
        if(ifile)
        {
            TRACK_FILE_PIPE_FLF(pipefds[RXPIPE],@"rxpipe",ifile,iline,ifunction);
            TRACK_FILE_PIPE_FLF(pipefds[TXPIPE],@"txpipe",ifile,iline,ifunction);
        }
        else
        {
            TRACK_FILE_PIPE(pipefds[RXPIPE],@"rxpipe");
            TRACK_FILE_PIPE(pipefds[TXPIPE],@"txpipe");
        }
        socket_set_blocking(pipefds[RXPIPE], 0);
        socket_set_blocking(pipefds[TXPIPE], 0);
        isPrepared = YES;
    }
}

- (void) dealloc
{
    [self terminate];
}
- (void) terminate
{
    if(pipefds[RXPIPE]>=0)
    {
        TRACK_FILE_CLOSE(pipefds[RXPIPE]);
        close(pipefds[RXPIPE]);
        pipefds[RXPIPE] = -1;
    }
    if(pipefds[TXPIPE]>=0)
    {
        TRACK_FILE_CLOSE(pipefds[TXPIPE]);
        close(pipefds[TXPIPE]);
        pipefds[TXPIPE] = -1;
    }
    pipefds[RXPIPE] = -1;
    pipefds[TXPIPE] = -1;
    isPrepared = NO;
}



#ifdef INFTIM
#define POLL_NOTIMEOUT INFTIM
#else
#define POLL_NOTIMEOUT (-1)
#endif

static void flushpipe(int fd)
{
    unsigned char buf[128];
    ssize_t bytes;
    do
	{
        bytes = read(fd, buf, sizeof(buf));
    } while (bytes > 0);
}


- (int) sleep:(UMMicroSec) microseconds wakeOn:(UMSleeper_Signal)sig;	/* returns signal value if signal was received, 0 on timer epxiry, -1 on error  */
{
    struct pollfd pollfd[2];
    int pollresult = 0;
    int wait_time;
    long long start_time = [UMThroughputCounter microsecondTime];
    long long end_time = start_time + microseconds;
    long long now;
    

    int events = POLLIN | POLLPRI | POLLERR | POLLHUP | POLLNVAL;

#ifdef POLLRDBAND
    events |= POLLRDBAND;
#endif 
    
#ifdef POLLRDHUP
    events |= POLLRDHUP;
#endif
    
    [self prepare];
    if(pipefds[RXPIPE] < 0)
    {
        return -1;
    }

    while(pollresult == 0)
    {
        now = [UMThroughputCounter microsecondTime];
        if(now > end_time)
        {
            return pollresult;
        }
        if (microseconds < 0)
        {

            memset(&pollfd,0x00,sizeof(pollfd));
            pollfd[0].fd = pipefds[RXPIPE];
            pollfd[0].events = events;
            pollfd[0].revents = 0;
            pollresult = poll(pollfd, 1, (int)POLL_NOTIMEOUT);
        }
        else
        {
            long long remaining = microseconds;
            
            //#define SLICE_TIME   (2073600LL*1000LL*1000LL)/* 24 days is about the max which fits into a signed integer */
    #define SLICE_TIME (1000LL*1000LL*10LL*60LL)   /* max 10 minutes for testing */
            while((remaining > 0) && (pollresult == 0))
            {
                if(remaining < SLICE_TIME)
                {
                    wait_time = (int)remaining/1000; /* poll wants miliseconds */
                    memset(&pollfd,0x00,sizeof(pollfd));
                    pollfd[0].fd = pipefds[RXPIPE];
                    pollfd[0].events = events;
                    pollfd[0].revents = 0;
                    
                    pollresult = poll(&pollfd[0], 1, wait_time);
                    remaining = 0LL;
                }
                else
                {
                    remaining = remaining - SLICE_TIME;
                    wait_time = (int)SLICE_TIME / 1000000;
                    memset(&pollfd,0x00,sizeof(pollfd));
                    pollfd[0].fd = pipefds[RXPIPE];
                    pollfd[0].events = events;
                    pollfd[0].revents = 0;
                    pollresult = poll(&pollfd[0], 1, wait_time);
                }
            }
        }
        if(pollresult > 0)
        {
            /* something to read */
            UMSleeper_Signal signalToRead=0xFE;
            ssize_t bytes;
            uint8_t buffer[4];
            bytes = read(pipefds[RXPIPE], &buffer, 4);
            if(bytes == 4)
            {
                signalToRead = (buffer[0] << 24) | (buffer[1] << 16) | (buffer[2] <<8) | buffer[3];
                if(signalToRead &  sig) /* checking if signal's bit is set */
                {
                    return (int)signalToRead;
                }
            }
        }
    }
    return pollresult; /* we get here on timeout only */
}


- (int) sleep:(long long) microseconds	/* returns 1 if interrupted, 0 if timer expired */
{
    return [self sleep:microseconds wakeOn:UMSleeper_AnySignal];
};	/* returns signal if signal was received, 0 on timer epxiry, -1 on error  */

- (void) reset
{
    if(isPrepared)
    {
        flushpipe(pipefds[RXPIPE]);
    }
}

- (void) wakeUp:(UMSleeper_Signal)signal
{
    if(pipefds[RXPIPE] > 0)
    {
        uint8_t bytes[4];
        bytes[0] = (signal & 0xFF000000 ) >> 24;
        bytes[1] = (signal & 0x00FF0000 ) >> 16;
        bytes[2] = (signal & 0x0000FF00 ) >> 8;
        bytes[3] = (signal & 0x000000FF ) >> 0;
        write(pipefds[TXPIPE], &bytes,4);
    }
}


- (void) wakeUp
{
    [self wakeUp:UMSleeper_WakeupSignal];
}

@end
