//
//  LoginItem.h
//  Swift Dictation
//
//  Created by 夏目夏樹 on 4/8/13.
//  Copyright (c) 2013 夏目夏樹. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ServiceManagement/ServiceManagement.h>

@interface LoginItem : NSObject

@property NSString *bundleIdentifier;
@property (getter=isEnabled) BOOL enabled;

+ (LoginItem *)loginItemWithBundleIdentifier:(NSString *)aBundleIdentifier;
- (id)initWithBundleIdentifier:(NSString *)aBundleIdentifier;
- (void)setEnabled:(BOOL)flag;
- (BOOL)isEnabled;

@end
