//
//  APBeacon.m
//  APBeacons
//
//  Created by Ashutosh Priyadarshy on 10/28/13.
//  Copyright (c) 2013 EEMe labs. All rights reserved.
//

#import "APMutableBeacon.h"

@interface APMutableBeacon ()

@property CLProximity proximity;
@property CLLocationAccuracy accuracy;

@end

@implementation APMutableBeacon

- (id)init
{
    NSUUID *uuid = [[NSUUID alloc] init];
    NSNumber *number = [NSDecimalNumber notANumber];
    NSString *identifier = [[NSString alloc] init];
    
    return [self initWithProximityUUID:uuid major:number minor:number identifier:identifier];
}

- (id)initWithProximityUUID:(NSUUID *)proximityUUID major:(NSNumber *)major minor:(NSNumber *)minor identifier:(NSString *)identifier
{
    self = [super init];
    if (self) {
        
        self.proximityUUID = proximityUUID;
        self.major = major;
        self.minor = minor;
        self.identifier = identifier;
        self.accuracy = 0.0;
        self.rssi = 0.0;
        self.proximity = CLProximityUnknown;
        self.validated = NO; // default value
    }
    
    return self;
}

-(id)copyWithZone:(NSZone *)zone
{
    id copy = [[[self class] alloc] init];
    
    if (copy){
        [copy setProximityUUID:[self.proximityUUID copyWithZone:zone]];
        [copy setMajor:[self.major copyWithZone:zone]];
        [copy setMinor:[self.minor copyWithZone:zone]];
        [copy setIdentifier:[self.identifier copyWithZone:zone]];
        [copy setProximity:self.proximity];
        [copy setAccuracy:self.accuracy];
        [copy setRssi:self.rssi];
        [copy setValidated:self.validated];
    }
    NSLog(@"[APMutableBeacon copyWithZone:(NSZone *)zone]");
    return copy;
}

-(BOOL)isPopulated
{
    if (self.proximityUUID && ![self.major isEqualToNumber:[NSDecimalNumber notANumber]] && ![self.minor isEqualToNumber:[NSDecimalNumber notANumber]]) {
        return YES;
    } else {
        return NO; 
    }
}

-(void)setRssi:(NSInteger)rssi
{
    
    _rssi = rssi;
    
    if (_rssi > 0 && _rssi > -45) {
        self.proximity = CLProximityImmediate;
    } else if (_rssi <= -45 && _rssi < -65) {
        self.proximity = CLProximityNear;
    } else if (_rssi <= -65 && _rssi < -140){
        self.proximity = CLProximityFar;
    } else {
        self.proximity = CLProximityUnknown;
    }
}

@end
