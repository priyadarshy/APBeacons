//
//  APBeaconService.h
//  APBeacons
//
//  Created by Ashutosh Priyadarshy on 10/25/13.
//  Copyright (c) 2013 EEMe labs. All rights reserved.
//
//   This describes the service that every APBeacon transmits via BLE.
//    <<default_service>>
//       -> major_characteristic //[User Data]
//       -> minor_characteristic //[User Data]
//       -> verification_hash_characteristic //[Used to Verify Service Provider]
//
//

@import Foundation;
@import CoreBluetooth;

/* Constants for our BLE UUIDs */
NSString * const serviceUUIDString;
NSString * const proximityCharacteristicUUIDString;
NSString * const majorCharacteristicUUIDString;
NSString * const minorCharacteristicUUIDString;
NSString * const verificationHashCharacteristicUUIDString;
/* Use this to compute and compare hashes to verify periperhal identity. */
NSString * const keySeedString;


@interface APBeaconService : NSObject

@property (strong, nonatomic, readonly) CBMutableService *defaultService;
@property (strong, nonatomic, readonly) CBMutableCharacteristic *proximityUUIDCharacteristic;
@property (strong, nonatomic, readonly) CBMutableCharacteristic *majorCharacteristic;
@property (strong, nonatomic, readonly) CBMutableCharacteristic *minorCharacteristic;
@property (strong, nonatomic, readonly) CBMutableCharacteristic *verificationHashCharacteristic;

- (id)initWithProximityUUID:(NSUUID *)proximityUUID major:(NSData *)major minor:(NSData *)minor;
- (id)initWithProximityUUID:(NSUUID *)proximityUUID major:(NSData *)major;
- (id)initWithProximityUUID:(NSUUID *)proximityUUID;
- (id)initWildcardService;

- (BOOL)verifyHash:(NSString *)verificationHash;

- (NSArray *)availableServiceUUIDs;
- (NSArray *)availableCharacteristicUUIDs;
- (CBUUID *)defaultServiceUUID;
- (CBUUID *)proximityUUIDCharacteristicUUID;
- (CBUUID *)majorCharacteristicUUID;
- (CBUUID *)minorCharacteristicUUID;
- (CBUUID *)verificationHashCharacteristicUUID;


@end
