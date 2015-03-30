//
//  MRTableHeaderFooter.m
//  MRTableBuilder
//
//  Created by Martin Rybak on 3/16/15.
//  Copyright (c) 2015 Martin Rybak. All rights reserved.
//

#import "MRTableHeaderFooter.h"
#import "MRTableSection.h"
#import "MRTableBuilder.h"

@implementation MRTableHeaderFooter

- (instancetype)initWithNib:(UINib*)nib reuseIdentifier:(NSString*)reuseIdentifier
{
	if (self = [super init]) {
		_viewNib = nib;
		_reuseIdentifier = reuseIdentifier;
	}
	return self;
}

- (instancetype)initWithClass:(Class)class reuseIdentifier:(NSString*)reuseIdentifier
{
	if (self = [super init]) {
		_viewClass = class;
		_reuseIdentifier = reuseIdentifier;
	}
	return self;
}

- (instancetype)initWithReuseIdentifier:(NSString*)reuseIdentifier
{
	if (self = [super init]) {
		_viewClass = [UITableViewHeaderFooterView class];
		_reuseIdentifier = reuseIdentifier;
	}
	return self;
}

- (instancetype)init
{
	if (self = [super init]) {
		_viewClass = [UITableViewHeaderFooterView class];
		_reuseIdentifier = [UITableViewHeaderFooterView description];
	}
	return self;
}

- (UITableViewHeaderFooterView*)buildView
{
	UITableViewHeaderFooterView* view = [self.section.tableBuilder.tableView dequeueReusableHeaderFooterViewWithIdentifier:self.reuseIdentifier];
	if (self.onConfigure) {
		self.onConfigure(view);
	}
	return view;
}

@end
