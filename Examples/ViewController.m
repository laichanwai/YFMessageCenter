//
//  ViewController.m
//  Examples
//
//  Created by laizw on 2019/2/2.
//  Copyright © 2019 laizw. All rights reserved.
//

#import "ViewController.h"
#import "YFMessageCenter.h"

@interface ViewController () <ChangeTextProtocol2>
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    OBSERVE_MESSAGE(self, ChangeTextProtocol);
    OBSERVE_MESSAGE(self, ChangeTextProtocol2);
}

- (void)changeText:(NSString *)text {
    self.titleLabel.text = text;
}

- (void)changeText2:(NSString *)text {
    self.titleLabel.text = text;
}

@end
