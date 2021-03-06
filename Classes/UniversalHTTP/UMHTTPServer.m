//
//  UMHTTPServer.m
//  UniversalHTTP
//
//  Copyright: © 2016 Andreas Fink (andreas@fink.org), Basel, Switzerland. All rights reserved.
//

#import "UMHTTPServer.h"
#import "UMHTTPConnection.h"
#import "UMHTTPPageHandler.h"
#import "UMSocket.h"
#import "UMSleeper.h"
#import "UMLogFeed.h"
#import "UMHTTPRequest.h"
#include <sys/types.h>
#include <netinet/in.h> 
#ifdef SENTEST
#import "UMConfig.h"
#endif
#import "UMLock.h"

@implementation UMHTTPServer

@synthesize	serverName;
@synthesize	status;


@synthesize authorizeConnectionDelegate;
@synthesize authenticateRequestDelegate;

/* HTTP methods accordings to RFC2616 */
@synthesize httpOptionsDelegate;
@synthesize httpGetDelegate;
@synthesize httpHeadDelegate;
@synthesize httpPostDelegate;
@synthesize httpPutDelegate;
@synthesize httpDeleteDelegate;
@synthesize httpTraceDelegate;
@synthesize httpConnectDelegate;

@synthesize httpGetPostDelegate;
@synthesize name;
@synthesize advertizeName;
@synthesize enableSSL;

/***/

@synthesize listenerSocket;

- (id) init
{
	return [self initWithPort:UMHTTP_DEFAULT_PORT socketType:UMSOCKET_TYPE_TCP];
}

- (id) initWithPort:(in_port_t)port 
{
	return [self initWithPort:port socketType:UMSOCKET_TYPE_TCP];
}

- (id) initWithPort:(in_port_t)port socketType:(UMSocketType)type
{
    return [self initWithPort:port socketType:type ssl:NO sslKeyFile:NULL sslCertFile:NULL];
}

- (id) initWithPort:(in_port_t)port socketType:(UMSocketType)type ssl:(BOOL)doSSL sslKeyFile:(NSString *)sslKeyFile sslCertFile:(NSString *)sslCertFile
{
    self = [super init];
    if(self)
    {	
        getPostDict = [[NSMutableDictionary alloc]init];
        httpOperationsQueue = [NSOperationQueue mainQueue]; // [[NSOperationQueue alloc] init];
        listenerSocket = [[UMSocket alloc] initWithType:type];
        [listenerSocket setLocalPort:port];
        sleeper		= [[UMSleeper alloc]initFromFile:__FILE__ line:__LINE__ function:__func__];
        connections = [[NSMutableArray alloc] init];
        terminatedConnections = [[NSMutableArray alloc]init];
        lock		= [[NSLock alloc] init];
        sslLock     = [[NSLock alloc]init];
        name =  @"unnamed";
        receivePollTimeoutMs = 500;
        serverName = @"UMHTTPServer 1.0";
        enableSSL = doSSL;
        if(doSSL)
        {
            if(sslKeyFile)
            {
                [self setPrivateKeyFile:sslKeyFile];
            }
            if(sslCertFile)
            {
                [self setCertificateFile:sslCertFile];
            }
        }
    }
    return self;
}

- (NSString *)description
{
    NSMutableString *desc;
    
    desc = [[NSMutableString alloc] initWithString:@"UM HTTP server dump starts\n"];
    [desc appendFormat:@"server name was %@\n", serverName ? serverName : @"not set"];
    [desc appendFormat:@"listenerSocket was %@\n", listenerSocket ? listenerSocket : @"not set"];
    [desc appendFormat:@"connections were %@\n", connections ? connections : @"none"];
    [desc appendFormat:@"terminated connections were %@\n", terminatedConnections ? terminatedConnections : @"none"];
    [desc appendString:@"UM HTTP server dump ends\n"];
    return desc;
}

- (UMSocketError) start
{
	UMSocketError	sErr;
    logFeed.copyToConsole = 1;
    @autoreleasepool
    {
		if(status != UMHTTPServerStatus_notRunning)
		{
			[logFeed majorError:0 withText:[NSString stringWithFormat:@"HTTPServer '%@' on port %d failed to start because its already started",name, [listenerSocket requestedLocalPort]]];
			return UMSocketError_generic_error;
		}

		[logFeed info:0 withText:[NSString stringWithFormat:@"HTTPServer '%@' on port %d is starting up\r\n",name, [listenerSocket requestedLocalPort]]];
		[lock lock];

		status = UMHTTPServerStatus_startingUp;
        [self runSelectorInBackground:@selector(mainListener)
                           withObject:NULL
                                 file:__FILE__
                                 line:__LINE__
                             function:__func__];

 //       [NSThread detachNewThreadSelector:@selector(mainListener) toTarget:self withObject:nil];

		[sleeper reset];

		while(status == UMHTTPServerStatus_startingUp)
        {
			[sleeper sleep:100000];/* wait 100ms */
        }

	    if( status == UMHTTPServerStatus_running )
	    {
		    sErr = UMSocketError_no_error;
	    }
	    else
	    {
		    sErr = lastErr;
		    status = UMHTTPServerStatus_notRunning;
	    }
    
	    [lock unlock];
    
	    if( status == UMHTTPServerStatus_running)
	    {
		    [logFeed info:0 withText:[NSString stringWithFormat:@"HTTPServer '%@' on port %d is running\n",name, [listenerSocket requestedLocalPort]]];
	    }
	    else
	    {
		    [logFeed majorError:0 withText:[NSString stringWithFormat:@"HTTPServer '%@' on port %d failed to start due to '%@'\n",name, [listenerSocket requestedLocalPort] ,[UMSocket getSocketErrorString:sErr]]];
	    }
    }
	return sErr;
}

