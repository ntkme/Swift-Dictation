//
//  LoginItem.m
//  Swift Dictation
//
//  Created by 夏目夏樹 on 4/8/13.
//  Copyright (c) 2013 夏目夏樹. All rights reserved.
//

#import "LoginItem.h"

extern CFArrayRef SMCopyAllJobDictionaries(CFStringRef) __attribute__((weak_import));

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
    if (SMCopyAllJobDictionaries != NULL) {
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
    } else {
        NSTask *task = [[NSTask alloc] init];
        [task setLaunchPath:@"/bin/launchctl"];
        [task setArguments: @[@"print-disabled", [NSString stringWithFormat:@"user/%i", getuid()]]];
        NSPipe *pipe = [NSPipe pipe];
        [task setStandardOutput:pipe];
        [task launch];
        NSString *disabled = [[NSString alloc] initWithData:[[pipe fileHandleForReading] readDataToEndOfFile] encoding:NSUTF8StringEncoding];
        return [disabled rangeOfString:[NSString stringWithFormat:@"\"%@\" => false", bundleIdentifier]].location != NSNotFound;
    }
}

- (void)setEnabled:(BOOL)flag
{
    SMLoginItemSetEnabled((__bridge CFStringRef)bundleIdentifier, flag);
}

@end
