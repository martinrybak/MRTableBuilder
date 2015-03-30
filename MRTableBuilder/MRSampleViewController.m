//
//  MRSampleViewController.m
//  MRTableBuilder
//
//  Created by Martin Rybak on 3/28/15.
//  Copyright (c) 2015 Martin Rybak. All rights reserved.
//

#import "MRSampleViewController.h"
#import "MRTableBuilderSamples.h"

@interface MRSampleViewController ()

@property (strong, nonatomic) UITableView* tableView;
@property (strong, nonatomic) MRTableBuilder* tableBuilder;

@end

@implementation MRSampleViewController

- (void)loadView
{
	self.tableBuilder = [MRTableBuilderSamples form3];
	self.view = [[UIView alloc] init];
	self.tableView = [[UITableView alloc] init];
	[self.view addSubview:self.tableView];
	self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1 constant:0]];
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
	[self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.tableView.editing = YES;
	self.tableView.allowsSelectionDuringEditing = YES;
	[self.tableBuilder bindToTableView:self.tableView];
}

- (UIRectEdge)edgesForExtendedLayout
{
	return UIRectEdgeNone;
}

@end
