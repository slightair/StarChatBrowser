//
//  SCBAppDelegate.m
//  StarChatBrowser
//
//  Created by slightair on 12/06/02.
//  Copyright (c) 2012 slightair. All rights reserved.
//

#import "SCBAppDelegate.h"
#import "SCBGrowlClient.h"
#import "SCBConstants.h"
#import "SCBHotkeyMonitor.h"
#import <Carbon/Carbon.h>

@interface SCBAppDelegate ()

@property (strong) NSStatusItem *statusItem;
@property (strong) SCBHotkeyMonitor *hotkeyMonitor;

@end

@implementation SCBAppDelegate
{
    NSStatusItem *_statusItem;
}

@synthesize windowController = _windowController;
@synthesize statusItem = _statusItem;
@synthesize hotkeyMonitor = _hotkeyMonitor;

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
    
    self.hotkeyMonitor = [[SCBHotkeyMonitor alloc] init];
    [self.hotkeyMonitor setup];
    [self.hotkeyMonitor registerHotkey:kVK_ANSI_S 
                       modifierKeyCode:controlKey 
                               handler:^{
                                   [self.windowController toggleDisplayStatus];
                               }
     ];
    
    
    
    NSString *starchatServerURLString = [[NSUserDefaults standardUserDefaults] objectForKey:kUserSettingsStarChatServerURL];
    BOOL enableLoadingAtStartup = [[[NSUserDefaults standardUserDefaults] objectForKey:kUserSettingsEnableLoadingAtStartup] boolValue];
    
    if (starchatServerURLString && enableLoadingAtStartup) {
        [self.windowController loadMainPage:starchatServerURLString];
    }
    else {
        [self.windowController showPreferences];
    }
}

- (void)applicationWillResignActive:(NSNotification *)notification
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL isKeepWindowOnTop = [[userDefaults valueForKey:kUserSettingsKeepWindowOnTop] boolValue];
    
    if (!isKeepWindowOnTop) {
        [self.windowController hideWindow];
    }
}

- (void)didClickedStatusItem:(id)sender
{
    [self.windowController toggleDisplayStatus];
}

- (void)applicationWillTerminate:(NSNotification *)notification {
    [self.hotkeyMonitor unregisterAllHotkeys];
}

@end
