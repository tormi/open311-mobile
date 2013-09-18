/**
 * @copyright 2013 City of Bloomington, Indiana. All Rights Reserved
 * @author Cliff Ingham <inghamn@bloomington.in.gov>
 * @license http://www.gnu.org/licenses/gpl.txt GNU/GPLv3, see LICENSE.txt
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 */

#import "ChooseServiceController.h"
#import "Preferences.h"
#import "Open311.h"
#import "Strings.h"
#import "NewReportController.h"

@interface ChooseServiceController ()

@end

@implementation ChooseServiceController {
    Open311 *open311;
    NSString *currentServerName;
    NSArray *services;
}
static NSString * const kCellIdentifier = @"service_cell";
static NSString * const kSegueToNewReport = @"SegueToNewReport";

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    open311 = [Open311 sharedInstance];
    currentServerName = [[Preferences sharedInstance] getCurrentServer][kOpen311_Name];
    services = [open311 getServicesForGroup:self.group];
    self.navigationItem.title = self.group;
    
    //add empty footer so that empty rows will not be shown at the end of the table
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
}

- (void)viewWillAppear:(BOOL)animated
{
    if (![currentServerName isEqualToString:[[Preferences sharedInstance] getCurrentServer][kOpen311_Name]]) {
        currentServerName = nil;
        [self.navigationController popViewControllerAnimated:NO];
    }
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [services count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    NSDictionary *service = services[indexPath.row];
    
    cell.textLabel      .text = service[kOpen311_ServiceName];
    cell.detailTextLabel.text = service[kOpen311_Description];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        // The device is an iPad running iOS 3.2 or later.
        [self.delegate didSelectService:services[tableView.indexPathForSelectedRow.row]];
    }
    else {
        // The device is an iPhone or iPod touch.
        [self performSegueWithIdentifier:kSegueToNewReport sender:self];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        // The device is an iPad running iOS 3.2 or later.
    }
    else {
        // The device is an iPhone or iPod touch.
        NewReportController *report = [segue destinationViewController];
        report.service = services[[[self.tableView indexPathForSelectedRow] row]];

    }
}

- (void)setGroup:(NSString *)group
{
    _group = group;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        // The device is an iPad running iOS 3.2 or later.
        open311 = [Open311 sharedInstance];
        
        currentServerName = [[Preferences sharedInstance] getCurrentServer][kOpen311_Name];
        
        services = [open311 getServicesForGroup:self.group];
        //self.navigationItem.title = self.group;
        [self.tableView reloadData];
    }
    else {
        //The device is an iPhone or iPod
    }
    
}
@end
