//
//  ViewController.m
//  ZWModelExample
//
//  Created by Gavin on 17/3/1.
//  Copyright © 2017年 Gavin. All rights reserved.
//

#import "ViewController.h"
#import "ZWIMModel.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view, typically from a nib.
  
  // model
  
  ZWIMModel *model = [ZWIMModel zw_modelWithJSON:@{}];

}


- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}


@end
