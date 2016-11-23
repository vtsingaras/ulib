//
//  UMHTTPClientRequest.h
//  ulib
//
//  Created by Andreas Fink on 23.11.16.
//  Copyright © 2016 Andreas Fink. All rights reserved.
//

#import <ulib/ulib.h>

@class UMHTTPClient;

@interface UMHTTPClientRequest : UMObject
{
    NSURLRequest *theRequest;
    NSString *urlString;
    NSURL *url;
    UMHTTPClient *client;
    id  delegate;
    NSURLConnection *urlCon;
}
@property(readwrite,strong) NSURLRequest *theRequest;
@property(readwrite,strong) NSString *urlString;
@property(readwrite,strong) NSURL *url;
@property(readwrite,strong) UMHTTPClient *client;
@property(readwrite,strong) id delegate;
@property(readwrite,strong) NSURLConnection *urlCon;

- (UMHTTPClientRequest *)initWithURLString:(NSString *)urls
                                withChache:(BOOL)cache
                                   timeout:(NSTimeInterval) timeout;

@end
