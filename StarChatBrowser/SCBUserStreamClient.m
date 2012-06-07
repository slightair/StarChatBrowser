//
//  SCBUserStreamClient.m
//  StarChatBrowser
//
//  Created by slightair on 12/06/02.
//  Copyright (c) 2012 slightair. All rights reserved.
//

#import "SCBUserStreamClient.h"

@interface SCBUserStreamClient ()

@property (strong) NSString *username;
@property (strong) SBJsonStreamParserAdapter *streamParserAdapter;
@property (strong) SBJsonStreamParser *streamParser;
@property          SCBUserStreamClientConnectionStatus connectionStatus;

@end

@implementation SCBUserStreamClient

@synthesize username = _username;
@synthesize streamParserAdapter = _streamParserAdapter;
@synthesize streamParser = _streamParser;
@synthesize delegate = _delegate;
@synthesize connectionStatus = _connectionStatus;

- (id)initWithBaseURL:(NSURL *)url username:(NSString *)username
{
    self = [super initWithBaseURL:url];
    if (self) {
        SBJsonStreamParserAdapter *adapter = [[SBJsonStreamParserAdapter alloc] init];
        adapter.delegate = self;
        
        SBJsonStreamParser *parser = [[SBJsonStreamParser alloc] init];
        parser.delegate = adapter;
        parser.supportMultipleDocuments = YES;
        
        self.username = username;
        self.streamParserAdapter = adapter;
        self.streamParser = parser;
        self.connectionStatus = kSCBUserStreamClientConnectionStatusNone;
    }
    return self;
}

- (void)start
{
    NSMutableURLRequest *request = [self requestWithMethod:@"GET" path:[NSString stringWithFormat:@"/users/%@/stream", self.username] parameters:nil];
    
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    self.connectionStatus = kSCBUserStreamClientConnectionStatusConnecting;
    [connection start];
}

#pragma mark -
#pragma mark NSURLConnectionDelegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.connectionStatus = kSCBUserStreamClientConnectionStatusConnected;
    if ([self.delegate respondsToSelector:@selector(userStreamClientDidConnected:)]) {
        [self.delegate userStreamClientDidConnected:self];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.streamParser parse:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    self.connectionStatus = kSCBUserStreamClientConnectionStatusDisconnected;
    if ([self.delegate respondsToSelector:@selector(userStreamClientDidDisconnected:)]) {
        [self.delegate userStreamClientDidDisconnected:self];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    self.connectionStatus = kSCBUserStreamClientConnectionStatusDisconnected;
    if ([self.delegate respondsToSelector:@selector(userStreamClientDidDisconnected:)]) {
        [self.delegate userStreamClientDidDisconnected:self];
    }
}


#pragma mark -
#pragma mark SBJsonStreamParserAdapterDelegate Methods

- (void)parser:(SBJsonStreamParser *)parser foundObject:(NSDictionary *)dict
{
    if ([self.delegate respondsToSelector:@selector(userStreamClient:didReceivedUserInfo:)]) {
        [self.delegate userStreamClient:self didReceivedUserInfo:dict];
    }
}

- (void)parser:(SBJsonStreamParser *)parser foundArray:(NSArray *)array
{
}

@end
