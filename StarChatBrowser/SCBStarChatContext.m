//
//  SCBStarChatContext.m
//  StarChatBrowser
//
//  Created by slightair on 12/06/25.
//  Copyright (c) 2012 slightair. All rights reserved.
//

#import "SCBStarChatContext.h"
#import "SCBGrowlClient.h"
#import "CLVStarChatAPIClient.h"

@interface SCBStarChatContext ()

@property (strong) NSString *userName;
@property (strong) CLVStarChatAPIClient *apiClient;
@property (strong, readwrite) SCBUserStreamClient *userStreamClient;

@end

@implementation SCBStarChatContext

@synthesize baseURL = _baseURL;
@synthesize userName = _userName;
@synthesize apiClient = _apiClient;
@synthesize userStreamClient = _userStreamClient;

- (void)setBaseURL:(NSURL *)baseURL
{
    self.apiClient = [[CLVStarChatAPIClient alloc] initWithBaseURL:baseURL];
    
    [self.userStreamClient stop];
    self.userStreamClient = [[SCBUserStreamClient alloc] initWithBaseURL:baseURL];
}

- (void)setUserName:(NSString *)userName andPassword:(NSString *)password
{
    self.userName = userName;
    
    if ([self.apiClient.userName isEqualToString:userName]) {
        [self.apiClient setAuthorizationHeaderWithUsername:userName password:password];
    }
    
    if (![self.userStreamClient.userName isEqualToString:userName]) {
        [self.userStreamClient stop];
        [self.userStreamClient setAuthorizationHeaderWithUsername:userName password:password];
    }
}

- (void)receivedPacket:(NSDictionary *)packet
{
    if ([[packet objectForKey:@"type"] isEqualToString:@"message"]) {
        NSDictionary *message = [packet objectForKey:@"message"];
        
        if ([[message objectForKey:@"user_name"] isEqualToString:self.userName]) {
            return;
        }
        
        NSString *title = [message objectForKey:@"channel_name"];
        NSString *description = [NSString stringWithFormat:@"%@: %@", [message objectForKey:@"user_name"], [message objectForKey:@"body"]];
        
        [[SCBGrowlClient sharedClient] notifyNewMessageWithTitle:title description:description userInfo:packet];
    }
}

@end