- (void) mainListener
{
	@autoreleasepool
    {
        ulib_set_thread_name(@"[UMHTTPServer mainListener]");
        /* performSelector will handle pool by itself */
		UMSocketError		sErr = 0, ret;
        
		listenerRunning = YES;
		sErr  = [listenerSocket bind];
		if(!sErr)
        {
			sErr  = [listenerSocket listen];
        }
		if(sErr == UMSocketError_no_error)
        {
			status = UMHTTPServerStatus_running;
        }
		else
		{
			lastErr = sErr;
			status = UMHTTPServerStatus_failed;
		}
        
        if([advertizeName length]>0)
        {
            listenerSocket.advertizeDomain=@"";
            listenerSocket.advertizeName=advertizeName;
            listenerSocket.advertizeType=@"_http._tcp";
            [listenerSocket publish];
        }
		[sleeper wakeUp];
		
		while(status == UMHTTPServerStatus_running)
		{
            @autoreleasepool
            {
                ret = [listenerSocket dataIsAvailable:receivePollTimeoutMs];
                if(ret == UMSocketError_has_data_and_hup)
                {
                    NSLog(@"  UMSocketError_has_data_and_hup");

                    /* we get HTTP request but nobody is there to read the answer so we ignore it */
                    ;
                }
                else if (ret == UMSocketError_has_data)
                {
                    /* we get new HTTP request */
                    UMSocket *clientSocket = [listenerSocket accept:&ret];
                    if(clientSocket)
                    {
                        clientSocket.useSSL=enableSSL;
                        clientSocket.serverSideKeyFilename  = privateKeyFile;
                        clientSocket.serverSideKeyData      = privateKeyFileData;
                        clientSocket.serverSideCertFilename = certFile;
                        clientSocket.serverSideCertData     = certFileData;
                        if ([self authorizeConnection:clientSocket] == UMHTTPServerAuthorize_successful)
                        {
                            
                            UMHTTPConnection *con = [[UMHTTPConnection alloc] initWithSocket:clientSocket server:self];
                            @synchronized(self)
                            {
                                [connections addObject:con];
                            }
                            
                            [con runSelectorInBackground:@selector(connectionListener)
                                              withObject:NULL
                                                    file:__FILE__
                                                    line:__LINE__
                                                function:__func__];
//                            [NSThread detachNewThreadSelector:@selector(connectionListener) toTarget:con withObject:nil];
						    con = nil;
                        }
					    else
					    {
						    [clientSocket close];
					    }
                    }
                }
                else if(ret == UMSocketError_no_data)
                {
                    ;
                }
                else
                {
                    lastErr = ret;
                    status = UMHTTPServerStatus_failed;
                }
            }
            
            
            /* maintenance work */
			while ([terminatedConnections count] > 0)
			{
 				@synchronized(self)
                {
                    UMHTTPConnection *con = [terminatedConnections objectAtIndex:0];
                    [con terminate];
                    [terminatedConnections removeObjectAtIndex:0];
				}
			}
		}
        
		status = UMHTTPServerStatus_shutDown;
        [listenerSocket unpublish];
		[listenerSocket close];
		listenerRunning = NO;
    }
}

-(UMHTTPServerAuthorizeResult) authorizeConnection:(UMSocket *)us
{
	if(authorizeConnectionDelegate)
    {
		if([authorizeConnectionDelegate respondsToSelector:@selector(httpAuthorizeConnection:)])
        {
			return [authorizeConnectionDelegate httpAuthorizeConnection:us];
        }
    }
	return UMHTTPServerAuthorize_successful;
}

- (void) stop
{
	[logFeed info:0 withText:[NSString stringWithFormat:@"HTTPServer '%@' on port %d is stopping\r\n",name, [listenerSocket requestedLocalPort]]];
    
    if((status !=UMHTTPServerStatus_running) && (listenerRunning!=YES))
    {
		return;
    }
	status = UMHTTPServerStatus_shuttingDown;
	while(status == UMHTTPServerStatus_shuttingDown)
	{
		[sleeper sleep:100]; /* wait 100ms */
	}
	status = UMHTTPServerStatus_notRunning;
    
    [logFeed info:0 withText:[NSString stringWithFormat:@"HTTPServer '%@' on port %d is stopped\r\n",name, [listenerSocket requestedLocalPort]]];
}


