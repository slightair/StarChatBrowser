//
//  SCBMainWindow.m
//  StarChatBrowser
//
//  Created by slightair on 12/06/02.
//  Copyright (c) 2012 slightair. All rights reserved.
//

#import "SCBMainWindow.h"

#define kWindowAnimationDuration 0.25

@implementation SCBMainWindow

@synthesize toolButtonActionMenu = _toolButtonActionMenu;

- (void)show
{
    if (self.isVisible) {
        self.alphaValue = 0.0;
    }
    
    NSDictionary *animationSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                       self, NSViewAnimationTargetKey,
                                       NSViewAnimationFadeInEffect, NSViewAnimationEffectKey,
                                       nil];
    NSViewAnimation *animation = [[NSViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObject:animationSettings]];
    animation.duration = kWindowAnimationDuration;
    animation.animationCurve = NSAnimationEaseIn;
    animation.delegate = self;
    
    [animation startAnimation];
}

- (void)hide
{
    if (self.isVisible) {
        self.alphaValue = 1.0;
    }
    
    NSDictionary *animationSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                       self, NSViewAnimationTargetKey,
                                       NSViewAnimationFadeOutEffect, NSViewAnimationEffectKey,
                                       nil];
    NSViewAnimation *animation = [[NSViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObject:animationSettings]];
    animation.duration = kWindowAnimationDuration;
    animation.animationCurve = NSAnimationEaseIn;
    animation.delegate = self;
    
    [animation startAnimation];
}

- (void)close
{
    [self hide];
}

- (void)animationDidEnd:(NSAnimation *)animation
{
    if (self.alphaValue == 0.0) {
        self.isVisible = NO;
    }
}

- (BOOL)canBecomeKeyWindow
{
    return YES;
}

- (BOOL)performKeyEquivalent:(NSEvent *)theEvent
{
    BOOL isMatchKeyEquivalent = [super performKeyEquivalent:theEvent];
    if (isMatchKeyEquivalent) {
        return isMatchKeyEquivalent;
    }
    
    return [self.toolButtonActionMenu performKeyEquivalent:theEvent];
}

@end

