APBeacons
=========

iOS 7 provides developers access to iBeacons. When using an iOS device as a beacon you are unable to broadcast with the app being in the background. APBeacons was designed as a workaround to this issue. APBeacons uses CoreBluetooth in both the peripheral and central mode simultaneously in order to make background broadcasting possible. 

The key features that I hope to incorporate into APBeacons are:

+ Support for a Proximity UUID
+ Support for a major & minor value. 
+ Very basic verification of broadcaster's identity. 
+ Proximity reading.
+ Accuracy reading. 

__Current Status__:  APBeacons is under development and does not replicate the core functionalities entirely yet. 

__Open Questions__: After some investigations and some experiments where I logged RSSI, Proximity Readings, Accuracy Readings for iBeacons I've got a feeling that Proximity Readings are a function of RSSI & Accuracy and that Accuracy readings are a function of RSSI and the input transmission power for 1 meter away. This is a parameter you can set for a non iOS iBeacon. In order to spoof the iBeacon's power settings we need to figure out the 1 meter dB reading of the iBeacon and determine the default value. Will probably just use trial and error for now. 

__QUESTIONS__: [root@ashuto.sh](root@ashuto.sh)

Relationship between CLBeacon, CLBeaconRegion and CBPeripheralManager and CBCentralManager. 

__CLIENT EXAMPLE__

Let's work out the client side first and assume there are functional peripherals broadcasting themselves and some of them are what we call APBeacons.

Let's assume there are N peripheral devices named p<sub>0</sub>, p<sub>1</sub>…p<sub>N</sub>. Each of these N peripheral devices is broadcasting various services and characteristics. Our job is to search the ether for all peripheral and determine for each p<sub>i</sub> if its service and characteristics belong to APBeacons and then to determine if its a particular APBeacon that we've registered to get callbacks about. At the point that we determine that the devie is no ordinary peripheral and an APBeacon, we should create the APBeacon object. 

