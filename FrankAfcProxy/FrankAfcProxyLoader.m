//
//  FrankAfcProxyLoader.m
//
//  Created by Toshiyuki Terashita on 2013/06/26.
//  Copyright (c) 2013 Toshiyuki Suzumura. All rights reserved.
//

#import "FrankAfcProxyLoader.h"
#import "FrankAfcProxy.h"

@implementation FrankAfcProxyLoader

+ (void)applicationDidBecomeActive:(NSNotification*)notification
{
    [FrankAfcProxy run];
}

+ (void)load
{
    NSLog(@"Injecting FrankAfcProxy");
    
    NSString *notificationName = @"UIApplicationDidBecomeActiveNotification";
    
    [[NSNotificationCenter defaultCenter] addObserver:[self class]
                                             selector:@selector(applicationDidBecomeActive:)
                                                 name:notificationName
                                               object:nil];
}

@end
