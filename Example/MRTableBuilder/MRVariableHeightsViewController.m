//
//  MRVariableHeightsViewController.m
//  MRTableBuilder
//
//  Created by Martin Rybak on 3/31/15.
//  Copyright (c) 2015 Martin Rybak. All rights reserved.
//

#import "MRVariableHeightsViewController.h"
#import "MRTableBuilder.h"
#import "MRMultilineCell.h"

NSUInteger const MRVariableHeightsViewControllerRowCount = 10;

@interface MRVariableHeightsViewController ()

@property (strong, nonatomic) UITableView* tableView;
@property (strong, nonatomic) MRTableBuilder* tableBuilder;
@property (strong, nonatomic) NSArray* data;

@end

@implementation MRVariableHeightsViewController

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
	[self loadData];
	[self loadTable];
}

- (void)loadData
{
	NSMutableArray* output = [NSMutableArray array];
	for (NSInteger i = 0; i < MRVariableHeightsViewControllerRowCount; i++) {
		[output addObject:[self randomWords]];
	}
	self.data = [output copy];
}

- (void)loadTable
{
	//Create the table builder
	self.tableBuilder = [[MRTableBuilder alloc] init];
	
	//Create the first section
	MRTableSection* section = [[MRTableSection alloc] init];
	[self.tableBuilder addSection:section];
	
	//Create 10 rows with random text
	for (NSInteger i = 0; i < self.data.count; i++) {
		MRTableRow* row = [[MRTableRow alloc] initWithNib:[UINib nibWithNibName:[MRMultilineCell description] bundle:nil] reuseIdentifier:[MRMultilineCell description]];
		row.shouldHighlight = @(NO);
		row.onConfigure = ^(MRMultilineCell* cell) {
			cell.keyLabel.text = [self.data[i] substringToIndex:MIN(30, [self.data[i] length])];
			cell.valueLabel.text = self.data[i];
		};
		[section addRow:row];
	}

	[self.tableBuilder bindToTableView:self.tableView];
}

/**
 *  Returns between 5 and 100 random words
 *
 *  @return NSString
 */
- (NSString*)randomWords
{
	int count = arc4random_uniform(95) + 5;
	NSArray* words = @[ @"Lorem", @"ipsum", @"dolor", @"sit", @"amet", @"consectetur", @"adipiscing", @"elit", @"sed", @"do", @"eiusmod", @"tempor", @"incididunt" ];
	NSMutableArray* output = [NSMutableArray array];
	for (int i = 0; i < count; i++) {
		int randomIndex = arc4random_uniform(words.count);
		[output addObject:words[randomIndex]];
	}
	return [output componentsJoinedByString:@" "];
}

@end
