//
//  MRLoginViewController.m
//  MRTableBuilder
//
//  Created by Martin Rybak on 3/31/15.
//  Copyright (c) 2015 Martin Rybak. All rights reserved.
//

#import "MRLoginViewController.h"
#import "MRTableBuilder.h"
#import "MRTextFieldCell.h"

@interface MRLoginViewController ()

@property (weak, nonatomic) IBOutlet UITableView* tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint* tableHeightConstraint;
@property (strong, nonatomic) MRTableBuilder* tableBuilder;
@property (strong, nonatomic) MRTableRow* emailRow;
@property (strong, nonatomic) MRTableRow* passwordRow;

@end

@implementation MRLoginViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.view.backgroundColor = [UIColor colorWithHue:0.59 saturation:0.33 brightness:0.99 alpha:1];
	self.tableView.scrollEnabled = NO;
	self.tableView.separatorInset = UIEdgeInsetsZero;
	self.tableView.layer.cornerRadius = 10.0;
	[self loadTable];
	
	//Reload table to calculate contentSize
	[self.tableView reloadData];
	self.tableHeightConstraint.constant = self.tableView.contentSize.height;
}

- (UIRectEdge)edgesForExtendedLayout
{
	return UIRectEdgeNone;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField*)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString*)string
{
	NSString* text = [textField.text stringByReplacingCharactersInRange:range withString:string];
	if (text.length > 8) {
		[self showErrorForTextField:textField];
	} else {
		[self hideErrorForTextField:textField];
	}
	return YES;
}

#pragma mark - Private

- (void)loadTable
{
	self.tableBuilder = [[MRTableBuilder alloc] init];
	
	MRTableSection* section = [[MRTableSection alloc] init];
	[self.tableBuilder addSection:section];
	
	__weak __typeof__(self) weakSelf = self;
	
	//Email
	self.emailRow = [[MRTableRow alloc] initWithClass:[MRTextFieldCell class]];
	self.emailRow.height = 60.0;
	self.emailRow.shouldHighlight = @(NO);
	self.emailRow.onConfigure = ^(MRTextFieldCell* cell) {
		cell.textField.placeholder = @"Email";
		cell.textField.clearButtonMode = UITextFieldViewModeAlways;
		cell.textField.tag = 1;
		cell.textField.delegate = weakSelf;
	};
	[section addRow:self.emailRow];
	
	//Password
	self.passwordRow = [[MRTableRow alloc] initWithClass:[MRTextFieldCell class]];
	self.passwordRow.height = 60.0;
	self.passwordRow.shouldHighlight = @(NO);
	self.passwordRow.onConfigure = ^(MRTextFieldCell* cell) {
		cell.textField.placeholder = @"Password";
		cell.textField.clearButtonMode = UITextFieldViewModeAlways;
		cell.textField.secureTextEntry = YES;
		cell.textField.tag = 2;
		cell.textField.delegate = weakSelf;
	};
	[section addRow:self.passwordRow];
	
	//Button
	MRTableRow* buttonRow = [[MRTableRow alloc] init];
	buttonRow.height = 60.0;
	buttonRow.onConfigure = ^(MRTextFieldCell* cell) {
		cell.textLabel.text = @"Login";
		cell.textLabel.textAlignment = NSTextAlignmentCenter;
		cell.textLabel.textColor = [UIColor whiteColor];
		cell.backgroundColor = [UIColor blueColor];
	};
	buttonRow.onDidSelect = ^(NSIndexPath* indexPath){
		[weakSelf.tableView deselectRowAtIndexPath:indexPath animated:YES];
		[weakSelf showAlert];
	};
	[section addRow:buttonRow];
	
	[self.tableBuilder bindToTableView:self.tableView];
}

- (void)showErrorForTextField:(UITextField*)textField
{
	[UIView transitionWithView:textField.superview duration:0.3 options:0 animations:^{
		textField.superview.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.1];
	} completion:nil];
}

- (void)hideErrorForTextField:(UITextField*)textField
{
	[UIView transitionWithView:textField.superview duration:0.3 options:0 animations:^{
		textField.superview.backgroundColor = [UIColor whiteColor];
	} completion:nil];
}

- (void)showAlert
{
	[self.view endEditing:YES];
	MRTextFieldCell* emailCell = [self.tableBuilder cellForRow:self.emailRow];
	MRTextFieldCell* passwordCell = [self.tableBuilder cellForRow:self.passwordRow];
	NSString* message = [NSString stringWithFormat:@"You entered:\n%@\n%@", emailCell.textField.text, passwordCell.textField.text];
	[[[UIAlertView alloc] initWithTitle:@"Login" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
}

@end
