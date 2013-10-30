//
//  APBeaconTestViewController.h
//  APBeacons
//
//  Created by Ashutosh Priyadarshy on 10/29/13.
//  Copyright (c) 2013 EEMe labs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APBeaconManager.h"
#import "APBeaconRegion.h"

@interface APBeaconTestViewController : UIViewController <APBeaconManagerDelegate>

@property (strong, nonatomic) APBeaconManager *beaconManager;

@end
