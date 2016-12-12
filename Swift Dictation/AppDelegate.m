//
//  AppDelegate.m
//  Swift Dictation
//
//  Created by 夏目夏樹 on 12/16/12.
//  Copyright (c) 2012 夏目夏樹. All rights reserved.
//

#import "AppDelegate.h"
#import "InputMethodManager.h"
#import "MasterDictationManager.h"
#import "NSLocale+Ext.h"
#import "LoginItem.h"

static NSString *const kAppUserDefaultOpenAtLogin = @"OpenAtLogin";
static NSString *const kAppUserDefaultShowDictationLanguage = @"ShowDictationLanguage";
static NSString *const kAppUserDefaultLocaleSupport = @"LocaleSupport";
static NSString *const kAppMenuItemLocaleIdentifier = @"LocaleIdentifier";
static NSString *const kAppMenuItemLanguage = @"Language";

@implementation AppDelegate

+ (void)initialize
{
    NSString *currentSystemVersion = [[NSDictionary dictionaryWithContentsOfFile:@"/System/Library/CoreServices/SystemVersion.plist"] objectForKey:@"ProductVersion"];
    NSDictionary *theDictationLocaleIdentifiersDictionary = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"LocaleSupport"
                                                                                                                                       ofType:@"plist"]];
    NSArray *defaultDictationLocaleIdentifiers = [theDictationLocaleIdentifiersDictionary objectForKey:@"LocaleSupport"];
    NSDictionary *minimumSystemVersion = [theDictationLocaleIdentifiersDictionary objectForKey:@"MinimumSystemVersion"];
    for (NSString *systemVersion in minimumSystemVersion) {
        if ([systemVersion compare:currentSystemVersion options:NSNumericSearch] == NSOrderedDescending) {
            defaultDictationLocaleIdentifiers = [defaultDictationLocaleIdentifiers filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSString *localeIdentifier, NSDictionary *bindings) {
                if ([[minimumSystemVersion objectForKey:systemVersion] containsObject:localeIdentifier]) {
                    return NO;
                }
                return YES;
            }]];
        }
    }

    NSArray *preferredLanguages = [NSLocale preferredLanguages];
    NSMutableArray *preferredCanonicalLocaleIdentifiers = [NSMutableArray arrayWithCapacity:[preferredLanguages count]];
    for (NSString *language in preferredLanguages) {
        [preferredCanonicalLocaleIdentifiers addObject:[NSLocale canonicalLocaleIdentifierFromString:language
                                                                                       forComponents:@[NSLocaleLanguageCode, NSLocaleScriptCode]]];
    }
    preferredLanguages = [preferredCanonicalLocaleIdentifiers copy];

    NSArray *enabledInputMethodLanguages = [[InputMethodManager defaultManager] enabledInputMethodLanguages];
    defaultDictationLocaleIdentifiers = [[defaultDictationLocaleIdentifiers filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSString *localeIdentifier, NSDictionary *bindings) {
        NSString *language = [NSLocale canonicalLocaleIdentifierFromString:localeIdentifier
                                                             forComponents:@[NSLocaleLanguageCode, NSLocaleScriptCode]];
        if ([preferredLanguages containsObject:language] &&
            [enabledInputMethodLanguages containsObject:language]) {
            return YES;
        }
        return NO;
    }]] sortedArrayUsingComparator:^(NSString *localeIdentifier1, NSString *localeIdentifier2) {
        NSInteger index1 = [preferredLanguages indexOfObject:[NSLocale canonicalLocaleIdentifierFromString:localeIdentifier1
                                                                                             forComponents:@[NSLocaleLanguageCode, NSLocaleScriptCode]]];
        NSInteger index2 = [preferredLanguages indexOfObject:[NSLocale canonicalLocaleIdentifierFromString:localeIdentifier2
                                                                                             forComponents:@[NSLocaleLanguageCode, NSLocaleScriptCode]]];
        if (index1 > index2) {
            return NSOrderedDescending;
        }
        if (index1 < index2) {
            return NSOrderedAscending;
        }
        return NSOrderedSame;
    }];

    [[NSUserDefaults standardUserDefaults] registerDefaults:@{
                                                              kAppUserDefaultShowDictationLanguage:@YES,
                                                              kAppUserDefaultLocaleSupport:defaultDictationLocaleIdentifiers
                                                              }];

    [[NSUserDefaults standardUserDefaults] setObject:[defaultDictationLocaleIdentifiers sortedArrayUsingComparator:^NSComparisonResult(NSString *localeIdentifier1, NSString *localeIdentifier2) {
        if ([[NSLocale canonicalLocaleIdentifierFromString:localeIdentifier1
                                             forComponents:@[NSLocaleLanguageCode, NSLocaleScriptCode]] isEqualToString:[NSLocale canonicalLocaleIdentifierFromString:localeIdentifier1
                                                                                                                                                        forComponents:@[NSLocaleLanguageCode, NSLocaleScriptCode]]]) {
            NSInteger index1 = [[[NSUserDefaults standardUserDefaults] arrayForKey:kAppUserDefaultLocaleSupport] indexOfObject:localeIdentifier1];
            NSInteger index2 = [[[NSUserDefaults standardUserDefaults] arrayForKey:kAppUserDefaultLocaleSupport] indexOfObject:localeIdentifier2];
            if (index1 > index2) {
                return NSOrderedDescending;
            }
            if (index1 < index2) {
                return NSOrderedAscending;
            }
        }
        return NSOrderedSame;
    }] forKey:kAppUserDefaultLocaleSupport];
}

