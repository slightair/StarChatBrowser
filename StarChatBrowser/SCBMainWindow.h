//
//  SCBMainWindow.h
//  StarChatBrowser
//
//  Created by slightair on 12/06/02.
//  Copyright (c) 2012 slightair. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SCBMainWindow : NSPanel <NSAnimationDelegate>

- (void)show;
- (void)hide;

@property (assign) IBOutlet NSMenu *toolButtonActionMenu;

@end
