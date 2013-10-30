//
//  APBeacon.m
//  APBeacons
//
//  Created by Ashutosh Priyadarshy on 10/28/13.
//  Copyright (c) 2013 EEMe labs. All rights reserved.
//

#import "APBeacon.h"

@interface APBeacon ()

@property NSUUID *proximityUUID;
@property NSNumber *major;
@property NSNumber *minor;
@property NSString *identifier;
@property CLProximity proximity;
@property CLLocationAccuracy accuracy;
@property NSInteger rssi;

@end

@implementation APBeacon

- (id)init
{
    NSUUID *uuid = [NSUUID UUID];
    NSNumber *number = [NSNumber numberWithInt:0];
    NSString *identifier = @"com.apbeacons.default";
    
    return [self initWithProximityUUID:uuid major:number minor:number identifier:identifier];
}

- (id)initWithProximityUUID:(NSUUID *)proximityUUID major:(NSNumber *)major minor:(NSNumber *)minor identifier:(NSString *)identifier
{
    self = [super init];
    if (self) {
        
        // Set default values.
        if (!identifier) {
            identifier = @"com.apbeacons.default";
        }
        if (!major) {
            major = [NSNumber numberWithInt:0];
        }
        if (!minor) {
            minor = [NSNumber numberWithInt:0];
        }
        
        self.proximityUUID = proximityUUID;
        self.major = major;
        self.minor = minor;
        self.identifier = identifier;
        self.accuracy = 0.0;
        self.rssi = 0.0;
        self.proximity = CLProximityUnknown;
    }
    
    return self;
}

@end
