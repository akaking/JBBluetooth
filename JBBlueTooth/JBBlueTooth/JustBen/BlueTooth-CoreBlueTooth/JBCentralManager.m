//
//  JBCentralManager.m
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

#import "JBCentralManager.h"
#import "JBUserDefaultServiceCenter.h"


#ifndef StoredPeripherals
#define StoredPeripherals   @"StoredPeripherals"
#endif


@interface JBCentralManager () <CBCentralManagerDelegate, CBPeripheralDelegate>

+ (id)sharedCentralManager;

@property (nonatomic, retain) CBCentralManager *centralManager;
@property (nonatomic, assign) BOOL pendingInit;

@property (nonatomic, retain, readwrite) NSMutableArray *foundPeripherals;
@property (nonatomic, retain, readwrite) NSMutableArray *connectedServices;

- (id)initWithCentralManagerDelegate:(id<JBCentralManagerDelegate>)centralManagerDelegate PeripheralDelegate:(id<JBPeripheralDelegate>)peripheralDelegate;

@end

@implementation JBCentralManager

#pragma mark -
#pragma mark - Class Methods
+ (id)sharedCentralManager
{
    return [self sharedCentralManagerWithCentralManagerDelegate:nil PeripheralDelegate:nil];
}

+ (id)sharedCentralManagerWithCentralManagerDelegate:(id<JBCentralManagerDelegate>)centralManagerDelegate PeripheralDelegate:(id<JBPeripheralDelegate>)peripheralDelegate
{
    static JBCentralManager *staticCentralManager = nil;
    if (!staticCentralManager) {
        staticCentralManager = [[self alloc] initWithCentralManagerDelegate:centralManagerDelegate PeripheralDelegate:peripheralDelegate];
    }
    
    return staticCentralManager;
}


#pragma mark -
#pragma mark - Object Methods
- (id)init
{
    self = [super init];
    if (self) {
        self.pendingInit = YES;
        
        //  The initialization call. The events of the central role will be dispatched on the provided queue. If nil, the main queue will be used.
        self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
        
        self.foundPeripherals = [[NSMutableArray alloc] init];
        self.connectedServices = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (id)initWithCentralManagerDelegate:(id<JBCentralManagerDelegate>)centralManagerDelegate PeripheralDelegate:(id<JBPeripheralDelegate>)peripheralDelegate
{
    self.centralManagerDelegate = centralManagerDelegate;
    self.peripheralDelegate = peripheralDelegate;
    
    return [self init];
}


//
//  Actions
//
- (void)startScanningAll
{
    //  Starts scanning for peripherals.
    //  If serviceUUIDs is nil all discovered peripherals will be returned,
    //  regardless of their supported services (not recommended).
    //  If the central is already scanning with different serviceUUIDs or options,
    //  the provided parameters will replace them.
    [self.centralManager scanForPeripheralsWithServices:nil options:nil];
    
    NSLog(@"scanning");
}

- (void)startScanning
{
    NSArray *services = [JBUUIDManager allServices];
    if (services && services.count > 0) {
        
        //  Starts scanning for peripherals.
        //  If serviceUUIDs is nil all discovered peripherals will be returned,
        //  regardless of their supported services (not recommended).
        //  If the central is already scanning with different serviceUUIDs or options,
        //  the provided parameters will replace them.
        [self.centralManager scanForPeripheralsWithServices:services options:nil];
    }
}

- (void)stopScanning
{
    [self.centralManager stopScan];
}

- (void)connectPeripheral:(CBPeripheral *)peripheral
{
    if (!peripheral.isConnected) {
        
        //  Initiates a connection to peripheral.
        //  Connection attempts never time out and, depending on the outcome,
        //  will result in a call to either centralManager:didConnectPeripheral:
        //  or centralManager:didFailToConnectPeripheral:error:.
        //  Pending attempts are cancelled automatically upon deallocation of peripheral,
        //  and explicitly via cancelPeripheralConnection.
        [self.centralManager connectPeripheral:peripheral options:nil];
    }
}

- (void)disconnectPeripheral:(CBPeripheral *)peripheral
{
    //  Cancels an active or pending connection to peripheral.
    //  This command is non-blocking, and any CBPeripheral commands that
    //  are still pending to peripheral may or may not complete.
    //  It extremely important to note that
    //  canceling a connection does not guarantee the immediate disconnection of the underlying physical link.
    //  This can be caused by a variety of different factors,
    //  including other application(s) that hold an outstanding connection to the peripheral.
    //  However, in this situation, you will still receive an immediate call to centralManager:didDisconnectPeripheral:error:.
    [self.centralManager cancelPeripheralConnection:peripheral];
}

- (void)clearPeripherals
{
    [self.foundPeripherals removeAllObjects];
    for (JBPeripheral *peripheral in self.connectedServices) {
        [peripheral reset];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.peripheralDelegate respondsToSelector:@selector(peripheralDidReset:)]) {
                [self.peripheralDelegate peripheralDidReset:peripheral];
            }
        });
    }
    [self.connectedServices removeAllObjects];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.centralManagerDelegate respondsToSelector:@selector(centralManagerDiscoveryDidRefresh)]) {
            [self.centralManagerDelegate centralManagerDiscoveryDidRefresh];
        }
    });
}

