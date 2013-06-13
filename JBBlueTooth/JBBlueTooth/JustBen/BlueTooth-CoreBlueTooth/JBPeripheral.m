//
//  JBPeripheral.m
//  JBBlueTooth
//
//  Connect to a peripheral and get/set specified Characteristics' value.
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

#import "JBPeripheral.h"
#import "JBCentralManager.h"
#import "JBUUIDManager.h"
#import "JBCharacteristic.h"

@interface JBPeripheral () <CBPeripheralDelegate>

@property (nonatomic, weak, readwrite) CBPeripheral *peripheral;
@property (nonatomic, assign) id <JBPeripheralDelegate> delegate;

@end


@implementation JBPeripheral

#pragma mark -
#pragma mark - init
- (id)initWithPeriphera:(CBPeripheral *)peripheral delegate:(id<JBPeripheralDelegate>)delegate
{
    self = [super init];
    if (self) {
        self.peripheral = peripheral;
        self.delegate = delegate;
    }
    
    return self;
}

#pragma mark -
#pragma mark - Object Methods
- (void)reset
{
    self.delegate = nil;
    self.peripheral = nil;
}

- (void)start
{
    if (self.peripheral && [JBUUIDManager allServices]) {
        
        //  Discovers available service(s) on the peripheral.
        //  peripheral:didDiscoverServices: delegate method will be called.
        [self.peripheral discoverServices:[JBUUIDManager allServices]];
    }
}



#pragma mark -
#pragma mark - CBPeripheralDelegate
/*! iOS6 only
 *  @method peripheralDidUpdateName:
 *
 *  @param peripheral	The peripheral providing this update.
 *
 *  @discussion			This method is invoked when the @link name @/link of <i>peripheral</i> changes.
 */
- (void)peripheralDidUpdateName:(CBPeripheral *)peripheral
{
    if (![peripheral isEqual:self.peripheral]) {
        return;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(peripheralDidUpdateName:)]) {
            [self.delegate peripheralDidUpdateName:self];
        }
    });
}

/*! iOS6 only
 *  @method peripheralDidInvalidateServices:
 *
 *  @param peripheral	The peripheral providing this update.
 *
 *  @discussion			This method is invoked when the @link services @/link of <i>peripheral</i> have been changed. At this point,
 *						all existing <code>CBService</code> objects are invalidated. Services can be re-discovered via @link discoverServices: @/link.
 */
- (void)peripheralDidInvalidateServices:(CBPeripheral *)peripheral
{
    if (![peripheral isEqual:self.peripheral]) {
        return;
    }
    
    [self start];
}

/*!
 *  @method peripheralDidUpdateRSSI:error:
 *
 *  @param peripheral	The peripheral providing this update.
 *	@param error		If an error occurred, the cause of the failure.
 *
 *  @discussion			This method returns the result of a @link readRSSI: @/link call.
 */
- (void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error
{
    if (![peripheral isEqual:self.peripheral]) {
        return;
    }
    
    if (error) {
        return;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(peripheralDidUpdateRSSI:)]) {
            [self.delegate peripheralDidUpdateRSSI:self];
        }
    });
}

