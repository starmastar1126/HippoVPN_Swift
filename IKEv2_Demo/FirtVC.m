//
//  FirtVC.m
//  HippoVPN
//
//  Created by xiao long on 2020/3/31.
//  Copyright © 2020 zorro. All rights reserved.
//

#import "FirtVC.h"
#import "SubscribeVC.h"
#import "HomeViewController.h"

@interface FirtVC ()

@property (weak, nonatomic) IBOutlet UILabel *label1;
@property (weak, nonatomic) IBOutlet UILabel *label2;
@property (weak, nonatomic) IBOutlet UILabel *label3;

@end

@implementation FirtVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
        _label1.text = @"That's why we want to be fully transparent about what data you agree to give us. We collect only a bare minimum of data required to offer you smooth and stable VPN experience, specifically:";
        
        NSString *text1 = @"Aggregated anonymous app usage data including your device type and OS version";
        NSString *text2 = @" - to troubleshoot effectively and improve our app.";
        NSMutableAttributedString *attributedString1 =
        [[NSMutableAttributedString alloc] initWithString:text1];
        [attributedString1 addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize: 18] range:NSMakeRange(0, attributedString1.length)];
        NSMutableAttributedString *attributedString2 = [[NSMutableAttributedString alloc] initWithString:text2];

        [attributedString1 appendAttributedString:attributedString2];
        _label2.attributedText = attributedString1;
        
        text1 = @"That's it. Anything else - well, we're simply not interested.";
        text2 = @" We DON'T log your online activity or any personally identifiable information. ";
        NSString *text3 = @"We make sure your private data remains truly private.";
        
        attributedString1 = [[NSMutableAttributedString alloc] initWithString:text1];
        attributedString2 = [[NSMutableAttributedString alloc] initWithString:text2];
        [attributedString2 addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize: 18] range:NSMakeRange(0, attributedString1.length)];
        NSMutableAttributedString *attributedString3 = [[NSMutableAttributedString alloc] initWithString:text3];

        [attributedString1 appendAttributedString:attributedString2];
        [attributedString1 appendAttributedString:attributedString3];
        _label3.attributedText = attributedString1;
}

- (IBAction)onAccept:(UIButton *)sender {
    BOOL isSubbed = [[[NSUserDefaults standardUserDefaults]
    objectForKey:@"isSubbed"] boolValue];
    if(isSubbed == NO) {
        SubscribeVC *subscribeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SubscribeVCID"];
        [self.navigationController pushViewController:subscribeVC animated:YES];
    } else {
        HomeViewController *homeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeVCID"];
        [self.navigationController pushViewController:homeVC animated:YES];
    }
}

@end
