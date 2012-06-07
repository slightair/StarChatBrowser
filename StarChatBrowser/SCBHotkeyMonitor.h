//
//  SCBHotkeyMonitor.h
//  StarChatBrowser
//
//  Created by  on 12/06/07.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^SCBHotkeyHandler)(void);

@interface SCBHotkeyMonitor : NSObject

- (void)setup;

- (UInt32)registerHotkey:(UInt32)keyCode 
         modifierKeyCode:(UInt32)modifierKeyCode
                 handler:(SCBHotkeyHandler)handler;

- (void)unregisterAllHotkeys;

@end
