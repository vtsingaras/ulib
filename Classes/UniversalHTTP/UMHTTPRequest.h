//
//  UMHTTPRequest.h
//  UniversalHTTP
//
//  Created by Andreas Fink on 30.12.08.
//  Copyright: © 2016 Andreas Fink (andreas@fink.org), Basel, Switzerland. All rights reserved.
//


#import "UMObject.h"
#import "UMHTTPResponseCode.h"
#import "UMHTTPAuthenticationStatus.h"

#define DEFAULT_UMHTTP_SERVER_TIMEOUT       90

@class UMHTTPRequest;
@protocol UMHTTPRequest_TimeoutProtocol<NSObject>
- (void) httpRequestTimeout:(UMHTTPRequest *)req;
@end

@class UMHTTPConnection;
@class UMSleeper;
@class UMHTTPCookie;


/*!
 @class UMHTTPRequest
 @brief  UMHTTPRequest represents a single http page request.

 A UMHTTPRequest is passed to a delegate of a UMHTTPServer.
 params is filled with the params passed on the URL (get) or in the body (post)
 */

@interface UMHTTPRequest : UMObject
{
	UMHTTPConnection	*connection;
	NSString			*method;
	NSString			*protocolVersion;
    NSString			*connectionValue;
	NSString			*path;
	NSURL				*url;
	NSMutableDictionary	*requestHeaders;
	NSMutableDictionary	*responseHeaders;
	NSData				*requestData;
	NSData				*responseData;
	NSDictionary		*params;
	UMHTTPResponseCode	responseCode;
    UMHTTPAuthenticationStatus authenticationStatus;
    BOOL                awaitingCompletion; /* set to YES if data is returned later */
    UMSleeper           *sleeper;  /* wake up this sleeper once data is returned by calling resumePendingRequest */
    NSMutableDictionary *requestCookies;
    NSMutableDictionary *responseCookies;
    NSDate              *completionTimeout;
    NSString            *authUsername;
    NSString            *authPassword;
    
    id<UMHTTPRequest_TimeoutProtocol>    timeoutDelegate;

@private
//    CFHTTPMessageRef	request;
//    CFHTTPMessageRef	response;
}

@property (readwrite,strong) UMHTTPConnection			*connection;
//@property (readonly,assign) CFHTTPMessageRef			request;
//@property (readonly,assign) CFHTTPMessageRef			response;
@property (readwrite,strong) NSString					*protocolVersion;
@property (readwrite,strong) NSString					*connectionValue;
@property (readwrite,strong) NSString					*method;
@property (readwrite,strong) NSString					*path;
@property (readwrite,strong) NSURL						*url;
@property (readwrite,strong) NSMutableDictionary		*requestHeaders;
@property (readwrite,strong) NSMutableDictionary        *responseHeaders;
@property (readwrite,strong) NSData						*requestData;
@property (readwrite,strong) NSData						*responseData;
@property (readwrite,assign) UMHTTPResponseCode			responseCode;
@property (readwrite,assign) UMHTTPAuthenticationStatus authenticationStatus;
@property (readwrite,assign) BOOL                       awaitingCompletion;
@property (readwrite,strong) NSMutableDictionary        *requestCookies;
@property (readwrite,strong) NSMutableDictionary		*responseCookies;
@property (readonly,strong) NSDictionary               *params;
@property (readonly,strong) id<UMHTTPRequest_TimeoutProtocol>    timeoutDelegate;
@property (readwrite,strong) NSString            *authUsername;
@property (readwrite,strong) NSString            *authPassword;



//- (id) initWithRequest:(CFHTTPMessageRef)req connection:(UMHTTPConnection *)conn;
- (id) init;
- (UMHTTPConnection *) connection;
//- (void) setResponse:(CFHTTPMessageRef)value;
- (void) setNotFound;
- (void) setRequireAuthentication;
- (void) extractGetParams;
- (void) extractPutParams;
- (void) extractPostParams;
- (void) extractParams:(NSString *)query;
- (NSString *)responseCodeAsString;
- (void) setRequestHeader:(NSString *)s withValue:(NSString *)value;
- (void) setRequestHeadersFromArray:(NSMutableArray *)array;
- (void) removeRequestHeader:(NSString *)s;
- (void) setResponseHeader:(NSString *)s withValue:(NSString *)value;
- (NSData *)extractResponseHeader;
- (NSData *)extractResponse;
- (void) setResponsePlainText:(NSString *)content;
- (void) setResponseHtmlString:(NSString *)content;
- (void) setResponseCssString:(NSString *)content;
- (void) setResponseJsonString:(NSString *)content;
- (void) setResponseJsonObject:(id)content;
- (void)setNotAuthorizedForRealm:(NSString *)realm;
- (void)setContentType:(NSString *)ct;
- (NSString *)description;
- (NSString *)authenticationStatusAsString;
- (NSMutableDictionary *)paramsMutableCopy;
- (void)setResponseTypeText;
- (void)setResponseTypeHtml;
- (void)setResponseTypeCss;
- (void)setResponseTypePng;
- (void)setResponseTypeJpeg;
- (void)setResponseTypeGif;
- (void)setResponseTypeJson;

- (void)setCookie:(NSString *)cookieName withValue:(NSString *)value;
- (void)setCookie:(NSString *)cookieName withValue:(NSString *)value forPath:(NSString *)path;
- (void)setCookie:(NSString *)cookieName withValue:(NSString *)value forPath:(NSString *)p expires:(NSDate *)expDate;
- (UMHTTPCookie *)getCookie:(NSString *)name;
- (void)makeAsync;
- (void)makeAsyncWithTimeout:(NSTimeInterval)timeoutInSeconds;
- (void)resumePendingRequest;
- (void)sleepUntilCompleted;
- (void)redirect:(NSString *)newPath;
- (void)setRequestCookie:(UMHTTPCookie *)cookie;
- (void)setResponseCookie:(UMHTTPCookie *)cookie;
@end
