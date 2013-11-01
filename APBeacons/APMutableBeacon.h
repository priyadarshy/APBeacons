//
//  APMutableBeacon.h
//  APBeacons
//
//  Created by Ashutosh Priyadarshy on 10/28/13.
//  Copyright (c) 2013 EEMe labs. All rights reserved.
//

@import Foundation;
@import CoreBluetooth;
@import CoreLocation;

@interface APMutableBeacon : NSObject <NSCopying>

@property (strong, nonatomic) NSUUID *proximityUUID;
@property (strong, nonatomic) NSNumber *major;
@property (strong, nonatomic) NSNumber *minor;
@property (strong, nonatomic) NSString *identifier;
@property (nonatomic, readonly) CLProximity proximity; // Not yet implemented.
@property (nonatomic, readonly) CLLocationAccuracy accuracy; // Not yet implemented.
@property (nonatomic) NSInteger rssi;
@property (nonatomic) BOOL validated;

- (id)initWithProximityUUID:(NSUUID *)proximityUUID major:(NSNumber *)major minor:(NSNumber *)minor identifier:(NSString *)identifier;
- (BOOL)isPopulated;

@end
