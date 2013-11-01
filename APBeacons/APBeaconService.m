//
//  APBeaconService.m
//  APBeacons
//
//  Created by Ashutosh Priyadarshy on 10/25/13.
//  Copyright (c) 2013 EEMe labs. All rights reserved.
//

#import "APBeaconService.h"
#import <CommonCrypto/CommonCrypto.h>

/* BLE Service and Characteristics */
NSString * const defaultServiceUUIDString = @"46EF24E0-E5C2-4A9F-9393-297531CBA651";
NSString * const proximityCharacteristicUUIDString = @"5C9291E3-5BC2-46D0-A1D1-CDD665E1A0A0";
NSString * const majorCharacteristicUUIDString = @"2081B950-1806-4AF8-9411-A846A8A919C9";
NSString * const minorCharacteristicUUIDString = @"0C2D58CF-3919-4E3A-9782-DA7743E8BBB3";
NSString * const keyCharacteristicUUIDString = @"C4B0E944-D3E1-4844-99A4-66F9806D92C9";
/* Seed value for computing verification hash. */
NSString * const keySeedString = @"6FED21D8-B48C-4B56-B6A1-98BBC0AEC4DA";

@interface APBeaconService ()

@property CBMutableService *defaultService;
@property CBMutableCharacteristic *proximityUUIDCharacteristic;
@property CBMutableCharacteristic *majorCharacteristic;
@property CBMutableCharacteristic *minorCharacteristic;
@property CBMutableCharacteristic *verificationHashCharacteristic;

@end

@implementation APBeaconService

#pragma mark - Initializer Methods

// Designated initializer.
- (id)initWithProximityUUID:(NSUUID *)proximityUUID major:(NSData *)major minor:(NSData *)minor
{
    self = [super init];
    if (self) {
        self.defaultService = [[CBMutableService alloc] initWithType:[self defaultServiceUUID] primary:YES];
        self.proximityUUIDCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[self proximityUUIDCharacteristicUUID] properties:CBCharacteristicPropertyRead value:[[proximityUUID UUIDString] dataUsingEncoding:NSUTF8StringEncoding] permissions:CBAttributePermissionsReadable];
        self.majorCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[self majorCharacteristicUUID] properties:CBCharacteristicPropertyRead value:major permissions:CBAttributePermissionsReadable];
        self.minorCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[self minorCharacteristicUUID] properties:CBCharacteristicPropertyRead value:minor permissions:CBAttributePermissionsReadable];
        self.verificationHashCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[self verificationHashCharacteristicUUID] properties:CBCharacteristicPropertyRead value:[self verificationKeyData] permissions:CBAttributePermissionsReadable];
        self.defaultService.characteristics = @[self.proximityUUIDCharacteristic, self.majorCharacteristic, self.minorCharacteristic, self.verificationHashCharacteristic];
    }
    return self;
}

- (id)initWithProximityUUID:(NSUUID *)proximityUUID major:(NSData *)major
{
    return [self initWithProximityUUID:proximityUUID major:major minor:[NSData data]];
}

- (id)initWithProximityUUID:(NSUUID *)proximityUUID
{
    return [self initWithProximityUUID:proximityUUID major:[NSData data] minor:[NSData data]];
}

// Create a wildcard service when you need to know the UUIDs of BLE elements and don't care about values.
-(id)initWildcardService
{
    return [self initWithProximityUUID:[NSUUID UUID] major:[NSData data] minor:[NSData data]];
}

-(NSArray *)availableServiceUUIDs
{
    return @[[self defaultServiceUUID]];
}

-(NSArray *)availableCharacteristicUUIDs
{
    return @[[self proximityUUIDCharacteristicUUID], [self majorCharacteristicUUID], [self minorCharacteristicUUID], [self verificationHashCharacteristicUUID]];
}

-(CBUUID *)defaultServiceUUID
{
    return [CBUUID UUIDWithString:defaultServiceUUIDString];
}

-(CBUUID *)proximityUUIDCharacteristicUUID
{
    return [CBUUID UUIDWithString:proximityCharacteristicUUIDString];
}

-(CBUUID *)majorCharacteristicUUID
{
    return [CBUUID UUIDWithString:majorCharacteristicUUIDString];
}

-(CBUUID *)minorCharacteristicUUID
{
    return [CBUUID UUIDWithString:minorCharacteristicUUIDString];
}

-(CBUUID *)verificationHashCharacteristicUUID
{
    return [CBUUID UUIDWithString:keyCharacteristicUUIDString];
}

-(NSData *)verificationKeyData
{
    NSLog(@"%@", [[self sha1:keySeedString] dataUsingEncoding:NSUTF8StringEncoding]);
    return [[self sha1:keySeedString] dataUsingEncoding:NSUTF8StringEncoding];
}

-(BOOL)verifyHash:(NSString *)verificationHash
{
    if ([verificationHash isEqualToString:[self sha1:keySeedString]]) {
        return YES;
    } else {
        return NO;
    }
}

-(NSString*) sha1:(NSString*)input
{
    const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:input.length];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    if (CC_SHA1(data.bytes, (int)data.length, digest)){
    
        NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
        for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++){
            [output appendFormat:@"%02x", digest[i]];
        }
        
        return output;
    } else {
        return nil;
    }
}

@end
