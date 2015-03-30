//
//  MRTableBuilder.m
//  MRTableBuilder
//
//  Created by Martin Rybak on 3/16/15.
//  Copyright (c) 2015 Martin Rybak. All rights reserved.
//

#import "MRTableBuilder.h"

@interface MRTableBuilder ()

@property (weak, nonatomic, readwrite) UITableView* tableView;
@property (strong, nonatomic) NSMutableArray* sections;

@end

@implementation MRTableBuilder

#pragma mark - NSObject

- (instancetype)init
{
	if (self = [super init]) {
		_sections = [NSMutableArray array];
	}
	return self;
}

//Only say YES to some selectors if at least one section or row has a value set
- (BOOL)respondsToSelector:(SEL)aSelector
{
	__block BOOL useEstimatedRowHeights = NO;
	__block BOOL useEstimatedHeaderHeights = NO;
	__block BOOL useEstimatedFooterHeights = NO;
	__block BOOL useHeaderViews = NO;
	__block BOOL useFooterViews = NO;
	__block BOOL useHeaderHeights = NO;
	__block BOOL useFooterHeights = NO;
	__block BOOL hasTitlesForDeleteConfirmationButtons = NO;
	__block BOOL useHighlights = NO;
	__block BOOL useIndents = NO;
	__block BOOL useEditRows = NO;
	__block BOOL useMoveRows = NO;
	__block BOOL useMenus = NO;
	__block BOOL useEditingStyles = NO;
	__block BOOL useIndentationLevels = NO;
	
	[self enumerateRowsUsingBlock:^(MRTableSection* section, MRTableRow* row, BOOL* stop) {
		useEstimatedRowHeights |= row.estimatedHeight > 0;
		useEstimatedHeaderHeights |= section.header.estimatedHeight > 0;
		useEstimatedFooterHeights |= section.footer.estimatedHeight > 0;
		useHeaderViews |= section.header != nil;
		useFooterViews |= section.footer != nil;
		useHeaderHeights |= section.header.height || section.headerHeight;
		useFooterHeights |= section.footer.height || section.footerHeight;
		hasTitlesForDeleteConfirmationButtons |= row.titleForDeleteConfirmationButton != nil;
		useHighlights |= row.shouldHighlight != nil;
		useIndents |= row.shouldIndentWhileEditing != nil;
		useEditRows |= row.canEdit != nil;
		useMoveRows |= row.canMove != nil;
		useMenus |= row.shouldShowMenu != nil;
		useEditingStyles |= row.editingStyle != nil;
		useIndentationLevels |= row.indentationLevel != nil;
	}];
	
	if (aSelector == @selector(tableView:estimatedHeightForRowAtIndexPath:)) {
		return useEstimatedRowHeights;
	}
	if (aSelector == @selector(tableView:estimatedHeightForHeaderInSection:)) {
		return useEstimatedHeaderHeights;
	}
	if (aSelector == @selector(tableView:estimatedHeightForFooterInSection:)) {
		return useEstimatedFooterHeights;
	}
	if (aSelector == @selector(tableView:viewForHeaderInSection:)) {
		return useHeaderViews;
	}
	if (aSelector == @selector(tableView:viewForFooterInSection:)) {
		return useFooterViews;
	}
	if (aSelector == @selector(tableView:heightForHeaderInSection:)) {
		return useHeaderHeights;
	}
	if (aSelector == @selector(tableView:heightForFooterInSection:)) {
		return useFooterHeights;
	}
	if (aSelector == @selector(tableView:titleForDeleteConfirmationButtonForRowAtIndexPath:)) {
		return hasTitlesForDeleteConfirmationButtons;
	}
	if (aSelector == @selector(tableView:shouldHighlightRowAtIndexPath:)) {
		return useHighlights;
	}
	if (aSelector == @selector(tableView:shouldIndentWhileEditingRowAtIndexPath:)) {
		return useIndents;
	}
	if (aSelector == @selector(tableView:canEditRowAtIndexPath:)) {
		return useEditRows;
	}
	if (aSelector == @selector(tableView:canMoveRowAtIndexPath:)) {
		return useMoveRows;
	}
	if (aSelector == @selector(tableView:moveRowAtIndexPath:toIndexPath:)) {
		return useMoveRows;
	}
	if (aSelector == @selector(tableView:shouldShowMenuForRowAtIndexPath:)) {
		return useMenus;
	}
	if (aSelector == @selector(tableView:editingStyleForRowAtIndexPath:)) {
		return useEditingStyles;
	}
	if (aSelector == @selector(tableView:indentationLevelForRowAtIndexPath:)) {
		return useIndentationLevels;
	}
	return [super respondsToSelector:aSelector];
}

