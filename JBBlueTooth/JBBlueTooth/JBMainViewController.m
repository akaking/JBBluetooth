//
//  JBMainViewController.m
//  JBBlueTooth
//
//  Created by YongbinZhang on 6/8/13.
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

#import "JBMainViewController.h"
#import "JBPeripheralViewController.h"
#import "JBCentralViewController.h"

@interface JBMainViewController ()


@property (nonatomic, retain) JBPeripheralViewController *peripheralVC;
@property (nonatomic, retain) UIButton *asClientButton;
- (void)actionForAsClientButton;
@property (nonatomic, retain) JBCentralViewController *certralVC;
@property (nonatomic, retain) UIButton *asServerButton;
- (void)actionForAsServerButton;

@end

@implementation JBMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Bluetooth";
        
        self.peripheralVC = [[JBPeripheralViewController alloc] initWithNibName:nil bundle:nil];
        self.certralVC = [[JBCentralViewController alloc] initWithNibName:nil bundle:nil];
        
        
        self.asClientButton = [[UIButton alloc] initWithFrame:CGRectMake(20.0f, 20.0f, self.view.bounds.size.width - 40.0f, self.view.bounds.size.height/6)];
        [self.asClientButton setBackgroundImage:[[UIImage imageNamed:@"ButtonBG"] stretchableImageWithLeftCapWidth:5 topCapHeight:5] forState:UIControlStateNormal];
        [self.asClientButton setTitle:@"As Client" forState:UIControlStateNormal];
        [self.asClientButton addTarget:self action:@selector(actionForAsClientButton) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.asClientButton];
        
        self.asServerButton = [[UIButton alloc] initWithFrame:CGRectMake(20.0f, 40.0f + self.view.bounds.size.height/6, self.view.bounds.size.width - 40.0f, self.view.bounds.size.height/6)];
        [self.asServerButton setBackgroundImage:[[UIImage imageNamed:@"ButtonBG"] stretchableImageWithLeftCapWidth:5 topCapHeight:5] forState:UIControlStateNormal];
        [self.asServerButton setTitle:@"As Server" forState:UIControlStateNormal];
        [self.asServerButton addTarget:self action:@selector(actionForAsServerButton) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.asServerButton];
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
- (void)actionForAsClientButton
{
    [self.navigationController pushViewController:self.peripheralVC animated:YES];
}

- (void)actionForAsServerButton
{
    [self.navigationController pushViewController:self.certralVC animated:YES];
}

@end
