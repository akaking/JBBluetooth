//
//  JBCentralManager.h
//  JBBlueTooth
//
//  Scan for and discover nearby LE peripherals with the matching service UUID.
//
//  Created by YongbinZhang on 6/7/13.
//
//  Copyright (c) 2013 YongbinZhang
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//


#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#import "JBPeripheral.h"
#import "JBUUIDManager.h"

@protocol JBPeripheralDelegate;
@protocol JBCentralManagerDelegate;
@interface JBCentralManager : NSObject

+ (id)sharedCentralManagerWithCentralManagerDelegate:(id<JBCentralManagerDelegate>)centralManagerDelegate PeripheralDelegate:(id<JBPeripheralDelegate>)peripheralDelegate;

//
//  UI controls
//
@property (nonatomic, assign) id<JBCentralManagerDelegate> centralManagerDelegate;
@property (nonatomic, assign) id<JBPeripheralDelegate> peripheralDelegate;

//
//  Actions
//
- (void)startScanningAll;
- (void)startScanning;
- (void)stopScanning;

- (void)connectPeripheral:(CBPeripheral *)peripheral;
- (void)disconnectPeripheral:(CBPeripheral *)peripheral;

- (void)clearPeripherals;

//
//  Settings
//
- (void)loadSavedPeripherals;
- (void)addSavedPeripheralWithUUID:(NSString *)peripheralUUID;
- (void)removeSavedPeripheralByUUID:(NSString *)peripheralUUID;
- (void)clearSavedPeripherals;

//
//  Access to the devices
//
@property (nonatomic, retain, readonly) NSMutableArray *foundPeripherals;
@property (nonatomic, retain, readonly) NSMutableArray *connectedServices;

@end


@protocol JBCentralManagerDelegate <NSObject>

@optional
- (void)centralManagerDeviceUnsupportedBTLE;
- (void)centralManagerAppIsNotAuthorizedToUse;
- (void)centralManagerDiscoveryDidRefresh;
- (void)centralManagerPoweredOff;
- (void)centralManagerPoweredOn;

- (void)centralManagerDidFailToConnectPeripheral:(CBPeripheral *)peripheral;
@end