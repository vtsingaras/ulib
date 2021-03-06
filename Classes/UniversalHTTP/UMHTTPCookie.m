//
//  UMHTTPCookie.m
//  ulib
//
//  Copyright: © 2016 Andreas Fink (andreas@fink.org), Basel, Switzerland. All rights reserved.
//

#import "UMHTTPCookie.h"

@implementation UMHTTPCookie

@synthesize name;
@synthesize value;
@synthesize expiration;
@synthesize version;
@synthesize path;
@synthesize domain;
@synthesize maxage;
@synthesize secure;
@synthesize comment;

- (UMHTTPCookie *)init
{
    self = [super init];
    if(self)
    {
        self.expiration = [NSDate dateWithTimeIntervalSinceNow: (60*60*24*7)];
    }
    return self;
}
- (NSString *)raw
{
    return raw;
}


-(void)setRaw:(NSString *)newRaw;
{
    raw = newRaw;
 
    BOOL first=YES;
    NSArray *items = [raw componentsSeparatedByString:@";"];
	for (NSString *itemString in items)
	{
		NSArray *item  = [itemString componentsSeparatedByString:@"="];
        if ([item count] == 2)
        {
		    NSString *tag = [item objectAtIndex:0];
		    NSString *val = [item objectAtIndex:1];
            if(first)
            {
                self.name=tag;
                self.value=val;
                first=NO;
            }
            else
            {
                if([tag isEqualToString:@"Domain" ])
                {
                    self.domain = value;
                }
                else if([tag isEqualToString:@"Path" ])
                {
                    self.path = val;
                }
                else if([tag isEqualToString:@"Version" ])
                {
                    self.version = val;
                }
                else if([tag isEqualToString:@"Max-Age" ])
                {
                    self.maxage = val;
                }
                else if([tag isEqualToString:@"Secure" ])
                {
                    self.secure = val;
                }
                else if([tag isEqualToString:@"Comment" ])
                {
                    self.comment = val;
                }
            }
        }
	}
}

@end


/*

The syntax for the Set-Cookie response header is

set-cookie      =       "Set-Cookie:" cookies
cookies         =       1#cookie
cookie          =       NAME "=" VALUE *(";" cookie-av)
NAME            =       attr
VALUE           =       value
cookie-av       =       "Comment" "=" value
|       "Domain" "=" value
|       "Max-Age" "=" value
|       "Path" "=" value
|       "Secure"
|       "Version" "=" 1*DIGIT

 
 
 
 
 
 av-pairs        =       av-pair *(";" av-pair)
 av-pair         =       attr ["=" value]        ; optional value
 attr            =       token
 value           =       word
 word            =       token | quoted-string
 

*/
