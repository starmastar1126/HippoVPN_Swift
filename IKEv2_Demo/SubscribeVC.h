//
//  SubscribeVC.h
//  HippoVPN
//
//  Created by xiao long on 2020/3/31.
//  Copyright © 2020 zorro. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>
#import "Util.h"

NS_ASSUME_NONNULL_BEGIN

@interface SubscribeVC : UIViewController<SKProductsRequestDelegate,SKPaymentTransactionObserver> {
  SKProductsRequest *productsRequest;
  NSArray *validProducts;
}

- (void)fetchAvailableProducts;
- (BOOL)canMakePurchases;
- (void)purchaseMyProduct:(SKProduct*)product;
@end

NS_ASSUME_NONNULL_END
