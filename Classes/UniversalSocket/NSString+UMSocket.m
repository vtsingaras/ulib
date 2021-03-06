//
//  NSString+UMSocket.m
//  ulib
//
//  Copyright: © 2016 Andreas Fink (andreas@fink.org), Basel, Switzerland. All rights reserved.
//
//

#import "NSString+UMSocket.h"
#include <arpa/inet.h>

@implementation NSString(UMSocket)

- (BOOL)isIPv4
{
    struct in_addr addr4;
    
    int result = inet_pton(AF_INET,self.UTF8String, &addr4);
    if(result==0)
    {
        return NO;
    }
    return YES;
}

- (BOOL)isIPv6
{
    struct in6_addr addr6;

    int result = inet_pton(AF_INET6,self.UTF8String, &addr6);
    if(result==0)
    {
        return NO;
    }
    return YES;
}

@end