#pragma mark - Public

- (void)bindToTableView:(UITableView*)tableView
{
	_tableView = tableView;
	tableView.dataSource = self;
	tableView.delegate = self;
	
	//Register custom headers and footers
	[self enumerateSectionsUsingBlock:^(MRTableSection* section, BOOL* stop) {
		if (section.header) {
			if (section.header.viewNib) {
				[self.tableView registerNib:section.header.viewNib forHeaderFooterViewReuseIdentifier:section.header.reuseIdentifier];
			} else {
				[self.tableView registerClass:section.header.viewClass forHeaderFooterViewReuseIdentifier:section.header.reuseIdentifier];
			}
		}
		if (section.footer) {
			if (section.footer.viewNib) {
				[self.tableView registerNib:section.footer.viewNib forHeaderFooterViewReuseIdentifier:section.footer.reuseIdentifier];
			} else {
				[self.tableView registerClass:section.footer.viewClass forHeaderFooterViewReuseIdentifier:section.footer.reuseIdentifier];
			}
		}
	}];
	
	//Register custom cells
	[self enumerateRowsUsingBlock:^(MRTableSection* section, MRTableRow* row, BOOL* stop) {
		if (row.cellNib) {
			[self.tableView registerNib:row.cellNib forCellReuseIdentifier:row.reuseIdentifier];
			return;
		} else {
			[self.tableView registerClass:row.cellClass forCellReuseIdentifier:row.reuseIdentifier];
		}
	}];
}

- (void)addSection:(MRTableSection*)section
{
	section.tableBuilder = self;
	[self.sections addObject:section];
}

- (void)removeSection:(MRTableSection*)section
{
	section.tableBuilder = nil;
	[self.sections removeObject:section];
}

- (void)clear
{
	[self.sections removeAllObjects];
}

- (NSIndexPath*)indexPathForRow:(MRTableRow*)aRow
{
	for (int i = 0; i < self.sections.count; i++) {
		MRTableSection* section = self.sections[i];
		for (int j = 0; j < section.rows.count; j++) {
			MRTableRow* row = section.rows[j];
			if (row == aRow) {
				return [NSIndexPath indexPathForRow:j inSection:i];;
			}
		}
	}
	return nil;
}

- (id)cellForRow:(MRTableRow*)row
{
	if (!row) {
		return nil;
	}
	
	NSIndexPath* indexPath = [self indexPathForRow:row];
	UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
	if (!cell) {
		cell = [self tableView:self.tableView cellForRowAtIndexPath:indexPath];
	}
	return cell;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
	MRTableSection* formSection = self.sections[section];
	return [formSection tableView:tableView numberOfRowsInSection:section];
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
	MRTableSection* formSection = self.sections[indexPath.section];
	return [formSection tableView:tableView cellForRowAtIndexPath:indexPath];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
	return self.sections.count;
}

- (NSString*)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section
{
	MRTableSection* formSection = self.sections[section];
	return [formSection tableView:tableView titleForHeaderInSection:section];
}

- (NSString *)tableView:(UITableView*)tableView titleForFooterInSection:(NSInteger)section
{
	MRTableSection* formSection = self.sections[section];
	return [formSection tableView:tableView titleForFooterInSection:section];
}

