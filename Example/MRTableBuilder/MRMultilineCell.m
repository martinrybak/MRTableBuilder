//
//  MRMultilineCell.m
//  MRTableBuilder
//
//  Created by Martin Rybak on 3/19/15.
//  Copyright (c) 2015 ServiceTask. All rights reserved.
//

#import "MRMultilineCell.h"

@implementation MRMultilineCell

#pragma mark - Public

- (void)layoutSubviews
{
	[super layoutSubviews];
	[self.contentView updateConstraintsIfNeeded];
	[self.contentView layoutIfNeeded];
	self.valueLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.valueLabel.bounds);
}

@end
