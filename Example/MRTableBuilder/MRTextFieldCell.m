//
//  MRTextFieldCell.m
//  MRTableBuilder
//
//  Created by Martin Rybak on 3/30/15.
//  Copyright (c) 2015 Martin Rybak. All rights reserved.
//

#import "MRTextFieldCell.h"

@implementation MRTextFieldCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier
{
	if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
		self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
		_textField = [[UITextField alloc] init];
		_textField.translatesAutoresizingMaskIntoConstraints = NO;
		[self.contentView addSubview:_textField];
		[self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[textField]-0-|" options:0 metrics:nil views:@{ @"textField": self.textField }]];
		[self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[textField]-0-|" options:0 metrics:nil views:@{ @"textField": self.textField }]];
	}
	return self;
}

@end
