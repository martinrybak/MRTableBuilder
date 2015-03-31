//
//  MRAppDelegate.m
//  MRTableBuilder
//
//  Created by Martin Rybak on 3/28/15.
//  Copyright (c) 2015 Martin Rybak. All rights reserved.
//

#import "MRAppDelegate.h"
#import "MRStartViewController.h"
#import "MRVariableHeightsViewController.h"
#import "MRLoginViewController.h"

@interface MRAppDelegate ()

@property (strong, nonatomic) UINavigationController* navigationController;

@end

@implementation MRAppDelegate

- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
	self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
	MRStartViewController* startViewController = [[MRStartViewController alloc] init];
	startViewController.title = @"Table Samples";
	startViewController.onSampleTableOptionSelected = ^(MRSampleTableOption option) {
		[self showSampleTableOption:option];
	};
	self.navigationController = [[UINavigationController alloc] initWithRootViewController:startViewController];
	self.navigationController.navigationBar.translucent = NO;
	
	self.window.rootViewController = self.navigationController;
	[self.window makeKeyAndVisible];
	return YES;
}

- (void)showSampleTableOption:(MRSampleTableOption)option
{
	Class class;
	switch (option)
	{
		case MRSampleTableOptionLogin:
			class = [MRLoginViewController class];
			break;
		case MRSampleTableOptionVariableHeights:
			class = [MRVariableHeightsViewController class];
			break;
	}
	
	UIViewController* viewController = [[class alloc] init];
	viewController.title = [class description];
	[self.navigationController pushViewController:viewController animated:YES];
}

@end
