//
//  LJJNotExistViewController.m
//  Pods
//
//  Created by liusui on 2016/9/29.
//
//

#import "LJJNotExistViewController.h"

@interface LJJNotExistViewController ()

@end

@implementation LJJNotExistViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UILabel *label = [[UILabel alloc]initWithFrame:self.view.bounds];
    label.text = @"404";
    label.textColor = [UIColor grayColor];
    label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label];
}

@end
