//
//  JBPeripheralManager.m
//  JBBlueTooth
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

#import "JBPeripheralManager.h"
#import "JBUUIDManager.h"

@interface JBPeripheralManager () <CBPeripheralManagerDelegate>

@property (nonatomic, assign) id<JBPeripheralManagerDelegate> peripheralManagerDelegate;
- (id)initWithPeripheralDelegate:(id<JBPeripheralManagerDelegate>)peripheralDelegate;

- (void)setupServices;


@property (nonatomic, retain) NSData *mainData;
@property (nonatomic, retain) NSString *range;
@property (nonatomic, assign) BOOL continuedUpdate;
@property (nonatomic, retain) CBMutableCharacteristic *previousCharacteristic;
@property (nonatomic, retain) NSArray *previousCentrals;
- (BOOL)hasData;
- (void)ridData;
- (NSData *)getNextData;

@end



@implementation JBPeripheralManager

#pragma mark -
#pragma mark - Class Methods
+ (id)sharedPeripheralManagerWithPeripheralDelegate:(id<JBPeripheralManagerDelegate>)peripheralDelegate
{
    static JBPeripheralManager *staticPeripheralManager = nil;
    if (!staticPeripheralManager) {
        staticPeripheralManager = [[self alloc] initWithPeripheralDelegate:peripheralDelegate];
    }
    
    return staticPeripheralManager;
}

#pragma mark -
#pragma mark - Object Methods
- (id)initWithPeripheralDelegate:(id<JBPeripheralManagerDelegate>)peripheralDelegate
{
    self = [super init];
    if (self) {
        self.peripheralManagerDelegate = peripheralDelegate;
        self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
    }
    
    return self;
}

//
//  Action
//
- (void)sendData:(NSData *)data ToCentral:(CBCentral *)central InCharacteristic:(CBMutableCharacteristic *)characteristic
{
    self.continuedUpdate = NO;
    
    if (!data || !characteristic) {
        return;
    }
    
    NSArray *centrals = nil;
    if (central) {
        centrals = [[NSArray alloc] initWithObjects:central, nil];
    }
        
    self.mainData = data;
    while ([self hasData]) {
        if ([self.peripheralManager updateValue:[self getNextData] forCharacteristic:characteristic onSubscribedCentrals:centrals]) {
            [self ridData];
        } else {
            self.continuedUpdate = YES;
            self.previousCharacteristic = characteristic;
            self.previousCentrals = centrals;
        }
    }
    
    NSString *endStr = @"ENDAL";
    NSData *endData = [endStr dataUsingEncoding:NSUTF8StringEncoding];
    [self.peripheralManager updateValue:endData forCharacteristic:characteristic onSubscribedCentrals:centrals];
}


#pragma mark -
#pragma mark - Class Extensions
- (void)setupServices
{
    static BOOL isPrimaryService = YES;
    
    NSArray *serviceUUIDs = [JBUUIDManager allServices];
    if (!serviceUUIDs) {
        return;
    }
    
    for (CBUUID *serviceUUID in serviceUUIDs) {
        CBMutableService *service = [[CBMutableService alloc] initWithType:serviceUUID primary:isPrimaryService];
        isPrimaryService = NO;
        
        NSArray *characteristicUUIDs = [JBUUIDManager characteristicsInServiceWithUUID:serviceUUID];
        if (characteristicUUIDs && characteristicUUIDs.count > 0) {
            
            NSMutableArray *characteristics = [[NSMutableArray alloc] init];
            for (CBUUID *characteristicUUID in characteristicUUIDs) {
                JBCharacteristic *jbCharacteristic = [JBUUIDManager characteristicWithUUID:characteristicUUID];
                CBMutableCharacteristic *characteristic = nil;
                if (jbCharacteristic.needNotifyValue) {
                   characteristic = [[CBMutableCharacteristic alloc] initWithType:characteristicUUID properties:CBCharacteristicPropertyRead | CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsReadable];
                } else {
                    characteristic = [[CBMutableCharacteristic alloc] initWithType:characteristicUUID properties:CBCharacteristicPropertyRead value:nil permissions:CBAttributePermissionsReadable];
                }
                
                [characteristics addObject:characteristic];
            }
            
            service.characteristics = characteristics;
        }
        
        [self.peripheralManager addService:service];
    }
}



- (BOOL)hasData{
    if ([self.mainData length]>0) {
        return YES;
    }else{
        return NO;
    }
}

- (void)ridData{
    if ([self.mainData length]>19) {
        self.mainData = [self.mainData subdataWithRange:NSRangeFromString(self.range)];
    }else{
        self.mainData = nil;
    }
}

