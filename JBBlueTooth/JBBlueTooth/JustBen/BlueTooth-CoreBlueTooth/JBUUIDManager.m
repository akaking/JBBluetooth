//
//  JBUUIDManager.m
//  JBBlueTooth
//
//  Defines Services' UUID and Characteristics' UUID
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

#import "JBUUIDManager.h"
#import "JBUUID.h"
#import "JBCharacteristic.h"


#ifndef PathOfPlistFileInMainBundle
#define PathOfPlistFileInMainBundle(plistFileName)      [[NSBundle mainBundle] pathForResource:plistFileName ofType:@"plist"]
#endif


#ifndef UUIDPlistFileName
#define UUIDPlistFileName                       @"uuid"
#endif


#ifndef UUIDDicKey
#define UUIDDicKey
#define UUIDDicKeyServiceUUID                   @"serviceUUIDString"
#define UUIDDicKeyCharacteristicList            @"characteristicList"
#define UUIDDicKeyCharacteristicUUID            @"characteristicUUIDString"
#define UUIDDicKeyCharacteristicNeedNotifyValue @"needNotifyValue"
#endif

@interface JBUUIDManager ()

//  singleton method
+ (JBUUIDManager *)defaultUUIDManager;

//  read uuid.plist
- (void)readUUIDPlistFile;

//  data stored in uuid.plist
@property (nonatomic, retain) NSMutableArray *uuids;

@end


@implementation JBUUIDManager


#pragma mark -
#pragma mark - Class Extensions
//  singleton method
+ (JBUUIDManager *)defaultUUIDManager
{
    static JBUUIDManager *staticUUIDManager = nil;
    if (!staticUUIDManager) {
        staticUUIDManager = [[JBUUIDManager alloc] init];
        [staticUUIDManager readUUIDPlistFile];
    }
    
    return staticUUIDManager;
}

//  read uuid.plist
- (void)readUUIDPlistFile
{
    if (!self.uuids) {
        self.uuids = [[NSMutableArray alloc] init];
    }
    [self.uuids removeAllObjects];
    
    
    //  read stored data in uuid.plist
    NSArray *uuidDics = [[NSArray alloc] initWithContentsOfFile:PathOfPlistFileInMainBundle(UUIDPlistFileName)];
    if (uuidDics && uuidDics.count > 0) {
        for (NSDictionary *uuidDic in uuidDics) {
            
            //  get the service's uuid
            NSString *serviceUUIDString = [uuidDic objectForKey:UUIDDicKeyServiceUUID];
            if (serviceUUIDString) {
                NSMutableArray *jbCharacteristicList = [[NSMutableArray alloc] init];
                
                //  get the characteristics' uuid in service
                NSArray *characteristicList = [uuidDic objectForKey:UUIDDicKeyCharacteristicList];
                if (characteristicList) {
                    for (NSDictionary *characristricDic in characteristicList) {
                        NSString *characteristicUUIDString = [characristricDic objectForKey:UUIDDicKeyCharacteristicUUID];
                        NSNumber *needNotifyValue = [characristricDic objectForKey:UUIDDicKeyCharacteristicNeedNotifyValue];
                        if (characteristicUUIDString) {
                            JBCharacteristic *jbCharacteristic = [[JBCharacteristic alloc] initWithUUID:[CBUUID UUIDWithString:characteristicUUIDString] NeedNotityValue:needNotifyValue.boolValue];
                            [jbCharacteristicList addObject:jbCharacteristic];
                        }
                    }
                }
                
                JBUUID *jbUUID = [[JBUUID alloc] initWithServiceUUID:[CBUUID UUIDWithString:serviceUUIDString] Characteristics:jbCharacteristicList];
                [self.uuids addObject:jbUUID];
            }
        }
    }
}


#pragma mark -
#pragma mark - Class Methods

//  JBUUID object list defined in uuid.plist
+ (NSArray *)allUUIDs
{
    return [self defaultUUIDManager].uuids;
}

//  CBUUID object list of services defined in uuid.plist
+ (NSArray *)allServices
{
    if ([self defaultUUIDManager].uuids && [self defaultUUIDManager].uuids.count > 0) {
        NSMutableArray *services = [[NSMutableArray alloc] init];
        for (JBUUID *jbUUID in [self defaultUUIDManager].uuids) {
            [services addObject:jbUUID.serviceUUID];
        }
        
        return services;
    }
    
    return nil;
}

//  check whether is service available with uuid
+ (BOOL)serviceAvailable:(CBUUID *)serviceUUID
{
    if ([self defaultUUIDManager].uuids && [self defaultUUIDManager].uuids.count > 0) {
        for (JBUUID *jbUUID in [self defaultUUIDManager].uuids) {
            if ([jbUUID.serviceUUID isEqual:serviceUUID]) {
                return YES;
            }
        }
    }
    
    return NO;
}

//  JBCharacteristic object list in service seperified by uuid that defined in uuid.plist
+ (NSArray *)characteristicsInServiceWithUUID:(CBUUID *)serviceUUID
{
    if ([self defaultUUIDManager].uuids && [self defaultUUIDManager].uuids.count > 0) {
        for (JBUUID *jbUUID in [self defaultUUIDManager].uuids) {
            if ([jbUUID.serviceUUID isEqual:serviceUUID]) {
                return jbUUID.characteristics;
            }
        }
    }
    
    return nil;
}

//  JBCharacteristic object with uuid defined in uuid.plist
+ (JBCharacteristic *)characteristicWithUUID:(CBUUID *)characteristicWithUUID
{
    if ([self defaultUUIDManager].uuids && [self defaultUUIDManager].uuids.count > 0) {
        for (JBUUID *jbUUID in [self defaultUUIDManager].uuids) {
            for (JBCharacteristic *jbCharacteristic in jbUUID.characteristics) {
                if ([jbCharacteristic.UUID isEqual:characteristicWithUUID]) {
                    return jbCharacteristic;
                }
            }
        }
    }
    
    return nil;
}

@end
