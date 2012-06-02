//
//  SCBAppDelegate.h
//  StarChatBrowser
//
//  Created by slightair on 12/06/02.
//  Copyright (c) 2012 slightair. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SCBMainWindowController.h"

@interface SCBAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet SCBMainWindowController *windowController;

@end
