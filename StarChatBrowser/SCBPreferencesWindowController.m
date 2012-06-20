//
//  SCBPreferencesWindowController.m
//  StarChatBrowser
//
//  Created by slightair on 12/06/07.
//  Copyright (c) 2012 slightair. All rights reserved.
//

#import "SCBPreferencesWindowController.h"
#import "SCBAppDelegate.h"
#import "SCBMainWindowController.h"
#import "SCBConstants.h"

enum TabViewItemIndexes {
    TabViewItemIndexGeneral = 0,
    TabViewItemIndexAbout,
};

@interface SCBPreferencesWindowController ()

@end

@implementation SCBPreferencesWindowController

@synthesize serverURLTextField = _serverURLTextField;
@synthesize loadingAtStartupCheckButton = _loadingAtStartupCheckButton;
@synthesize tabView = _tabView;
@synthesize toolbar = _toolbar;
@synthesize versionLabel = _versionLabel;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
    self.toolbar.selectedItemIdentifier = @"General";
    
    NSDictionary *bundleInfoDictionary = [[NSBundle mainBundle] infoDictionary];
    self.versionLabel.stringValue = [NSString stringWithFormat:@"%@ (%@)",
                                     [bundleInfoDictionary objectForKey:@"CFBundleShortVersionString"],
                                     [bundleInfoDictionary objectForKey:@"CFBundleVersion"]];
    
    NSString *serverURLString = [[NSUserDefaults standardUserDefaults] objectForKey:kUserSettingsStarChatServerURL];
    BOOL enableLoadingAtStartup = [[[NSUserDefaults standardUserDefaults] objectForKey:kUserSettingsEnableLoadingAtStartup] boolValue];
    
    if (serverURLString) {
        self.serverURLTextField.stringValue = serverURLString;
    }
    
    self.loadingAtStartupCheckButton.state = enableLoadingAtStartup ? NSOnState : NSOffState;
}

- (void)didPressedLoadButton:(id)sender
{
    SCBAppDelegate *appDelegate = [NSApplication sharedApplication].delegate;
    SCBMainWindowController *mainWindowController = appDelegate.windowController;
    
    NSString *serverURL = self.serverURLTextField.stringValue;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:serverURL forKey:kUserSettingsStarChatServerURL];
    [userDefaults synchronize];
    
    [mainWindowController loadMainPage:serverURL];
    [self.window close];
}

- (void)didPressedLoadingAtStartupCheckButton:(id)sender
{
    BOOL isOn = ((NSButton *)sender).state == NSOnState ? YES : NO;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:isOn forKey:kUserSettingsEnableLoadingAtStartup];
    [userDefaults synchronize];
}

- (void)didSelectToolbarItem:(id)sender
{
    NSString *identifier = [sender itemIdentifier];
    
    if ([identifier isEqualToString:@"General"]) {
        [self.tabView selectTabViewItemAtIndex:TabViewItemIndexGeneral];
    }
    else if ([identifier isEqualToString:@"About"]) {
        [self.tabView selectTabViewItemAtIndex:TabViewItemIndexAbout];
    }
}

@end
