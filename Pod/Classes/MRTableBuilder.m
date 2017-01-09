//
//  MRTableBuilder.m
//  MRTableBuilder
//
//  Created by Martin Rybak on 3/16/15.
//  Copyright (c) 2015 Martin Rybak. All rights reserved.
//

#import "MRTableBuilder.h"

CGFloat const MRTableBuilderDefaultRowHeight = 44.0;

@interface MRTableBuilder ()

@property (weak, nonatomic, readwrite) UITableView* tableView;

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

- (void)dealloc
{
	self.tableView.delegate = nil;
	self.tableView.dataSource = nil;
}

//Only say YES to some selectors if set explicitly or at least one section or row has a value set
- (BOOL)respondsToSelector:(SEL)aSelector
{
	[self enumerateSectionsUsingBlock:^(MRTableSection* section, BOOL* stop) {
		self.useEstimatedHeaderHeights |= section.header.estimatedHeight > 0;
		self.useEstimatedFooterHeights |= section.footer.estimatedHeight > 0;
		self.useHeaderViews |= section.header != nil;
		self.useFooterViews |= section.footer != nil;
		self.useHeaderHeights |= section.header.height || section.headerHeight;
		self.useFooterHeights |= section.footer.height || section.footerHeight;
	}];
	
	[self enumerateRowsUsingBlock:^(MRTableSection* section, MRTableRow* row, BOOL* stop) {
		self.hasTitlesForDeleteConfirmationButtons |= row.titleForDeleteConfirmationButton != nil;
		self.useEditActions |= row.editActions != nil;
		self.useHighlights |= row.shouldHighlight != nil;
		self.useIndents |= row.shouldIndentWhileEditing != nil;
		self.useEditRows |= row.canEdit != nil;
		self.useMoveRows |= row.canMove != nil;
		self.useMenus |= row.shouldShowMenu != nil;
		self.useEditingStyles |= row.editingStyle != nil;
		self.useIndentationLevels |= row.indentationLevel != nil;
	}];
	
	if (aSelector == @selector(tableView:estimatedHeightForHeaderInSection:)) {
		return self.useEstimatedHeaderHeights;
	}
	if (aSelector == @selector(tableView:estimatedHeightForFooterInSection:)) {
		return self.useEstimatedFooterHeights;
	}
	if (aSelector == @selector(tableView:viewForHeaderInSection:)) {
		return self.useHeaderViews;
	}
	if (aSelector == @selector(tableView:viewForFooterInSection:)) {
		return self.useFooterViews;
	}
	if (aSelector == @selector(tableView:heightForHeaderInSection:)) {
		return self.useHeaderHeights;
	}
	if (aSelector == @selector(tableView:heightForFooterInSection:)) {
		return self.useFooterHeights;
	}
	if (aSelector == @selector(tableView:titleForDeleteConfirmationButtonForRowAtIndexPath:)) {
		return self.hasTitlesForDeleteConfirmationButtons;
	}
	if (aSelector == @selector(tableView:editActionsForRowAtIndexPath:)) {
		return self.useEditActions;
	}
	if (aSelector == @selector(tableView:shouldHighlightRowAtIndexPath:)) {
		return self.useHighlights;
	}
	if (aSelector == @selector(tableView:shouldIndentWhileEditingRowAtIndexPath:)) {
		return self.useIndents;
	}
	if (aSelector == @selector(tableView:canEditRowAtIndexPath:)) {
		return self.useEditRows;
	}
	if (aSelector == @selector(tableView:canMoveRowAtIndexPath:)) {
		return self.useMoveRows;
	}
	if (aSelector == @selector(tableView:commitEditingStyle:forRowAtIndexPath:)) {
		return self.useEditingStyles;
	}
	if (aSelector == @selector(tableView:moveRowAtIndexPath:toIndexPath:)) {
		return self.useMoveRows;
	}
	if (aSelector == @selector(tableView:shouldShowMenuForRowAtIndexPath:)) {
		return self.useMenus;
	}
	if (aSelector == @selector(tableView:editingStyleForRowAtIndexPath:)) {
		return self.useEditingStyles;
	}
	if (aSelector == @selector(tableView:indentationLevelForRowAtIndexPath:)) {
		return self.useIndentationLevels;
	}
	return [super respondsToSelector:aSelector];
}

