//
//  JBUUID.h
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

#import <Foundation/Foundation.h>

@class CBUUID;
@interface JBUUID : NSObject

@property (nonatomic, retain, readonly) CBUUID *serviceUUID;
@property (nonatomic, retain, readonly) NSArray *characteristics;

- (id)initWithServiceUUID:(CBUUID *)serviceUUID Characteristics:(NSArray *)characteristics;

@end
