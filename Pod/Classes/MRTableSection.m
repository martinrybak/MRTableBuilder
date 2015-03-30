//
//  MRTableSection.m
//  MRTableBuilder
//
//  Created by Martin Rybak on 3/16/15.
//  Copyright (c) 2015 Martin Rybak. All rights reserved.
//

#import "MRTableSection.h"
#import "MRTableBuilder.h"

@implementation MRTableSection

#pragma mark - NSObject

- (instancetype)init
{
	if (self = [super init]) {
		_rows = [NSMutableArray array];
	}
	return self;
}

#pragma mark - Public

- (void)setHeader:(MRTableHeaderFooter*)header
{
	_header = header;
	header.section = self;
}

- (void)setFooter:(MRTableHeaderFooter*)footer
{
	_footer = footer;
	footer.section = self;
}

- (void)addRow:(MRTableRow*)row
{
	row.section = self;
	[self.rows addObject:row];
}

- (void)removeRow:(MRTableRow*)row
{
	row.section = nil;
	[self.rows removeObject:row];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
	return self.rows.count;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
	MRTableRow* row = self.rows[indexPath.row];
	return [row buildCellWithIndexPath:indexPath];
}

- (NSString*)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section
{
	return self.headerTitle;
}

- (NSString*)tableView:(UITableView*)tableView titleForFooterInSection:(NSInteger)section
{
	return self.footerTitle;
}

//Returns YES by default
- (BOOL)tableView:(UITableView*)tableView canEditRowAtIndexPath:(NSIndexPath*)indexPath
{
	MRTableRow* row = self.rows[indexPath.row];
	if (row.canEdit) {
		return row.canEdit.boolValue;
	}
	return YES;
}

//Returns NO by default
- (BOOL)tableView:(UITableView*)tableView canMoveRowAtIndexPath:(NSIndexPath*)indexPath
{
	MRTableRow* row = self.rows[indexPath.row];
	if (row.canMove) {
		return row.canMove.boolValue;
	}
	return NO;
}

- (void)tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath
{
	MRTableRow* row = self.rows[indexPath.row];
	
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		if (row.onCommitDelete) {
			row.onCommitDelete();
		}
		[tableView beginUpdates];
		[self.rows removeObject:row];
		[tableView deleteRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationAutomatic];
		[tableView endUpdates];
	}
	if (editingStyle == UITableViewCellEditingStyleInsert) {
		if (row.onCommitInsert) {
			row.onCommitInsert();
		}
	}
}

#pragma mark - UITableViewDelegate

// Display customization

- (void)tableView:(UITableView*)tableView willDisplayCell:(UITableViewCell*)cell forRowAtIndexPath:(NSIndexPath*)indexPath
{
	MRTableRow* row = self.rows[indexPath.row];
	if (row.onWillDisplay) {
		row.onWillDisplay(cell);
	}
}

- (void)tableView:(UITableView*)tableView willDisplayHeaderView:(UIView*)view forSection:(NSInteger)section
{
	if (self.onWillDisplayHeader) {
		self.onWillDisplayHeader(view);
	}
}

- (void)tableView:(UITableView*)tableView willDisplayFooterView:(UIView*)view forSection:(NSInteger)section
{
	if (self.onWillDisplayFooter) {
		self.onWillDisplayFooter(view);
	}
}

- (void)tableView:(UITableView*)tableView didEndDisplayingCell:(UITableViewCell*)cell forRowAtIndexPath:(NSIndexPath*)indexPath
{
	//Check if cell builder still exists
	if (indexPath.row >= self.rows.count) {
		return;
	}
	
	MRTableRow* row = self.rows[indexPath.row];
	if (row.onDidEndDisplaying) {
		row.onDidEndDisplaying(cell);
	}
}

- (void)tableView:(UITableView*)tableView didEndDisplayingHeaderView:(UIView*)view forSection:(NSInteger)section
{
	if (self.onDidEndDisplayingHeader) {
		self.onDidEndDisplayingHeader(view);
	}
}

