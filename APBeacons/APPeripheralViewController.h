//
//  APPeripheralViewController.h
//  APBeacons
//
//  Created by Ashutosh Priyadarshy on 10/25/13.
//  Copyright (c) 2013 EEMe labs. All rights reserved.
//


@import UIKit;
@import CoreBluetooth;
#import "APService.h"

@interface APPeripheralViewController : UIViewController <CBPeripheralManagerDelegate>

@property (strong, nonatomic) APService *service; 
@property (strong, nonatomic) CBPeripheralManager *peripheralManager;
@property (strong, nonatomic) CBMutableService *defaultService;
@property (strong, nonatomic) CBMutableCharacteristic *majorCharacteristic;
@property (strong, nonatomic) CBMutableCharacteristic *minorCharacteristic;

@end
