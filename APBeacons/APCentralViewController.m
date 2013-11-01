//
//  APCentralViewController.m
//  APBeacons
//
//  Created by Ashutosh Priyadarshy on 10/25/13.
//  Copyright (c) 2013 EEMe labs. All rights reserved.
//

#import "APCentralViewController.h"
#import "APBeaconService.h"

@interface APCentralViewController ()

@end

@implementation APCentralViewController

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
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:nil];
    self.service = [[APBeaconService alloc] initWildcardService];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ManagerSetup

-(void)performScan
{
//    NSArray *services = @[[APService defaultServiceUUID]];
    NSArray *services = [self.service availableServiceUUIDs];
    [self.centralManager scanForPeripheralsWithServices:services
                                                options:nil];
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
            [self performScan];
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
    self.connectablePeripheral = peripheral;
    [self.centralManager connectPeripheral:self.connectablePeripheral options:nil];

}

- (void) centralManager:(CBCentralManager *)central
   didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"centralManager:didConnectPeripheral:%@", peripheral);
    [peripheral setDelegate:self];
    NSLog(@"discovering services...");
//    [peripheral discoverServices:@[[APService defaultServiceUUID]]];
    [peripheral discoverServices:[self.service availableServiceUUIDs]];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    
    for (CBService *service in peripheral.services) {
        NSLog(@"Discovered service %@", service);
        // TODO Should be a stronger check.
        if (service.isPrimary) {
            [peripheral discoverCharacteristics:[self.service availableCharacteristicUUIDs] forService:service];
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
    
    NSData *data = characteristic.value;
    NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSLog(@"Value for <CBCharacteristic = %@> is %@", characteristic, dataString);
    
    // If the hash value checks out. We can verify this sensor.
    if ([characteristic.UUID isEqual:[self.service verificationHashCharacteristicUUID]]) {
        NSLog(@"This is hte characterisitc we're looking for.");
        if ([self.service verifyHash:dataString]) {
            NSLog(@"Peripheral verified.");
            // Time to create a beacon and hold on to it.
        }
    }
}

@end
