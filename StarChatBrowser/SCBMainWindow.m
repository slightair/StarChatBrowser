//
//  SCBMainWindow.m
//  StarChatBrowser
//
//  Created by slightair on 12/06/02.
//  Copyright (c) 2012 slightair. All rights reserved.
//

#import "SCBMainWindow.h"

@implementation SCBMainWindow

- (BOOL)canBecomeKeyWindow
{
    return YES;
}

- (void)mouseDown:(NSEvent *)theEvent
{
    NSPoint origin = [self frame].origin;
    NSPoint oldPosition = [self convertBaseToScreen:[theEvent locationInWindow]];
    while ((theEvent = [self nextEventMatchingMask:NSLeftMouseDraggedMask|NSLeftMouseUpMask]) && ([theEvent type] != NSLeftMouseUp)) {
        NSPoint newPosition = [self convertBaseToScreen:[theEvent locationInWindow]];
        origin.x += newPosition.x - oldPosition.x;
        origin.y += newPosition.y - oldPosition.y;
        [self setFrameOrigin:origin];
        oldPosition = newPosition;
    }
}

@end

