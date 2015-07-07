//
//  MRTableBuilder.h
//  MRTableBuilder
//
//  Created by Martin Rybak on 3/16/15.
//  Copyright (c) 2015 Martin Rybak. All rights reserved.
//

#import "MRTableSection.h"

extern CGFloat const MRTableBuilderDefaultRowHeight;

@interface MRTableBuilder : NSObject <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic, readonly) UITableView* tableView;
@property (strong, nonatomic) NSMutableArray* sections;
@property (copy, nonatomic) NSArray* sectionIndexTitles;
@property (copy, nonatomic) NSInteger(^sectionForSectionIndex)(NSString* title, NSInteger index);
@property (copy, nonatomic) NSIndexPath*(^targetIndexPathForMove)(NSIndexPath* sourceIndexPath, NSIndexPath* proposedDestinationIndexPath);
@property (copy, nonatomic) void(^onMoveRow)(NSIndexPath* sourceIndexPath, NSIndexPath* destinationIndexPath);
- (instancetype)init;
- (void)bindToTableView:(UITableView*)tableView;
- (void)addSection:(MRTableSection*)section;
- (void)removeSection:(MRTableSection*)section;
- (void)clear;
- (id)cellForRow:(MRTableRow*)row;
- (NSIndexPath*)indexPathForRow:(MRTableRow*)aRow;
- (void)reloadRow:(MRTableRow*)row;
- (void)reloadRow:(MRTableRow*)row withAnimation:(UITableViewRowAnimation)animation;
- (void)reloadRows:(NSArray*)rows;
- (void)reloadRows:(NSArray*)rows withAnimation:(UITableViewRowAnimation)animation;
- (void)registerRow:(MRTableRow*)row;
- (void)registerSection:(MRTableSection*)section;

@end
