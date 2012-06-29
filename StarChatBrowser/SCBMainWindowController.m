//
//  SCBMainWindowController.m
//  StarChatBrowser
//
//  Created by slightair on 12/06/02.
//  Copyright (c) 2012 slightair. All rights reserved.
//

#import "SCBMainWindowController.h"
#import "SCBMainWindow.h"
#import "SCBConstants.h"
#import "SCBPreferencesWindowController.h"
#import "SCBStarChatContext.h"
#import "SCBGrowlClient.h"
#import "NSData+Base64.h"

@interface SCBMainWindowController ()

- (void)refreshMainWebView;
- (void)moveChannel:(NSString *)channel;
- (void)didClickedGrowlNewMessageNotification:(NSNotification *)notification;

@property (strong) NSString *mainPageURLString;
@property (strong) NSString *authInfo;
@property (strong) id authRequestResourceIdentifier;
@property (strong) id updateUserRequestResourceIdentifier;
@property (strong) SCBPreferencesWindowController *preferencesWindowController;
@property (strong) SCBStarChatContext *starChatContext;

@end

@implementation SCBMainWindowController

@synthesize mainWebView = _mainWebView;
@synthesize toolButtonActionMenu = _toolButtonActionMenu;
@synthesize mainPageURLString = _mainPageURLString;
@synthesize authInfo = _authInfo;
@synthesize authRequestResourceIdentifier = _authRequestResourceIdentifier;
@synthesize updateUserRequestResourceIdentifier = _updateUserRequestResourceIdentifier;
@synthesize preferencesWindowController = _preferencesWindowController;
@synthesize streamAPIStatusButton = _streamAPIStatusButton;
@synthesize starChatContext = _starChatContext;

- (void)prepare
{
    self.starChatContext = [[SCBStarChatContext alloc] init];
    self.streamAPIStatusButton.image = [NSImage imageNamed:NSImageNameStatusNone];
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self
                           selector:@selector(didClickedGrowlNewMessageNotification:)
                               name:kSCBNotificationClickedGrowlNewMessageNotification
                             object:nil];
    [notificationCenter addObserver:self
                           selector:@selector(userStreamClientWillConnect:)
                               name:kSCBNotificationUserStreamClientWillConnect
                             object:nil];
    [notificationCenter addObserver:self
                           selector:@selector(userStreamClientDidConnected:)
                               name:kSCBNotificationUserStreamClientDidConnected
                             object:nil];
    [notificationCenter addObserver:self
                           selector:@selector(userStreamClientDidDisconnected:)
                               name:kSCBNotificationUserStreamClientDidDisconnected
                             object:nil];
    [notificationCenter addObserver:self
                           selector:@selector(userStreamClientDidFail:)
                               name:kSCBNotificationUserStreamClientDidFail
                             object:nil];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    BOOL isKeepWindowOnTop = [[userDefaults valueForKey:kUserSettingsKeepWindowOnTop] boolValue];
    NSMenuItem *keepWindowOnTopItem = [self.toolButtonActionMenu itemWithTitle:@"Keep Window On Top"];
    [keepWindowOnTopItem setState:(isKeepWindowOnTop ? NSOnState : NSOffState)];
    [self.window setHidesOnDeactivate:(isKeepWindowOnTop ? NO : YES)];
}

