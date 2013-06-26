//
//  FrankAfcProxy.m
//
//  Created by Toshiyuki Suzumura on 2013/06/11.
//  Copyright (c) 2013 Toshiyuki Suzumura All rights reserved.
//

#import "FrankAfcProxy.h"
#import "FileChangeObserver.h"

#ifndef FRANKAFCPROXY_PRODUCT_VERSION
#define FRANKAFCPROXY_PRODUCT_VERSION UNKNOWN
#endif

#define xstr(s) str(s)
#define str(s) #s
#define VERSIONED_NAME "FrankAfcProxy iOS Server " xstr(FRANKAFCPROXY_PRODUCT_VERSION)
const unsigned char frankAfcProxy_version[] = "@(#)" VERSIONED_NAME "\n";

@interface FrankAfcProxy () <FileChangeObserverDelegate>
{
    NSOperationQueue* _queueHTTPRequest;
    FileChangeObserver* _header_observer;
    NSString* _in_header;
    NSString* _in_body;
    NSString* _out_header;
    NSString* _out_body;
}
@end


@implementation FrankAfcProxy

- (void)httpRequestWithHeaderData:(NSData*)headerData bodyData:(NSData*)bodyData
{
    if (!headerData) {
        [@"Bad request: header is nil.\n" writeToFile:_out_body atomically:NO encoding:NSUTF8StringEncoding error:nil];
        [@{@"Status": @400} writeToFile:_out_header atomically:NO];
        NSLog(@"header is nil");
        return;
    }
    
    NSMutableDictionary* headers = [NSJSONSerialization JSONObjectWithData:headerData
                                                                   options:NSJSONReadingMutableContainers
                                                                     error:nil];
    
    NSMutableURLRequest* req = [[NSMutableURLRequest alloc] init];
    [req setURL:[NSURL URLWithString:[headers objectForKey:@"URI"]]];
    [req setHTTPMethod:[headers objectForKey:@"Method"]];
    [headers removeObjectForKey:@"URI"];
    [headers removeObjectForKey:@"Method"];
    
    for (NSString* key in headers.keyEnumerator) {
        [req setValue:[headers objectForKey:key] forHTTPHeaderField:key];
    }
    [req setHTTPBody:bodyData];
    
    NSLog(@"\n%@ %@\n%@\n%@", req.HTTPMethod, req.URL.description, req.allHTTPHeaderFields.description, req.HTTPBody.description);
    
    [NSURLConnection sendAsynchronousRequest:req
                                       queue:_queueHTTPRequest
                           completionHandler:^(NSURLResponse* res_, NSData* response_body, NSError* response_error) {
                               NSHTTPURLResponse* res = (NSHTTPURLResponse*)res_;
                               NSLog(@"=> %d", res.statusCode);
                               
                               [response_body writeToFile:_out_body atomically:NO];
                               NSMutableDictionary* result_headers = [NSMutableDictionary dictionaryWithDictionary:res.allHeaderFields];
                               [result_headers setObject:[NSNumber numberWithInteger:res.statusCode]
                                                  forKey:@"Status"];
                               NSData* header = [NSJSONSerialization dataWithJSONObject:result_headers
                                                                                options:0
                                                                                  error:nil];
                               [header writeToFile:_out_header atomically:NO];
                               NSLog(@"%@ => %d", req.URL, header.length);
                           }];
}



#pragma mark - FileChangeObserverDelegate

- (void)fileChanged:(FileChangeObserver*)observer typeMask:(FileChangeNotificationType)type
{
    NSLog(@"header in: %@:", [NSString stringWithKEventFFlags:type]);
    if (type & NOTE_DELETE) {
        return;
    }
    NSData* headerData = [NSData dataWithContentsOfFile:_in_header];
    NSData* bodyData = [NSData dataWithContentsOfFile:_in_body];
    truncate(_in_header.UTF8String, 0);
    truncate(_in_body.UTF8String, 0);
    [self httpRequestWithHeaderData:headerData bodyData:bodyData];
}



#pragma mark - Life cycle.

+ (void)run
{
    static FrankAfcProxy* proxy;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        proxy = [[FrankAfcProxy alloc] init];
    });
}

- (id)init
{
    self = [super init];
    if (self) {
        _queueHTTPRequest = [[NSOperationQueue alloc] init];
        _queueHTTPRequest.maxConcurrentOperationCount = 1;
        
        NSError* err;
        NSString* dir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        _in_header  = [dir stringByAppendingPathComponent:@"in.header"];
        _in_body    = [dir stringByAppendingPathComponent:@"in.body"];
        _out_header = [dir stringByAppendingPathComponent:@"out.header"];
        _out_body   = [dir stringByAppendingPathComponent:@"out.body"];
        
        NSFileManager* fm = [NSFileManager defaultManager];
        [fm createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:&err];
        [fm createFileAtPath:_in_header  contents:nil attributes:nil];
        [fm createFileAtPath:_in_body    contents:nil attributes:nil];
        [fm createFileAtPath:_out_header contents:nil attributes:nil];
        [fm createFileAtPath:_out_body   contents:nil attributes:nil];
        
        _header_observer = [FileChangeObserver observerForURL:[[NSURL alloc] initFileURLWithPath:_in_header]
                                                        types:kFileChangeType_Delete|kFileChangeType_Write
                                                     delegate:self];
        NSLog(@"Target: %@/\n", dir);
    }
    return self;
}

@end
