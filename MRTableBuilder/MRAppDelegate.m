//
//  MRAppDelegate.m
//  MRTableBuilder
//
//  Created by Martin Rybak on 3/28/15.
//  Copyright (c) 2015 Martin Rybak. All rights reserved.
//

#import "MRAppDelegate.h"
#import "MRTestViewController.h"
#import "MRSampleViewController.h"

@interface MRAppDelegate ()

@end

@implementation MRAppDelegate

- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
	self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
	UIViewController* viewController = [[MRTestViewController alloc] init];
	self.window.rootViewController = viewController;
	[self.window makeKeyAndVisible];
	return YES;
}

@end
