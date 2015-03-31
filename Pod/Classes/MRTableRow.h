//
//  MRTableRow.h
//  MRTableBuilder
//
//  Created by Martin Rybak on 3/11/15.
//  Copyright (c) 2015 Martin Rybak. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MRTableSection;

@interface MRTableRow : NSObject

@property (weak, nonatomic) MRTableSection* section;
@property (strong, nonatomic) Class cellClass;
@property (strong, nonatomic) UINib* cellNib;
@property (copy, nonatomic) NSString* reuseIdentifier;
@property (assign, nonatomic) CGFloat height;
@property (assign, nonatomic) CGFloat estimatedHeight;
@property (strong, nonatomic) NSNumber* canEdit;
@property (strong, nonatomic) NSNumber* canMove;
@property (strong, nonatomic) NSNumber* shouldHighlight;
@property (strong, nonatomic) NSNumber* shouldIndentWhileEditing;
@property (strong, nonatomic) NSNumber* editingStyle;
@property (strong, nonatomic) NSNumber* indentationLevel;
@property (strong, nonatomic) NSNumber* shouldShowMenu;
@property (copy, nonatomic) NSString* titleForDeleteConfirmationButton;
@property (copy, nonatomic) NSArray* editActions;
@property (copy, nonatomic) void(^onConfigure)(id cell);
@property (copy, nonatomic) void(^onCommitDelete)(void);
@property (copy, nonatomic) void(^onCommitInsert)(void);
@property (copy, nonatomic) void(^onAccessoryButtonTapped)(void);
@property (copy, nonatomic) void(^onWillDisplay)(id cell);
@property (copy, nonatomic) void(^onDidEndDisplaying)(id cell);
@property (copy, nonatomic) void(^onDidHighlight)(void);
@property (copy, nonatomic) void(^onDidUnhighlight)(void);
@property (copy, nonatomic) NSIndexPath*(^onWillSelect)(NSIndexPath* indexPath);
@property (copy, nonatomic) NSIndexPath*(^onWillDeselect)(NSIndexPath* indexPath);
@property (copy, nonatomic) void(^onDidSelect)(NSIndexPath* indexPath);
@property (copy, nonatomic) void(^onDidDeselect)(NSIndexPath* indexPath);
@property (copy, nonatomic) void(^onWillBeginEditing)(void);
@property (copy, nonatomic) void(^onDidEndEditing)(void);
@property (copy, nonatomic) BOOL(^canPerformAction)(SEL action, id sender);
@property (copy, nonatomic) void(^onPerformAction)(SEL action, id sender);

- (instancetype)initWithNib:(UINib*)nib reuseIdentifier:(NSString*)reuseIdentifier;
- (instancetype)initWithClass:(Class)class reuseIdentifier:(NSString*)reuseIdentifier;
- (instancetype)initWithClass:(Class)class;
- (instancetype)initWithReuseIdentifier:(NSString*)reuseIdentifier;
- (instancetype)init;
- (UITableViewCell*)buildCellWithIndexPath:(NSIndexPath*)indexPath;
- (UITableViewCell*)buildCell;
- (void)configureCell:(UITableViewCell*)cell;

@end
