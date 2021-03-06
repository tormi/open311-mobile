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

#import "HomeController.h"
#import "Strings.h"
#import "Preferences.h"
#import "Open311.h"

static NSString * const kSegueToSettings = @"SegueToSettings";
static NSString * const kSegueToChooseGroup = @"SegueToChooseGroup";
static NSString * const kSegueToContainerView = @"SegueToChooseGroupiPad";
static NSString * const kSegueToServers = @"SegueToServers";
static NSString * const kSegueToArchive = @"SegueToArchive";
static NSString * const kUnwindSegueFromServersToHome = @"UnwindSegueFromServersToHome";
static NSString * const kUnwindSegueFromReportToHome = @"UnwindSegueFromReportToHome";
static NSString * const kSegueToAbout = @"SegueToAbout";

@implementation HomeController

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	[self loadServer];
}

/**
 * Check if the user has chosen a server.
 * If not, redirect them to the servers tab;
 * otherwise, load all service information from the server.
 */
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self refreshPersonalInfo];
}

- (void)loadServer
{
	Preferences *preferences = [Preferences sharedInstance];
	
	NSDictionary *currentServer = [preferences getCurrentServer];
	if (currentServer == nil) {
		[self performSegueWithIdentifier:kSegueToServers sender:self];
	}
	else {
		self.navigationItem.title = currentServer[kOpen311_Name];
		
		HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
		[self.navigationController.view addSubview:HUD];
		HUD.delegate = self;
		HUD.labelText = NSLocalizedString(kUI_HudLoadingMessage, nil);
		[HUD show:YES];
		Open311 *open311 = [Open311 sharedInstance];
		[open311 loadServer:currentServer withCompletion:^() {
            [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
        }];
		NSString *filename = currentServer[kOpen311_SplashImage];
		if (!filename) { filename = @"open311"; }
		[self.splashImage setImage:[UIImage imageNamed:filename]];
	}
}

- (void)refreshPersonalInfo
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *firstname = [defaults stringForKey:kOpen311_FirstName];
	NSString *lastname  = [defaults stringForKey:kOpen311_LastName];
	if ([firstname length] > 0 || [lastname length] > 0) {
        self.personalInfoLabel.text = [NSString stringWithFormat:@"%@ %@", firstname, lastname];
	}
	
	[self.tableView reloadData];
}

#pragma mark - Table Handler Methods

#pragma mark -unwind segue
-(IBAction) didReturnFromServersController:(UIStoryboardSegue *)sender
{
	if ([sender.identifier isEqualToString:kUnwindSegueFromServersToHome]) {
		[self loadServer];
    }
}

-(IBAction) didReturnAfterSendingReport:(UIStoryboardSegue *)sender
{
	//    if ([sender.identifier isEqualToString:kUnwindSegueFromReportToHome])
	//      TODO: do something if it should open the Archive
}

#pragma mark MBProgressHUDDelegate methods
- (void)hudWasHidden:(MBProgressHUD *)hud
{
	// Remove HUD from screen when the HUD was hidded
	[HUD removeFromSuperview];
	HUD.labelText = nil;
	HUD = nil;
}


@end
