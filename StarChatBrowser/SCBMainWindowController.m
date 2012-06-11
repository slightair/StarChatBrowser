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
#import "SCBGrowlClient.h"
#import "SCBPreferencesWindowController.h"
#import "NSData+Base64.h"

@interface SCBMainWindowController ()

- (void)refreshMainWebView;
- (void)startUserStreamClient:(NSString *)username password:(NSString *)password;
- (void)didClickedGrowlNewMessageNotification:(NSNotification *)notification;

@property (strong) NSString *mainPageURLString;
@property (strong) NSString *authInfo;
@property (strong) id authRequestResourceIdentifier;
@property (strong) SCBPreferencesWindowController *preferencesWindowController;
@property (strong) SCBUserStreamClient *userStreamClient;

@end

@implementation SCBMainWindowController

@synthesize mainWebView = _mainWebView;
@synthesize toolButtonActionMenu = _toolButtonActionMenu;
@synthesize mainPageURLString = _mainPageURLString;
@synthesize authInfo = _authInfo;
@synthesize authRequestResourceIdentifier = _authRequestResourceIdentifier;
@synthesize preferencesWindowController = _preferencesWindowController;
@synthesize userStreamClient = _userStreamClient;

- (void)prepare
{
    self.mainWebView.resourceLoadDelegate = self;
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self
                           selector:@selector(didClickedGrowlNewMessageNotification:)
                               name:kSCBNotificationClickedGrowlNewMessageNotification
                             object:[SCBGrowlClient sharedClient]];
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

- (void)loadMainPage:(NSString *)URLString
{
    self.mainPageURLString = URLString;
    [self.mainWebView setMainFrameURL:URLString];
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

- (void)startUserStreamClient:(NSString *)username password:(NSString *)password
{
    NSURL *baseURL = [NSURL URLWithString:self.mainPageURLString];
    if (!self.userStreamClient) {
        self.userStreamClient = [[SCBUserStreamClient alloc] initWithBaseURL:baseURL username:username];
        self.userStreamClient.delegate = self;
        [self.userStreamClient setAuthorizationHeaderWithUsername:username password:password];
    }

    if (self.userStreamClient.connectionStatus == kSCBUserStreamClientConnectionStatusNone ||
        self.userStreamClient.connectionStatus == kSCBUserStreamClientConnectionStatusDisconnected ||
        self.userStreamClient.connectionStatus == kSCBUserStreamClientConnectionStatusFailed) {
        [self.userStreamClient start];
    }
}

- (IBAction)didPushedRefreshButton:(id)sender
{
    [self refreshMainWebView];
}

- (IBAction)didPushedActionButton:(id)sender
{
    [NSMenu popUpContextMenu:self.toolButtonActionMenu withEvent:[[NSApplication sharedApplication] currentEvent] forView:nil];
}

- (IBAction)didSelectPreferencesItem:(id)sender
{
    [self showPreferences];
}

- (IBAction)didSelectQuitItem:(id)sender
{
    [[NSApplication sharedApplication] terminate:self];
}

#pragma mark -
#pragma mark Notification selectors

- (void)didClickedGrowlNewMessageNotification:(NSNotification *)notification
{
    NSLog(@"%@", notification);
    [self showWindow];
}

#pragma mark -
#pragma mark SCBUserStreamClientDelegate Methods

- (void)userStreamClient:(SCBUserStreamClient *)client didReceivedUserInfo:(NSDictionary *)userInfo
{
    if ([[userInfo objectForKey:@"type"] isEqualToString:@"message"]) {
        NSDictionary *message = [userInfo objectForKey:@"message"];
        NSString *title = [message objectForKey:@"channel_name"];
        NSString *description = [NSString stringWithFormat:@"%@: %@", [message objectForKey:@"user_name"], [message objectForKey:@"body"]];
        
        [[SCBGrowlClient sharedClient] notifyNewMessageWithTitle:title description:description userInfo:userInfo];
    }
}

- (void)userStreamClientDidDisconnected:(SCBUserStreamClient *)client
{
    [client start];
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
    
    return request;
}

- (void)webView:(WebView *)sender resource:(id)identifier didReceiveResponse:(NSURLResponse *)response fromDataSource:(WebDataSource *)dataSource
{
    if ([identifier isEqual:self.authRequestResourceIdentifier] && ((NSHTTPURLResponse *)response).statusCode == 200) {
        NSArray *authInfoParams = [self.authInfo componentsSeparatedByString:@":"];
        NSString *username = [authInfoParams objectAtIndex:0];
        NSString *password = [authInfoParams objectAtIndex:1];
        
        [self startUserStreamClient:username password:password];
        
        self.authInfo = nil;
        self.authRequestResourceIdentifier = nil;
    }
}

@end
