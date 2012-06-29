//
//  SCBMainWindowController.h
//  StarChatBrowser
//
//  Created by slightair on 12/06/02.
//  Copyright (c) 2012 slightair. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "SCBUserStreamClient.h"

@interface SCBMainWindowController : NSWindowController

- (void)prepare;
- (void)showWindow;
- (void)hideWindow;
- (void)toggleDisplayStatus;
- (void)loadMainPage:(NSString *)urlString;
- (void)showPreferences;
- (IBAction)didPushedRefreshButton:(id)sender;
- (IBAction)didPushedActionButton:(id)sender;
- (IBAction)didPushedStreamAPIStatusButton:(id)sender;
- (IBAction)didSelectPreferencesItem:(id)sender;
- (IBAction)didSelectKeepWindowOnTopItem:(id)sender;
- (IBAction)didSelectQuitItem:(id)sender;

@property (assign) IBOutlet WebView *mainWebView;
@property (assign) IBOutlet NSMenu *toolButtonActionMenu;
@property (assign) IBOutlet NSButton *streamAPIStatusButton;

@end
