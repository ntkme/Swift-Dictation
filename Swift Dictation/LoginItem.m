//
//  LoginItem.m
//  Swift Dictation
//
//  Created by 夏目夏樹 on 4/8/13.
//  Copyright (c) 2013 夏目夏樹. All rights reserved.
//

#import "LoginItem.h"

@implementation LoginItem

@synthesize bundleIdentifier;

+ (LoginItem *)loginItemWithBundleIdentifier:(NSString *)aBundleIdentifier
{
    return [[LoginItem alloc] initWithBundleIdentifier:aBundleIdentifier];
}

- (id)initWithBundleIdentifier:(NSString *)aBundleIdentifier
{
    self = [super init];
    if (self) {
        bundleIdentifier = aBundleIdentifier;
    }
    return self;
}

- (BOOL)isEnabled
{
    BOOL enabled = NO;
    CFArrayRef allJobDictionaries = SMCopyAllJobDictionaries(kSMDomainUserLaunchd);
    CFIndex i, c = CFArrayGetCount(allJobDictionaries);
    for (i = 0; i < c; i++) {
        if ([[(NSDictionary *)CFArrayGetValueAtIndex(allJobDictionaries, i) objectForKey:@"Label"] isEqualToString:bundleIdentifier]) {
            enabled = YES;
            break;
        }
    }
    CFRelease(allJobDictionaries);
    return enabled;
}

- (void)setEnabled:(BOOL)flag
{
    SMLoginItemSetEnabled((__bridge CFStringRef)bundleIdentifier, flag);
}

@end
