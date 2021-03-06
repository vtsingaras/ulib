//
//  UMLogHandler.m
//  ulib.framework
//
//  Copyright: © 2016 Andreas Fink (andreas@fink.org), Basel, Switzerland. All rights reserved.
//


#import "UMLogHandler.h"
#import "UMLogConsole.h"
#import "UMLogDestination.h"
#import "UMLogFile.h"


@implementation UMLogHandler

@synthesize	logDestinations;
@synthesize	console;
@synthesize	lock;

- (UMLogHandler *) init
{
    self = [super init];
    if(self)
    {
        logDestinations = [[NSMutableArray alloc] init];
        lock = [[NSLock alloc]init];
    }	return self;
}

- (UMLogHandler *)initWithConsole
{
    self = [super init];
    if(self)
    {
        logDestinations = [[NSMutableArray alloc] init];
        lock = [[NSLock alloc]init];
        console = [[UMLogConsole alloc] init];
        [self addLogDestination:console];
    }
	return self;
}

- (void) addLogDestination:(UMLogDestination *)dst
{
    [lock lock];
	[logDestinations addObject: dst];
    [lock unlock];
}

- (void) removeLogDestination:(UMLogDestination *)dst
{
	NSUInteger i;

    [lock lock];
	i = [logDestinations indexOfObject: dst];
	if (i == NSNotFound)
    {
		return;
    }
    [logDestinations removeObjectAtIndex:i];
    [lock unlock];
}

- (void) logAnEntry:(UMLogEntry *)logEntry
{	
	UMLogDestination *dst = nil;

	[lock lock];
	for ( dst in logDestinations )
	{
		[dst unlockedLogAnEntry:logEntry];
	}
	[lock unlock];
}

- (void) unlockedLogAnEntry:(UMLogEntry *)logEntry
{	
	UMLogDestination *dst;
    
	for ( dst in logDestinations )
	{
		[dst unlockedLogAnEntry:logEntry];
	}
}

- (void) log:(UMLogLevel) level section:(NSString *)section subsection:(NSString *)subsection name:(NSString *)name text:(NSString *)message errorCode:(int)err
{
	UMLogEntry *e;
	
	e = [[UMLogEntry alloc] init];
	[e setLevel: level];
	[e setSection: section];
	[e setSubsection: subsection];
	[e setName: name];
    [e setMessage: message];
	[e setErrorCode: err];
	[self logAnEntry:e];
}

- (NSString *)description
{
    NSMutableString *s = [[NSMutableString alloc]init];
    [s appendFormat:@"%@\n", [super description]];
    if(console)
    {
        [s appendFormat:@" Logs to Console: %@\n",[console oneLineDescription]];
    }

    UMLogDestination *logDestination;
    [lock lock];
    for(logDestination in logDestinations)
    {
        if(logDestination == console)
            continue;
        [s appendFormat:@" Logs to: %@\n", [logDestination oneLineDescription]];
    }
    [lock unlock];
    return s;
}

- (UMLogLevel)level
{
    UMLogLevel minLevel = UMLOG_PANIC;
    UMLogDestination *dst;
    
    for (dst in logDestinations)
    {
        if(dst.level < minLevel)
        {
            minLevel = dst.level;
        }
    }
    return dst.level;
}

@end
