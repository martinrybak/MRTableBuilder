//
//  MRTableSection.h
//  MRTableBuilder
//
//  Created by Martin Rybak on 3/16/15.
//  Copyright (c) 2015 Martin Rybak. All rights reserved.
//

#import "MRTableRow.h"
#import "MRTableHeaderFooter.h"

@class MRTableBuilder;

@interface MRTableSection : NSObject <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) MRTableBuilder* tableBuilder;
@property (strong, nonatomic) NSMutableArray* rows;
@property (copy, nonatomic) NSString* headerTitle;
@property (copy, nonatomic) NSString* footerTitle;
@property (assign, nonatomic) CGFloat headerHeight;
@property (assign, nonatomic) CGFloat footerHeight;
@property (strong, nonatomic) MRTableHeaderFooter* header;
@property (strong, nonatomic) MRTableHeaderFooter* footer;
@property (copy, nonatomic) void(^onWillDisplayHeader)(id view);
@property (copy, nonatomic) void(^onWillDisplayFooter)(id view);
@property (copy, nonatomic) void(^onDidEndDisplayingHeader)(id view);
@property (copy, nonatomic) void(^onDidEndDisplayingFooter)(id view);

- (instancetype)init;
- (void)addRow:(MRTableRow*)row;
- (void)addRow:(MRTableRow*)row withAnimation:(UITableViewRowAnimation)animation;
- (void)removeRow:(MRTableRow*)row;
- (void)removeRow:(MRTableRow*)row withAnimation:(UITableViewRowAnimation)animation;
- (void)insertRow:(MRTableRow*)row afterRow:(MRTableRow*)afterRow;
- (void)insertRow:(MRTableRow*)row afterRow:(MRTableRow*)afterRow withAnimation:(UITableViewRowAnimation)animation;

@end