- (void)showWindow
{
    SCBMainWindow *mainWindow = (SCBMainWindow *)self.window;
    
    if (!mainWindow.isVisible) {
        [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
        [self.window makeKeyAndOrderFront:self];
        
        [mainWindow show];
    }
}

- (void)hideWindow
{
    SCBMainWindow *mainWindow = (SCBMainWindow *)self.window;
    
    if (mainWindow.isVisible) {
        [mainWindow hide];
    }
}

- (void)toggleDisplayStatus
{
    SCBMainWindow *mainWindow = (SCBMainWindow *)self.window;
    
    if (mainWindow.isVisible) {
        [mainWindow hide];
    }
    else {
        [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
        [self.window makeKeyAndOrderFront:self];
        
        [mainWindow show];
    }
}

- (void)loadMainPage:(NSString *)urlString
{
    self.starChatContext.baseURL = [NSURL URLWithString:urlString];
    
    self.mainPageURLString = urlString;
    [self.mainWebView setMainFrameURL:urlString];
}

- (void)moveChannel:(NSString *)channel
{
    CFStringRef encodedChannelName = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (__bridge CFStringRef)channel, NULL, CFSTR (";,/?:@&=+$#"), kCFStringEncodingUTF8);
    NSString *urlString = [[self.mainPageURLString stringByAppendingPathComponent:@"#channels"] stringByAppendingPathComponent:(__bridge NSString *)encodedChannelName];
    CFRelease(encodedChannelName);
    
    [self.mainWebView setMainFrameURL:urlString];
}

- (void)refreshMainWebView
{
    [self.mainWebView reload:self];
}

- (void)showPreferences
{
    if (!self.preferencesWindowController) {
        self.preferencesWindowController = [[SCBPreferencesWindowController alloc] initWithWindowNibName:@"SCBPreferencesWindowController"];
    }
    
    [self.window addChildWindow:self.preferencesWindowController.window ordered:NSWindowAbove];
    [self.preferencesWindowController showWindow:self];
}

- (IBAction)didPushedRefreshButton:(id)sender
{
    [self refreshMainWebView];
}

- (IBAction)didPushedActionButton:(id)sender
{
    [NSMenu popUpContextMenu:self.toolButtonActionMenu withEvent:[[NSApplication sharedApplication] currentEvent] forView:nil];
}

- (IBAction)didPushedStreamAPIStatusButton:(id)sender
{
    
}

- (IBAction)didSelectPreferencesItem:(id)sender
{
    [self showPreferences];
}

- (IBAction)didSelectKeepWindowOnTopItem:(id)sender
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    BOOL isOn = ![[userDefaults valueForKey:kUserSettingsKeepWindowOnTop] boolValue];
    [(NSMenuItem *)sender setState:(isOn ? NSOnState : NSOffState)];
    [userDefaults setBool:isOn forKey:kUserSettingsKeepWindowOnTop];
    [userDefaults synchronize];
    
    [self.window setHidesOnDeactivate:(isOn ? NO : YES)];
}

- (IBAction)didSelectQuitItem:(id)sender
{
    [[NSApplication sharedApplication] terminate:self];
}

#pragma mark -
#pragma mark Notification selectors

- (void)didClickedGrowlNewMessageNotification:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    NSString *channel = [[userInfo objectForKey:@"message"] objectForKey:@"channel_name"];
    
    [self moveChannel:channel];
    [self showWindow];
}

- (void)userStreamClientWillConnect:(NSNotification *)notification
{
    self.streamAPIStatusButton.image = [NSImage imageNamed:NSImageNameStatusPartiallyAvailable];
}

- (void)userStreamClientDidConnected:(NSNotification *)notification
{
    self.streamAPIStatusButton.image = [NSImage imageNamed:NSImageNameStatusAvailable];
}

- (void)userStreamClientDidDisconnected:(NSNotification *)notification
{
    self.streamAPIStatusButton.image = [NSImage imageNamed:NSImageNameStatusUnavailable];
}

- (void)userStreamClientDidFail:(NSNotification *)notification
{
    self.streamAPIStatusButton.image = [NSImage imageNamed:NSImageNameStatusUnavailable];
}

#pragma mark -
#pragma mark WebResourceLoadDelegate Methods

- (NSURLRequest *)webView:(WebView *)sender resource:(id)identifier willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse fromDataSource:(WebDataSource *)dataSource
{
    NSString *path = request.URL.path;
    if ([path hasPrefix:@"/users/"] && [path hasSuffix:@"/ping"]) {
        NSString *authorization = [[request allHTTPHeaderFields] objectForKey:@"Authorization"];
        NSData *decodedData = [NSData dataFromBase64String:[authorization substringFromIndex:6]];
        NSString *decodedString = [[NSString alloc] initWithData:decodedData encoding:NSASCIIStringEncoding];
        
        self.authInfo = decodedString;
        self.authRequestResourceIdentifier = identifier;
    }
    else if ([path isEqualToString:[NSString stringWithFormat:@"/users/%@", self.starChatContext.userName]] &&
             [request.HTTPMethod isEqualToString:@"PUT"]) {
        self.updateUserRequestResourceIdentifier = identifier;
    }
    
    return request;
}

