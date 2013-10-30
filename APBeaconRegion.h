//
//  APBeaconRegion.h
//  APBeacons
//
//  Created by Ashutosh Priyadarshy on 10/29/13.
//  Copyright (c) 2013 EEMe labs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APBeaconService.h"

typedef enum APBeaconRegionState {
    APBeaconRegionStateUnknown,
    APBeaconRegionStateInside,
    APBeaconRegionStateOutside
} APBeaconRegionState;

@interface APBeaconRegion : NSObject

@property (strong, readonly, nonatomic) APBeaconService *service;
@property (strong, readonly, nonatomic) NSUUID *proximityUUID;
@property (strong, readonly, nonatomic) NSNumber *major;
@property (strong, readonly, nonatomic) NSNumber *minor;
@property (strong, readonly, nonatomic) NSString *identifier;
@property (nonatomic, assign) BOOL notifyEntryStateOnDisplay;

- (id)initWithProximityUUID:(NSUUID *)proximityUUID identifier:(NSString *)identifier;
- (id)initWithProximityUUID:(NSUUID *)proximityUUID major:(NSNumber *)major identifier:(NSString *)identifier;
- (id)initWithProximityUUID:(NSUUID *)proximityUUID major:(NSNumber *)major minor:(NSNumber *)minor identifier:(NSString *)identifier;


@end
