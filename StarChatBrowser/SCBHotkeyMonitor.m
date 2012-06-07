//
//  SCBHotkeyMonitor.m
//  StarChatBrowser
//
//  Created by  on 12/06/07.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SCBHotkeyMonitor.h"
#import <Carbon/Carbon.h>

static OSStatus hotKeyHandler(EventHandlerCallRef nextHandler, EventRef theEvent, void *userData);



@interface SCBHotkeyHandlerKeeper : NSObject{
    SCBHotkeyHandler _handler;
    EventHotKeyRef _hotkeyRef;
}

@property (nonatomic, strong) SCBHotkeyHandler handler;
@property (nonatomic, assign) EventHotKeyRef hotkeyRef;

- (id)initWithHandler:(SCBHotkeyHandler)handler;

@end

@interface SCBHotkeyMonitor()

@property (nonatomic, strong) NSMutableDictionary *hotkeyHandlers;

- (void)handleHotkeyForHotKeyID:(EventHotKeyID)hotkeyId;

@end

@implementation SCBHotkeyMonitor

@synthesize hotkeyHandlers = _hotkeyHandlers;

- (id)init {
    self = [super init];
    if (self) {
        self.hotkeyHandlers = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)dealloc {
    [self unregisterAllHotkeys];
    self.hotkeyHandlers = nil;
}

- (void)setup {
    EventTypeSpec eventTypeSpecList[] ={
        { kEventClassKeyboard, kEventHotKeyPressed }
    };
    
    InstallApplicationEventHandler(&hotKeyHandler, 
                                   GetEventTypeCount(eventTypeSpecList), 
                                   eventTypeSpecList, 
                                   (__bridge void*)self,
                                   NULL);
    
}

- (UInt32)registerHotkey:(UInt32)keyCode 
         modifierKeyCode:(UInt32)modifierKeyCode
                 handler:(SCBHotkeyHandler)handler {
    // どのキーが登録されているか。の管理がしずらい。というか、ブロックよりselector渡した方がわかりやすいような気もする
    SCBHotkeyHandlerKeeper *keeper = [[SCBHotkeyHandlerKeeper alloc] initWithHandler:handler];
    EventHotKeyID hotKeyID;
    hotKeyID.id = keyCode + modifierKeyCode;
    hotKeyID.signature = 'htky';
    EventHotKeyRef hotkeyRef = NULL;
    
    // GetEventMonitorTarget
    OSStatus res = RegisterEventHotKey(keyCode, modifierKeyCode, hotKeyID, GetApplicationEventTarget(), 0, &hotkeyRef);
    NSLog(@"RegisterEventHotKey result %d", res);
    keeper.hotkeyRef = hotkeyRef;
    [self.hotkeyHandlers setObject:keeper forKey:[NSNumber numberWithUnsignedInt:hotKeyID.id]];
    
    return hotKeyID.id;
}

- (void)unregisterAllHotkeys {
    for (NSNumber *key in self.hotkeyHandlers) {
        SCBHotkeyHandlerKeeper *keeper = [self.hotkeyHandlers objectForKey:key];
        UnregisterEventHotKey(keeper.hotkeyRef);
        keeper.hotkeyRef = NULL;
    }
    [self.hotkeyHandlers removeAllObjects];
}

- (void)handleHotkeyForHotKeyID:(EventHotKeyID)hotkeyId {
    NSNumber *key = [NSNumber numberWithUnsignedInt:hotkeyId.id];
    SCBHotkeyHandlerKeeper *keeper = [self.hotkeyHandlers objectForKey:key];
    if (keeper) {
        keeper.handler();
    }
}

@end

static OSStatus hotKeyHandler(EventHandlerCallRef nextHandler, EventRef theEvent, void *userData)
{
    
    EventHotKeyID hotKeyID;
    GetEventParameter(theEvent, kEventParamDirectObject, typeEventHotKeyID, NULL,
                      sizeof(hotKeyID), NULL, &hotKeyID);
    
    if (hotKeyID.signature == 'htky') {
        SCBHotkeyMonitor *me = (__bridge SCBHotkeyMonitor*)userData;
        [me handleHotkeyForHotKeyID:hotKeyID];
        
    }
    
    return noErr;
}

@implementation SCBHotkeyHandlerKeeper

@synthesize handler = _handler;
@synthesize hotkeyRef = _hotkeyRef;

- (id)initWithHandler:(SCBHotkeyHandler)handler {
    self = [super init];
    if (self) {
        self.handler = handler;
    }
    return self;
}

- (void)dealloc {
    self.handler = NULL;
    self.hotkeyRef = NULL;
}



@end