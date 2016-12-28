//
//  MRTableHeaderFooter.h
//  MRTableBuilder
//
//  Created by Martin Rybak on 3/16/15.
//  Copyright (c) 2015 Martin Rybak. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MRTableSection;

@interface MRTableHeaderFooter : NSObject

@property (weak, nonatomic) MRTableSection* section;
@property (strong, nonatomic) UINib* viewNib;
@property (strong, nonatomic) Class viewClass;
@property (copy, nonatomic) NSString* reuseIdentifier;
@property (assign, nonatomic) CGFloat height;
@property (assign, nonatomic) CGFloat estimatedHeight;
@property (copy, nonatomic) void(^onConfigure)(id);
- (instancetype)initWithNib:(UINib*)nib reuseIdentifier:(NSString*)reuseIdentifier;
- (instancetype)initWithClass:(Class)class reuseIdentifier:(NSString*)reuseIdentifier;
- (instancetype)initWithClass:(Class)class;
- (instancetype)initWithReuseIdentifier:(NSString*)reuseIdentifier;
- (instancetype)init;
- (UITableViewHeaderFooterView*)buildView;

@end
