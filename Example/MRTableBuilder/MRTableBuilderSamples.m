//
//  MRTableBuilderSamples.m
//  MRTableBuilder
//
//  Created by Martin Rybak on 3/29/15.
//  Copyright (c) 2015 Martin Rybak. All rights reserved.
//

#import "MRTableBuilderSamples.h"

@implementation MRTableBuilderSamples

+ (MRTableBuilder*)form1
{
	MRTableBuilder* tableBuilder = [[MRTableBuilder alloc] init];
	
	MRTableSection* section = [[MRTableSection alloc] init];
	[tableBuilder addSection:section];
	
	for (NSUInteger i = 0; i < 100; i++) {
		MRTableRow* row = [[MRTableRow alloc] init];
		row.onConfigure = ^(UITableViewCell* cell) {
			cell.textLabel.text = [NSString stringWithFormat:@"Cell %d", i];
		};
		[section addRow:row];
	}
	
	return tableBuilder;
}

+ (MRTableBuilder*)form2
{
	MRTableBuilder* tableBuilder = [[MRTableBuilder alloc] init];
	
	MRTableSection* section = [[MRTableSection alloc] init];
	section.headerTitle = @"Header";
	section.footerTitle = @"Footer";
	[tableBuilder addSection:section];
	
	for (NSUInteger i = 0; i < 100; i++) {
		MRTableRow* row = [[MRTableRow alloc] init];
		row.onConfigure = ^(UITableViewCell* cell) {
			cell.textLabel.text = [NSString stringWithFormat:@"Cell %d", i];
		};
		[section addRow:row];
	}
	
	return tableBuilder;
}

+ (MRTableBuilder*)form3
{
	MRTableBuilder* tableBuilder = [[MRTableBuilder alloc] init];
	
	MRTableSection* section1 = [[MRTableSection alloc] init];
	section1.header = [[MRTableHeaderFooter alloc] init];
	section1.header.onConfigure = ^(UITableViewHeaderFooterView* view) {
		view.textLabel.text = @"Section 1";
	};
	[tableBuilder addSection:section1];
	
	MRTableRow* row1 = [[MRTableRow alloc] init];
	row1.height = 80.0;
	row1.onConfigure = ^(UITableViewCell* cell) {
		cell.textLabel.text = @"row 1";
	};
	row1.onDidSelect = ^(NSIndexPath* indexPath){
		NSLog(@"you selected row 1");
		[tableBuilder.tableView deselectRowAtIndexPath:indexPath animated:YES];
	};
	[section1 addRow:row1];
	
	MRTableSection* section2 = [[MRTableSection alloc] init];
	section2.headerTitle = @"Section 2";
	section2.headerHeight = 60.0;
	[tableBuilder addSection:section2];
	
	MRTableRow* row2 = [[MRTableRow alloc] init];
	row2.height = 50.0;
	row2.onConfigure = ^(UITableViewCell* cell) {
		cell.textLabel.text = @"row 2";
	};
	row2.onDidSelect = ^(NSIndexPath* indexPath){
		NSLog(@"you selected row 2");
		[tableBuilder.tableView deselectRowAtIndexPath:indexPath animated:YES];
	};
	[section2 addRow:row2];
	
	MRTableSection* section3 = [[MRTableSection alloc] init];
	section3.headerTitle = @"Section 3 Header";
	section3.footerTitle = @"Section 3 Footer";
	section3.headerHeight = 40.0;
	section3.footerHeight = 40.0;
	[tableBuilder addSection:section3];
	
	MRTableRow* row3 = [[MRTableRow alloc] init];
	row3.height = 80.0;
	row3.canMove = @(YES);
	row3.onConfigure = ^(UITableViewCell* cell) {
		cell.textLabel.text = @"row 3";
	};
	row3.onDidSelect = ^(NSIndexPath* indexPath){
		NSLog(@"you selected row 3");
		[tableBuilder.tableView deselectRowAtIndexPath:indexPath animated:YES];
	};
	[section3 addRow:row3];
	
	MRTableRow* row4 = [[MRTableRow alloc] init];
	row4.editingStyle = @(UITableViewCellEditingStyleInsert);
	[section3 addRow:row4];
	
	return tableBuilder;
}

@end
