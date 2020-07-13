//
//  MyNavigationViewController.m
//  VPN Pro
//
//  Created by Vũ Thanh Tùng on 4/27/18.
//  Copyright © 2018 HUST. All rights reserved.
//

#import "MyNavigationViewController.h"
#import "SubscriptionController.h"
#import "Util.h"
//#import "SubViewConnectController.h"
@interface MyNavigationViewController ()
@property (weak, nonatomic) IBOutlet UIView *uiViewHeader;
@property (weak, nonatomic) IBOutlet UILabel *lableFullName;
@property (weak, nonatomic) IBOutlet UILabel *versionName;

@end
//static bool isClickServerVPN = false;
@implementation MyNavigationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //CGSize screenSize = [UIScreen mainScreen].bounds.size;
    //UIImage *bottomImage = [UIImage imageNamed:@"banne_color.png"];
    _uiViewHeader.backgroundColor = [Util colorWithHexString:@"#38BCAE"];
    //UIImageView *headerBanner = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, screenSize.width, 20)];
    //headerBanner.image = bottomImage;
    //[self.view addSubview:headerBanner];
    if ( [(NSString*)[UIDevice currentDevice].model hasPrefix:@"iPad"] ) {
        self.revealViewController.rearViewRevealWidth = self.view.frame.size.width / 2;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"section:%ld", (long)indexPath.section);
    NSLog(@"row:%ld", (long)indexPath.row);
    [self.revealViewController setFrontViewPosition: FrontViewPositionLeft animated: YES];//set revewl view controller to the left
    switch (indexPath.row) {
        case 0:{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"subscription" object:self];
            break;
        }
        case 1:{
//            [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"https://hippovpn-5cbb70.ingress-bonde.easywp.com/terms/"]];
            [SubscriptionController setIndexChoose:0];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"term" object:self];
            break;
        }
        case 2:{
//            [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"https://hippovpn-5cbb70.ingress-bonde.easywp.com/privacy/"]];
            [SubscriptionController setIndexChoose:1];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"term" object:self];
            break;
        }
        case 3:{
            [SubscriptionController setIndexChoose:2];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"term" object:self];
            break;
        }
        case 4:{
//            [SubscriptionController setIndexChoose:2];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"setting" object:self];
            break;
        }
        default:
            break;
    }
}
@end