- (void)awakeFromNib
{
    [openAtLoginMenuItem bind:@"value"
                     toObject:[LoginItem loginItemWithBundleIdentifier:[[NSBundle bundleWithPath:[[[[[[NSBundle mainBundle] bundlePath]
                                                                                                     stringByAppendingPathComponent:@"Contents"]
                                                                                                    stringByAppendingPathComponent:@"Library"]
                                                                                                   stringByAppendingPathComponent:@"LoginItems"]
                                                                                                  stringByAppendingPathComponent:@"Swift Dictation Login Helper.app"]] bundleIdentifier]]
                  withKeyPath:@"self.enabled"
                      options:nil];

    NSArray *localeIdentifiers = [[NSUserDefaults standardUserDefaults] arrayForKey:kAppUserDefaultLocaleSupport];
    NSDictionary *preferedLocaleIdentifiers = [self preferedLocaleIdentifiers];
    NSMutableArray *menuItems = [NSMutableArray array];

    for (NSString *localeIdentifier in localeIdentifiers) {
        NSString *language = [NSLocale canonicalLocaleIdentifierFromString:localeIdentifier
                                                             forComponents:@[NSLocaleLanguageCode, NSLocaleScriptCode]];
        if ([localeIdentifier isEqualToString:[preferedLocaleIdentifiers objectForKey:language]]) {
            [menuItems addObject:[[NSMenuItem alloc] initWithTitle:[[NSLocale currentLocale] displayNameForKey:NSLocaleIdentifier
                                                                                                         value:language]
                                                            action:nil
                                                     keyEquivalent:@""]];
        }
        NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:[[NSLocale currentLocale] displayNameForKey:NSLocaleCountryCode
                                                                                                       value:[[NSLocale componentsFromLocaleIdentifier:localeIdentifier] objectForKey:NSLocaleCountryCode]]
                                                          action:@selector(languageMenuItemAction:)
                                                   keyEquivalent:@""];
        [menuItem setIndentationLevel:1];
        [menuItem setRepresentedObject:@{
                                         kAppMenuItemLocaleIdentifier:localeIdentifier,
                                         kAppMenuItemLanguage:language
                                         }];
        [menuItems addObject:menuItem];
    }

    if ([menuItems count] > 0) {
        [menuItems addObject:[NSMenuItem separatorItem]];
    }
    [menuItems enumerateObjectsWithOptions:NSEnumerationReverse
                                usingBlock:^(NSMenuItem *menuItem, NSUInteger idx, BOOL *stop) {
                                    [mainMenu insertItem:menuItem atIndex:0];
                                }];

    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    if ([statusItem respondsToSelector:@selector(button)]) {
        NSImage *image = [NSImage imageNamed:@"StatusItemImage"];
        [image setTemplate:YES];
        [[statusItem button] setImagePosition:NSImageOnly];
        [[statusItem button] setImage:image];
    } else {
        [statusItem setHighlightMode:YES];
        [statusItem setImage:[NSImage imageNamed:@"StatusItemImage"]];
        [statusItem setAlternateImage:[NSImage imageNamed:@"StatusItemAlternateImage"]];
    }
    [statusItem setMenu:mainMenu];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    void (^inputMethodDidChange)(NSNotification *) = ^(NSNotification *aNotification){
        if ([[MasterDictationManager defaultManager] isEnabled]) {
            NSString *selectedInputMethodLanguage = [[InputMethodManager defaultManager] language];
            if (![[[InputMethodManager defaultManager] bundleIdentifier] isEqualToString:kDictationIMBundleIdentifier] &&
                ![selectedInputMethodLanguage isEqualToString:lastSelectedInputMethodLanguage]) {
                lastSelectedInputMethodLanguage = selectedInputMethodLanguage;

                NSString *dictationLocaleIdentifier;
                for (NSString *localeIdentifier in [[NSUserDefaults standardUserDefaults] objectForKey:kAppUserDefaultLocaleSupport]) {
                    if ([selectedInputMethodLanguage isEqualToString:[NSLocale canonicalLocaleIdentifierFromString:localeIdentifier
                                                                                                     forComponents:@[NSLocaleLanguageCode, NSLocaleScriptCode]]]) {
                        dictationLocaleIdentifier = localeIdentifier;
                        break;
                    }
                }
                if (!dictationLocaleIdentifier) {
                    dictationLocaleIdentifier = [[[NSUserDefaults standardUserDefaults] arrayForKey:kAppUserDefaultLocaleSupport] objectAtIndex:0];
                }

                [[MasterDictationManager defaultManager] setLocaleIdentifier:[NSLocale canonicalLocaleIdentifierFromString:dictationLocaleIdentifier
                                                                                                             forComponents:@[NSLocaleLanguageCode, NSLocaleCountryCode]]];
                [[MasterDictationManager defaultManager] terminate];
            }
        }
        [self setStatusItemTitle];
    };

    [[NSNotificationCenter defaultCenter] addObserverForName:NSTextInputContextKeyboardSelectionDidChangeNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:inputMethodDidChange];

    inputMethodDidChange(nil);
}

