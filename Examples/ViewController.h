//
//  ViewController.h
//  Examples
//
//  Created by laizw on 2019/2/2.
//  Copyright © 2019 laizw. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ChangeTextProtocol <NSObject>

- (void)changeText:(NSString *)text;

@end

@protocol ChangeTextProtocol2 <ChangeTextProtocol>

- (void)changeText2:(NSString *)text;

@end

@interface ViewController : UIViewController


@end