//
//  Settings
//
- (void)loadSavedPeripherals
{
    NSArray *storedPeripherals = [JBUserDefaultServiceCenter getUserDefaultValueByKey:StoredPeripherals];
    if (!storedPeripherals || ![storedPeripherals isKindOfClass:[NSArray class]]) {
        return;
    }
    
    NSMutableArray *peripherals = [[NSMutableArray alloc] init];
    for (id peripheralUUIDString in storedPeripherals) {
        if (![peripheralUUIDString isKindOfClass:[NSString class]]) {
            continue;
        }
        
        CFUUIDRef uuid = CFUUIDCreateFromString(NULL, (CFStringRef)peripheralUUIDString);
        if (!uuid) {
            continue;
        }
        
        [peripherals addObject:(id)CFBridgingRelease(uuid)];
    }
    
    
    //  Attempts to retrieve the CBPeripheral object(s) that correspond to peripheralUUIDs.
    [self.centralManager retrievePeripherals:peripherals];
}

- (void)addSavedPeripheralWithUUID:(NSString *)peripheralUUID
{
    NSArray *storedPeripherals = [JBUserDefaultServiceCenter getUserDefaultValueByKey:StoredPeripherals];
    NSMutableArray *newPeripherals = [[NSMutableArray alloc] init];
    if ([storedPeripherals isKindOfClass:[NSArray class]] && storedPeripherals.count > 0) {
        [newPeripherals addObjectsFromArray:storedPeripherals];
    }
    
    if (peripheralUUID) {
        [newPeripherals addObject:peripheralUUID];
    }
    
    [JBUserDefaultServiceCenter setUserDefaultValue:newPeripherals WithKey:StoredPeripherals];
}

- (void)removeSavedPeripheralByUUID:(NSString *)peripheralUUID
{
    NSArray *storedPeripherals = [JBUserDefaultServiceCenter getUserDefaultValueByKey:StoredPeripherals];
    NSMutableArray *newPeripherals = [[NSMutableArray alloc] init];
    if (![storedPeripherals isKindOfClass:[NSArray class]] || storedPeripherals.count <= 0) {
        return;
    } else {
        [newPeripherals addObjectsFromArray:storedPeripherals];
    }
    
    if (peripheralUUID) {
        [newPeripherals removeObject:peripheralUUID];
    }
    
    [JBUserDefaultServiceCenter setUserDefaultValue:newPeripherals WithKey:StoredPeripherals];
}

- (void)clearSavedPeripherals
{
    [JBUserDefaultServiceCenter deleteUserDefaultValueByKey:StoredPeripherals];
}



#pragma mark -
#pragma mark - CBCentralManagerDelegate

