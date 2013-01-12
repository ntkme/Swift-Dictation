//
//  main.m
//  Dictation Login Helper
//
//  Created by 夏目夏樹 on 12/16/12.
//  Copyright (c) 2012 夏目夏樹. All rights reserved.
//

#import <Cocoa/Cocoa.h>

int main(int argc, char *argv[])
{
    NSString *bundlePath = [[[[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent] stringByDeletingLastPathComponent] stringByDeletingLastPathComponent] stringByDeletingLastPathComponent];
    if ([[NSRunningApplication runningApplicationsWithBundleIdentifier:[[NSBundle bundleWithPath:bundlePath] bundleIdentifier]] count]==0) {
        [[NSWorkspace sharedWorkspace] launchApplication:bundlePath];
    }
    return 0;
}
