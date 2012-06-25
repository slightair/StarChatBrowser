//
//  SCBStarChatContext.h
//  StarChatBrowser
//
//  Created by slightair on 12/06/25.
//  Copyright (c) 2012 slightair. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCBUserStreamClient.h"

@interface SCBStarChatContext : NSObject

- (void)receivedPacket:(NSDictionary *)packet;
- (void)setUserName:(NSString *)userName andPassword:(NSString *)password;

@property (nonatomic, strong) NSURL *baseURL;
@property (strong, readonly) NSString *userName;
@property (strong, readonly) SCBUserStreamClient *userStreamClient;

@end
