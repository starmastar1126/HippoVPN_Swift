//
//  HomeViewController.h
//  IKEv2_Demo
//
//  Created by Viet Anh on 3/22/20.
//  Copyright © 2020 zorro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface HomeViewController : UIViewController<SKProductsRequestDelegate,SKPaymentTransactionObserver> {
   SKProductsRequest *productsRequest;
   NSArray *validProducts;
}

- (void)fetchAvailableProducts;
- (BOOL)canMakePurchases;
- (void)purchaseMyProduct:(SKProduct*)product;
@property (nonatomic) dispatch_queue_t queue;
@property (nonatomic) dispatch_queue_t coreVPN;
@end

NS_ASSUME_NONNULL_END