- (void)webView:(WebView *)sender resource:(id)identifier didReceiveResponse:(NSURLResponse *)response fromDataSource:(WebDataSource *)dataSource
{
    if ([identifier isEqual:self.authRequestResourceIdentifier] && ((NSHTTPURLResponse *)response).statusCode == 200) {
        NSArray *authInfoParams = [self.authInfo componentsSeparatedByString:@":"];
        NSString *userName = [authInfoParams objectAtIndex:0];
        NSString *password = [authInfoParams objectAtIndex:1];
        
        [self.starChatContext setUserName:userName andPassword:password];
        [self.starChatContext startUserStreamClient];
        
        self.authInfo = nil;
        self.authRequestResourceIdentifier = nil;
    }
    else if ([identifier isEqual:self.updateUserRequestResourceIdentifier] && ((NSHTTPURLResponse *)response).statusCode == 200) {
        [self.starChatContext updateKeywords];
        
        self.updateUserRequestResourceIdentifier = nil;
    }
}

#pragma mark -
#pragma mark WebUIDelegate Methods

- (BOOL)webView:(WebView *)sender runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WebFrame *)frame
{
    WebDataSource *dataSource = [frame dataSource] ? [frame dataSource] : [frame provisionalDataSource];
    NSString *host = dataSource.response.URL.host ? dataSource.response.URL.host : @"JavaScript";
    
    NSAlert *alert = [NSAlert alertWithMessageText:host defaultButton:@"OK" alternateButton:@"Cancel" otherButton:nil informativeTextWithFormat:message];
    
    if ([alert runModal] == NSAlertDefaultReturn) {
        return YES;
    }
    else {
        return NO;
    }
}

- (void)webView:(WebView *)sender runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WebFrame *)frame
{
    WebDataSource *dataSource = [frame dataSource] ? [frame dataSource] : [frame provisionalDataSource];
    NSString *host = dataSource.response.URL.host ? dataSource.response.URL.host : @"JavaScript";
    
    NSAlert *alert = [NSAlert alertWithMessageText:host defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:message];
    [alert runModal];
}

#pragma mark -
#pragma mark WebPolicyDelegate Methods

- (void)webView:(WebView *)webView decidePolicyForNewWindowAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request newFrameName:(NSString *)frameName decisionListener:(id<WebPolicyDecisionListener>)listener
{
    [listener ignore];
    
    [[NSWorkspace sharedWorkspace] openURL:request.URL];
}

#pragma mark -
#pragma mark WebFrameLoadDelegate Methods

- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame
{
    if ([frame isEqualTo:sender.mainFrame]) {
        [[sender windowScriptObject] setValue:self forKey:@"SCBMainWindowController"];
        
        NSString *hookLogOutEventScript = @"$('#logOutLink a').click(function(){window.SCBMainWindowController.didClickLogOut();return false;});";
        [sender stringByEvaluatingJavaScriptFromString:hookLogOutEventScript];
    }
}

#pragma mark -
#pragma mark WebScripting Methods

+ (NSString *)webScriptNameForSelector:(SEL)aSelector
{
    NSString *name = nil;
    if (aSelector == @selector(didClickLogOut)){
        name = @"didClickLogOut";
    }
    return name;
}

+ (BOOL)isSelectorExcludedFromWebScript:(SEL)aSelector
{
    if (aSelector == @selector(didClickLogOut)){
        return NO;
    }
    return YES;
}

#pragma mark -
#pragma mark JavaScript bridge Methods

- (void)didClickLogOut
{
    [self.starChatContext setUserName:nil andPassword:nil];
}

@end
