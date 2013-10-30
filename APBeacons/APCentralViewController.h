//
//  APCentralViewController.h
//  APBeacons
//
//  Created by Ashutosh Priyadarshy on 10/25/13.
//  Copyright (c) 2013 EEMe labs. All rights reserved.
//

#import "APBeaconService.h"
@import UIKit;
@import CoreBluetooth;

@interface APCentralViewController : UIViewController <CBCentralManagerDelegate, CBPeripheralDelegate>

@property (strong, nonatomic) APBeaconService *service;
@property (strong, nonatomic) CBCentralManager *centralManager;
@property (strong, nonatomic) CBPeripheral *connectablePeripheral;
@property (strong, nonatomic) NSMutableArray *connectedBeacons;

@end
