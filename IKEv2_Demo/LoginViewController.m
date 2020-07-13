//
//  LoginViewController.m
//  IKEv2_Demo
//
//  Created by zqqf16 on 16/3/16.
//  Copyright © 2016年 zqqf16. All rights reserved.
//

#import <NetworkExtension/NEVPNManager.h>
#import <NetworkExtension/NEVPNConnection.h>
#import <NetworkExtension/NEVPNProtocolIKEv2.h>
#import "LoginViewController.h"
#define kTutorialPointProductID @"Hippo"
@interface LoginViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *server;
@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UITextField *presharedKey;
@property (weak, nonatomic) IBOutlet UITextField *remoteIdentifier;
@property (weak, nonatomic) IBOutlet UITextField *localIdentifier;

@property (weak, nonatomic) IBOutlet UIButton *actionButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (strong, nonatomic) NEVPNManager *vpnManager;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.vpnManager = [NEVPNManager sharedManager];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(vpnStatusDidChanged:)
               name:NEVPNStatusDidChangeNotification
             object:nil];
    
    
    // Adding activity indicator
    activityIndicatorView = [[UIActivityIndicatorView alloc]
    initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityIndicatorView.center = self.view.center;
    [activityIndicatorView hidesWhenStopped];
    [self.view addSubview:activityIndicatorView];
    [activityIndicatorView startAnimating];
    
    //Hide purchase button initially
    purchaseButton.hidden = YES;
    [self fetchAvailableProducts];
}

