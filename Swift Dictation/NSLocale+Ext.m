//
//  NSLocale+Ext.m
//  Swift Dictation
//
//  Created by 夏目夏樹 on 4/5/13.
//  Copyright (c) 2013 夏目夏樹. All rights reserved.
//

#import "NSLocale+Ext.h"

@implementation NSLocale(Ext)

+ (NSString *)localeIdentifier:(NSString *)aLocaleIdentifier forComponents:(NSArray *)components
{
    NSDictionary *theComponentsFromLocaleIdentifier = [NSLocale componentsFromLocaleIdentifier:aLocaleIdentifier];
    NSMutableDictionary *theComponentsForLocaleIdentifier = [NSMutableDictionary dictionary];
    for (NSString *component in components) {
        if ([theComponentsFromLocaleIdentifier objectForKey:component]) {
            [theComponentsForLocaleIdentifier setObject:[theComponentsFromLocaleIdentifier objectForKey:component] forKey:component];
        }
    }
    return [NSLocale localeIdentifierFromComponents:theComponentsForLocaleIdentifier];
}

+ (NSString *)canonicalLocaleIdentifierFromString:(NSString *)aLocaleIdentifier forComponents:(NSArray *)components
{
    return [NSLocale canonicalLocaleIdentifierFromString:[self localeIdentifier:aLocaleIdentifier forComponents:components]];
}

+ (NSString *)canonicalLanguageIdentifierFromString:(NSString *)aLocaleIdentifier forComponents:(NSArray *)components
{
    return [NSLocale canonicalLanguageIdentifierFromString:[self localeIdentifier:aLocaleIdentifier forComponents:components]];
}

@end
