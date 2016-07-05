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
@property (assign, nonatomic) BOOL useEstimatedHeaderHeights;
@property (assign, nonatomic) BOOL useEstimatedFooterHeights;
@property (assign, nonatomic) BOOL useHeaderViews;
@property (assign, nonatomic) BOOL useFooterViews;
@property (assign, nonatomic) BOOL useHeaderHeights;
@property (assign, nonatomic) BOOL useFooterHeights;
@property (assign, nonatomic) BOOL hasTitlesForDeleteConfirmationButtons;
@property (assign, nonatomic) BOOL useEditActions;
@property (assign, nonatomic) BOOL useHighlights;
@property (assign, nonatomic) BOOL useIndents;
@property (assign, nonatomic) BOOL useEditRows;
@property (assign, nonatomic) BOOL useMoveRows;
@property (assign, nonatomic) BOOL useMenus;
@property (assign, nonatomic) BOOL useEditingStyles;
@property (assign, nonatomic) BOOL useIndentationLevels;

- (instancetype)init;
- (void)bindToTableView:(UITableView*)tableView;
- (void)addSection:(MRTableSection*)section;
- (void)addSection:(MRTableSection*)section withAnimation:(UITableViewRowAnimation)animation;
- (void)insertSection:(MRTableSection*)section atIndex:(NSUInteger)index;
- (void)insertSection:(MRTableSection*)section aboveSection:(MRTableSection*)aboveSection;
- (void)insertSection:(MRTableSection*)section belowSection:(MRTableSection*)belowSection;
- (void)insertSections:(NSArray*)sections belowSection:(MRTableSection*)belowSection;
- (void)insertSections:(NSArray*)sections aboveSection:(MRTableSection*)aboveSection;
- (void)insertSection:(MRTableSection*)section atIndex:(NSUInteger)index withAnimation:(UITableViewRowAnimation)animation;
- (void)insertSection:(MRTableSection*)section aboveSection:(MRTableSection*)aboveSection withAnimation:(UITableViewRowAnimation)animation;
- (void)insertSection:(MRTableSection*)section belowSection:(MRTableSection*)belowSection withAnimation:(UITableViewRowAnimation)animation;
- (void)insertSections:(NSArray*)sections belowSection:(MRTableSection*)belowSection withAnimation:(UITableViewRowAnimation)animation;
- (void)insertSections:(NSArray*)sections aboveSection:(MRTableSection*)aboveSection withAnimation:(UITableViewRowAnimation)animation;
- (void)removeSection:(MRTableSection*)section;
- (void)removeSection:(MRTableSection*)section withAnimation:(UITableViewRowAnimation)animation;
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
