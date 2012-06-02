//
//  SCBMainWindowController.m
//  StarChatBrowser
//
//  Created by slightair on 12/06/02.
//  Copyright (c) 2012 slightair. All rights reserved.
//

#import "SCBMainWindowController.h"
#import "SCBGrowlClient.h"

@interface SCBMainWindowController ()

@end

@implementation SCBMainWindowController

@synthesize mainWebView = _mainWebView;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
        window.backgroundColor = [NSColor clearColor];
        [window setOpaque:NO];
    }
    
    return self;
}

- (void)display
{
    [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];    
    [self.window makeKeyAndOrderFront:self];
}

- (void)loadMainPage
{
    [_mainWebView setMainFrameURL:@"http://localhost:4567"];
    
    NSURL *baseURL = [NSURL URLWithString:@"http://localhost:4567"];
    SCBUserStreamClient *client = [[SCBUserStreamClient alloc] initWithBaseURL:baseURL username:@"foo"];
    [client setAuthorizationHeaderWithUsername:@"foo" password:@"bar"];
    client.delegate = self;
    [client start];
}

- (IBAction)didPressedQuitButton:(id)sender
{
    NSLog(@"huh...");
    [[NSApplication sharedApplication] terminate:self];
}

#pragma mark -
#pragma mark SCBUserStreamClientDelegate Methods

- (void)userStreamClient:(SCBUserStreamClient *)client didReceivedUserInfo:(NSDictionary *)userInfo
{
    if ([[userInfo objectForKey:@"type"] isEqualToString:@"message"]) {
        NSDictionary *message = [userInfo objectForKey:@"message"];
        NSString *title = [message objectForKey:@"channel_name"];
        NSString *description = [NSString stringWithFormat:@"%@: %@", [message objectForKey:@"user_name"], [message objectForKey:@"body"]];
        
        [[SCBGrowlClient sharedClient] notifyNewMessageWithTitle:title description:description context:nil];
    }
}

@end
