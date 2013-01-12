//
//  InputMethodManager.m
//  Swift Dictation
//
//  Created by 夏目夏樹 on 4/5/13.
//  Copyright (c) 2013 夏目夏樹. All rights reserved.
//

#import "InputMethodManager.h"

@implementation InputMethodManager

+ (InputMethodManager *)defaultManager
{
    static InputMethodManager *defaultManager = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        defaultManager = [[InputMethodManager alloc] init];
    });

    return defaultManager;
}

- (NSArray *)enabledInputMethodLanguages;
{
    NSMutableArray *languageIdentifiers = [NSMutableArray array];
    CFArrayRef inputSourceList = TISCreateInputSourceList((__bridge CFDictionaryRef)@{
                                                 (__bridge NSString *)kTISPropertyInputSourceCategory:(__bridge NSString *)kTISCategoryKeyboardInputSource
                                                 }, NO);
    CFIndex i, c = CFArrayGetCount(inputSourceList);
    for (i = 0; i < c; i++) {
        NSString *languageIdentifier = (__bridge NSString *)CFArrayGetValueAtIndex(TISGetInputSourceProperty((TISInputSourceRef)CFArrayGetValueAtIndex(inputSourceList, i), kTISPropertyInputSourceLanguages), 0);
        if (![languageIdentifiers containsObject:languageIdentifier]) {
            [languageIdentifiers addObject:languageIdentifier];
        }
    }
    return [languageIdentifiers copy];
}

- (NSString *)language
{
    return (__bridge NSString *)CFArrayGetValueAtIndex(TISGetInputSourceProperty(TISCopyCurrentKeyboardInputSource(), kTISPropertyInputSourceLanguages), 0);
}

- (NSString *)bundleIdentifier
{
    return (__bridge NSString *)TISGetInputSourceProperty(TISCopyCurrentKeyboardInputSource(), kTISPropertyBundleID);
}

@end
