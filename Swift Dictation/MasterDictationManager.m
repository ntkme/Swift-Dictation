//
//  MasterDictationManager.m
//  Swift Dictation
//
//  Created by 夏目夏樹 on 4/5/13.
//  Copyright (c) 2013 夏目夏樹. All rights reserved.
//

#import "MasterDictationManager.h"

NSString *const kDictationIMBundleIdentifier = @"com.apple.inputmethod.ironwood";
static NSString *const kDictationIMUserDefaultPersistentDomain = @"com.apple.speech.recognition.AppleSpeechRecognition.prefs";
static NSString *const kDictationIMIntroMessagePresented = @"DictationIMIntroMessagePresented";
static NSString *const kDictationIMLocaleIdentifier = @"DictationIMLocaleIdentifier";
static NSString *const kDictationIMCanAutoEnable = @"AppleIronwoodCanAutoEnable";
static NSString *const kDictationIMMasterDictationEnabled = @"DictationIMMasterDictationEnabled";
static NSString *const kDictationIMPresentedOfflineUpgradeSuggestion = @"PresentedOfflineUpgradeSuggestion";


@implementation DictationManager

+ (DictationManager *)defaultManager
{
    static DictationManager *defaultManager = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        defaultManager = [[DictationManager alloc] init];
    });

    return defaultManager;
}

- (NSDictionary *)persistentDomain
{
    return [[NSUserDefaults standardUserDefaults] persistentDomainForName:kDictationIMUserDefaultPersistentDomain];
}

- (void)setPersistentDomain:(NSDictionary *)aDictionary
{
    [[NSUserDefaults standardUserDefaults] setPersistentDomain:aDictionary
                                                       forName:kDictationIMUserDefaultPersistentDomain];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)addEntriesToPersistentDomainFromDictionary:(NSDictionary *)aDictionary
{
    NSMutableDictionary *theMutablePersistentDomain = [[self persistentDomain] mutableCopy];
    [theMutablePersistentDomain addEntriesFromDictionary:aDictionary];
    [self setPersistentDomain:theMutablePersistentDomain];
}

- (void)setEnabled:(BOOL)flag
{
    [self addEntriesToPersistentDomainFromDictionary:@{
                           kDictationIMCanAutoEnable:[NSNumber numberWithBool:flag]
     }];
}

- (BOOL)isEnabled
{
    return [[[self persistentDomain] objectForKey:kDictationIMCanAutoEnable] boolValue];
}


- (void)setIntroMessagePresented:(BOOL)flag
{
    [self addEntriesToPersistentDomainFromDictionary:@{
                   kDictationIMIntroMessagePresented:[NSNumber numberWithBool:flag]
     }];
}

- (BOOL)isIntroMessagePresented
{
    return [[[self persistentDomain] objectForKey:kDictationIMIntroMessagePresented] boolValue];
}

- (NSString *)localeIdentifier
{
    return [[self persistentDomain] objectForKey:kDictationIMLocaleIdentifier];
}

- (void)setLocaleIdentifier:(NSString *)aLocaleIdentifier
{
    NSDictionary *theComponents = [NSLocale componentsFromLocaleIdentifier:aLocaleIdentifier];
    [self addEntriesToPersistentDomainFromDictionary:@{
                        kDictationIMLocaleIdentifier:[NSLocale canonicalLocaleIdentifierFromString:[NSLocale localeIdentifierFromComponents:@{
                                                                                                                       NSLocaleLanguageCode:[theComponents objectForKey:NSLocaleLanguageCode],
                                                                                                                        NSLocaleCountryCode:[theComponents objectForKey:NSLocaleCountryCode]
                                                                                                    }]]
     }];
}

- (void)terminate
{
    for (NSRunningApplication *runningApplication in [NSRunningApplication runningApplicationsWithBundleIdentifier:kDictationIMBundleIdentifier]) {
        [runningApplication terminate];
    }
}

@end


@implementation MasterDictationManager

+ (DictationManager *)defaultManager
{
    static DictationManager *defaultManager = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        NSString *currentSystemVersion = [[NSDictionary dictionaryWithContentsOfFile:@"/System/Library/CoreServices/SystemVersion.plist"] objectForKey:@"ProductVersion"];
        if ([currentSystemVersion compare:@"10.9" options:NSNumericSearch] != NSOrderedAscending) {
            defaultManager = [[MasterDictationManager alloc] init];
        } else {
            defaultManager = [[DictationManager alloc] init];
        }
    });

    return defaultManager;
}

- (void)setEnabled:(BOOL)flag
{
    [self addEntriesToPersistentDomainFromDictionary:@{
                                                       kDictationIMMasterDictationEnabled:[NSNumber numberWithBool:flag]
                                                       }];
}

- (BOOL)isEnabled
{
    return [[[self persistentDomain] objectForKey:kDictationIMMasterDictationEnabled] boolValue];
}

- (void)setOfflineUpgradeSuggestionPresented:(BOOL)flag
{
    [self addEntriesToPersistentDomainFromDictionary:@{
                                                       kDictationIMPresentedOfflineUpgradeSuggestion:[NSNumber numberWithBool:flag]
                                                       }];
}

- (BOOL)isOfflineUpgradeSuggestionPresented
{
    return [[[self persistentDomain] objectForKey:kDictationIMPresentedOfflineUpgradeSuggestion] boolValue];
}

@end

