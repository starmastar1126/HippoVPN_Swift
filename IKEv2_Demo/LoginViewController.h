//
//  LoginViewController.h
//  IKEv2_Demo
//
//  Created by zqqf16 on 16/3/16.
//  Copyright © 2016年 zqqf16. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>
@interface LoginViewController :UIViewController <SKProductsRequestDelegate,SKPaymentTransactionObserver> {
   SKProductsRequest *productsRequest;
   NSArray *validProducts;
   UIActivityIndicatorView *activityIndicatorView;
   IBOutlet UILabel *productTitleLabel;
   IBOutlet UILabel *productDescriptionLabel;
   IBOutlet UILabel *productPriceLabel;
   IBOutlet UIButton *purchaseButton;
}

- (void)fetchAvailableProducts;
- (BOOL)canMakePurchases;
- (void)purchaseMyProduct:(SKProduct*)product;
- (IBAction)purchase:(id)sender;

@end
