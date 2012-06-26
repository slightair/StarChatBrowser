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
#import "SCBConstants.h"

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
    self.userStreamClient.delegate = self;
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

- (void)startUserStreamClient
{
    [self.userStreamClient start];
}

- (void)stopUserStreamClient
{
    [self.userStreamClient stop];
}

#pragma mark -
#pragma mark SCBUserStreamClientDelegate Methods

- (void)userStreamClient:(SCBUserStreamClient *)client didReceivedPacket:(NSDictionary *)packet
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

- (void)userStreamClientWillConnect:(SCBUserStreamClient *)client
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kSCBNotificationUserStreamClientWillConnect
                                                        object:self];
}

- (void)userStreamClientDidConnected:(SCBUserStreamClient *)client
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kSCBNotificationUserStreamClientDidConnected
                                                        object:self];
}

- (void)userStreamClientDidDisconnected:(SCBUserStreamClient *)client
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kSCBNotificationUserStreamClientDidDisconnected
                                                        object:self];}

- (void)userStreamClient:(SCBUserStreamClient *)client didFailWithError:(NSError *)error
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kSCBNotificationUserStreamClientDidFail
                                                        object:self
                                                      userInfo:[NSDictionary dictionaryWithObject:error forKey:@"error"]];
}

@end
