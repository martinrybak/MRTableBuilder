//
//  MRTestViewController.m
//  MRTableBuilder
//
//  Created by Martin Rybak on 3/29/15.
//  Copyright (c) 2015 Martin Rybak. All rights reserved.
//

#import "MRTestViewController.h"

@interface MRTestViewController ()

@property (strong, nonatomic) UITableView* tableView;
@property (strong, nonatomic) NSMutableArray* rows;

@end

@implementation MRTestViewController

- (void)loadView
{
	self.rows = [NSMutableArray array];
	for (NSUInteger i = 0; i < 5; i++) {
		[self.rows addObject:@(i)];
	}
	
	self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
	self.tableView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds];
	self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
	[self.tableView setEditing:YES];
	self.tableView.dataSource = self;
	self.tableView.delegate = self;
	self.tableView.editing = YES;
	[self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:[UITableViewCell description]];
	[self.view addSubview:self.tableView];

	self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];
}

- (UIRectEdge)edgesForExtendedLayout
{
	return UIRectEdgeNone;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
	if (section == 0) {
		return self.rows.count;
	}
	return 5;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
	if (indexPath.section == 0) {
		UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:[UITableViewCell description]];
		NSNumber* number = self.rows[indexPath.row];
		cell.textLabel.text = [NSString stringWithFormat:@"Cell %@", number];
		return cell;
	}
	UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:[UITableViewCell description]];
	cell.textLabel.text = @"Extra cell";
	return cell;
}

- (void)tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath
{
	if (indexPath.section == 0 && editingStyle == UITableViewCellEditingStyleDelete) {
		[tableView beginUpdates];
		[self.rows removeObject:self.rows[indexPath.row]];
		[tableView deleteRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationAutomatic];
		[tableView endUpdates];
	}
}

- (BOOL)tableView:(UITableView*)tableView canEditRowAtIndexPath:(NSIndexPath*)indexPath
{
	return indexPath.section == 0;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return @"Header";
}

- (NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
	return @"Footer";
}

@end
