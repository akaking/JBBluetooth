//
//  JBPeripheralViewController.m
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

#import "JBPeripheralViewController.h"
#import "JBPeripheralManager.h"

@interface JBPeripheralViewController () <JBPeripheralManagerDelegate>

@property (nonatomic, retain) JBPeripheralManager *peripheralManager;

@property (nonatomic, retain) UIButton *sendButton;
- (void)actionForSendButton;


@property (nonatomic, retain) CBCentral *central;
@property (nonatomic, retain) CBMutableCharacteristic *characteristic;

@end

@implementation JBPeripheralViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Client";
        
        self.peripheralManager = [JBPeripheralManager sharedPeripheralManagerWithPeripheralDelegate:self];
        
        self.sendButton = [[UIButton alloc] initWithFrame:CGRectMake(20.0f, 20.0f, self.view.bounds.size.width - 40.0f, self.view.bounds.size.height/6)];
        [self.sendButton setBackgroundImage:[[UIImage imageNamed:@"ButtonBG"] stretchableImageWithLeftCapWidth:5 topCapHeight:5] forState:UIControlStateNormal];
        [self.sendButton setTitle:@"Advertise" forState:UIControlStateNormal];
        [self.sendButton addTarget:self action:@selector(actionForSendButton) forControlEvents:UIControlEventTouchUpInside];
        self.sendButton.enabled = NO;
        [self.view addSubview:self.sendButton];
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
- (void)actionForSendButton
{
    NSDictionary *dict = @{ @"NAME" : @"Khaos Tian",@"EMAIL":@"khaos.tian@gmail.com" };
    NSData * mainData = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:nil];
    [self.peripheralManager sendData:mainData ToCentral:self.central InCharacteristic:self.characteristic];
}


#pragma mark -
#pragma mark - JBPeripheralManagerDelegate
- (void)peripheralManagerDeviceUnsupportedBTLE:(JBPeripheralManager *)peripheralManager
{
    self.sendButton.enabled = NO;
}

- (void)peripheralManagerAppIsNotAuthorizedToUse:(JBPeripheralManager *)peripheralManager
{
    self.sendButton.enabled = NO;
}

- (void)peripheralManagerPoweredOff:(JBPeripheralManager *)peripheralManager
{
    self.sendButton.enabled = NO;
}

- (void)peripheralManagerPoweredOn:(JBPeripheralManager *)peripheralManager
{
    self.sendButton.enabled = YES;
}

- (void)peripheralManager:(JBPeripheralManager *)peripheralManager WriteDataIsAvailableWithCentral:(CBCentral *)central toCharacteristic:(CBCharacteristic *)characteristic
{
    self.central = central;
    self.characteristic = (CBMutableCharacteristic *)characteristic;
    
    self.sendButton.enabled = YES;
}

@end
