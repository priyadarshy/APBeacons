//
//  APBeaconManager.m
//  APBeacons
//
//  Created by Ashutosh Priyadarshy on 10/28/13.
//  Copyright (c) 2013 EEMe labs. All rights reserved.
//
//  APBeaconManager manages a Central and a Peripheral as needed.
//

#import "APBeaconManager.h"

@interface APBeaconManager ()

@property CBPeripheralManager *peripheralManager;
@property CBCentralManager *centralManager;
@property APBeaconRegion *beaconRegion;
@property NSMutableDictionary *txBeaconRegions;

@end

@implementation APBeaconManager

- (id)init
{
    self = [super init];
    if (self) {
        self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil options:nil];
//        self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:nil];
        self.beaconRegion = [[APBeaconRegion alloc] init];
    }
    return self;
}

/*
 * Calls made by our delegate to make things happen.
 */
-(void)startBroadcastingBeaconRegion:(APBeaconRegion *)beaconRegion
{
    // Post an error message if we're overwriting a previous identifier.
    if ([self.beaconRegion.identifier isEqualToString:self.beaconRegion.identifier]){
        NSLog(@"Beacon Region previously exists for identifier %@. Will overwrite.", beaconRegion.identifier);
    }
    // Assign this beacon region to be the manager's beacon region.
    self.beaconRegion = beaconRegion;
}

/*
 * Things we do internally with the Peripheral and BLE.
 */
-(void)setupServiceForBeaconRegion
{
    if (self.peripheralManager.state == CBPeripheralManagerStatePoweredOn) {
        // Add beacon region to monitored regions and remove from queue.
        [self.peripheralManager addService:self.beaconRegion.service.defaultService];
    } else {
        NSLog(@"Unable to broadcast service. Peripheral Manager not powered on.");
    }
}

-(void)advertiseServiceForBeaconRegion
{
    [self.peripheralManager startAdvertising:@{CBAdvertisementDataServiceUUIDsKey:
                                                   [self.beaconRegion.service availableServiceUUIDs],
                                               CBAdvertisementDataLocalNameKey:
                                                   @"APBeacons"
                                               }
     ];
}

#pragma mark - CBPeripheralManagerDelegate Methods

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    // Log the state change message to the console. 
    NSString *stateDescription = nil;
    switch (peripheral.state) {
        case CBPeripheralManagerStateResetting:
            stateDescription = @"resetting"; break;
        case CBPeripheralManagerStateUnsupported:
            stateDescription = @"unsupported"; break;
        case CBPeripheralManagerStateUnauthorized:
            stateDescription = @"unauthorized"; break;
        case CBPeripheralManagerStatePoweredOff:
            stateDescription = @"off"; break;
        case CBPeripheralManagerStatePoweredOn:
            stateDescription = @"on"; break;
        default:
            stateDescription = @"unknown"; break;
    }
    NSLog(@"peripheralManager:%@ didUpdateState: %@ (%d)", peripheral, stateDescription, (int)peripheral.state);
    
    switch (peripheral.state) {
        case CBPeripheralManagerStatePoweredOn:
            [self setupServiceForBeaconRegion];
            [self advertiseServiceForBeaconRegion];
            break;
        default:
            break;
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error
{
    NSLog(@"peripheralManager:%@ didAddService:%@ error:%@",
          peripheral, service, [error localizedDescription]);
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error
{
    if (error) {
        NSLog(@"APBeaconManager - (peripheralManagerDidStartAdvertising:)%@ error:%@", peripheral, [error localizedDescription]);
        // Inform delegate of advertisement failure.
        if ([self.delegate respondsToSelector:@selector(beaconManager:failedToAdvertiseRegion:)]) {
            [self.delegate beaconManager:self failedToAdvertiseRegion:self.beaconRegion];
        }
    } else {
        // Inform delegate of advertisement success.
        if ([self.delegate respondsToSelector:@selector(beaconManager:didStartAdvertisingRegion:)]) {
            [self.delegate beaconManager:self didStartAdvertisingRegion:self.beaconRegion];
        }
    }
}

// This is never called because we have static data.
- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request
{
    // Set high latency, we want to conserve battery.
    [peripheral setDesiredConnectionLatency:CBPeripheralManagerConnectionLatencyHigh forCentral:request.central];
    
    // Let's see which characteristics a Central tries to read.
    for (CBCharacteristic * characteristic in self.beaconRegion.service.defaultService.characteristics) {
        if ([characteristic.UUID isEqual:request.characteristic.UUID]) {
            NSLog(@"Central %@ just read %@", request.central, characteristic);
        }
    }
}

- (void)respondToRequest:(CBATTRequest *)request withResult:(CBATTError)result
{
    
}



@end