- (NSData *)getNextData
{
    NSData *data;
    if ([self.mainData length]>19) {
        int datarest = [self.mainData length]-20;
        data = [self.mainData subdataWithRange:NSRangeFromString(@"{0,20}")];
        self.range = [NSString stringWithFormat:@"{20,%i}",datarest];
    }else{
        int datarest = [self.mainData length];
        self.range = [NSString stringWithFormat:@"{0,%i}",datarest];
        data = [self.mainData subdataWithRange:NSRangeFromString(self.range)];
    }
    return data;
}



/*!
 *  @protocol CBPeripheralManagerDelegate
 *
 *  @discussion The delegate of a @link CBPeripheralManager @/link object must adopt the <code>CBPeripheralManagerDelegate</code> protocol. The
 *              single required method indicates the availability of the peripheral manager, while the optional methods provide information about
 *              centrals, which can connect and access the local database.
 *
 */
#pragma mark -
#pragma mark - CBPeripheralManagerDelegate

/*!
 *  @method peripheralManagerDidUpdateState:
 *
 *  @param peripheral   The peripheral manager whose state has changed.
 *
 *  @discussion         Invoked whenever the peripheral manager's state has been updated. Commands should only be issued when the state is
 *                      <code>CBPeripheralManagerStatePoweredOn</code>. A state below <code>CBPeripheralManagerStatePoweredOn</code>
 *                      implies that advertisement has stopped and any connected centrals have been disconnected. If the state moves below
 *                      <code>CBPeripheralManagerStatePoweredOff</code>, advertisement is stopped and must be explicitly restarted, and the
 *                      local database is cleared and all services must be re-added.
 *
 *  @see                state
 *
 */
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    if (![peripheral isEqual:self.peripheralManager]) {
        return;
    }
    
    static NSInteger peripheralManagerState = -1;

    //  CBPeripheralManagerStateUnknown       State unknown, update imminent.
    //  CBPeripheralManagerStateResetting     The connection with the system service was momentarily lost, update imminent.
    //  CBPeripheralManagerStateUnsupported   The platform doesn't support the Bluetooth Low Energy Peripheral/Server role.
    //  CBPeripheralManagerStateUnauthorized  The application is not authorized to use the Bluetooth Low Energy Peripheral/Server role.
    //  CBPeripheralManagerStatePoweredOff    Bluetooth is currently powered off.
    //  CBPeripheralManagerStatePoweredOn     Bluetooth is currently powered on and available to use.
    switch (peripheral.state) {
        case CBPeripheralManagerStateUnknown:
        {            
            break;
        }
            
        case CBPeripheralManagerStateResetting:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
            });
            
            break;
        }
            
        case CBPeripheralManagerStateUnsupported:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([self.peripheralManagerDelegate respondsToSelector:@selector(peripheralManagerDeviceUnsupportedBTLE:)]) {
                    [self.peripheralManagerDelegate peripheralManagerDeviceUnsupportedBTLE:self];
                }
            });
            
            break;
        }
            
        case CBPeripheralManagerStateUnauthorized:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([self.peripheralManagerDelegate respondsToSelector:@selector(peripheralManagerAppIsNotAuthorizedToUse:)]) {
                    [self.peripheralManagerDelegate peripheralManagerAppIsNotAuthorizedToUse:self];
                }
            });
            
            break;
        }
            
        case CBPeripheralManagerStatePoweredOff:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (peripheralManagerState != -1) {
                    if ([self.peripheralManagerDelegate respondsToSelector:@selector(peripheralManagerPoweredOff:)]) {
                        [self.peripheralManagerDelegate peripheralManagerPoweredOff:self];
                    }
                }
            });
            
            break;
        }
            
        case CBPeripheralManagerStatePoweredOn:
        {
            [self setupServices];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([self.peripheralManagerDelegate respondsToSelector:@selector(peripheralManagerPoweredOn:)]) {
                    [self.peripheralManagerDelegate peripheralManagerPoweredOn:self];
                }
            });
            
            break;
        }
            
        default:
        {
            break;
        }
    }
    
    peripheralManagerState = self.peripheralManager.state;
}



/*!
 *  @method peripheralManagerDidStartAdvertising:error:
 *
 *  @param peripheral   The peripheral manager providing this information.
 *  @param error        If an error occurred, the cause of the failure.
 *
 *  @discussion         This method returns the result of a @link startAdvertising: @/link call. If advertisement could
 *                      not be started, the cause will be detailed in the <i>error</i> parameter.
 *
 */
- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error
{
    if (error) {
        return;
    }
    
    NSLog(@"did start advertising");
}

