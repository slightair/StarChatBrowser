//
//  SCBUserStreamClient.h
//  StarChatBrowser
//
//  Created by slightair on 12/06/02.
//  Copyright (c) 2012 slightair. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPClient.h"
#import "SBJson.h"

typedef enum {
    kSCBUserStreamClientConnectionStatusNone,
    kSCBUserStreamClientConnectionStatusConnecting,
    kSCBUserStreamClientConnectionStatusConnected,
    kSCBUserStreamClientConnectionStatusDisconnected
} SCBUserStreamClientConnectionStatus;

@class SCBUserStreamClient;

@protocol SCBUserStreamClientDelegate <NSObject>
- (void)userStreamClient:(SCBUserStreamClient *)client didReceivedUserInfo:(NSDictionary *)userInfo;
@optional
- (void)userStreamClientDidConnected:(SCBUserStreamClient *)client;
- (void)userStreamClientDidDisconnected:(SCBUserStreamClient *)client;
@end

@interface SCBUserStreamClient : AFHTTPClient <NSURLConnectionDelegate, SBJsonStreamParserAdapterDelegate>

- (id)initWithBaseURL:(NSURL *)url username:(NSString *)username;
- (void)start;

@property (assign) id <SCBUserStreamClientDelegate> delegate;
@property (readonly) SCBUserStreamClientConnectionStatus connectionStatus;

@end