/*!
 *  @method centralManagerDidUpdateState:
 *
 *  @param central  The central manager whose state has changed.
 *
 *  @discussion     Invoked whenever the central manager's state has been updated. Commands should only be issued when the state is
 *                  <code>CBCentralManagerStatePoweredOn</code>. A state below <code>CBCentralManagerStatePoweredOn</code>
 *                  implies that scanning has stopped and any connected peripherals have been disconnected. If the state moves below
 *                  <code>CBCentralManagerStatePoweredOff</code>, all <code>CBPeripheral</code> objects obtained from this central
 *                  manager become invalid and must be retrieved or discovered again.
 *
 *  @see            state
 *
 */
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{    
    if (![self.centralManager isEqual:central]) {
        return;
    }
    
    //  CBCentralManagerStateUnknown       State unknown, update imminent.
    //  CBCentralManagerStateResetting     The connection with the system service was momentarily lost, update imminent.
    //  CBCentralManagerStateUnsupported   The platform doesn't support the Bluetooth Low Energy Central/Client role.
    //  CBCentralManagerStateUnauthorized  The application is not authorized to use the Bluetooth Low Energy Central/Client role.
    //  CBCentralManagerStatePoweredOff    Bluetooth is currently powered off.
    //  CBCentralManagerStatePoweredOn     Bluetooth is currently powered on and available to use.

    static NSInteger centralManagerState = -1;
    
    switch (central.state) {
        case CBCentralManagerStateUnknown:
        {
            /* Bad news, let's wait for another event. */
            
            break;
        }
            
        case CBCentralManagerStateResetting:
        {
            [self clearPeripherals];
            self.pendingInit = YES;
            
            break;
        }
            
        case CBCentralManagerStateUnsupported:
        {
            //  The platform doesn't support the Bluetooth Low Energy Central/Client role.
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([self.centralManagerDelegate respondsToSelector:@selector(centralManagerDeviceUnsupportedBTLE)]) {
                    [self.centralManagerDelegate centralManagerDeviceUnsupportedBTLE];
                }
            });
            
            break;
        }
            
        case CBCentralManagerStateUnauthorized:
        {
            /* Tell user the app is not allowed. */
            //  The application is not authorized to use the Bluetooth Low Energy Central/Client role.
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([self.centralManagerDelegate respondsToSelector:@selector(centralManagerAppIsNotAuthorizedToUse)]) {
                    [self.centralManagerDelegate centralManagerAppIsNotAuthorizedToUse];
                }
            });
            
            break;
        }
            
        case CBCentralManagerStatePoweredOff:
        {
            [self clearPeripherals];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([self.centralManagerDelegate respondsToSelector:@selector(centralManagerDiscoveryDidRefresh)]) {
                    [self.centralManagerDelegate centralManagerDiscoveryDidRefresh];
                }
            });
            
            /* Tell user to power ON BT for functionality, but not on first run - the Framework will alert in that instance. */
            if (centralManagerState != -1) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([self.centralManagerDelegate respondsToSelector:@selector(centralManagerPoweredOff)]) {
                        [self.centralManagerDelegate centralManagerPoweredOff];
                    }
                });
            }
            
            break;
        }
            
        case CBCentralManagerStatePoweredOn:
        {
            self.pendingInit = NO;
            [self loadSavedPeripherals];
            [self.centralManager retrieveConnectedPeripherals];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([self.centralManagerDelegate respondsToSelector:@selector(centralManagerPoweredOn)]) {
                    [self.centralManagerDelegate centralManagerPoweredOn];
                }
            });
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([self.centralManagerDelegate respondsToSelector:@selector(centralManagerDiscoveryDidRefresh)]) {
                    [self.centralManagerDelegate centralManagerDiscoveryDidRefresh];
                }
            });
            
            break;
        }
        
        default:
            break;
    }
    
    centralManagerState = self.centralManager.state;
}


/*!
 *  @method centralManager:didRetrievePeripherals:
 *
 *  @param central      The central manager providing this information.
 *  @param peripherals  A list of <code>CBPeripheral</code> objects.
 *
 *  @discussion         This method returns the result of a @link retrievePeripherals @/link call, with the peripheral(s) that the central manager was
 *                      able to match to the provided UUID(s).
 *
 */
- (void)centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray *)peripherals
{
    NSLog(@"1");
    
    for (CBPeripheral *peripheral in peripherals) {
        //  Initiates a connection to peripheral.
        //  Connection attempts never time out and, depending on the outcome,
        //  will result in a call to either centralManager:didConnectPeripheral:
        //  or  centralManager:didFailToConnectPeripheral:error:.
        //  Pending attempts are cancelled automatically upon deallocation of peripheral,
        //  and explicitly via cancelPeripheralConnection.
        [self.centralManager connectPeripheral:peripheral options:nil];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.centralManagerDelegate respondsToSelector:@selector(centralManagerDiscoveryDidRefresh)]) {
            [self.centralManagerDelegate centralManagerDiscoveryDidRefresh];
        }
    });
}

/*!
 *  @method centralManager:didRetrieveConnectedPeripherals:
 *
 *  @param central      The central manager providing this information.
 *  @param peripherals  A list of <code>CBPeripheral</code> objects representing all peripherals currently connected to the system.
 *
 *  @discussion         This method returns the result of a @link retrieveConnectedPeripherals @/link call.
 *
 */
- (void)centralManager:(CBCentralManager *)central didRetrieveConnectedPeripherals:(NSArray *)peripherals
{
    NSLog(@"2");

    for (CBPeripheral *peripheral in peripherals) {
        //  Initiates a connection to peripheral.
        //  Connection attempts never time out and, depending on the outcome,
        //  will result in a call to either centralManager:didConnectPeripheral:
        //  or  centralManager:didFailToConnectPeripheral:error:.
        //  Pending attempts are cancelled automatically upon deallocation of peripheral,
        //  and explicitly via cancelPeripheralConnection.
        [self.centralManager connectPeripheral:peripheral options:nil];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.centralManagerDelegate respondsToSelector:@selector(centralManagerDiscoveryDidRefresh)]) {
            [self.centralManagerDelegate centralManagerDiscoveryDidRefresh];
        }
    });
}

