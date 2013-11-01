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
    NSData *majorData = [[self.major stringValue] dataUsingEncoding:NSUTF8StringEncoding];
    NSData *minorData = [[self.minor stringValue] dataUsingEncoding:NSUTF8StringEncoding];
    // Initialize the APBeaconService (the BLE service).
    self.service = [[APBeaconService alloc] initWithProximityUUID:proximityUUID major:majorData minor:minorData];
    
    return self;
}

@end
