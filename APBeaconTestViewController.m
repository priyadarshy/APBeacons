//
//  APBeaconTestViewController.m
//  APBeacons
//
//  Created by Ashutosh Priyadarshy on 10/29/13.
//  Copyright (c) 2013 EEMe labs. All rights reserved.
//

#import "APBeaconTestViewController.h"

@interface APBeaconTestViewController ()

@end

@implementation APBeaconTestViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.beaconManager = [[APBeaconManager alloc] init];
    [self.beaconManager setDelegate:self];
    APBeaconRegion *beaconRegion = [[APBeaconRegion alloc] initWithProximityUUID:[NSUUID UUID] major:[NSNumber numberWithInt:44] minor:[NSNumber numberWithInt:22] identifier:@"com.beacons.test"];
    [self.beaconManager startBroadcastingBeaconRegion:beaconRegion];
    [self.beaconManager beginScanningForBeacons];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - APBeaconManagerDelegate Methods
- (void)beaconManager:(APBeaconManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(APBeaconRegion *)region
{
    NSLog(@"Beacons = %@", beacons);
}
- (void)beaconManager:(APBeaconManager *)manager didEnterRegion:(APBeaconRegion *)region
{
    
}
- (void)beaconManager:(APBeaconManager *)manager didExitRegion:(APBeaconRegion *)region
{
    
}
- (void)beaconManager:(APBeaconManager *)manager didDetermineState:(APBeaconRegionState)state forRegion:(APBeaconRegion *)region
{
    
}
- (void)beaconManager:(APBeaconManager *)manager didStartAdvertisingRegion:(APBeaconRegion *)beaconRegion
{
    NSLog(@"didStartAdvertisingRegion");
}
- (void)beaconManager:(APBeaconManager *)manager failedToAdvertiseRegion:(APBeaconRegion *)beaconRegion
{
    NSLog(@"failedToAdvertiseRegion");
}


@end
