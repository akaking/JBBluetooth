//
//  JBUUID.m
//  JBBlueTooth
//
//  JBUUID object is responsed to a service and the service's characteristics.
//  Just a simple Struct of service's uuid and characteristics' UUID in service.
//  service's UUID and characteristics's UUID are stored in uuid.plist file.
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

#import "JBUUID.h"

@interface JBUUID ()

@property (nonatomic, retain, readwrite) CBUUID *serviceUUID;
@property (nonatomic, retain, readwrite) NSArray *characteristics;

@end


@implementation JBUUID

- (id)initWithServiceUUID:(CBUUID *)serviceUUID Characteristics:(NSArray *)characteristics
{
    self = [super init];
    if (self) {
        self.serviceUUID = serviceUUID;
        self.characteristics = characteristics;
    }
    
    return self;
}

@end
