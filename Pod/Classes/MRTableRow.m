//
//  MRTableRow.m
//  MRTableBuilder
//
//  Created by Martin Rybak on 3/11/15.
//  Copyright (c) 2015 Martin Rybak. All rights reserved.
//

#import "MRTableRow.h"
#import "MRTableSection.h"
#import "MRTableBuilder.h"

@implementation MRTableRow

- (instancetype)initWithNib:(UINib*)nib reuseIdentifier:(NSString*)reuseIdentifier
{
	if (self = [super init]) {
		_cellNib = nib;
		_reuseIdentifier = reuseIdentifier;
	}
	return self;
}

- (instancetype)initWithClass:(Class)class reuseIdentifier:(NSString*)reuseIdentifier
{
	if (self = [super init]) {
		_cellClass = class;
		_reuseIdentifier = reuseIdentifier;
	}
	return self;
}

- (instancetype)initWithClass:(Class)class
{
	if (self = [super init]) {
		_cellClass = class;
		_reuseIdentifier = [class description];
	}
	return self;
}

- (instancetype)initWithReuseIdentifier:(NSString*)reuseIdentifier
{
	if (self = [super init]) {
		_cellClass = [UITableViewCell class];
		_reuseIdentifier = reuseIdentifier;
	}
	return self;
}

- (instancetype)init
{
	if (self = [super init]) {
		_cellClass = [UITableViewCell class];
		_reuseIdentifier = [UITableViewCell description];
	}
	return self;
}

- (UITableViewCell*)buildCellWithIndexPath:(NSIndexPath*)indexPath
{
	UITableViewCell* cell = [self.section.tableBuilder.tableView dequeueReusableCellWithIdentifier:self.reuseIdentifier forIndexPath:indexPath];
	cell.bounds = CGRectMake(0.0f, 0.0f, self.section.tableBuilder.tableView.bounds.size.width, cell.bounds.size.height);
	[self configureCell:cell];
	return cell;
}

- (UITableViewCell*)buildCell
{
	UITableView* tableView = self.section.tableBuilder.tableView;
	UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:self.reuseIdentifier];
	
	//Trigger an auto layout pass to update the table's bounds
	[tableView layoutIfNeeded];
	
	//Manually set the cell bounds using the table width
	cell.bounds = CGRectMake(0.0f, 0.0f, tableView.bounds.size.width, cell.bounds.size.height);
	
	//Update the cell contents
	[self configureCell:cell];
	
	//Trigger an auto layout pass on the cell
	[cell layoutIfNeeded];
	
	return cell;
}

- (void)configureCell:(UITableViewCell*)cell
{
	if (self.onConfigure) {
		self.onConfigure(cell);
	}
}

@end
