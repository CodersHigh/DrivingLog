//
//  LSAssetController.m
//  DrivingLog
//
//  Created by JokerPortable on 11. 7. 18..
//  Copyright 2011 LingoStar. All rights reserved.
//

#import "LSAssetController.h"
#import "LSAssetPlayerController.h"
#import "LSAppDelegate.h"
#import "LSLogData.h"
#import <QuartzCore/QuartzCore.h>

@implementation LSAssetController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CALayer *navBarImageLayer = [CALayer layer];
    navBarImageLayer.frame = CGRectMake(0, 0, 320, 44);
    navBarImageLayer.contents = (id)[[UIImage imageNamed:@"navbar_log_list.png"] CGImage];
    [self.navigationController.navigationBar.layer addSublayer:navBarImageLayer];
    
    UIBarButtonItem *doneButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissModal:)];
    self.navigationItem.rightBarButtonItem = doneButtonItem;
}

-(NSString *)documentDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths lastObject];
}

- (void)dismissModal:(id)sender
{
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSMutableArray *)drivingLogArray
{
    LSAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    return appDelegate.drivingLogArray;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.drivingLogArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"LogListCell" owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
        cell.contentView.backgroundColor = [UIColor darkGrayColor];
    }
    
    LSLogData *currLog = [self.drivingLogArray objectAtIndex:indexPath.row];
    UILabel *cellLabel;
    
    cellLabel = (UILabel *)[cell viewWithTag:11];
    cellLabel.text = currLog.assetName;
    
    cellLabel = (UILabel *)[cell viewWithTag:21];
    cellLabel.text = currLog.durationString;
    
    cellLabel = (UILabel *)[cell viewWithTag:22];
    cellLabel.text = currLog.sizeString;
    
    cellLabel = (UILabel *)[cell viewWithTag:31];
    NSString *routeString = [NSString stringWithFormat:@"%@ ~ %@", currLog.startAddress, currLog.lastAddress];
    cellLabel.text = routeString;
    
    return cell;
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 86.0;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LSAssetPlayerController *playViewController = [[LSAssetPlayerController alloc] initWithNibName:@"LSAssetPlayerController" bundle:nil];
    
    LSLogData *selectedLog = [self.drivingLogArray objectAtIndex:indexPath.row];
    playViewController.selectedLogData = selectedLog;
    [self.navigationController pushViewController:playViewController animated:YES];
}

@end
