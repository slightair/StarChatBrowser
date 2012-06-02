//
//  SCBGrowlClient.m
//  StarChatBrowser
//
//  Created by slightair on 12/06/02.
//  Copyright (c) 2012 slightair. All rights reserved.
//

#import "GCDSingleton.h"
#import "SCBGrowlClient.h"

#define kGrowlNewMessageNotificationName @"NewMessageNotification"

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

- (void)notifyNewMessageWithTitle:(NSString *)title description:(NSString *)description context:(id)context
{
    [GrowlApplicationBridge notifyWithTitle:title
                                description:description
                           notificationName:kGrowlNewMessageNotificationName
                                   iconData:nil
                                   priority:0
                                   isSticky:NO
                               clickContext:context];
}

#pragma mark -
#pragma mark GrowlApplicationBridgeDelegate

- (NSDictionary *)registrationDictionaryForGrowl
{
    NSArray *notifications = [NSArray arrayWithObjects:
                              kGrowlNewMessageNotificationName,
                              nil];
    
    return [NSDictionary dictionaryWithObjectsAndKeys:
            notifications, GROWL_NOTIFICATIONS_ALL,
            notifications, GROWL_NOTIFICATIONS_DEFAULT,
            nil];
}

- (void)growlNotificationWasClicked:(id)clickContext
{
    
}

- (void)growlNotificationTimedOut:(id)clickContext
{
    
}

@end
