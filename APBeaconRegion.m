//
//  APBeaconRegion.m
//  APBeacons
//
//  Created by Ashutosh Priyadarshy on 10/29/13.
//  Copyright (c) 2013 EEMe labs. All rights reserved.
//

#import "APBeaconRegion.h"

@interface APBeaconRegion ()

@property APBeaconService *service;
@property NSUUID *proximityUUID;
@property NSNumber *major;
@property NSNumber *minor;
@property NSString *identifier;

@end

@implementation APBeaconRegion

- (id)initWithProximityUUID:(NSUUID *)proximityUUID identifier:(NSString *)identifier
{
    return [self initWithProximityUUID:proximityUUID major:[NSNumber numberWithInt:0] minor:[NSNumber  numberWithInt:0] identifier:identifier];
}
- (id)initWithProximityUUID:(NSUUID *)proximityUUID major:(NSNumber *)major identifier:(NSString *)identifier
{
    return [self initWithProximityUUID:proximityUUID major:major minor:[NSNumber numberWithInt:0] identifier:identifier];
}
- (id)initWithProximityUUID:(NSUUID *)proximityUUID major:(NSNumber *)major minor:(NSNumber *)minor identifier:(NSString *)identifier
{
    self = [super init];
    if (self) {
        self.proximityUUID = proximityUUID;
        self.major = major;
        self.minor = minor;
        self.identifier = identifier;
        self.notifyEntryStateOnDisplay = NO;
    }
    
    // Move out conversion to NSData for clarity.
    int major_val = [self.major intValue];
    NSData *majorData = [NSData dataWithBytes:&major_val length:sizeof(major_val)];
    int minor_val  = [self.minor intValue];
    NSData *minorData = [NSData dataWithBytes:&minor_val length:sizeof(minor_val)];
    // Initialize the APBeaconService (the BLE service).
    self.service = [[APBeaconService alloc] initWithMajorData:majorData minorData:minorData];
    
    return self;
}

@end
