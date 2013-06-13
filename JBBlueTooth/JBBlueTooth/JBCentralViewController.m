//
//  JBCentralViewController.m
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

#import "JBCentralViewController.h"
#import "JBCentralManager.h"
#import "JBPeripheral.h"

@interface JBCentralViewController () <JBCentralManagerDelegate, JBPeripheralDelegate>

@property (nonatomic, retain) JBCentralManager *centralManager;

@property (nonatomic, retain) UIButton *startButton;
- (void)actionForStartButton;
@property (nonatomic, retain) UIButton *stopButton;
- (void)actionForStopButton;

@end

@implementation JBCentralViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Server";
        
        self.centralManager = [JBCentralManager sharedCentralManagerWithCentralManagerDelegate:self PeripheralDelegate:self];
        
        self.startButton = [[UIButton alloc] initWithFrame:CGRectMake(20.0f, 20.0f, self.view.bounds.size.width - 40.0f, self.view.bounds.size.height/6)];
        [self.startButton setBackgroundImage:[[UIImage imageNamed:@"ButtonBG"] stretchableImageWithLeftCapWidth:5 topCapHeight:5] forState:UIControlStateNormal];
        [self.startButton setTitle:@"Start" forState:UIControlStateNormal];
        [self.startButton addTarget:self action:@selector(actionForStartButton) forControlEvents:UIControlEventTouchUpInside];
        self.startButton.enabled = NO;
        [self.view addSubview:self.startButton];
        
        self.stopButton = [[UIButton alloc] initWithFrame:CGRectMake(20.0f, 40.0f + self.view.bounds.size.height/6, self.view.bounds.size.width - 40.0f, self.view.bounds.size.height/6)];
        [self.stopButton setBackgroundImage:[[UIImage imageNamed:@"ButtonBG"] stretchableImageWithLeftCapWidth:5 topCapHeight:5] forState:UIControlStateNormal];
        [self.stopButton setTitle:@"Stop" forState:UIControlStateNormal];
        [self.stopButton addTarget:self action:@selector(actionForStopButton) forControlEvents:UIControlEventTouchUpInside];
        self.stopButton.enabled = NO;
        [self.view addSubview:self.stopButton];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark - Class Extensions
- (void)actionForStartButton
{
    self.startButton.enabled = NO;
    self.stopButton.enabled = YES;
    
    [self.centralManager startScanningAll];
}

- (void)actionForStopButton
{
    self.stopButton.enabled = NO;
    self.startButton.enabled = YES;
    
    [self.centralManager stopScanning];
}

#pragma mark -
#pragma mark - JBCentralManagerDelegate
- (void)centralManagerDeviceUnsupportedBTLE
{
    self.startButton.enabled = NO;
    self.stopButton.enabled = NO;
    
    NSLog(@"device unsupported BTLE");
}

- (void)centralManagerAppIsNotAuthorizedToUse
{
    NSLog(@"The application is not authorized to use the Bluetooth Low Energy Central/Client role.");
}

- (void)centralManagerDiscoveryDidRefresh
{
    NSLog(@"refresh");
    
    for (CBPeripheral *peripheral in self.centralManager.foundPeripherals) {
        NSLog(@"-peripheral:%@", peripheral.name);
    }
}

- (void)centralManagerDiscoveryStatePoweredOff
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"powered off" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];
    
    self.startButton.enabled = NO;
    self.stopButton.enabled = NO;
}

- (void)centralManagerPoweredOn
{
    self.startButton.enabled = YES;
    self.stopButton.enabled = NO;
}

- (void)centralManagerDidFailToConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"fail to connect peripheral:%@ RSSI:%@", peripheral.name, peripheral.RSSI);
}


#pragma mark -
#pragma mark - JBPeripheralDelegate
- (void)peripheralDidChangeStatus:(JBPeripheral *)peripheral
{
    NSLog(@"peripheral(%@) change status:%i", peripheral.peripheral.name, peripheral.peripheral.isConnected);
}

- (void)peripheralDidReset:(JBPeripheral *)peripheral
{
    NSLog(@"reset a peripheral");
}

- (void)peripheral:(JBPeripheral *)peripheral characteristicUpdateValueWithCharacteristic:(CBCharacteristic *)characteristic
{
    NSData *value = characteristic.value;
    NSLog(@"peripheral(%@) update value:%@ in characteristic:%@", peripheral.peripheral.name, value, characteristic.UUID);
}

- (void)peripheral:(JBPeripheral *)peripheral characteristicNotifyValueWithCharacteristic:(CBCharacteristic *)characteristic
{
    NSLog(@"peripheral(%@) notify value in characteristic:%@", peripheral.peripheral.name, characteristic.UUID);
}

- (void)peripheralDidUpdateRSSI:(JBPeripheral *)peripheral
{
    NSLog(@"peripheral(%@) update RSSI:%@", peripheral.peripheral, peripheral.peripheral.RSSI);
}

- (void)peripheralDidUpdateName:(JBPeripheral *)peripheral
{
    NSLog(@"peripheral(%@) update name:%@", peripheral.peripheral.UUID, peripheral.peripheral.name);
}


@end
