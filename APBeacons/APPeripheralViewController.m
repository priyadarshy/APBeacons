//
//  APPeripheralViewController.m
//  APBeacons
//
//  Created by Ashutosh Priyadarshy on 10/25/13.
//  Copyright (c) 2013 EEMe labs. All rights reserved.
//

#import "APPeripheralViewController.h"
#import "APBeaconService.h"

// Data values.
NSString * const defaultMajor = @"42";
NSString * const defaultMinor = @"21";

@interface APPeripheralViewController ()

@end

@implementation APPeripheralViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.service = [[APBeaconService alloc] initWithMajorData:[@"42" dataUsingEncoding:NSUTF8StringEncoding] minorData:[@"21" dataUsingEncoding:NSUTF8StringEncoding]];
    self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - PeripheralSetup

-(void)setupService
{    
    [self.peripheralManager addService:self.service.defaultService];
}

-(void)advertiseService
{
    [self.peripheralManager startAdvertising:@{CBAdvertisementDataServiceUUIDsKey:
                                                 [self.service availableServiceUUIDs],
                                               CBAdvertisementDataLocalNameKey:
                                                   @"APBeacons"
                                               }
     ];
}

#pragma mark - CBPeripheralManagerDelegate Methods

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    NSString *state = nil;
    switch (peripheral.state) {
        case CBPeripheralManagerStateResetting:
            state = @"resetting"; break;
        case CBPeripheralManagerStateUnsupported:
            state = @"unsupported"; break;
        case CBPeripheralManagerStateUnauthorized:
            state = @"unauthorized"; break;
        case CBPeripheralManagerStatePoweredOff:
            state = @"off"; break;
        case CBPeripheralManagerStatePoweredOn:
            state = @"on"; break;
        default:
            state = @"unknown"; break;
    }
    NSLog(@"peripheralManagerDidUpdateState:%@ to %@ (%d)", peripheral, state, (int)peripheral.state);
    
    switch (peripheral.state) {
        case CBPeripheralManagerStatePoweredOn:
            [self setupService];
            [self advertiseService];
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
    NSLog(@"peripheralManagerDidStartAdvertising:%@ error:%@", peripheral, [error localizedDescription]);
}

@end
