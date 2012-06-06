//
//  SCBPreferencesWindowController.h
//  StarChatBrowser
//
//  Created by slightair on 12/06/07.
//  Copyright (c) 2012 slightair. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SCBPreferencesWindowController : NSWindowController

- (IBAction)didPressedLoadButton:(id)sender;
- (IBAction)didPressedLoadingAtStartupCheckButton:(id)sender;

@property (assign) IBOutlet NSTextField *serverURLTextField;
@property (assign) IBOutlet NSButton *loadingAtStartupCheckButton;

@end
