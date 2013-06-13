//
//  JBPeripheral.h
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

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#import "JBCentralManager.h"
#import "JBUUIDManager.h"


@protocol JBPeripheralDelegate;
@interface JBPeripheral : NSObject

@property (nonatomic, weak, readonly) CBPeripheral *peripheral;

- (id)initWithPeriphera:(CBPeripheral *)peripheral delegate:(id <JBPeripheralDelegate>)delegate;

- (void)reset;
- (void)start;

@end


@protocol JBPeripheralDelegate <NSObject>

@optional
- (void)peripheralDidChangeStatus:(JBPeripheral *)peripheral;
- (void)peripheralDidReset:(JBPeripheral *)peripheral;

- (void)peripheral:(JBPeripheral *)peripheral characteristicUpdateValueWithCharacteristic:(CBCharacteristic *)characteristic;
- (void)peripheral:(JBPeripheral *)peripheral characteristicNotifyValueWithCharacteristic:(CBCharacteristic *)characteristic;

- (void)peripheralDidUpdateRSSI:(JBPeripheral *)peripheral;

- (void)peripheralDidUpdateName:(JBPeripheral *)peripheral;
@end