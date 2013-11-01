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
@property NSTimer *scanTimer;
@property NSMutableDictionary *txBeaconRegions;
@property APBeaconService *wildcardBeaconService;
@property CBPeripheral *readablePeripheral;
@property NSMutableDictionary *scannedPeripherals;
@property NSMutableDictionary *verifiedAndPopulatedPeripherals;

@end

@implementation APBeaconManager

- (id)init
{
    return [self initWithDelegate:nil];
}

- (id)initWithDelegate:(id)delegate
{
    self = [super init];
    if  (self) {
        self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil options:nil];
        self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:nil];
        self.beaconRegion = [[APBeaconRegion alloc] init];
        self.delegate = delegate;
        self.wildcardBeaconService = [[APBeaconService alloc] initWildcardService];
        self.scannedPeripherals = [[NSMutableDictionary alloc] init];
        self.verifiedAndPopulatedPeripherals = [[NSMutableDictionary alloc] init];
        self.scanTimer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(beginScanningForBeacons) userInfo:nil repeats:YES];
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

-(void)stopBroadcastingBeaconRegion:(APBeaconRegion *)beaconRegion
{
    // Eventually we might support broadcasting multiple APBeacons from one device.
    if (beaconRegion == nil) {
        // If we pass nil, we ask peripheralManger to stop broadcasting our saved beaconRegion.
        [self.peripheralManager removeService:self.beaconRegion.service.defaultService];
    } else {
        [self.peripheralManager removeService:beaconRegion.service.defaultService];
    }
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

/*
 *
 *
 *          ***   CENTRAL MANAGER CODE   ***
 *
 *
 */

//
//      FUNCTIONS CALLED BY USER/CALLER
//
#pragma mark - ManagerSetup

-(void)beginScanningForBeacons
{
    NSArray *services = [self.wildcardBeaconService availableServiceUUIDs];
    [self.centralManager scanForPeripheralsWithServices:services
                                                options:nil];

    // TODO MEMORY LEAK
    // Add the refresh timer to the run loop and start refreshing our client list at 1 Hz.
//    [[NSRunLoop currentRunLoop] addTimer:self.scanTimer forMode:NSDefaultRunLoopMode];
}

#pragma mark - CBCentralManagerDelegate Methods

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    NSLog(@"centralManagerDidUpdateState:%@", central);
    NSString * state = nil;
    switch ([self.centralManager state]) {
        case CBCentralManagerStateUnsupported:
            state = @"The platform/hardware doesn't support Bluetooth Low Energy.";
            break;
        case CBCentralManagerStateUnauthorized:
            state = @"The app is not authorized to use Bluetooth Low Energy.";
            break;
        case CBCentralManagerStatePoweredOff:
            state = @"Bluetooth is currently powered off.";
            break;
        case CBCentralManagerStatePoweredOn:
            state = @"Powered On";
            [self beginScanningForBeacons];
            break;
        case CBCentralManagerStateUnknown:
        default:
            state = @"Unknown";
    }
    NSLog(@"centralManagerDidUpdateState: %@ to %@", central, state);
}

- (void)centralManager:(CBCentralManager *)central
 didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary *)advertisementData
                  RSSI:(NSNumber *)RSSI {
    
    NSLog(@"Discovered %@, %@, %d", peripheral.name, advertisementData, [RSSI intValue]);
    self.readablePeripheral = peripheral;
    [self.centralManager connectPeripheral:self.readablePeripheral options:nil];
    
}

