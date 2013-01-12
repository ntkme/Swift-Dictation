//
//  InputMethodManager.h
//  Swift Dictation
//
//  Created by 夏目夏樹 on 4/5/13.
//  Copyright (c) 2013 夏目夏樹. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Carbon/Carbon.h>

@interface InputMethodManager : NSObject

+ (InputMethodManager *)defaultManager;
- (NSArray *)enabledInputMethodLanguages;
- (NSString *)language;
- (NSString *)bundleIdentifier;

@end
