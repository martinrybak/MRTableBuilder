//
//  MRStartViewController.h
//  MRTableBuilder
//
//  Created by Martin Rybak on 3/30/15.
//  Copyright (c) 2015 Martin Rybak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MRTableBuilder.h"

typedef NS_ENUM(NSUInteger, MRSampleTableOption) {
	MRSampleTableOptionLogin,
	MRSampleTableOptionVariableHeights
};

@interface MRStartViewController : UIViewController

@property (copy, nonatomic) void(^onSampleTableOptionSelected)(MRSampleTableOption option);

@end