/*!
 *  @method peripheral:didDiscoverServices:
 *
 *  @param peripheral	The peripheral providing this information.
 *	@param error		If an error occurred, the cause of the failure.
 *
 *  @discussion			This method returns the result of a @link discoverServices: @/link call. If the service(s) were read successfully, they can be retrieved via
 *						<i>peripheral</i>'s @link services @/link property.
 *
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    NSArray *services = nil;
    
    if (![peripheral isEqual:self.peripheral]) {
        return;
    }
    
    if (error) {
        return;
    }
    
    services = [peripheral services];
    if (!services || ![services count]) {
        return;
    }
    
    for (CBService *service in services) {
        NSArray *charateristics = [JBUUIDManager characteristicsInServiceWithUUID:service.UUID];
        if (charateristics) {
            //  Discovers the specified characteristic(s) of service.
            //  peripheral:didDiscoverCharacteristicsForService:error: delegate method will be called. 
            [peripheral discoverCharacteristics:charateristics forService:service];
        }
    }
}

/*!
 *  @method peripheral:didDiscoverIncludedServicesForService:error:
 *
 *  @param peripheral	The peripheral providing this information.
 *  @param service		The <code>CBService</code> object containing the included services.
 *	@param error		If an error occurred, the cause of the failure.
 *
 *  @discussion			This method returns the result of a @link discoverIncludedServices:forService: @/link call. If the included service(s) were read successfully,
 *						they can be retrieved via <i>service</i>'s <code>includedServices</code> property.
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(CBService *)service error:(NSError *)error
{
    NSArray *services = nil;
    
    if (![peripheral isEqual:self.peripheral]) {
        return;
    }
    
    if (error) {
        return;
    }
    
    services = [peripheral services];
    if (!services || ![services count]) {
        return;
    }
    
    for (CBService *service in services) {
        NSArray *charateristics = [JBUUIDManager characteristicsInServiceWithUUID:service.UUID];
        if (charateristics) {
            //  Discovers the specified characteristic(s) of service.
            //  peripheral:didDiscoverCharacteristicsForService:error: delegate method will be called.
            [peripheral discoverCharacteristics:charateristics forService:service];
        }
    }

}

/*!
 *  @method peripheral:didDiscoverCharacteristicsForService:error:
 *
 *  @param peripheral	The peripheral providing this information.
 *  @param service		The <code>CBService</code> object containing the characteristic(s).
 *	@param error		If an error occurred, the cause of the failure.
 *
 *  @discussion			This method returns the result of a @link discoverCharacteristics:forService: @/link call. If the characteristic(s) were read successfully,
 *						they can be retrieved via <i>service</i>'s <code>characteristics</code> property.
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if (![peripheral isEqual:self.peripheral]) {
        return;
    }
    
    if (error) {
        return;
    }
    
    if (![JBUUIDManager serviceAvailable:service.UUID]) {
        return;
    }

    for (CBCharacteristic *characteristic in service.characteristics) {
        JBCharacteristic *jbCharacteristic = [JBUUIDManager characteristicWithUUID:characteristic.UUID];
        if (jbCharacteristic) {
            jbCharacteristic.characteristic = characteristic;
        }
        
        //  Reads the characteristic value for characteristic.
        //  peripheral:didUpdateValueForCharacteristic:error: delegate method will be called.
        [peripheral readValueForCharacteristic:characteristic];
        
        
        //  Enables or disables notifications/indications for the characteristic value of characteristic</i>.
        //  If characteristic allows both, notifications will be used. When notifications/indications are enabled,
        //  updates to the characteristic value will be received via delegate method peripheral:didUpdateValueForCharacteristic:error:.
        //  Since it is the peripheral that chooses when to send an update, the application should be prepared to
        //  handle them as long as notifications/indications remain enabled.
        
        // peripheral:didUpdateNotificationStateForCharacteristic:error: delegate method will be called.
        if (jbCharacteristic.needNotifyValue) {
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
    }
}

/*!
 *  @method peripheral:didUpdateValueForCharacteristic:error:
 *
 *  @param peripheral		The peripheral providing this information.
 *  @param characteristic	A <code>CBCharacteristic</code> object.
 *	@param error			If an error occurred, the cause of the failure.
 *
 *  @discussion				This method is invoked after a @link readValueForCharacteristic: @/link call, or upon receipt of a notification/indication.
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (![peripheral isEqual:self.peripheral]) {
        return;
    }
    
    if (error) {
        return;
    }
    
    JBCharacteristic *jbCharacteristic = [JBUUIDManager characteristicWithUUID:characteristic.UUID];
    if (jbCharacteristic) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.delegate respondsToSelector:@selector(peripheral:characteristicUpdateValueWithCharacteristic:)]) {
                [self.delegate peripheral:self characteristicUpdateValueWithCharacteristic:characteristic];
            }
        });
    }
}

/*!
 *  @method peripheral:didWriteValueForCharacteristic:error:
 *
 *  @param peripheral		The peripheral providing this information.
 *  @param characteristic	A <code>CBCharacteristic</code> object.
 *	@param error			If an error occurred, the cause of the failure.
 *
 *  @discussion				This method returns the result of a @link writeValue:forCharacteristic: @/link call.
 */
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (![peripheral isEqual:self.peripheral]) {
        return;
    }
    
    if (error) {
        return;
    }
    
    JBCharacteristic *jbCharacteristic = [JBUUIDManager characteristicWithUUID:characteristic.UUID];
    if (jbCharacteristic) {
        [peripheral readValueForCharacteristic:characteristic];
    }
}

/*!
 *  @method peripheral:didUpdateNotificationStateForCharacteristic:error:
 *
 *  @param peripheral		The peripheral providing this information.
 *  @param characteristic	A <code>CBCharacteristic</code> object.
 *	@param error			If an error occurred, the cause of the failure.
 *
 *  @discussion				This method returns the result of a @link setNotifyValue:forCharacteristic: @/link call.
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (![peripheral isEqual:self.peripheral]) {
        return;
    }
    
    if (error) {
        return;
    }
    
    JBCharacteristic *jbCharacteristic = [JBUUIDManager characteristicWithUUID:characteristic.UUID];
    if (jbCharacteristic) {
        if (jbCharacteristic.needNotifyValue) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([self.delegate respondsToSelector:@selector(peripheral:characteristicNotifyValueWithCharacteristic:)]) {
                    [self.delegate peripheral:self characteristicNotifyValueWithCharacteristic:characteristic];
                }
            });
        }
    }
}

/*!
 *  @method peripheral:didDiscoverDescriptorsForCharacteristic:error:
 *
 *  @param peripheral		The peripheral providing this information.
 *  @param characteristic	A <code>CBCharacteristic</code> object.
 *	@param error			If an error occurred, the cause of the failure.
 *
 *  @discussion				This method returns the result of a @link discoverDescriptorsForCharacteristic: @/link call. If the descriptors were read successfully,
 *							they can be retrieved via <i>characteristic</i>'s <code>descriptors</code> property.
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{}

/*!
 *  @method peripheral:didUpdateValueForDescriptor:error:
 *
 *  @param peripheral		The peripheral providing this information.
 *  @param descriptor		A <code>CBDescriptor</code> object.
 *	@param error			If an error occurred, the cause of the failure.
 *
 *  @discussion				This method returns the result of a @link readValueForDescriptor: @/link call.
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error
{}

/*!
 *  @method peripheral:didWriteValueForDescriptor:error:
 *
 *  @param peripheral		The peripheral providing this information.
 *  @param descriptor		A <code>CBDescriptor</code> object.
 *	@param error			If an error occurred, the cause of the failure.
 *
 *  @discussion				This method returns the result of a @link writeValue:forDescriptor: @/link call.
 */
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error
{}

@end