- (BOOL)tableView:(UITableView*)tableView canEditRowAtIndexPath:(NSIndexPath*)indexPath
{
	MRTableSection* formSection = self.sections[indexPath.section];
	return [formSection tableView:tableView canEditRowAtIndexPath:indexPath];
}

- (BOOL)tableView:(UITableView*)tableView canMoveRowAtIndexPath:(NSIndexPath*)indexPath
{
	MRTableSection* formSection = self.sections[indexPath.section];
	return [formSection tableView:tableView canMoveRowAtIndexPath:indexPath];
}

- (NSArray*)sectionIndexTitlesForTableView:(UITableView*)tableView
{
	return self.sectionIndexTitles;
}

- (NSInteger)tableView:(UITableView*)tableView sectionForSectionIndexTitle:(NSString*)title atIndex:(NSInteger)index
{
	if (self.sectionForSectionIndex) {
		return self.sectionForSectionIndex(title, index);
	}
	return 0;
}

- (void)tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath
{
	MRTableSection* formSection = self.sections[indexPath.section];
	[formSection tableView:tableView commitEditingStyle:editingStyle forRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView*)tableView moveRowAtIndexPath:(NSIndexPath*)sourceIndexPath toIndexPath:(NSIndexPath*)destinationIndexPath
{
	if (self.onMoveRow) {
		self.onMoveRow(sourceIndexPath, destinationIndexPath);
	}
	
	MRTableSection* sourceSection = self.sections[sourceIndexPath.section];
	MRTableSection* destinationSection = self.sections[destinationIndexPath.section];
	MRTableRow* row = sourceSection.rows[sourceIndexPath.row];
	
	[tableView beginUpdates];
	[sourceSection.rows removeObject:row];
	[destinationSection.rows insertObject:row atIndex:destinationIndexPath.row];
	[tableView endUpdates];
}

#pragma mark - UITableViewDelegate

// Display customization

- (void)tableView:(UITableView*)tableView willDisplayCell:(UITableViewCell*)cell forRowAtIndexPath:(NSIndexPath*)indexPath
{
	MRTableSection* formSection = self.sections[indexPath.section];
	[formSection tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView*)tableView willDisplayHeaderView:(UIView*)view forSection:(NSInteger)section
{
	MRTableSection* formSection = self.sections[section];
	[formSection tableView:tableView willDisplayHeaderView:view forSection:section];
}

- (void)tableView:(UITableView*)tableView willDisplayFooterView:(UIView*)view forSection:(NSInteger)section
{
	MRTableSection* formSection = self.sections[section];
	[formSection tableView:tableView willDisplayFooterView:view forSection:section];
}

- (void)tableView:(UITableView*)tableView didEndDisplayingCell:(UITableViewCell*)cell forRowAtIndexPath:(NSIndexPath*)indexPath
{
	MRTableSection* formSection = self.sections[indexPath.section];
	[formSection tableView:tableView didEndDisplayingCell:cell forRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView*)tableView didEndDisplayingHeaderView:(UIView*)view forSection:(NSInteger)section
{
	MRTableSection* formSection = self.sections[section];
	[formSection tableView:tableView didEndDisplayingHeaderView:view forSection:section];
}

- (void)tableView:(UITableView*)tableView didEndDisplayingFooterView:(UIView*)view forSection:(NSInteger)section
{
	MRTableSection* formSection = self.sections[section];
	[formSection tableView:tableView didEndDisplayingFooterView:view forSection:section];
}

// Variable height support

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
	MRTableSection* formSection = self.sections[indexPath.section];
	return [formSection tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
	MRTableSection* formSection = self.sections[section];
	return [formSection tableView:tableView heightForHeaderInSection:section];
}

- (CGFloat)tableView:(UITableView*)tableView heightForFooterInSection:(NSInteger)section
{
	MRTableSection* formSection = self.sections[section];
	return [formSection tableView:tableView heightForFooterInSection:section];
}

// Use the estimatedHeight methods to quickly calcuate guessed values which will allow for fast load times of the table.
// If these methods are implemented, the above -tableView:heightForXXX calls will be deferred until views are ready to be displayed, so more expensive logic can be placed there.
- (CGFloat)tableView:(UITableView*)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath*)indexPath
{
	MRTableSection* formSection = self.sections[indexPath.section];
	return [formSection tableView:tableView estimatedHeightForRowAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView*)tableView estimatedHeightForHeaderInSection:(NSInteger)section
{
	MRTableSection* formSection = self.sections[section];
	return [formSection tableView:tableView estimatedHeightForHeaderInSection:section];
}

- (CGFloat)tableView:(UITableView*)tableView estimatedHeightForFooterInSection:(NSInteger)section
{
	MRTableSection* formSection = self.sections[section];
	return [formSection tableView:tableView estimatedHeightForFooterInSection:section];
}

// Section header & footer information. Views are preferred over title should you decide to provide both

- (UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section
{
	MRTableSection* formSection = self.sections[section];
	return [formSection tableView:tableView viewForHeaderInSection:section];
}

- (UIView*)tableView:(UITableView*)tableView viewForFooterInSection:(NSInteger)section
{
	MRTableSection* formSection = self.sections[section];
	return [formSection tableView:tableView viewForFooterInSection:section];
}

// Accessories (disclosures).

- (void)tableView:(UITableView*)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath*)indexPath
{
	MRTableSection* formSection = self.sections[indexPath.section];
	[formSection tableView:tableView accessoryButtonTappedForRowWithIndexPath:indexPath];
}

// Selection

// -tableView:shouldHighlightRowAtIndexPath: is called when a touch comes down on a row.
// Returning NO to that message halts the selection process and does not cause the currently selected row to lose its selected look while the touch is down.

- (BOOL)tableView:(UITableView*)tableView shouldHighlightRowAtIndexPath:(NSIndexPath*)indexPath
{
	MRTableSection* formSection = self.sections[indexPath.section];
	return [formSection tableView:tableView shouldHighlightRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView*)tableView didHighlightRowAtIndexPath:(NSIndexPath*)indexPath
{
	MRTableSection* formSection = self.sections[indexPath.section];
	[formSection tableView:tableView didHighlightRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView*)tableView didUnhighlightRowAtIndexPath:(NSIndexPath*)indexPath
{
	MRTableSection* formSection = self.sections[indexPath.section];
	[formSection tableView:tableView didUnhighlightRowAtIndexPath:indexPath];
}

// Called before the user changes the selection. Return a new indexPath, or nil, to change the proposed selection.
- (NSIndexPath*)tableView:(UITableView*)tableView willSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
	MRTableSection* formSection = self.sections[indexPath.section];
	return [formSection tableView:tableView willSelectRowAtIndexPath:indexPath];
}

- (NSIndexPath*)tableView:(UITableView*)tableView willDeselectRowAtIndexPath:(NSIndexPath*)indexPath
{
	MRTableSection* formSection = self.sections[indexPath.section];
	return [formSection tableView:tableView willDeselectRowAtIndexPath:indexPath];
}

// Called after the user changes the selection.
- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
	MRTableSection* formSection = self.sections[indexPath.section];
	[formSection tableView:tableView didSelectRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView*)tableView didDeselectRowAtIndexPath:(NSIndexPath*)indexPath
{
	MRTableSection* formSection = self.sections[indexPath.section];
	[formSection tableView:tableView didDeselectRowAtIndexPath:indexPath];
}

// Editing

// Allows customization of the editingStyle for a particular cell located at 'indexPath'. If not implemented, all editable cells will have UITableViewCellEditingStyleDelete set for them when the table has editing property set to YES.
- (UITableViewCellEditingStyle)tableView:(UITableView*)tableView editingStyleForRowAtIndexPath:(NSIndexPath*)indexPath
{
	MRTableSection* formSection = self.sections[indexPath.section];
	return [formSection tableView:tableView editingStyleForRowAtIndexPath:indexPath];
}

- (NSString*)tableView:(UITableView*)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath*)indexPath
{
	MRTableSection* formSection = self.sections[indexPath.section];
	return [formSection tableView:tableView titleForDeleteConfirmationButtonForRowAtIndexPath:indexPath];
}

// supercedes -tableView:titleForDeleteConfirmationButtonForRowAtIndexPath: if return value is non-nil
- (NSArray*)tableView:(UITableView*)tableView editActionsForRowAtIndexPath:(NSIndexPath*)indexPath
{
	MRTableSection* formSection = self.sections[indexPath.section];
	return [formSection tableView:tableView editActionsForRowAtIndexPath:indexPath];
}

// Controls whether the background is indented while editing.  If not implemented, the default is YES.  This is unrelated to the indentation level below.  This method only applies to grouped style table views.
- (BOOL)tableView:(UITableView*)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
	MRTableSection* formSection = self.sections[indexPath.section];
	return [formSection tableView:tableView shouldIndentWhileEditingRowAtIndexPath:indexPath];
}

// The willBegin/didEnd methods are called whenever the 'editing' property is automatically changed by the table (allowing insert/delete/move). This is done by a swipe activating a single row
- (void)tableView:(UITableView*)tableView willBeginEditingRowAtIndexPath:(NSIndexPath*)indexPath
{
	MRTableSection* formSection = self.sections[indexPath.section];
	[formSection tableView:tableView willBeginEditingRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView*)tableView didEndEditingRowAtIndexPath:(NSIndexPath*)indexPath
{
	MRTableSection* formSection = self.sections[indexPath.section];
	[formSection tableView:tableView didEndEditingRowAtIndexPath:indexPath];
}

// Moving/reordering

// Allows customization of the target row for a particular row as it is being moved/reordered
- (NSIndexPath*)tableView:(UITableView*)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath*)sourceIndexPath toProposedIndexPath:(NSIndexPath*)proposedDestinationIndexPath
{
	if (self.targetIndexPathForMove) {
		return self.targetIndexPathForMove(sourceIndexPath, proposedDestinationIndexPath);
	}
	return proposedDestinationIndexPath;
}

// Indentation

// return 'depth' of row for hierarchies
- (NSInteger)tableView:(UITableView*)tableView indentationLevelForRowAtIndexPath:(NSIndexPath*)indexPath
{
	MRTableSection* formSection = self.sections[indexPath.section];
	return [formSection tableView:tableView indentationLevelForRowAtIndexPath:indexPath];
}

// Copy/Paste.  All three methods must be implemented by the delegate.

- (BOOL)tableView:(UITableView*)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath*)indexPath
{
	MRTableSection* formSection = self.sections[indexPath.section];
	return [formSection tableView:tableView shouldShowMenuForRowAtIndexPath:indexPath];
}

- (BOOL)tableView:(UITableView*)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath*)indexPath withSender:(id)sender
{
	MRTableSection* formSection = self.sections[indexPath.section];
	return [formSection tableView:tableView canPerformAction:action forRowAtIndexPath:indexPath withSender:sender];
}

- (void)tableView:(UITableView*)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath*)indexPath withSender:(id)sender
{
	MRTableSection* formSection = self.sections[indexPath.section];
	[formSection tableView:tableView performAction:action forRowAtIndexPath:indexPath withSender:sender];
}

#pragma mark - Private

- (void)enumerateSectionsUsingBlock:(void (^)(MRTableSection* section, BOOL* stop))block
{
	for (int i = 0; i < self.sections.count; i++) {
		MRTableSection* section = self.sections[i];
		if (block) {
			BOOL stop = NO;
			block(section, &stop);
			if (stop) {
				break;
			}
		}
	}
}

- (void)enumerateRowsUsingBlock:(void (^)(MRTableSection* section, MRTableRow* row, BOOL* stop))block
{
	for (int i = 0; i < self.sections.count; i++) {
		MRTableSection* section = self.sections[i];
		for (int j = 0; j < section.rows.count; j++) {
			MRTableRow* row = section.rows[j];
			if (block) {
				BOOL stop = NO;
				block(section, row, &stop);
				if (stop) {
					break;
				}
			}
		}
	}
}

@end
