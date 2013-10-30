//
//  APBeacon.h
//  APBeacons
//
//  Created by Ashutosh Priyadarshy on 10/28/13.
//  Copyright (c) 2013 EEMe labs. All rights reserved.
//

@import Foundation;
@import CoreBluetooth;
@import CoreLocation;

@interface APBeacon : NSObject

@property (strong, nonatomic, readonly) NSUUID *proximityUUID;
@property (strong, nonatomic, readonly) NSNumber *major;
@property (strong, nonatomic, readonly) NSNumber *minor;
@property (strong, nonatomic, readonly) NSString *identifier;
@property (nonatomic, readonly) CLProximity proximity; // Not yet implemented.
@property (nonatomic, readonly) CLLocationAccuracy accuracy; // Not yet implemented.
@property (nonatomic, readonly) NSInteger rssi; // Not yet implemented.

@end