-(void)fetchAvailableProducts {
   NSSet *productIdentifiers = [NSSet
   setWithObjects:@"Hippo",nil];
   productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
   productsRequest.delegate = self;
   [productsRequest start];
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


#pragma mark StoreKit Delegate

-(void)paymentQueue:(SKPaymentQueue *)queue
updatedTransactions:(NSArray *)transactions {
   for (SKPaymentTransaction *transaction in transactions) {
      switch (transaction.transactionState) {
         case SKPaymentTransactionStatePurchasing:
            NSLog(@"Purchasing");
         break;
         
         case SKPaymentTransactionStatePurchased:
            if ([transaction.payment.productIdentifier
            isEqualToString:kTutorialPointProductID]) {
               NSLog(@"Purchased ");
               UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:
               @"Purchase is completed succesfully" message:nil delegate:
               self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
               [[NSUserDefaults standardUserDefaults] setObject: [NSNumber numberWithBool:YES] forKey:@"isSubbed"];
               [alertView show];
            }
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
         break;
            
         case SKPaymentTransactionStateRestored:
            NSLog(@"Restored ");
            [[NSUserDefaults standardUserDefaults] setObject: [NSNumber numberWithBool:YES] forKey:@"isSubbed"];
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
         break;
            
         case SKPaymentTransactionStateFailed:
         [[NSUserDefaults standardUserDefaults] setObject: [NSNumber numberWithBool:NO] forKey:@"isSubbed"];
            NSLog(@"Purchase failed ");
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
      validProduct = [response.products objectAtIndex:0];
      
       NSLog(@"Product Title: %@",validProduct.localizedTitle);
       NSLog(@"Product Desc: %@",validProduct.localizedDescription);
       NSLog(@"Product Price: %@",validProduct.price);
   } else {
   }
   
//   [activityIndicatorView stopAnimating];
   purchaseButton.hidden = NO;
}


- (void)vpnStatusDidChanged:(NSNotification *)notification{
    NEVPNStatus status = _vpnManager.connection.status;

    //UIAlertView *alert;
    if(status == NEVPNStatusInvalid){
        NSLog(@"NEVPNStatusInvalid");
        //_tfButton.enabled = YES;
    }
    if(status == NEVPNStatusConnecting){
        NSLog(@"NEVPNStatusConnecting");
        
    }
    if(status == NEVPNStatusReasserting){
        NSLog(@"NEVPNStatusReasserting");
        
    }
    if(status == NEVPNStatusConnected){
        NSLog(@"NEVPNStatusConnected");
      
    }
    if(status == NEVPNStatusDisconnected){
        NSLog(@"NEVPNStatusDisconnected");
    }
    if(status == NEVPNStatusDisconnecting){
        NSLog(@"NEVPNStatusDisconnecting");
    }
    return;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSArray *textFieldList = @[_server, _username, _password, _presharedKey, _remoteIdentifier, _localIdentifier];
    NSUInteger index = [textFieldList indexOfObject:textField];
    
    [textField resignFirstResponder];

    if (index < textFieldList.count - 1) {
        [(UITextField *)[textFieldList objectAtIndex:index+1] becomeFirstResponder];
    }
    
    return YES;
}

#pragma mark - VPN Control
- (IBAction)btn:(id)sender {
//    NEVPNStatus status = _vpnManager.connection.status;
//    if (status == NEVPNStatusConnected
//        || status == NEVPNStatusConnecting
//        || status == NEVPNStatusReasserting) {
//        [self disconnect];
//    } else {
//        [self connect];
//    }
    
    [self purchaseMyProduct:[validProducts objectAtIndex:0]];
    purchaseButton.enabled = NO;
}
- (void)installProfile {
    NSString *server = @"vpn.olivertech.ltd";
    NSString *remoteIdentifier = @"vpn.olivertech.ltd";
    NSString *localIdnetifier = @"vpn.olivertech.ltd";
    NSString *username = @"0435383557702149.hippovpn.com";
    NSString *password = @"VQ2Frron";
    
    // Save password & psk
    [self createKeychainValue:password forIdentifier:@"VPN_PASSWORD"];
//    [self createKeychainValue:@"securevpn" forIdentifier:@"PSK"];
    
    // Load config from perference
    [_vpnManager loadFromPreferencesWithCompletionHandler:^(NSError *error) {
        
        if (error) {
            NSLog(@"Load config failed [%@]", error.localizedDescription);
            return;
        }
        
        NEVPNProtocolIKEv2 *p = (NEVPNProtocolIKEv2 *)_vpnManager.protocolConfiguration;
        
        if (p) {
            // Protocol exists.
            // If you don't want to edit it, just return here.
            
            
        } else {
            // create a new one.
            p = [[NEVPNProtocolIKEv2 alloc] init];
            
        }
        // config IPSec protocol
        p.username = username;
        p.serverAddress = server;
        
        // Get password persistent reference from keychain
        // If password doesn't exist in keychain, should create it beforehand.
        // [self createKeychainValue:@"your_password" forIdentifier:@"VPN_PASSWORD"];
        p.passwordReference = [self searchKeychainCopyMatching:@"VPN_PASSWORD"];
        
        // PSK
        p.authenticationMethod = NEVPNIKEAuthenticationMethodNone;
        p.useExtendedAuthentication = YES;
        // [self createKeychainValue:@"your_psk" forIdentifier:@"PSK"];
//        p.sharedSecretReference = [self searchKeychainCopyMatching:@"PSK"];
        p.disableMOBIKE = NO;
        p.disableRedirect = NO;
        p.enableRevocationCheck = NO;
        p.childSecurityAssociationParameters.diffieHellmanGroup = 14;
        p.childSecurityAssociationParameters.encryptionAlgorithm = NEVPNIKEv2EncryptionAlgorithmAES128GCM;
        p.childSecurityAssociationParameters.integrityAlgorithm = NEVPNIKEv2IntegrityAlgorithmSHA256;
        p.childSecurityAssociationParameters.lifetimeMinutes = 1440;
        
        p.deadPeerDetectionRate = UIFontWeightMedium;
        
        p.IKESecurityAssociationParameters.encryptionAlgorithm = NEVPNIKEv2EncryptionAlgorithmAES256;
        p.IKESecurityAssociationParameters.diffieHellmanGroup = 14;
        p.IKESecurityAssociationParameters.lifetimeMinutes = 1440;
        p.IKESecurityAssociationParameters.integrityAlgorithm = NEVPNIKEv2IntegrityAlgorithmSHA256;
        
        if (@available(iOS 13.0, *)) {
            p.enableFallback = NO;
        } else {
            // Fallback on earlier versions
        }
        p.useConfigurationAttributeInternalIPSubnet = NO;
        /*
         // certificate
         p.identityData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"client" ofType:@"p12"]];
         p.identityDataPassword = @"[Your certificate import password]";
         */
        
        p.localIdentifier = localIdnetifier;
        p.remoteIdentifier = remoteIdentifier;
        
        p.useExtendedAuthentication = YES;
        p.disconnectOnSleep = NO;
        
        _vpnManager.protocolConfiguration = p;
        _vpnManager.localizedDescription = @"IKEv2";
        _vpnManager.enabled = YES;
        
        [_vpnManager saveToPreferencesWithCompletionHandler:^(NSError *error) {
            if (error) {
                NSLog(@"Save config failed [%@]", error.localizedDescription);
            }
        }];
        
    }];
}

- (void)connect {
    // Install profile
    [self installProfile];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(vpnConfigDidChanged:)
               name:NEVPNConfigurationChangeNotification
             object:nil];
    
}

- (void)disconnect
{
    [_vpnManager.connection stopVPNTunnel];
}

- (void)vpnConfigDidChanged:(NSNotification *)notification
{
    // TODO: Save configuration failed
    [self startConnecting];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NEVPNConfigurationChangeNotification
                                                  object:nil];
}