- (void)tableView:(UITableView*)tableView didEndDisplayingFooterView:(UIView*)view forSection:(NSInteger)section
{
	if (self.onDidEndDisplayingFooter) {
		self.onDidEndDisplayingFooter(view);
	}
}

// Variable height support

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
	MRTableRow* row = self.rows[indexPath.row];
	if (row.height) {
		return row.height;
	}
	UITableViewCell* cell = [row buildCell];
	return [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height + 1.0;
}

- (CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
	if (self.header) {
		if (self.header.height) {
			return self.header.height;
		}
		UITableViewHeaderFooterView* header = [self.header buildView];
		return [header systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
	}
	if (self.headerHeight) {
		return self.headerHeight;
	}
	return 0;
}

- (CGFloat)tableView:(UITableView*)tableView heightForFooterInSection:(NSInteger)section
{
	if (self.footer) {
		if (self.footer.height) {
			return self.footer.height;
		}
		UITableViewHeaderFooterView* footer = [self.footer buildView];
		return [footer.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height + 1.0;
	}
	if (self.footerHeight) {
		return self.footerHeight;
	}
	return 0;
}

// Use the estimatedHeight methods to quickly calcuate guessed values which will allow for fast load times of the table.
// If these methods are implemented, the above -tableView:heightForXXX calls will be deferred until views are ready to be displayed, so more expensive logic can be placed there.
- (CGFloat)tableView:(UITableView*)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath*)indexPath
{
	MRTableRow* row = self.rows[indexPath.row];
	if (row.estimatedHeight) {
		return row.estimatedHeight;
	}
	return 0;
}

- (CGFloat)tableView:(UITableView*)tableView estimatedHeightForHeaderInSection:(NSInteger)section
{
	if (self.header) {
		return self.header.estimatedHeight;
	}
	return 0;
}

- (CGFloat)tableView:(UITableView*)tableView estimatedHeightForFooterInSection:(NSInteger)section
{
	if (self.footer) {
		return self.footer.estimatedHeight;
	}
	return 0;
}

// Section header & footer information. Views are preferred over title should you decide to provide both

- (UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section
{
	return [self.header buildView];
}

- (UIView*)tableView:(UITableView*)tableView viewForFooterInSection:(NSInteger)section
{
	return [self.footer buildView];
}

// Accessories (disclosures).

- (void)tableView:(UITableView*)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath*)indexPath
{
	MRTableRow* row = self.rows[indexPath.row];
	if (row.onAccessoryButtonTapped) {
		row.onAccessoryButtonTapped();
	}
}

// Selection

//Returns YES by default
- (BOOL)tableView:(UITableView*)tableView shouldHighlightRowAtIndexPath:(NSIndexPath*)indexPath
{
	MRTableRow* row = self.rows[indexPath.row];
	if (row.shouldHighlight) {
		return row.shouldHighlight.boolValue;
	}
	return YES;
}

- (void)tableView:(UITableView*)tableView didHighlightRowAtIndexPath:(NSIndexPath*)indexPath
{
	MRTableRow* row = self.rows[indexPath.row];
	if (row.onDidHighlight) {
		row.onDidHighlight();
	}
}

- (void)tableView:(UITableView*)tableView didUnhighlightRowAtIndexPath:(NSIndexPath*)indexPath
{
	MRTableRow* row = self.rows[indexPath.row];
	if (row.onDidUnhighlight) {
		row.onDidUnhighlight();
	}
}

- (NSIndexPath*)tableView:(UITableView*)tableView willSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
	MRTableRow* row = self.rows[indexPath.row];
	if (row.onWillSelect) {
		return row.onWillSelect(indexPath);
	}
	return indexPath;
}

