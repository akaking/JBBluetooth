//
//  JBUserDefaultServiceCenter.m
//  FreeDaily
//
//  Created by YongbinZhang on 4/9/13.
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


#import "JBUserDefaultServiceCenter.h"

@interface JBUserDefaultServiceCenter ()

+ (NSUserDefaults *)StandardUserDefaults;

@end

@implementation JBUserDefaultServiceCenter

#pragma mark - 
#pragma mark - Class Extensions
+ (NSUserDefaults *)StandardUserDefaults
{
    return [NSUserDefaults standardUserDefaults];
}


#pragma mark - 
#pragma mark - Class Methods
+ (id)getUserDefaultValueByKey:(NSString *)key
{
    if (key && key.length > 0) {
        return [[self StandardUserDefaults] objectForKey:key];
    } else {
        return nil;
    }
}

+ (BOOL)deleteUserDefaultValueByKey:(NSString *)key
{
    if (key && key.length > 0) {
        [[self StandardUserDefaults] removeObjectForKey:key];
        [[self StandardUserDefaults] synchronize];
        
        return (nil == [self getUserDefaultValueByKey:key]);
    } else {
        return NO;
    }
}

+ (BOOL)setUserDefaultValue:(id)value WithKey:(NSString *)key
{
    if (key && key.length > 0 && value) {
        [[self StandardUserDefaults] setObject:value forKey:key];
        [[self StandardUserDefaults] synchronize];
        
        return (nil != [self getUserDefaultValueByKey:key]);
    } else {
        return NO;
    }
}


@end