- (void) centralManager:(CBCentralManager *)central
   didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"centralManager:didConnectPeripheral:%@", peripheral);
    [peripheral setDelegate:self];
    NSLog(@"discovering services...");
    [peripheral discoverServices:[self.wildcardBeaconService availableServiceUUIDs]];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    
    for (CBService *service in peripheral.services) {
        NSLog(@"Discovered service %@", service);
        if (service.isPrimary) {
            [peripheral discoverCharacteristics:[self.wildcardBeaconService availableCharacteristicUUIDs] forService:service];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral
didDiscoverCharacteristicsForService:(CBService *)service
             error:(NSError *)error
{
    NSLog(@"peripheral:%@ didDiscoverCharacteristicsForService:%@ error:%@",
          peripheral, service, [error localizedDescription]);
    
    if (error) {
        NSLog(@"Discovered characteristics for %@ with error: %@",
              service.UUID, [error localizedDescription]);
        return;
    } else {
        for (CBCharacteristic *characteristic in service.characteristics){
            NSLog(@"Discovered characteristic %@", characteristic);
            [peripheral readValueForCharacteristic:characteristic];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral
didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic
             error:(NSError *)error {
    
    if (!error) {
        
        NSData *data = characteristic.value;
        NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"Value for <CBCharacteristic = %@> is %@", characteristic, dataString);
        
        APMutableBeacon *mutableBeacon;
        // Pull out the appropriate APMutableBeacon associated with this peripheral.
        if ([self.scannedPeripherals objectForKey:peripheral.identifier]) {
            mutableBeacon = [self.scannedPeripherals objectForKey:peripheral.identifier];
        } else if ([self.verifiedAndPopulatedPeripherals objectForKey:peripheral.identifier]) {
            mutableBeacon = [self.verifiedAndPopulatedPeripherals objectForKey:peripheral.identifier];
        } else {
            // Create a new one if we don't have it in either set.
            mutableBeacon = [[APMutableBeacon alloc] init];
            [self.scannedPeripherals setObject:mutableBeacon forKey:peripheral.identifier];
        }
        
        //
        //  Fill in all beacon data values by traversing characteristics.
        //
        
        // If the hash value checks out. We can verify this sensor.
        if ([characteristic.UUID isEqual:[self.wildcardBeaconService verificationHashCharacteristicUUID]]){
            if ([self.wildcardBeaconService verifyHash:dataString]) {
                NSLog(@"Found Valid APBeacon.");
                mutableBeacon.validated = YES;
            } else {
                // If the scanned peripheral doesn't pass our checks, forget about it.
                [self.scannedPeripherals removeObjectForKey:peripheral.identifier];
            }
        }
        // Update the numeric fields of the mutableBeacon.
        if ([characteristic.UUID isEqual:[self.wildcardBeaconService proximityUUIDCharacteristicUUID]]) {
            [mutableBeacon setProximityUUID:[[NSUUID alloc] initWithUUIDString:dataString]];
        }
        if ([characteristic.UUID isEqual:[self.wildcardBeaconService majorCharacteristicUUID]]) {
            [mutableBeacon setMajor:[NSNumber numberWithInteger:[dataString integerValue]]];
        }
        if ([characteristic.UUID isEqual:[self.wildcardBeaconService minorCharacteristicUUID]]) {
            [mutableBeacon setMinor:[NSNumber numberWithInteger:[dataString integerValue]]];
        }
        if([mutableBeacon isPopulated]) {
            // Inform our delegate we found one!
            mutableBeacon.rssi = [peripheral.RSSI integerValue];
            
            // Add the mutableBeacon to the verifiedAndPopulated collection, remove it from scannedPeripherals.
            [self.verifiedAndPopulatedPeripherals setObject:mutableBeacon forKey:peripheral.identifier];
            [self.scannedPeripherals removeObjectForKey:peripheral.identifier];
            
            NSArray *rangedBeacons = [self.verifiedAndPopulatedPeripherals allValues];
            NSArray *copiedRangedBeacons = [[NSArray alloc] initWithArray:rangedBeacons copyItems:YES];
            
            if ([self.delegate respondsToSelector:@selector(beaconManager:didRangeBeacons:inRegion:)]) {
                [self.delegate beaconManager:self didRangeBeacons:copiedRangedBeacons inRegion:nil];
            }
            
            [peripheral readRSSI]; // Request an RSSI update.
        }
        [self.scannedPeripherals setObject:mutableBeacon forKey:peripheral.identifier];
    }
}

- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error
{
    if([self.scannedPeripherals objectForKey:peripheral.identifier]){

        APMutableBeacon *mutableBeacon = [self.scannedPeripherals objectForKey:peripheral.identifier];
        [mutableBeacon setRssi:[peripheral.RSSI integerValue]];
    }
}



@end