#pragma mark - Public

- (void)bindToTableView:(UITableView*)tableView
{
	//Clear out the old datasource and delegate
	tableView.dataSource = nil;
	tableView.delegate = nil;
	
	//Prevent tableView:didEndDisplayingCell:forRowAtIndexPath from being called on previous cells
	[tableView reloadData];
	
	//Set self as the new datasource and delegate
	_tableView = tableView;
	tableView.dataSource = self;
	tableView.delegate = self;
	
	//Register custom headers and footers
	[self enumerateSectionsUsingBlock:^(MRTableSection* section, BOOL* stop) {
		[self registerSection:section];
	}];
	
	//Register custom cells
	[self enumerateRowsUsingBlock:^(MRTableSection* section, MRTableRow* row, BOOL* stop) {
		[self registerRow:row];
	}];
	
	//Trigger a reload of the table
	[tableView reloadData];
}

- (MRTableSection*)sectionAtIndex:(NSUInteger)index
{
	//Safety check
	if (index < self.sections.count) {
		return self.sections[index];
	}
	return nil;
}

- (MRTableSection*)sectionAtIndexPath:(NSIndexPath*)indexPath
{
	return [self sectionAtIndex:indexPath.section];
}

- (void)addSection:(MRTableSection*)section
{
	NSInteger index = self.sections.count;
	[self insertSection:section atIndex:index];
}

- (void)addSection:(MRTableSection*)section withAnimation:(UITableViewRowAnimation)animation
{
	NSInteger index = self.sections.count;
	[self insertSection:section atIndex:index withAnimation:animation];
}

- (void)insertSection:(MRTableSection*)section atIndex:(NSUInteger)index
{
	section.tableBuilder = self;
	[self registerSection:section];
	[self.sections insertObject:section atIndex:index];
}

- (void)insertSection:(MRTableSection*)section aboveSection:(MRTableSection*)aboveSection
{
	NSInteger index = [self.sections indexOfObject:aboveSection];
	[self insertSection:section atIndex:index];
}

- (void)insertSection:(MRTableSection*)section belowSection:(MRTableSection*)belowSection
{
	NSInteger index = [self.sections indexOfObject:belowSection] + 1;
	[self insertSection:section atIndex:index];
}

- (void)insertSections:(NSArray*)sections belowSection:(MRTableSection*)belowSection
{
	MRTableSection* topSection = belowSection;
	for (MRTableSection* section in sections) {
		[self insertSection:section belowSection:topSection];
		topSection = section;
	};
}

- (void)insertSections:(NSArray*)sections aboveSection:(MRTableSection*)aboveSection
{
	for (MRTableSection* section in sections) {
		[self insertSection:section aboveSection:aboveSection];
	};
}

- (void)insertSection:(MRTableSection*)section atIndex:(NSUInteger)index withAnimation:(UITableViewRowAnimation)animation
{
	[self.tableView beginUpdates];
	[self insertSection:section atIndex:index];
	NSIndexSet* indexSet = [NSIndexSet indexSetWithIndex:index];
	[self.tableView insertSections:indexSet withRowAnimation:animation];
	[self.tableView endUpdates];
}

- (void)insertSection:(MRTableSection*)section aboveSection:(MRTableSection*)aboveSection withAnimation:(UITableViewRowAnimation)animation
{
	NSInteger index = [self.sections indexOfObject:aboveSection];
	[self insertSection:section atIndex:index withAnimation:animation];
}

