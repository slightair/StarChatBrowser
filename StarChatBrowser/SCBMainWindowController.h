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

- (void)display;
- (void)loadMainPage;
- (IBAction)didPressedQuitButton:(id)sender;

@property (assign) IBOutlet WebView *mainWebView;

@end
