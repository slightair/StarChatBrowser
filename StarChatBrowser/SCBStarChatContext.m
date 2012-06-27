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

- (void)reloadInfo;

@property (strong) NSString *userName;
@property (strong) CLVStarChatAPIClient *apiClient;
@property (strong, readwrite) SCBUserStreamClient *userStreamClient;
@property (strong) NSMutableArray *subscribedChannels;
@property (strong) NSMutableDictionary *nickDictionary;
@property (strong) NSMutableArray *keywords;

@end

@implementation SCBStarChatContext

@synthesize baseURL = _baseURL;
@synthesize userName = _userName;
@synthesize apiClient = _apiClient;
@synthesize userStreamClient = _userStreamClient;
@synthesize subscribedChannels = _subscribedChannels;
@synthesize nickDictionary = _nickDictionary;
@synthesize keywords = _keywords;

- (void)setBaseURL:(NSURL *)baseURL
{
    self.subscribedChannels = [NSMutableArray array];
    self.nickDictionary = [NSMutableDictionary dictionary];
    self.keywords = [NSMutableArray array];
    
    self.apiClient = [[CLVStarChatAPIClient alloc] initWithBaseURL:baseURL];
    
    [self.userStreamClient stop];
    self.userStreamClient = [[SCBUserStreamClient alloc] initWithBaseURL:baseURL];
    self.userStreamClient.delegate = self;
}

- (void)setUserName:(NSString *)userName andPassword:(NSString *)password
{
    self.userName = userName;
    
    if (![self.apiClient.userName isEqualToString:userName]) {
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

- (void)reloadInfo
{
    self.nickDictionary = [NSMutableDictionary dictionary];
    self.keywords = nil;
    
    [self.apiClient subscribedChannels:^(NSArray *channels){
        self.subscribedChannels = [NSMutableArray arrayWithArray:channels];
        
        dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_source_t source = dispatch_source_create(DISPATCH_SOURCE_TYPE_DATA_ADD, 0, 0, globalQueue);
        
        __block NSInteger complete = 0;
        dispatch_source_set_event_handler(source, ^{
            complete += dispatch_source_get_data(source);
            if (complete == [channels count]) {
                dispatch_source_cancel(source);
            }
        });
        
        dispatch_source_set_cancel_handler(source, ^{
            dispatch_release(source);
        });
        
        for (CLVStarChatChannelInfo *channel in channels) {
            [self.apiClient usersForChannel:channel.name
                                 completion:^(NSArray *users){
                                     for (CLVStarChatUserInfo *user in users) {
                                         if ([user.name isEqualToString:self.userName] && !self.keywords) {
                                             self.keywords = [NSMutableArray arrayWithArray:user.keywords];
                                         }
                                         [self.nickDictionary setObject:user.nick forKey:user.name];
                                     }
                                     dispatch_source_merge_data(source, 1);
                                 }
                                    failure:^(NSError *error){
                                        NSLog(@"%@", [error localizedDescription]);
                                    }];
        }
        
        dispatch_resume(source);
    }
                               failure:^(NSError *error){
                                   NSLog(@"%@", [error localizedDescription]);
                               }];
}

#pragma mark -
#pragma mark SCBUserStreamClientDelegate Methods

- (void)userStreamClient:(SCBUserStreamClient *)client didReceivedPacket:(NSDictionary *)packet
{
    if ([[packet objectForKey:@"type"] isEqualToString:@"message"]) {
        CLVStarChatMessageInfo *message = [CLVStarChatMessageInfo messageInfoWithDictionary:[packet objectForKey:@"message"]];
        
        if ([message.userName isEqualToString:self.userName]) {
            return;
        }
        
        NSString *nick = [self.nickDictionary objectForKey:message.userName];
        if (message.temporaryNick) {
            nick = message.temporaryNick;
        }
        
        [[SCBGrowlClient sharedClient] notifyNewMessageWithTitle:message.channelName
                                                     description:[NSString stringWithFormat:@"%@: %@", nick, message.body]
                                                        userInfo:packet];
    }
}

- (void)userStreamClientWillConnect:(SCBUserStreamClient *)client
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kSCBNotificationUserStreamClientWillConnect
                                                        object:self];
}

- (void)userStreamClientDidConnected:(SCBUserStreamClient *)client
{
    [self reloadInfo];
    
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
