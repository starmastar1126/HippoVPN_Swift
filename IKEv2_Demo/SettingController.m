//
//  SettingController.m
//  HippoVPN
//
//  Created by Viet Anh on 4/7/20.
//  Copyright © 2020 zorro. All rights reserved.
//

#import "SettingController.h"
#import "Util.h"
@interface SettingController ()
@property (weak, nonatomic) IBOutlet UIButton *uiBtn;
@end

@implementation SettingController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _uiBtn.layer.cornerRadius = 25;
    // Do any additional setup after loading the view.
    self.view.backgroundColor =[Util colorWithHexString:@"#38BCAE"];
}

- (IBAction)actionClose:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end