- (void)connectionDone:(UMHTTPConnection *)con
{
	@synchronized(self)
	{
        if(con)
        {
            [connections removeObject:con];
            [terminatedConnections addObject:con];
        }
	}
}

/* calling the delegates */

- (void) httpOptions:(UMHTTPRequest *)req
{
	if( [httpOptionsDelegate respondsToSelector:@selector(httpOptions:)] )
    {
		[httpOptionsDelegate httpOptions:req];
    }
	else
    {
		[self httpUnknownMethod:req];
    }
}

- (void) httpGet:(UMHTTPRequest *)req
{
    [req extractGetParams];
    
	if( [httpGetDelegate respondsToSelector:@selector(httpGet:)] )
    {
		[httpGetDelegate  httpGet:req];
    }
	else
    {
		[self httpGetPost:req];
    }
}

- (void) httpHead:(UMHTTPRequest *)req
{
    [req extractGetParams];
	if( [httpHeadDelegate respondsToSelector:@selector(httpHead:)] )
    {
		[httpHeadDelegate  httpHead:req];
    }
	else
    {
		[self httpUnknownMethod:req];
    }
}

- (void) httpPost:(UMHTTPRequest *)req
{
    [req extractPostParams];

	if( [httpPostDelegate respondsToSelector:@selector(httpPost:)] )
    {
		[httpPostDelegate  httpPost:req];
    }
	else
    {
        [self httpGetPost:req];
    }
}

- (void) httpPut:(UMHTTPRequest *)req
{
    [req extractPutParams];

	if( [httpPutDelegate respondsToSelector:@selector(httpPut:)] )
    {
		[httpPutDelegate  httpPut:req];
    }
	else
    {
		[self httpGetPost:req];
    }
}


- (void) httpDelete:(UMHTTPRequest *)req
{
	if( [httpDeleteDelegate respondsToSelector:@selector(httpDelete:)] )
    {
		[httpDeleteDelegate  httpDelete:req];
    }
	else
	{
        [self httpUnknownMethod:req];
    }
}

- (void) httpTrace:(UMHTTPRequest *)req
{
	if( [httpTraceDelegate respondsToSelector:@selector(httpTrace:)] )
    {	
        [httpTraceDelegate  httpTrace:req];
    }
    else
    {
        [self httpUnknownMethod:req];
    }
}

- (void) httpConnect:(UMHTTPRequest *)req
{
	if( [httpConnectDelegate respondsToSelector:@selector(httpConnect:)] )
    {
		[httpConnectDelegate  httpConnect:req];
    }
	else
	{
        [self httpUnknownMethod:req];
    }
}

- (void) httpGetPost:(UMHTTPRequest *)req
{
    UMHTTPPageHandler *handler = [getPostDict objectForKey:[req.url path]];
    if(handler)
    {
        [handler call:req];
    }
    else if( [httpGetPostDelegate respondsToSelector:@selector(httpGetPost:)] )
    {
        @try
        {
    		[httpGetPostDelegate  httpGetPost:req];
        }
        @catch(NSException *ex)
        {
            [req setResponsePlainText:ex.userInfo[@"sysmsg"]];
        }    
    }
	else
    {
        [self httpUnknownMethod:req];
    }
}

- (void) httpUnknownMethod:(UMHTTPRequest *) req;
{
    [req setNotFound];

    /*
     NSString ("HTTP/1.1 302 Found
Date: Mon, 29 Aug 2011 12:50:51 GMT
Server: Apache/2.2.19 (Unix) mod_ssl/2.2.19 OpenSSL/0.9.8r DAV/2 PHP/5.3.6 with Suhosin-Patch
Location: https:///
    Content-Length: 323
Connection: close
    Content-Type: text/html; charset=iso-8859-1
     */
}

- (void) addPageHandler:(UMHTTPPageHandler *)h
{
    [getPostDict setObject:h forKey:[h path]];
}

- (void) setPrivateKeyFile:(NSString *)filename
{
    privateKeyFile = filename;
    privateKeyFileData = [NSData dataWithContentsOfFile:filename];

}

- (void) setCertificateFile:(NSString *)filename
{
    certFile = filename;
    certFileData = [NSData dataWithContentsOfFile:filename];

}

- (UMHTTPAuthenticationStatus) httpAuthenticateRequest:(UMHTTPRequest *) req realm:(NSString **)realm
{
    if(authenticateRequestDelegate)
    {
        if([authenticateRequestDelegate respondsToSelector:@selector(httpAuthenticateRequest:realm:)])
        {
            return [authenticateRequestDelegate httpAuthenticateRequest:req realm:realm];
        }
    }
    return UMHTTP_AUTHENTICATION_STATUS_NOT_REQUESTED;
}
@end