- (void)insertSection:(MRTableSection*)section belowSection:(MRTableSection*)belowSection withAnimation:(UITableViewRowAnimation)animation
{
	NSInteger index = [self.sections indexOfObject:belowSection] + 1;
	[self insertSection:section atIndex:index withAnimation:animation];
}

- (void)insertSections:(NSArray*)sections belowSection:(MRTableSection*)belowSection withAnimation:(UITableViewRowAnimation)animation
{
	[self.tableView beginUpdates];
	[self insertSections:sections belowSection:belowSection];
	[self.tableView insertSections:[self indexSetForSections:sections] withRowAnimation:animation];
	[self.tableView endUpdates];
}

- (void)insertSections:(NSArray*)sections aboveSection:(MRTableSection*)aboveSection withAnimation:(UITableViewRowAnimation)animation
{
	[self.tableView beginUpdates];
	[self insertSections:sections aboveSection:aboveSection];
	[self.tableView insertSections:[self indexSetForSections:sections] withRowAnimation:animation];
	[self.tableView endUpdates];
}

- (void)removeSection:(MRTableSection*)section
{
	[self.sections removeObject:section];
}

- (void)removeSection:(MRTableSection*)section withAnimation:(UITableViewRowAnimation)animation
{
	[self.tableView beginUpdates];
	[self.sections removeObject:section];
	NSUInteger index = [self.sections indexOfObject:section];
	NSIndexSet* indexSet = [NSIndexSet indexSetWithIndex:index];
	[self.tableView deleteSections:indexSet withRowAnimation:animation];
	[self.tableView endUpdates];
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

- (BOOL)isSectionVisible:(MRTableSection*)section
{
	CGRect visibleRect = CGRectMake(self.tableView.contentOffset.x, self.tableView.contentOffset.y, self.tableView.bounds.size.width, self.tableView.bounds.size.height);
	CGRect sectionRect = [self.tableView rectForSection:section];
	return CGRectIntersectsRect(visibleRect, sectionRect);
}

- (BOOL)isRowVisible:(MRTableRow*)row
{
	NSIndexPath* indexPath = [self indexPathForRow:row];
	return [[self.tableView indexPathsForVisibleRows] containsObject:indexPath];
}

- (void)reloadRow:(MRTableRow*)row
{
	[self reloadRow:row withAnimation:UITableViewRowAnimationAutomatic];
}

- (void)reloadRow:(MRTableRow*)row withAnimation:(UITableViewRowAnimation)animation
{
	NSIndexPath* indexPath = [self indexPathForRow:row];
	if (indexPath) {
		[self.tableView reloadRowsAtIndexPaths:@[ indexPath ] withRowAnimation:animation];
	}
}

- (void)reloadRows:(NSArray*)rows
{
	[self reloadRows:rows withAnimation:UITableViewRowAnimationAutomatic];
}

- (void)reloadRows:(NSArray*)rows withAnimation:(UITableViewRowAnimation)animation
{
	NSMutableArray* indexPaths = [NSMutableArray array];
	for (MRTableRow* row in rows) {
		NSIndexPath* indexPath = [self indexPathForRow:row];
		if (indexPath) {
			[indexPaths addObject:indexPath];
		}
	}
	[self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:animation];
}

- (id)cellForRow:(MRTableRow*)row
{
	if (!row) {
		return nil;
	}
	
	NSIndexPath* indexPath = [self indexPathForRow:row];
	if (!indexPath) {
		return nil;
	}
	
	UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
	if (!cell) {
		cell = [self tableView:self.tableView cellForRowAtIndexPath:indexPath];
	}
	
	return cell;
}

- (void)registerRow:(MRTableRow*)row
{
	if (row.cellNib) {
		[self.tableView registerNib:row.cellNib forCellReuseIdentifier:row.reuseIdentifier];
		return;
	} else {
		[self.tableView registerClass:row.cellClass forCellReuseIdentifier:row.reuseIdentifier];
	}
}

- (void)registerSection:(MRTableSection*)section
{
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
	for (MRTableRow* row in section.rows) {
		[self registerRow:row];
	}
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
	MRTableSection* formSection = [self sectionAtIndex:section];
	return [formSection tableView:tableView numberOfRowsInSection:section];
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
	MRTableSection* formSection = [self sectionAtIndexPath:indexPath];
	return [formSection tableView:tableView cellForRowAtIndexPath:indexPath];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
	return self.sections.count;
}

- (NSString*)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section
{
	MRTableSection* formSection = [self sectionAtIndex:section];
	return [formSection tableView:tableView titleForHeaderInSection:section];
}

- (NSString*)tableView:(UITableView*)tableView titleForFooterInSection:(NSInteger)section
{
	MRTableSection* formSection = [self sectionAtIndex:section];
	return [formSection tableView:tableView titleForFooterInSection:section];
}

- (BOOL)tableView:(UITableView*)tableView canEditRowAtIndexPath:(NSIndexPath*)indexPath
{
	MRTableSection* formSection = [self sectionAtIndexPath:indexPath];
	return [formSection tableView:tableView canEditRowAtIndexPath:indexPath];
}

- (BOOL)tableView:(UITableView*)tableView canMoveRowAtIndexPath:(NSIndexPath*)indexPath
{
	MRTableSection* formSection = [self sectionAtIndexPath:indexPath];
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
	MRTableSection* formSection = [self sectionAtIndexPath:indexPath];
	[formSection tableView:tableView commitEditingStyle:editingStyle forRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView*)tableView moveRowAtIndexPath:(NSIndexPath*)sourceIndexPath toIndexPath:(NSIndexPath*)destinationIndexPath
{
	if (self.onMoveRow) {
		self.onMoveRow(sourceIndexPath, destinationIndexPath);
	}
	
	MRTableSection* sourceSection = [self sectionAtIndexPath:sourceIndexPath];
	MRTableSection* destinationSection = [self sectionAtIndexPath:destinationIndexPath];
	MRTableRow* row = [sourceSection rowAtIndexPath:sourceIndexPath];
	
	[tableView beginUpdates];
	[sourceSection.rows removeObject:row];
	[destinationSection.rows insertObject:row atIndex:destinationIndexPath.row];
	[tableView endUpdates];
}

#pragma mark - UITableViewDelegate

// Display customization

- (void)tableView:(UITableView*)tableView willDisplayCell:(UITableViewCell*)cell forRowAtIndexPath:(NSIndexPath*)indexPath
{
	MRTableSection* formSection = [self sectionAtIndexPath:indexPath];
	[formSection tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView*)tableView willDisplayHeaderView:(UIView*)view forSection:(NSInteger)section
{
	MRTableSection* formSection = [self sectionAtIndex:section];
	[formSection tableView:tableView willDisplayHeaderView:view forSection:section];
}

- (void)tableView:(UITableView*)tableView willDisplayFooterView:(UIView*)view forSection:(NSInteger)section
{
	MRTableSection* formSection = [self sectionAtIndex:section];
	[formSection tableView:tableView willDisplayFooterView:view forSection:section];
}

- (void)tableView:(UITableView*)tableView didEndDisplayingCell:(UITableViewCell*)cell forRowAtIndexPath:(NSIndexPath*)indexPath
{
	MRTableSection* formSection = [self sectionAtIndexPath:indexPath];
	[formSection tableView:tableView didEndDisplayingCell:cell forRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView*)tableView didEndDisplayingHeaderView:(UIView*)view forSection:(NSInteger)section
{
	MRTableSection* formSection = [self sectionAtIndex:section];
	[formSection tableView:tableView didEndDisplayingHeaderView:view forSection:section];
}

- (void)tableView:(UITableView*)tableView didEndDisplayingFooterView:(UIView*)view forSection:(NSInteger)section
{
	MRTableSection* formSection = [self sectionAtIndex:section];
	[formSection tableView:tableView didEndDisplayingFooterView:view forSection:section];
}

// Variable height support

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
	MRTableSection* formSection = [self sectionAtIndexPath:indexPath];
	return [formSection tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
	MRTableSection* formSection = [self sectionAtIndex:section];
	return [formSection tableView:tableView heightForHeaderInSection:section];
}

- (CGFloat)tableView:(UITableView*)tableView heightForFooterInSection:(NSInteger)section
{
	MRTableSection* formSection = [self sectionAtIndex:section];
	return [formSection tableView:tableView heightForFooterInSection:section];
}

// Use the estimatedHeight methods to quickly calcuate guessed values which will allow for fast load times of the table.
// If these methods are implemented, the above -tableView:heightForXXX calls will be deferred until views are ready to be displayed, so more expensive logic can be placed there.
- (CGFloat)tableView:(UITableView*)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath*)indexPath
{
	MRTableSection* formSection = [self sectionAtIndexPath:indexPath];
	return [formSection tableView:tableView estimatedHeightForRowAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView*)tableView estimatedHeightForHeaderInSection:(NSInteger)section
{
	MRTableSection* formSection = [self sectionAtIndex:section];
	return [formSection tableView:tableView estimatedHeightForHeaderInSection:section];
}

- (CGFloat)tableView:(UITableView*)tableView estimatedHeightForFooterInSection:(NSInteger)section
{
	MRTableSection* formSection = [self sectionAtIndex:section];
	return [formSection tableView:tableView estimatedHeightForFooterInSection:section];
}

// Section header & footer information. Views are preferred over title should you decide to provide both

- (UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section
{
	MRTableSection* formSection = [self sectionAtIndex:section];
	return [formSection tableView:tableView viewForHeaderInSection:section];
}

- (UIView*)tableView:(UITableView*)tableView viewForFooterInSection:(NSInteger)section
{
	MRTableSection* formSection = [self sectionAtIndex:section];
	return [formSection tableView:tableView viewForFooterInSection:section];
}

// Accessories (disclosures).

- (void)tableView:(UITableView*)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath*)indexPath
{
	MRTableSection* formSection = [self sectionAtIndexPath:indexPath];
	[formSection tableView:tableView accessoryButtonTappedForRowWithIndexPath:indexPath];
}

// Selection

// -tableView:shouldHighlightRowAtIndexPath: is called when a touch comes down on a row.
// Returning NO to that message halts the selection process and does not cause the currently selected row to lose its selected look while the touch is down.

- (BOOL)tableView:(UITableView*)tableView shouldHighlightRowAtIndexPath:(NSIndexPath*)indexPath
{
	MRTableSection* formSection = [self sectionAtIndexPath:indexPath];
	return [formSection tableView:tableView shouldHighlightRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView*)tableView didHighlightRowAtIndexPath:(NSIndexPath*)indexPath
{
	MRTableSection* formSection = [self sectionAtIndexPath:indexPath];
	[formSection tableView:tableView didHighlightRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView*)tableView didUnhighlightRowAtIndexPath:(NSIndexPath*)indexPath
{
	MRTableSection* formSection = [self sectionAtIndexPath:indexPath];
	[formSection tableView:tableView didUnhighlightRowAtIndexPath:indexPath];
}

// Called before the user changes the selection. Return a new indexPath, or nil, to change the proposed selection.
- (NSIndexPath*)tableView:(UITableView*)tableView willSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
	MRTableSection* formSection = [self sectionAtIndexPath:indexPath];
	return [formSection tableView:tableView willSelectRowAtIndexPath:indexPath];
}

- (NSIndexPath*)tableView:(UITableView*)tableView willDeselectRowAtIndexPath:(NSIndexPath*)indexPath
{
	MRTableSection* formSection = [self sectionAtIndexPath:indexPath];
	return [formSection tableView:tableView willDeselectRowAtIndexPath:indexPath];
}

// Called after the user changes the selection.
- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
	MRTableSection* formSection = [self sectionAtIndexPath:indexPath];
	[formSection tableView:tableView didSelectRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView*)tableView didDeselectRowAtIndexPath:(NSIndexPath*)indexPath
{
	MRTableSection* formSection = [self sectionAtIndexPath:indexPath];
	[formSection tableView:tableView didDeselectRowAtIndexPath:indexPath];
}

// Editing

// Allows customization of the editingStyle for a particular cell located at 'indexPath'. If not implemented, all editable cells will have UITableViewCellEditingStyleDelete set for them when the table has editing property set to YES.
- (UITableViewCellEditingStyle)tableView:(UITableView*)tableView editingStyleForRowAtIndexPath:(NSIndexPath*)indexPath
{
	MRTableSection* formSection = [self sectionAtIndexPath:indexPath];
	return [formSection tableView:tableView editingStyleForRowAtIndexPath:indexPath];
}

- (NSString*)tableView:(UITableView*)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath*)indexPath
{
	MRTableSection* formSection = [self sectionAtIndexPath:indexPath];
	return [formSection tableView:tableView titleForDeleteConfirmationButtonForRowAtIndexPath:indexPath];
}

// supercedes -tableView:titleForDeleteConfirmationButtonForRowAtIndexPath: if return value is non-nil
- (NSArray*)tableView:(UITableView*)tableView editActionsForRowAtIndexPath:(NSIndexPath*)indexPath
{
	MRTableSection* formSection = [self sectionAtIndexPath:indexPath];
	return [formSection tableView:tableView editActionsForRowAtIndexPath:indexPath];
}

// Controls whether the background is indented while editing.  If not implemented, the default is YES.  This is unrelated to the indentation level below.  This method only applies to grouped style table views.
- (BOOL)tableView:(UITableView*)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath*)indexPath
{
	MRTableSection* formSection = [self sectionAtIndexPath:indexPath];
	return [formSection tableView:tableView shouldIndentWhileEditingRowAtIndexPath:indexPath];
}

// The willBegin/didEnd methods are called whenever the 'editing' property is automatically changed by the table (allowing insert/delete/move). This is done by a swipe activating a single row
- (void)tableView:(UITableView*)tableView willBeginEditingRowAtIndexPath:(NSIndexPath*)indexPath
{
	MRTableSection* formSection = [self sectionAtIndexPath:indexPath];
	[formSection tableView:tableView willBeginEditingRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView*)tableView didEndEditingRowAtIndexPath:(NSIndexPath*)indexPath
{
	MRTableSection* formSection = [self sectionAtIndexPath:indexPath];
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
	MRTableSection* formSection = [self sectionAtIndexPath:indexPath];
	return [formSection tableView:tableView indentationLevelForRowAtIndexPath:indexPath];
}

// Copy/Paste.  All three methods must be implemented by the delegate.

- (BOOL)tableView:(UITableView*)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath*)indexPath
{
	MRTableSection* formSection = [self sectionAtIndexPath:indexPath];
	return [formSection tableView:tableView shouldShowMenuForRowAtIndexPath:indexPath];
}

- (BOOL)tableView:(UITableView*)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath*)indexPath withSender:(id)sender
{
	MRTableSection* formSection = [self sectionAtIndexPath:indexPath];
	return [formSection tableView:tableView canPerformAction:action forRowAtIndexPath:indexPath withSender:sender];
}

- (void)tableView:(UITableView*)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath*)indexPath withSender:(id)sender
{
	MRTableSection* formSection = [self sectionAtIndexPath:indexPath];
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

- (NSIndexSet*)indexSetForSections:(NSArray*)sections
{
	NSMutableIndexSet* indexSet = [NSMutableIndexSet indexSet];
	[sections enumerateObjectsUsingBlock:^(id section, NSUInteger index, BOOL* stop) {
		[indexSet addIndex:[self.sections indexOfObject:section]];
	}];
	return [indexSet copy];
}

@end
