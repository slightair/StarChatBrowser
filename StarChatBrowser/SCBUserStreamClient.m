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

@end

@implementation SCBUserStreamClient

@synthesize username = _username;
@synthesize streamParserAdapter = _streamParserAdapter;
@synthesize streamParser = _streamParser;
@synthesize delegate = _delegate;

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
    }
    return self;
}

- (void)start
{
    NSMutableURLRequest *request = [self requestWithMethod:@"GET" path:[NSString stringWithFormat:@"/users/%@/stream", self.username] parameters:nil];
    
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    [connection start];
}

#pragma mark -
#pragma mark NSURLConnectionDelegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.streamParser parse:data];
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
