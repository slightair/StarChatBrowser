//
//  SCBUserStreamClient.m
//  StarChatBrowser
//
//  Created by slightair on 12/06/02.
//  Copyright (c) 2012 slightair. All rights reserved.
//

#import "SCBUserStreamClient.h"

#define kClientBufferSize 2048

// CFNetwork CFReadStreamClientCallBack
void readHttpStreamCallBack(CFReadStreamRef stream, CFStreamEventType eventType, void *clientCallBackInfo);

@interface SCBUserStreamClient ()

- (void)releaseReadStream;

@property (strong) NSString *username;
@property (strong) SBJsonStreamParserAdapter *streamParserAdapter;
@property (strong) SBJsonStreamParser *streamParser;
@property          SCBUserStreamClientConnectionStatus connectionStatus;

// AFHTTPClient
@property (readwrite, nonatomic, retain) NSMutableDictionary *defaultHeaders;

@end

@implementation SCBUserStreamClient
{
    CFReadStreamRef _readStreamRef;
}

@synthesize username = _username;
@synthesize streamParserAdapter = _streamParserAdapter;
@synthesize streamParser = _streamParser;
@synthesize delegate = _delegate;
@synthesize connectionStatus = _connectionStatus;

// AFHTTPClient
@synthesize defaultHeaders = _defaultHeaders;

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
    self.connectionStatus = kSCBUserStreamClientConnectionStatusConnecting;
    if ([self.delegate respondsToSelector:@selector(userStreamClientWillConnect:)]) {
        [self.delegate userStreamClientWillConnect:self];
    }
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"/users/%@/stream", self.username] relativeToURL:self.baseURL];
    CFURLRef urlRef = CFURLCreateWithString(kCFAllocatorDefault, (__bridge CFStringRef)[url absoluteString], NULL);
    
    CFHTTPMessageRef messageRef = CFHTTPMessageCreateRequest(kCFAllocatorDefault, CFSTR("GET"), urlRef, kCFHTTPVersion1_1);
    for (NSString *headerFieldName in self.defaultHeaders) {
        CFHTTPMessageSetHeaderFieldValue(messageRef, (__bridge CFStringRef)headerFieldName, (__bridge CFStringRef)[self defaultValueForHeader:headerFieldName]);
    }
    CFHTTPMessageSetHeaderFieldValue(messageRef, CFSTR("Accept"), CFSTR("application/json"));
    
    _readStreamRef = CFReadStreamCreateForHTTPRequest(kCFAllocatorDefault, messageRef);
    CFStreamClientContext contextRef = {0, (__bridge void *)self, NULL, NULL, NULL};
    
    if (CFReadStreamSetClient(_readStreamRef,
                              (kCFStreamEventOpenCompleted  |
                               kCFStreamEventHasBytesAvailable |
                               kCFStreamEventEndEncountered |
                               kCFStreamEventErrorOccurred),
                              &readHttpStreamCallBack,
                              &contextRef)) {
        CFReadStreamScheduleWithRunLoop(_readStreamRef, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
    }
    CFReadStreamOpen(_readStreamRef);
    
    CFRelease(messageRef);
    CFRelease(urlRef);
}

- (void)reconnect
{
    [self start];
}

- (void)releaseReadStream
{
    if (_readStreamRef) {
        CFRelease(_readStreamRef);
    }
    _readStreamRef = NULL;
}

- (void)dealloc
{
    if (_readStreamRef) {
        CFRelease(_readStreamRef);
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

// CFNetwork CFReadStreamClientCallBack
void readHttpStreamCallBack(CFReadStreamRef stream, CFStreamEventType eventType, void *clientCallBackInfo) {
    SCBUserStreamClient *client = (__bridge SCBUserStreamClient *)clientCallBackInfo;
    
    switch (eventType) {
        case kCFStreamEventOpenCompleted:
        {
            client.connectionStatus = kSCBUserStreamClientConnectionStatusConnected;
            if ([client.delegate respondsToSelector:@selector(userStreamClientDidConnected:)]) {
                [client.delegate userStreamClientDidConnected:client];
            }
            
            break;
        }
        case kCFStreamEventHasBytesAvailable:
        {
            UInt8 buffer[kClientBufferSize];
            CFIndex bytesRead = CFReadStreamRead(stream, buffer, sizeof(buffer));
            
            if (bytesRead > 0) {
                NSData *data = [NSData dataWithBytes:buffer length:bytesRead];
                [client.streamParser parse:data];
            }
            
            break;
        }
        case kCFStreamEventEndEncountered:
        {
            client.connectionStatus = kSCBUserStreamClientConnectionStatusDisconnected;
            if ([client.delegate respondsToSelector:@selector(userStreamClientDidDisconnected:)]) {
                [client.delegate userStreamClientDidDisconnected:client];
            }
            
            CFReadStreamUnscheduleFromRunLoop(stream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
            CFReadStreamClose(stream);
            [client releaseReadStream];
            
            break;
        }
        case kCFStreamEventErrorOccurred:
        {
            CFErrorRef errorRef = CFReadStreamCopyError(stream);
            CFDictionaryRef userInfoRef = CFErrorCopyUserInfo(errorRef);
            NSError *error = [[NSError alloc] initWithDomain:(__bridge NSString *)CFErrorGetDomain(errorRef) code:CFErrorGetCode(errorRef) userInfo:(__bridge NSDictionary *)userInfoRef];
            
            CFRelease(userInfoRef);
            CFRelease(errorRef);
            
            client.connectionStatus = kSCBUserStreamClientConnectionStatusFailed;
            if ([client.delegate respondsToSelector:@selector(userStreamClient:didFailWithError:)]) {
                [client.delegate userStreamClient:client didFailWithError:error];
            }
            
            CFReadStreamUnscheduleFromRunLoop(stream, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
            CFReadStreamClose(stream);
            [client releaseReadStream];
            
            break;
        }
    }
}