- (NSIndexPath*)tableView:(UITableView*)tableView willDeselectRowAtIndexPath:(NSIndexPath*)indexPath
{
	MRTableRow* row = self.rows[indexPath.row];
	if (row.onWillDeselect) {
		return row.onWillDeselect(indexPath);
	}
	return indexPath;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
	MRTableRow* row = self.rows[indexPath.row];
	if (row.onDidSelect) {
		row.onDidSelect(indexPath);
	}
}

- (void)tableView:(UITableView*)tableView didDeselectRowAtIndexPath:(NSIndexPath*)indexPath
{
	MRTableRow* row = self.rows[indexPath.row];
	if (row.onDidDeselect) {
		row.onDidDeselect(indexPath);
	}
}

// Editing

// Allows customization of the editingStyle for a particular cell located at 'indexPath'. If not implemented, all editable cells will have UITableViewCellEditingStyleDelete set for them when the table has editing property set to YES.
- (UITableViewCellEditingStyle)tableView:(UITableView*)tableView editingStyleForRowAtIndexPath:(NSIndexPath*)indexPath
{
	MRTableRow* row = self.rows[indexPath.row];
	if (row.editingStyle) {
		return row.editingStyle.integerValue;
	}
	return UITableViewCellEditingStyleDelete;
}

- (NSString*)tableView:(UITableView*)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath*)indexPath
{
	MRTableRow* row = self.rows[indexPath.row];
	return row.titleForDeleteConfirmationButton;
}

// supercedes -tableView:titleForDeleteConfirmationButtonForRowAtIndexPath: if return value is non-nil
- (NSArray*)tableView:(UITableView*)tableView editActionsForRowAtIndexPath:(NSIndexPath*)indexPath
{
	MRTableRow* row = self.rows[indexPath.row];
	return row.editActions;
}

// Controls whether the background is indented while editing.  If not implemented, the default is YES.  This is unrelated to the indentation level below.  This method only applies to grouped style table views.
- (BOOL)tableView:(UITableView*)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
	MRTableRow* row = self.rows[indexPath.row];
	if (row.shouldIndentWhileEditing) {
		return row.shouldIndentWhileEditing.boolValue;
	}
	return YES;
}

// The willBegin/didEnd methods are called whenever the 'editing' property is automatically changed by the table (allowing insert/delete/move). This is done by a swipe activating a single row
- (void)tableView:(UITableView*)tableView willBeginEditingRowAtIndexPath:(NSIndexPath*)indexPath
{
	MRTableRow* row = self.rows[indexPath.row];
	if (row.onWillBeginEditing) {
		row.onWillBeginEditing();
	}
}

- (void)tableView:(UITableView*)tableView didEndEditingRowAtIndexPath:(NSIndexPath*)indexPath
{
	MRTableRow* row = self.rows[indexPath.row];
	if (row.onDidEndEditing) {
		row.onDidEndEditing();
	}
}

// Indentation

// return 'depth' of row for hierarchies
- (NSInteger)tableView:(UITableView*)tableView indentationLevelForRowAtIndexPath:(NSIndexPath*)indexPath
{
	MRTableRow* row = self.rows[indexPath.row];
	if (row.indentationLevel) {
		return row.indentationLevel.integerValue;
	}
	return 0;
}

// Copy/Paste.  All three methods must be implemented by the delegate.

//Default is NO
- (BOOL)tableView:(UITableView*)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath*)indexPath
{
	MRTableRow* row = self.rows[indexPath.row];
	if (row.shouldShowMenu) {
		return row.shouldShowMenu.boolValue;
	}
	return NO;
}

- (BOOL)tableView:(UITableView*)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath*)indexPath withSender:(id)sender
{
	MRTableRow* row = self.rows[indexPath.row];
	if (row.canPerformAction) {
		return row.canPerformAction(action, sender);
	}
	return NO;
}

- (void)tableView:(UITableView*)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath*)indexPath withSender:(id)sender
{
	MRTableRow* row = self.rows[indexPath.row];
	if (row.onPerformAction) {
		row.onPerformAction(action, sender);
	}
}

@end
