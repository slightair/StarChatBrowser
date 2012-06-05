//
//  SCBMainWindowController.m
//  StarChatBrowser
//
//  Created by slightair on 12/06/02.
//  Copyright (c) 2012 slightair. All rights reserved.
//

#import "SCBMainWindowController.h"
#import "SCBGrowlClient.h"
#import "NSData+Base64.h"

@interface SCBMainWindowController ()

- (void)startUserStreamClient:(NSString *)username password:(NSString *)password;

@property (strong) NSString *mainPageURLString;
@property (strong) NSString *authInfo;
@property (strong) id authRequestResourceIdentifier;

@end

@implementation SCBMainWindowController

@synthesize mainWebView = _mainWebView;
@synthesize toolButtonActionMenu = _toolButtonActionMenu;
@synthesize mainPageURLString = _mainPageURLString;
@synthesize authInfo = _authInfo;
@synthesize authRequestResourceIdentifier = _authRequestResourceIdentifier;

- (void)prepare
{
    self.mainWebView.resourceLoadDelegate = self;
}

- (void)display
{
    [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];    
    [self.window makeKeyAndOrderFront:self];
}

- (void)loadMainPage:(NSString *)URLString
{
    self.mainPageURLString = URLString;
    [_mainWebView setMainFrameURL:URLString];
}

- (void)startUserStreamClient:(NSString *)username password:(NSString *)password
{
    NSURL *baseURL = [NSURL URLWithString:self.mainPageURLString];
    SCBUserStreamClient *client = [[SCBUserStreamClient alloc] initWithBaseURL:baseURL username:username];
    [client setAuthorizationHeaderWithUsername:username password:password];
    client.delegate = self;
    [client start];
}

- (IBAction)didPushedDisclosureButton:(id)sender
{
    [NSMenu popUpContextMenu:self.toolButtonActionMenu withEvent:[[NSApplication sharedApplication] currentEvent] forView:nil];
}

- (IBAction)didSelectQuitItem:(id)sender
{
    NSLog(@"huh...");
    [[NSApplication sharedApplication] terminate:self];
}

#pragma mark -
#pragma mark SCBUserStreamClientDelegate Methods

- (void)userStreamClient:(SCBUserStreamClient *)client didReceivedUserInfo:(NSDictionary *)userInfo
{
    if ([[userInfo objectForKey:@"type"] isEqualToString:@"message"]) {
        NSDictionary *message = [userInfo objectForKey:@"message"];
        NSString *title = [message objectForKey:@"channel_name"];
        NSString *description = [NSString stringWithFormat:@"%@: %@", [message objectForKey:@"user_name"], [message objectForKey:@"body"]];
        
        [[SCBGrowlClient sharedClient] notifyNewMessageWithTitle:title description:description context:nil];
    }
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
