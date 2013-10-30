//
//  APPeripheralViewController.h
//  APBeacons
//
//  Created by Ashutosh Priyadarshy on 10/25/13.
//  Copyright (c) 2013 EEMe labs. All rights reserved.
//


@import UIKit;
@import CoreBluetooth;
#import "APBeaconService.h"

@interface APPeripheralViewController : UIViewController <CBPeripheralManagerDelegate>

@property (strong, nonatomic) APBeaconService *service; 
@property (strong, nonatomic) CBPeripheralManager *peripheralManager;

@end

