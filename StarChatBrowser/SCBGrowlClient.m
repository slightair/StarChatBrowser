//
//  SCBGrowlClient.m
//  StarChatBrowser
//
//  Created by slightair on 12/06/02.
//  Copyright (c) 2012 slightair. All rights reserved.
//

#import "GCDSingleton.h"
#import "SCBGrowlClient.h"
#import "SCBConstants.h"

#define kGrowlNewMessageNotificationName @"NewMessageNotification"
#define kGrowlSystemEventNotificationName @"SystemEventNotification"

#define kGrowlClickContextKeyNotificationName @"ClickContextKeyNotificationName"
#define kGrowlClickContextKeyUserInfo @"ClickContextKeyUserInfo"

@interface SCBGrowlClient ()

@end

@implementation SCBGrowlClient

+ (id)sharedClient
{
    DEFINE_SHARED_INSTANCE_USING_BLOCK(^{
        return [[self alloc] init];
    });
}

- (id)init
{
    self = [super init];
    if (self) {
        [GrowlApplicationBridge setGrowlDelegate:self];
    }
    return self;
}

- (void)notifyNewMessageWithTitle:(NSString *)title
                      description:(NSString *)description
                         isSticky:(BOOL)isSticky
                         userInfo:(NSDictionary *)userInfo
{
    NSDictionary *clickContext = [NSDictionary dictionaryWithObjectsAndKeys:
                                  kGrowlNewMessageNotificationName, kGrowlClickContextKeyNotificationName,
                                  userInfo, kGrowlClickContextKeyUserInfo,
                                  nil];
    
    [GrowlApplicationBridge notifyWithTitle:title
                                description:description
                           notificationName:kGrowlNewMessageNotificationName
                                   iconData:nil
                                   priority:0
                                   isSticky:isSticky
                               clickContext:clickContext];
}

- (void)notifySystemEventWithTitle:(NSString *)title
                       description:(NSString *)description
                          isSticky:(BOOL)isSticky
{
    [GrowlApplicationBridge notifyWithTitle:title
                                description:description
                           notificationName:kGrowlSystemEventNotificationName
                                   iconData:nil
                                   priority:0
                                   isSticky:isSticky
                               clickContext:nil];
}

#pragma mark -
#pragma mark GrowlApplicationBridgeDelegate

- (NSDictionary *)registrationDictionaryForGrowl
{
    NSArray *notifications = [NSArray arrayWithObjects:
                              kGrowlNewMessageNotificationName,
                              kGrowlSystemEventNotificationName,
                              nil];
    
    return [NSDictionary dictionaryWithObjectsAndKeys:
            notifications, GROWL_NOTIFICATIONS_ALL,
            notifications, GROWL_NOTIFICATIONS_DEFAULT,
            nil];
}

- (void)growlNotificationWasClicked:(id)clickContext
{
    NSString *notificationName = [(NSDictionary *)clickContext objectForKey:kGrowlClickContextKeyNotificationName];
    NSDictionary *userInfo = [(NSDictionary *)clickContext objectForKey:kGrowlClickContextKeyUserInfo];
    
    if ([notificationName isEqualToString:kGrowlNewMessageNotificationName]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kSCBNotificationClickedGrowlNewMessageNotification
                                                            object:self
                                                          userInfo:userInfo];
    }
}

- (void)growlNotificationTimedOut:(id)clickContext
{
    
}

@end
