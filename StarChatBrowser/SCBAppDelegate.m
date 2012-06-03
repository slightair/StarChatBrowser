//
//  SCBAppDelegate.m
//  StarChatBrowser
//
//  Created by slightair on 12/06/02.
//  Copyright (c) 2012 slightair. All rights reserved.
//

#import "SCBAppDelegate.h"
#import "SCBGrowlClient.h"

@interface SCBAppDelegate ()

@property (strong) NSStatusItem *statusItem;

@end

@implementation SCBAppDelegate
{
    NSStatusItem *_statusItem;
}

@synthesize windowController = _windowController;
@synthesize statusItem = _statusItem;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    NSStatusBar *statusBar = [NSStatusBar systemStatusBar];
    NSStatusItem *statusItem = [statusBar statusItemWithLength:NSSquareStatusItemLength];
    statusItem.title = @"★";
    statusItem.highlightMode = YES;
    statusItem.action = @selector(didClickedStatusItem:);
    
    self.statusItem = statusItem;
    
    [self.windowController prepare];
    [self.windowController loadMainPage:@"http://localhost:4567"];
}

- (void)didClickedStatusItem:(id)sender
{
    NSLog(@"huh...");
    [self.windowController display];
}

@end