- (void)setStatusItemTitle
{
    NSAttributedString *title = nil;
    if ([[MasterDictationManager defaultManager] isEnabled] && [[NSUserDefaults standardUserDefaults] boolForKey:kAppUserDefaultShowDictationLanguage]) {
        title = [[NSAttributedString alloc] initWithString:[@" " stringByAppendingString:[[NSLocale currentLocale] displayNameForKey:NSLocaleIdentifier
                                                                                                                               value:[[MasterDictationManager defaultManager] localeIdentifier]]]
                                                attributes:@{
                                                             NSFontAttributeName:[NSFont systemFontOfSize:11]
                                                             }];
    }
    if ([statusItem respondsToSelector:@selector(button)]) {
        [[statusItem button] setImagePosition:title == nil ? NSImageOnly : NSImageLeft];
        [[statusItem button] setAttributedTitle:title];
    } else {
        [statusItem setAttributedTitle:title];
    }
}

- (NSDictionary *)preferedLocaleIdentifiers
{
    NSMutableDictionary *preferedLocaleIdentifiers = [NSMutableDictionary dictionary];
    for (NSString *localeIdentifier in [[NSUserDefaults standardUserDefaults] arrayForKey:kAppUserDefaultLocaleSupport]) {
        NSString *language = [NSLocale canonicalLocaleIdentifierFromString:localeIdentifier
                                                             forComponents:@[NSLocaleLanguageCode, NSLocaleScriptCode]];
        if (![preferedLocaleIdentifiers objectForKey:language]) {
            [preferedLocaleIdentifiers setObject:localeIdentifier forKey:language];
        }
    }
    return [preferedLocaleIdentifiers copy];
}

- (void)menuNeedsUpdate:(NSMenu *)menu
{
    if (menu == mainMenu) {
        NSDictionary *preferedLocaleIdentifiers = [self preferedLocaleIdentifiers];
        for (NSMenuItem *menuItem in [menu itemArray]) {
            NSString *localeIdentifier = [[menuItem representedObject] objectForKey:kAppMenuItemLocaleIdentifier];
            if (localeIdentifier) {
                if ([localeIdentifier isEqualToString:[preferedLocaleIdentifiers objectForKey:[[menuItem representedObject] objectForKey:kAppMenuItemLanguage]]]) {
                    [menuItem setState:NSOnState];
                } else {
                    [menuItem setState:NSOffState];
                }
            }
        }
        if ([[NSUserDefaults standardUserDefaults] boolForKey:kAppUserDefaultShowDictationLanguage]) {
            [showDictationLanguageInStatusbarMenuItem setHidden:YES];
            [hideDictationLanguageInStatusbarMenuItem setHidden:NO];
        } else {
            [hideDictationLanguageInStatusbarMenuItem setHidden:YES];
            [showDictationLanguageInStatusbarMenuItem setHidden:NO];
        }
    }
}

- (void)languageMenuItemAction:(id)sender
{
    NSMutableArray *localeIdentifiers = [[[NSUserDefaults standardUserDefaults] arrayForKey:kAppUserDefaultLocaleSupport] mutableCopy];
    NSInteger idx1 = [localeIdentifiers indexOfObject:[[sender representedObject] objectForKey:kAppMenuItemLocaleIdentifier]];
    NSInteger idx2 = [localeIdentifiers indexOfObject:[[self preferedLocaleIdentifiers] objectForKey:[[sender representedObject] objectForKey:kAppMenuItemLanguage]]];
    if (idx1 != idx2) {
        [localeIdentifiers exchangeObjectAtIndex:idx1 withObjectAtIndex:idx2];
        [[NSUserDefaults standardUserDefaults] setObject:localeIdentifiers
                                                  forKey:kAppUserDefaultLocaleSupport];
        [[NSUserDefaults standardUserDefaults] synchronize];

        lastSelectedInputMethodLanguage = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:NSTextInputContextKeyboardSelectionDidChangeNotification
                                                            object:self];
    }
}


- (IBAction)toggleDictationLanguageInStatusbarAction:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setBool:![[NSUserDefaults standardUserDefaults] boolForKey:kAppUserDefaultShowDictationLanguage]
                                            forKey:kAppUserDefaultShowDictationLanguage];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self setStatusItemTitle];
}

- (IBAction)openDictationAndSpeechPreferencesAction:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL fileURLWithPath:@"/System/Library/PreferencePanes/Speech.prefPane"]];
}

@end
