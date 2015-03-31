//
//  MRStartViewController.m
//  MRTableBuilder
//
//  Created by Martin Rybak on 3/30/15.
//  Copyright (c) 2015 Martin Rybak. All rights reserved.
//

#import "MRStartViewController.h"

@interface MRStartViewController ()

@property (strong, nonatomic) UITableView* tableView;
@property (strong, nonatomic) MRTableBuilder* tableBuilder;

@end

@implementation MRStartViewController

- (void)loadView
{
	self.view = [[UIView alloc] init];
	self.tableView = [[UITableView alloc] init];
	[self.view addSubview:self.tableView];
	self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[tableView]|" options:0 metrics:nil views:@{ @"tableView":self.tableView }]];
	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[tableView]|" options:0 metrics:nil views:@{ @"tableView":self.tableView }]];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	[self loadTable];
}

- (void)loadTable
{
	//Create the table builder
	self.tableBuilder = [[MRTableBuilder alloc] init];
	
	//Create the first section
	MRTableSection* section = [[MRTableSection alloc] init];
	[self.tableBuilder addSection:section];
	
	//Create the first row
	MRTableRow* row1 = [[MRTableRow alloc] init];
	[section addRow:row1];
	row1.onConfigure = ^(UITableViewCell* cell) {
		cell.textLabel.text = @"Login Form";
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	};
	row1.onDidSelect = ^(NSIndexPath* indexPath) {
		[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
		[self selectSampleTableOption:MRSampleTableOptionLogin];
	};
	
	//Create the second row
	MRTableRow* row2 = [[MRTableRow alloc] init];
	[section addRow:row2];
	row2.onConfigure = ^(UITableViewCell* cell) {
		cell.textLabel.text = @"Variable Cell Heights";
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	};
	row2.onDidSelect = ^(NSIndexPath* indexPath) {
		[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
		[self selectSampleTableOption:MRSampleTableOptionVariableHeights];
	};
	
	[self.tableBuilder bindToTableView:self.tableView];
}

- (void)selectSampleTableOption:(MRSampleTableOption)option
{
	if (self.onSampleTableOptionSelected) {
		self.onSampleTableOptionSelected(option);
	}
}

@end
