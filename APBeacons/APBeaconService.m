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
NSString * const majorCharacteristicUUIDString = @"2081B950-1806-4AF8-9411-A846A8A919C9";
NSString * const minorCharacteristicUUIDString = @"0C2D58CF-3919-4E3A-9782-DA7743E8BBB3";
NSString * const keyCharacteristicUUIDString = @"C4B0E944-D3E1-4844-99A4-66F9806D92C9";
/* Seed value for computing verification hash. */
NSString * const keySeedString = @"6FED21D8-B48C-4B56-B6A1-98BBC0AEC4DA";

@interface APBeaconService ()

@property CBMutableService *defaultService;
@property CBMutableCharacteristic *majorCharacteristic;
@property CBMutableCharacteristic *minorCharacteristic;
@property CBMutableCharacteristic *verificationHashCharacteristic;

@end

@implementation APBeaconService

-(id)initWithMajorData:(NSData *)majorData minorData:(NSData *)minorData
{
    self = [super init];
    if (self) {
        self.defaultService = [[CBMutableService alloc] initWithType:[self defaultServiceUUID] primary:YES];
        self.majorCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[self majorCharacteristicUUID] properties:CBCharacteristicPropertyRead value:majorData permissions:CBAttributePermissionsReadable];
        self.minorCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[self minorCharacteristicUUID] properties:CBCharacteristicPropertyRead value:minorData permissions:CBAttributePermissionsReadable];
        self.verificationHashCharacteristic = [[CBMutableCharacteristic alloc] initWithType:[self verificationHashCharacteristicUUID] properties:CBCharacteristicPropertyRead value:[self verificationKeyData] permissions:CBAttributePermissionsReadable];
        self.defaultService.characteristics = @[self.majorCharacteristic, self.minorCharacteristic, self.verificationHashCharacteristic];
    }
    return self;
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
    
    if (CC_SHA1(data.bytes, data.length, digest)){
    
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
