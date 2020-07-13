//
//  SubscribeVC.m
//  HippoVPN
//
//  Created by xiao long on 2020/3/31.
//  Copyright © 2020 zorro. All rights reserved.
//

#import "SubscribeVC.h"
#import "HomeViewController.h"

@interface SubscribeVC ()

@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation SubscribeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSString *text1 = @"Try free for 3-days, by subscribing you agree to our ";
    NSMutableAttributedString *attrString1 =
    [[NSMutableAttributedString alloc] initWithString:text1  attributes:@{NSForegroundColorAttributeName :[UIColor whiteColor]}];
    [attrString1 addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize: 14] range:NSMakeRange(0, attrString1.length)];
    NSURL *termsUrl = [NSURL URLWithString:@"http://hippovpn.com/terms/"];
    NSAttributedString *attrTerms = [[NSAttributedString alloc] initWithString:@"Terms of service"
    attributes:@{NSForegroundColorAttributeName:[UIColor blueColor], NSFontAttributeName:[UIFont systemFontOfSize:14], NSLinkAttributeName:termsUrl}];
    NSURL *privacyUrl = [NSURL URLWithString:@"http://hippovpn.com/privacy/"];
    NSAttributedString *attrPrivacy = [[NSAttributedString alloc] initWithString:@"Privacy Policy"
    attributes:@{NSForegroundColorAttributeName:[UIColor blueColor], NSFontAttributeName:[UIFont systemFontOfSize:14], NSLinkAttributeName:privacyUrl}];
    NSString *text2 = @". If you do not cancel your subscription at least 24 hours before the end of the 3-day trial period, your yearly paid subscritpion will start and you will be charged £19.99 within 24 hours before the end of your trial. Subscriptions automatically renews unless it is canceled at least 24 hours before the end of the current period. Your account will be charged for renewal within 24 hours prior to the end of the current period. You can manage and cancel your subscriptions by going to your account settings on the App Store after purchase. Any unused portion of the free trial period will be forfeited when a subscription is purchased. ";
    NSMutableAttributedString *attrString2 =
    [[NSMutableAttributedString alloc] initWithString:text2  attributes:@{NSForegroundColorAttributeName :[UIColor whiteColor]}];
    [attrString2 addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize: 14] range:NSMakeRange(0, attrString2.length)];
    [attrString1 appendAttributedString:attrTerms];
    NSMutableAttributedString *attrString3 =
    [[NSMutableAttributedString alloc] initWithString:@" and acknowledge the "  attributes:@{NSForegroundColorAttributeName :[UIColor whiteColor]}];
    [attrString3 addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize: 14] range:NSMakeRange(0, attrString3.length)];
    [attrString1 appendAttributedString:attrString3];
    [attrString1 appendAttributedString:attrPrivacy];
    [attrString1 appendAttributedString:attrString2];
    _textView.attributedText = attrString1;
}

- (IBAction)onClose:(UIButton *)sender {
    HomeViewController *homeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeVCID"];
    [self.navigationController setViewControllers: @[homeVC] animated:YES];
}

- (IBAction)onSubscribe:(UIButton *)sender {
    [self fetchAvailableProducts];
//    dispatch_async(dispatch_get_main_queue(), ^{
//    });
}

- (BOOL)canMakePurchases {
   return [SKPaymentQueue canMakePayments];
}

- (void)purchaseMyProduct:(SKProduct*)product {
   if ([self canMakePurchases]) {
      SKPayment *payment = [SKPayment paymentWithProduct:product];
      [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
      [[SKPaymentQueue defaultQueue] addPayment:payment];
   } else {
      UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:
      @"Purchases are disabled in your device" message:nil delegate:
      self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
      [alertView show];
   }
}

-(void)fetchAvailableProducts {
   NSSet *productIdentifiers = [NSSet setWithObjects:@"Hippo",nil];
   productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
   productsRequest.delegate = self;
   [productsRequest start];
}

#pragma mark StoreKit Delegate

-(void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchasing:
                NSLog(@"Purchasing");
                break;
         
            case SKPaymentTransactionStatePurchased:
                NSLog(@"Purchased ");
                [[NSUserDefaults standardUserDefaults] setObject: [NSNumber numberWithBool:YES] forKey:@"isSubbed"];
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
        
            case SKPaymentTransactionStateRestored:
                NSLog(@"Restored ");
                [[NSUserDefaults standardUserDefaults] setObject: [NSNumber numberWithBool:YES] forKey:@"isSubbed"];
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            
            case SKPaymentTransactionStateFailed:
                NSLog(@"Purchase failed ");
                [self showAlert];
                [[NSUserDefaults standardUserDefaults] setObject: [NSNumber numberWithBool:NO] forKey:@"isSubbed"];
                break;
            default:
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
      }
   }
}

-(void)productsRequest:(SKProductsRequest *)request
didReceiveResponse:(SKProductsResponse *)response {
   SKProduct *validProduct = nil;
   int count = [response.products count];
   
      if (count>0) {
         validProducts = response.products;
         validProducts = response.products;
         for (SKProduct *validProduct in validProducts){
             if([validProduct.productIdentifier isEqualToString:@"Hippo"]){
                 NSLog(@"Product Title: %@",validProduct.localizedTitle);
                 NSLog(@"Product Desc: %@",validProduct.localizedDescription);
                 NSLog(@"Product Price: %@",validProduct.price);
                 break;
             }
         }
      } else {
      }
      
   //   [activityIndicatorView stopAnimating];
   }

- (void)showAlert {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:@"Purchase failed"
                                                   delegate:self
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"OK",nil];
    [alert show];
}

@end
