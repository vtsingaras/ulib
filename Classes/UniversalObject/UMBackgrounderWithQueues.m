//
//  UMBackgrounderWithQueues.m
//  ulib
//
//  Copyright: © 2016 Andreas Fink (andreas@fink.org), Basel, Switzerland. All rights reserved.
//
//

#import "UMBackgrounderWithQueues.h"
#import "UMQueue.h"
#import "UMLock.h"
#import "UMTask.h"
#import "UMSleeper.h"


@implementation UMBackgrounderWithQueues

@synthesize queues;

- (UMBackgrounderWithQueues *)init
{
    self = [super init];
    if(self)
    {
        queue = [[UMQueue alloc]init];
        sharedQueue = NO;
    }
    return self;
}


- (UMBackgrounderWithQueues *)initWithSharedQueues:(NSArray *)q
                                              name:(NSString *)n
                                       workSleeper:(UMSleeper *)ws;
{
    self = [super initWithName:n workSleeper:ws];
    if(self)
    {
        self.queues = q;
    }
    return self;
}

- (void)backgroundInit
{
    ulib_set_thread_name([NSString stringWithFormat:@"%@ (idle)",self.name]);
}

- (void)backgroundExit
{
    ulib_set_thread_name([NSString stringWithFormat:@"%@ (terminating)",self.name]);
}

- (int)work
{
    @autoreleasepool
    {
        NSUInteger n = [queues count];
        NSUInteger i;
        for(i=0;i<n;i++)
        {
            UMTask *task = NULL;
            @synchronized(queues)
            {
                [readLock lock];
                UMQueue *thisQueue = [queues objectAtIndex:i];
                task = [thisQueue getFirst];
                [readLock unlock];
            }
            if(task)
            {
                @synchronized(task)
                {
                    if(enableLogging)
                    {
                        NSLog(@"%@: got task %@ on queue %d",self.name,task,(int)i);
                    }
                    @autoreleasepool
                    {
                        [task runOnBackgrounder:self];
                    }
                }
                ulib_set_thread_name([NSString stringWithFormat:@"%@ (idle)",self.name]);
                return 1;
            }
        }
    }
    return 0;
}
@end
