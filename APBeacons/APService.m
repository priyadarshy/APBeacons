//
//  APService.m
//  APBeacons
//
//  Created by Ashutosh Priyadarshy on 10/25/13.
//  Copyright (c) 2013 EEMe labs. All rights reserved.
//

#import "APService.h"
#import <CommonCrypto/CommonCrypto.h>

/* BLE Service and Characteristics */
NSString * const defaultServiceUUIDString = @"46EF24E0-E5C2-4A9F-9393-297531CBA651";
NSString * const majorCharacteristicUUIDString = @"2081B950-1806-4AF8-9411-A846A8A919C9";
NSString * const minorCharacteristicUUIDString = @"0C2D58CF-3919-4E3A-9782-DA7743E8BBB3";
NSString * const keyCharacteristicUUIDString = @"C4B0E944-D3E1-4844-99A4-66F9806D92C9";
/* Seed value for computing verification hash. */
NSString * const keySeedString = @"6FED21D8-B48C-4B56-B6A1-98BBC0AEC4DA";

@implementation APService

+(id)sharedInstance
{
    static APService *__sharedInstance;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        __sharedInstance = [[APService alloc] init];
    });
    
    return __sharedInstance;
}

- (id)initWithMajorData:(NSData *)majorData minorData:(NSData *)minorData {
    
    self = [super init];
    if (self) {
        _defaultService = [[CBMutableService alloc] initWithType:[self defaultServiceUUID] primary:YES];
        _majorCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[self majorCharacteristicUUID] properties:CBCharacteristicPropertyRead value:majorData permissions:CBAttributePermissionsReadable];
        _minorCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[self minorCharacteristicUUID] properties:CBCharacteristicPropertyRead value:majorData permissions:CBAttributePermissionsReadable];
        _verificationHashCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[self verificationHashCharacteristicUUID] properties:CBCharacteristicPropertyRead value:majorData permissions:CBAttributePermissionsReadable];
        _defaultService.characteristics = @[self.majorCharacteristic, self.minorCharacteristic, self.verificationHashCharacteristic];
    }
    return self;
}

-(BOOL)verifyHash:(NSString *)key
{
    // The locally computed key and key string are computed from digest.
    unsigned char digest[CC_SHA1_DIGEST_LENGTH];
    NSData *stringBytes = [keySeedString dataUsingEncoding: NSUTF8StringEncoding];
    // Attempt the SHA-1 hash computation.
    if (CC_SHA1([stringBytes bytes], (int)[stringBytes length], digest)) {
        // SHA-1 hash has been calculated and stored in 'digest'.
        NSString *locallyComputedKey = [NSString stringWithUTF8String:(char *)digest];
        // Verify the hash.
        if ([key isEqualToString:locallyComputedKey]) {
            return YES;
        } else {
            return NO;
        }
    } else {
        NSLog(@"Unable to compute SHA1");
        return NO;
    }
}

-(NSArray *)availableServiceUUIDs
{
    return @[[self defaultServiceUUID]];
}

-(NSArray *)availableCharacteristicUUIDs
{
    return @[[self majorCharacteristicUUID], [self minorCharacteristicUUID], [self verificationHashCharacteristicUUID]];
}

-(CBUUID *)defaultServiceUUID
{
    return [CBUUID UUIDWithString:majorCharacteristicUUIDString];
}

-(CBUUID *)majorCharacteristicUUID
{
    return [CBUUID UUIDWithString:majorCharacteristicUUIDString];
}

-(CBUUID *)minorCharacteristicUUID
{
    return [CBUUID UUIDWithString:majorCharacteristicUUIDString];
}

-(CBUUID *)verificationHashCharacteristicUUID
{
    return [CBUUID UUIDWithString:keyCharacteristicUUIDString];
}

@end