/*!
 *  @method centralManager:didDiscoverPeripheral:advertisementData:RSSI:
 *
 *  @param central              The central manager providing this update.
 *  @param peripheral           A <code>CBPeripheral</code> object.
 *  @param advertisementData    A dictionary containing any advertisement and scan response data.
 *  @param RSSI                 The current RSSI of <i>peripheral</i>, in decibels.
 *
 *  @discussion                 This method is invoked while scanning, upon the discovery of <i>peripheral</i> by <i>central</i>. Any advertisement/scan response
 *                              data stored in <i>advertisementData</i> can be accessed via the <code>CBAdvertisementData</code> keys. A discovered peripheral must
 *                              be retained in order to use it; otherwise, it is assumed to not be of interest and will be cleaned up by the central manager.
 *
 *  @seealso                    CBAdvertisementData.h
 *
 */
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSLog(@"3");

    if (![self.foundPeripherals containsObject:peripheral]) {
        [self.foundPeripherals addObject:peripheral];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.centralManagerDelegate respondsToSelector:@selector(centralManagerDiscoveryDidRefresh)]) {
                [self.centralManagerDelegate centralManagerDiscoveryDidRefresh];
            }
        });
    }
}

/*!
 *  @method centralManager:didConnectPeripheral:
 *
 *  @param central      The central manager providing this information.
 *  @param peripheral   The <code>CBPeripheral</code> that has connected.
 *
 *  @discussion         This method is invoked when a connection initiated by @link connectPeripheral:options: @/link has succeeded.
 *
 */
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"4");

    JBPeripheral *peripheral_ = [[JBPeripheral alloc] initWithPeriphera:peripheral delegate:self.peripheralDelegate];
    [peripheral_ start];
    
    if (![self.connectedServices containsObject:peripheral]) {
        [self.connectedServices addObject:peripheral];
    }
    
    if ([self.foundPeripherals containsObject:peripheral]) {
        [self.foundPeripherals removeObject:peripheral];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.peripheralDelegate respondsToSelector:@selector(peripheralDidChangeStatus:)]) {
            [self.peripheralDelegate peripheralDidChangeStatus:peripheral_];
        }
    });
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.centralManagerDelegate respondsToSelector:@selector(centralManagerDiscoveryDidRefresh)]) {
            [self.centralManagerDelegate centralManagerDiscoveryDidRefresh];
        }
    });
}

/*!
 *  @method centralManager:didFailToConnectPeripheral:error:
 *
 *  @param central      The central manager providing this information.
 *  @param peripheral   The <code>CBPeripheral</code> that has failed to connect.
 *  @param error        The cause of the failure.
 *
 *  @discussion         This method is invoked when a connection initiated by @link connectPeripheral:options: @/link has failed to complete. As connection attempts do not
 *                      timeout, the failure of a connection is atypical and usually indicative of a transient issue.
 *
 */
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"5");

    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.centralManagerDelegate respondsToSelector:@selector(centralManagerDidFailToConnectPeripheral:)]) {
            [self.centralManagerDelegate centralManagerDidFailToConnectPeripheral:peripheral];
        }
    });
}

/*!
 *  @method centralManager:didDisconnectPeripheral:error:
 *
 *  @param central      The central manager providing this information.
 *  @param peripheral   The <code>CBPeripheral</code> that has disconnected.
 *  @param error        If an error occurred, the cause of the failure.
 *
 *  @discussion         This method is invoked upon the disconnection of a peripheral that was connected by @link connectPeripheral:options: @/link. If the disconnection
 *                      was not initiated by @link cancelPeripheralConnection @/link, the cause will be detailed in the <i>error</i> parameter. Once this method has been
 *                      called, no more methods will be invoked on <i>peripheral</i>'s <code>CBPeripheralDelegate</code>.
 *
 */
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"6");

    for (JBPeripheral *peripheral in self.connectedServices) {
        if ([peripheral.peripheral isEqual:peripheral]) {
            [self.connectedServices removeObject:peripheral];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([self.peripheralDelegate respondsToSelector:@selector(peripheralDidChangeStatus:)]) {
                    [self.peripheralDelegate peripheralDidChangeStatus:peripheral];
                }
            });
        }
        
        break;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.centralManagerDelegate respondsToSelector:@selector(centralManagerDiscoveryDidRefresh)]) {
            [self.centralManagerDelegate centralManagerDiscoveryDidRefresh];
        }
    });
}

@end