/*!
 *  @method peripheralManager:didAddService:error:
 *
 *  @param peripheral   The peripheral manager providing this information.
 *  @param service      The service that was added to the local database.
 *  @param error        If an error occurred, the cause of the failure.
 *
 *  @discussion         This method returns the result of an @link addService: @/link call. If the service could
 *                      not be published to the local database, the cause will be detailed in the <i>error</i> parameter.
 *
 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error
{
    if (error) {
        return;
    }
    
    //  Starts advertising.
    //  Supported advertising data types are CBAdvertisementDataLocalNameKey and CBAdvertisementDataServiceUUIDsKey.
    //  When in the foreground, an application can utilize up to 28 bytes of space in the initial advertisement data for
    //  any combination of the supported advertising data types.
    //  If this space is used up, there are an additional 10 bytes of space in the scan response that can be used only for the local name.
    //  Note that these sizes do not include the 2 bytes of header information that are required for each new data type.
    //  Any service UUIDs that do not fit in the allotted space will be added to a special "overflow" area,
    //  and can only be discovered by an iOS device that is explicitly scanning for them.
    //  While an application is in the background, the local name will not be used and all service UUIDs will be placed in the "overflow" area.
    
    //  call peripheralManagerDidStartAdvertising:error:
    [self.peripheralManager startAdvertising:@{
             CBAdvertisementDataLocalNameKey:@"JustBen",
          CBAdvertisementDataServiceUUIDsKey:@[service.UUID]
    }];
}

/*!
 *  @method peripheralManager:central:didSubscribeToCharacteristic:
 *
 *  @param peripheral       The peripheral manager providing this update.
 *  @param central          The central that issued the command.
 *  @param characteristic   The characteristic on which notifications or indications were enabled.
 *
 *  @discussion             This method is invoked when a central configures <i>characteristic</i> to notify or indicate.
 *                          It should be used as a cue to start sending updates as the characteristic value changes.
 *
 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.peripheralManagerDelegate respondsToSelector:@selector(peripheralManager:WriteDataIsAvailableWithCentral:toCharacteristic:)]) {
            [self.peripheralManagerDelegate peripheralManager:self WriteDataIsAvailableWithCentral:central toCharacteristic:characteristic];
        }
    });
}

/*!
 *  @method peripheralManager:central:didUnsubscribeFromCharacteristic:
 *
 *  @param peripheral       The peripheral manager providing this update.
 *  @param central          The central that issued the command.
 *  @param characteristic   The characteristic on which notifications or indications were disabled.
 *
 *  @discussion             This method is invoked when a central removes notifications/indications from <i>characteristic</i>.
 *
 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic
{
    
}

/*!
 *  @method peripheralManager:didReceiveReadRequest:
 *
 *  @param peripheral   The peripheral manager requesting this information.
 *  @param request      A <code>CBATTRequest</code> object.
 *
 *  @discussion         This method is invoked when <i>peripheral</i> receives an ATT request for a characteristic with a dynamic value.
 *                      For every invocation of this method, @link respondToRequest:withResult: @/link must be called.
 *
 *  @see                CBATTRequest
 *
 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request
{
    NSString *mainString = [NSString stringWithFormat:@"GN123"];
    NSData *cmainData= [mainString dataUsingEncoding:NSUTF8StringEncoding];
    request.value = cmainData;
    [peripheral respondToRequest:request withResult:CBATTErrorSuccess];
}

/*!
 *  @method peripheralManager:didReceiveWriteRequests:
 *
 *  @param peripheral   The peripheral manager requesting this information.
 *  @param requests     A list of one or more <code>CBATTRequest</code> objects.
 *
 *  @discussion         This method is invoked when <i>peripheral</i> receives an ATT request or command for one or more characteristics with a dynamic value.
 *                      For every invocation of this method, @link respondToRequest:withResult: @/link should be called exactly once. If <i>requests</i> contains
 *                      multiple requests, they must be treated as an atomic unit. If the execution of one of the requests would cause a failure, the request
 *                      and error reason should be provided to <code>respondToRequest:withResult:</code> and none of the requests should be executed.
 *
 *  @see                CBATTRequest
 *
 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray *)requests
{
    for (CBATTRequest *aReq in requests){
        NSLog(@"%@", [[NSString alloc]initWithData:aReq.value encoding:NSUTF8StringEncoding]);
        [peripheral respondToRequest:aReq withResult:CBATTErrorSuccess];
    }
}

/*!
 *  @method peripheralManagerIsReadyToUpdateSubscribers:
 *
 *  @param peripheral   The peripheral manager providing this update.
 *
 *  @discussion         This method is invoked after a failed call to @link updateValue:forCharacteristic:onSubscribedCentrals: @/link, when <i>peripheral</i> is again
 *                      ready to send characteristic value updates.
 *
 */
- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral
{
    if (self.continuedUpdate) {
        while ([self hasData]) {
            if ([self.peripheralManager updateValue:[self getNextData] forCharacteristic:self.previousCharacteristic onSubscribedCentrals:self.previousCentrals]) {
                [self ridData];
            } else {
                return;
            }
        }
        
        NSString *endStr = @"ENDAL";
        NSData *endData = [endStr dataUsingEncoding:NSUTF8StringEncoding];
        [self.peripheralManager updateValue:endData forCharacteristic:self.previousCharacteristic onSubscribedCentrals:self.previousCentrals];
    }
}


@end
