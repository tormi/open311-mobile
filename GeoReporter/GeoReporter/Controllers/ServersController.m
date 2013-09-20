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

#import "ServersController.h"
#import "Strings.h"
#import "Preferences.h"

@interface ServersController ()

@end

@implementation ServersController {
    Preferences *prefs;
    NSArray *availableServers;
    NSMutableArray *customServers;
    
}
static NSString * const kCellIdentifier = @"server_cell";
static NSString * const kUnwindSegueFromServersToHome = @"UnwindSegueFromServersToHome";

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //make view controller start below navigation bar; this wrks in iOS 7
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.navigationItem.title = NSLocalizedString(kUI_Servers, nil);

    availableServers = [Preferences getAvailableServers];
    prefs = [Preferences sharedInstance];
    
    UILabel *label = [[UILabel alloc] init];
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    
    NSString* tableHeaderText;
    tableHeaderText = @"Select the server to which the issues are reported. \"Available Servers\" contains the official endpoints. \"Custom Servers\" may contain other custom Open311 servers.";
    float headerWidth;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        // The device is an iPad running iOS 3.2 or later.
        headerWidth = 728;
    }
    else {
        // The device is an iPhone or iPod touch. 
        headerWidth = 280;
    }
    
    CGSize headerSize = [tableHeaderText sizeWithFont:[UIFont fontWithName:@"Heiti SC" size:13] constrainedToSize:CGSizeMake(headerWidth, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];

    self.label.text = tableHeaderText;
    self.headerView.frame = CGRectMake(20, 4, headerWidth, headerSize.height + 8 + 5);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSDictionary *currentServer = [prefs getCurrentServer];
    if (currentServer == nil) {
        [[self navigationItem] setHidesBackButton:YES];
    }
    
    customServers = [NSMutableArray arrayWithArray:[prefs getCustomServers]];
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [prefs saveCustomServers:customServers];
    
    [super viewWillDisappear:animated];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.tableView reloadSections:[[NSIndexSet alloc] initWithIndexesInRange:NSMakeRange(0, 2)] withRowAnimation:UITableViewRowAnimationNone];
}

/**
 * Returns a server dictionary from either Available or Custom servers.
 *
 * We are displaying both AvailableServers and CustomServers in one table:
 * AvailableServers first, then any customServers.
 * CustomServer indexes need to be offset by the number of availableServers
 */
- (NSDictionary *)getTargetServer:(NSInteger)index
{
    NSUInteger numAvailableServers = [availableServers count];
    if (index < numAvailableServers) {
        return availableServers[index];
    }
    else {
        index = index - numAvailableServers;
        return customServers[index];
    }
}



#pragma mark - Table View Handlers
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([customServers count] > 0) {
        return 2;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return [availableServers count];
    }
    return [customServers count];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) return @"Available Servers";
    return @"Custom Servers";
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    NSString *sectionTitle;
    if (section == 0) {
        sectionTitle = @"Available Servers";
    }
    else {
        sectionTitle = @"Custom Servers";
    }
    
    UILabel *label = [[UILabel alloc] init];
    CGRect frame = CGRectMake(20, 8, 320, 20);
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        // The device is an iPad running iOS 3.2 or later.
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        
        if(orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) {
            // The iPad is orientated Landscape
            frame = CGRectMake(120, 8, 320, 20);
        }
    }
    
    label.frame = frame;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor colorWithRed:78/255.0f green:84/255.0f blue:102/255.0f alpha:1];
    //    label.shadowColor = [UIColor grayColor];
    //    label.shadowOffset = CGSizeMake(-1.0, 1.0);
    label.font = [UIFont fontWithName:@"Heiti SC" size:15];
    label.text = sectionTitle;
    
    UIView *view = [[UIView alloc] init];
    [view addSubview:label];
    
    return view;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kCellIdentifier];
    }
    NSDictionary *server;
    if (indexPath.section == 0) {
        server = [self getTargetServer:indexPath.row];
    }
    else {
        server = [self getTargetServer:(indexPath.row + [availableServers count])];
    }
    
    
    
    cell.textLabel      .text = server[kOpen311_Name];
    cell.detailTextLabel.text = server[kOpen311_Url];
    cell.accessoryType = UITableViewCellAccessoryNone;
    if ([[prefs getCurrentServer][kOpen311_Name] isEqualToString:cell.textLabel.text]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        [prefs setCurrentServer:[self getTargetServer:indexPath.row]];
    }
    else {
        [prefs setCurrentServer:[self getTargetServer:(indexPath.row + [availableServers count])]];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    [self performSegueWithIdentifier:kUnwindSegueFromServersToHome sender:self];
}

#pragma mark - Table View Deletion Handlers
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        return TRUE;
    }
    return FALSE;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if ([tableView numberOfRowsInSection:[indexPath section]] > 1) {
            [customServers removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
        else
        {
            [customServers removeObjectAtIndex:indexPath.row];
            [tableView deleteSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}
@end
