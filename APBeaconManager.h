//
//  APBeaconManager.h
//  APBeacons
//
//  Created by Ashutosh Priyadarshy on 10/28/13.
//  Copyright (c) 2013 EEMe labs. All rights reserved.
//

@import Foundation;
@import CoreBluetooth;
#import "APBeaconRegion.h"


@class APBeaconManager;
@protocol APBeaconManagerDelegate <NSObject>

/*
 * When acting as a client send these messages to a client.
 */
- (void)beaconManager:(APBeaconManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(APBeaconRegion *)region;
- (void)beaconManager:(APBeaconManager *)manager didEnterRegion:(APBeaconRegion *)region;
- (void)beaconManager:(APBeaconManager *)manager didExitRegion:(APBeaconRegion *)region;
- (void)beaconManager:(APBeaconManager *)manager didDetermineState:(APBeaconRegionState)state forRegion:(APBeaconRegion *)region;
/*
 * When acting as a server send these messages to a delegate.
 */
- (void)beaconManager:(APBeaconManager *)manager didStartAdvertisingRegion:(APBeaconRegion *)beaconRegion;
- (void)beaconManager:(APBeaconManager *)manager failedToAdvertiseRegion:(APBeaconRegion *)beaconRegion;

@end

// TODO ADD Back the CBCentralManagerDelegate
@interface APBeaconManager : NSObject <CBPeripheralManagerDelegate, CBPeripheralDelegate>

@property (weak, nonatomic) id<APBeaconManagerDelegate> delegate;
@property (strong, nonatomic, readonly) CBPeripheralManager *peripheralManager;
//@property (strong, nonatomic, readonly) CBCentralManager *centralManager;
@property (strong, nonatomic, readonly) APBeaconRegion *beaconRegion;
@property (strong, nonatomic, readonly) NSMutableDictionary *txBeaconRegions;
@property (strong, nonatomic, readonly) NSMutableArray *txQueuedBeaconRegions;

// Caller uses this to start broadcasting the APBeacon.
-(void)startBroadcastingBeaconRegion:(APBeaconRegion *)beaconRegion;


@end
