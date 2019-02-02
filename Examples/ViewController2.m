//
//  ViewController2.m
//  Examples
//
//  Created by laizw on 2019/2/2.
//  Copyright © 2019 laizw. All rights reserved.
//

#import "ViewController2.h"
#import "YFMessageCenter.h"
#import "ViewController.h"

@interface ViewController2 ()
@property (weak, nonatomic) IBOutlet UITextField *textField;

@end

@implementation ViewController2

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)postAction:(id)sender {
    [DISPATCH_MESSAGE(ChangeTextProtocol) changeText:self.textField.text];
}

- (IBAction)postAction1:(id)sender {
    [DISPATCH_MESSAGE(ChangeTextProtocol2) changeText2:self.textField.text];
}

- (IBAction)postAction2:(id)sender {
    [DISPATCH_MESSAGE(ChangeTextProtocol2) changeText:self.textField.text];
}

@end