- (void)startConnecting
{
    NSError *startError;
    [_vpnManager.connection startVPNTunnelAndReturnError:&startError];
    if (startError) {
        NSLog(@"Start VPN failed: [%@]", startError.localizedDescription);
    }
}

#pragma mark - KeyChain

static NSString * const serviceName = @"im.zorro.ipsec_demo.vpn_config";

- (NSMutableDictionary *)newSearchDictionary:(NSString *)identifier {
    NSMutableDictionary *searchDictionary = [[NSMutableDictionary alloc] init];
    
    [searchDictionary setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
    
    NSData *encodedIdentifier = [identifier dataUsingEncoding:NSUTF8StringEncoding];
    [searchDictionary setObject:encodedIdentifier forKey:(__bridge id)kSecAttrGeneric];
    [searchDictionary setObject:encodedIdentifier forKey:(__bridge id)kSecAttrAccount];
    [searchDictionary setObject:serviceName forKey:(__bridge id)kSecAttrService];
    
    return searchDictionary;
}

- (NSData *)searchKeychainCopyMatching:(NSString *)identifier {
    NSMutableDictionary *searchDictionary = [self newSearchDictionary:identifier];
    
    // Add search attributes
    [searchDictionary setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
    
    // Add search return types
    // Must be persistent ref !!!!
    [searchDictionary setObject:@YES forKey:(__bridge id)kSecReturnPersistentRef];
    
    CFTypeRef result = NULL;
    SecItemCopyMatching((__bridge CFDictionaryRef)searchDictionary, &result);
    
    return (__bridge_transfer NSData *)result;
}

- (BOOL)createKeychainValue:(NSString *)password forIdentifier:(NSString *)identifier {
    NSMutableDictionary *dictionary = [self newSearchDictionary:identifier];
    
    OSStatus status = SecItemDelete((__bridge CFDictionaryRef)dictionary);
    
    NSData *passwordData = [password dataUsingEncoding:NSUTF8StringEncoding];
    [dictionary setObject:passwordData forKey:(__bridge id)kSecValueData];
    
    status = SecItemAdd((__bridge CFDictionaryRef)dictionary, NULL);
    
    if (status == errSecSuccess) {
        return YES;
    }
    return NO;
}

@end
