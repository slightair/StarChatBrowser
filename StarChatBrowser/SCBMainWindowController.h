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

@interface SCBMainWindowController : NSWindowController <SCBUserStreamClientDelegate>

- (void)prepare;
- (void)display;
- (void)loadMainPage:(NSString *)URLString;
- (IBAction)didPushedDisclosureButton:(id)sender;
- (IBAction)didSelectQuitItem:(id)sender;

@property (assign) IBOutlet WebView *mainWebView;
@property (assign) IBOutlet NSMenu *toolButtonActionMenu;

@end
