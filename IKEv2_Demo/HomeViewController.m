//
//  HomeViewController.m
//  IKEv2_Demo
//
//  Created by Viet Anh on 3/22/20.
//  Copyright © 2020 zorro. All rights reserved.
//

#import "HomeViewController.h"
#import "SWRevealViewController.h"
#import "SubscriptionController.h"
#import "SubscribeVC.h"
#import "Util.h"
#import <NetworkExtension/NEVPNManager.h>
#import <NetworkExtension/NEVPNConnection.h>
#import <NetworkExtension/NEVPNProtocolIKEv2.h>
#import "SettingController.h"
#define kTutorialPointProductID @"Hippo"

@interface HomeViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imgStatus;
@property (weak, nonatomic) IBOutlet UIButton *btnConnect;
@property (weak, nonatomic) IBOutlet UINavigationBar *navidationBar;
@property (weak, nonatomic) IBOutlet UIImageView *imgLogo;
@property (weak, nonatomic) IBOutlet UILabel *lbStatus;
@property (weak, nonatomic) IBOutlet UILabel *lbTime;
@property (strong, nonatomic) NEVPNManager *vpnManager;
@property (weak, nonatomic) NSTimer *myTimer;
@property (weak, nonatomic) IBOutlet UIImageView *imgIKEv2;
@property (weak, nonatomic) IBOutlet UIImageView *imgOpenVPN;
@property int currentTimeInSeconds;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *revealButtonItem;
@end

@implementation HomeViewController{
    BOOL isConnect;
    __block NETunnelProviderManager * vpnManager;
}
Boolean loadingIAP = false;
Boolean isWaitConnect = false;
Boolean isChooseIKEv2 = true;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.queue = dispatch_queue_create("check queue", 0);
    self.coreVPN = dispatch_queue_create("check coreVPN", 0);
    
    [self customSetup];
    
    _btnConnect.layer.cornerRadius = 25;
    
    self.vpnManager = [NEVPNManager sharedManager];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(vpnStatusDidChanged:)
               name:NEVPNStatusDidChangeNotification
             object:nil];
    
    if (!_currentTimeInSeconds) {
        _currentTimeInSeconds = 0 ;
    }
    
    if (!_myTimer) {
        _myTimer = [self createTimer];
    }
    
    // IAP
    [self fetchAvailableProducts];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handle_term) name:@"term" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handle_subscription) name:@"subscription" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handle_settin) name:@"setting" object:nil];
    
    UITapGestureRecognizer *tapIKEv2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handle_choose)];
    tapIKEv2.numberOfTapsRequired = 1;
    [self.imgIKEv2 setUserInteractionEnabled:YES];
    [self.imgIKEv2 addGestureRecognizer:tapIKEv2];
    
    UITapGestureRecognizer *tapOpenVPN = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handle_choose)];
    tapOpenVPN.numberOfTapsRequired = 1;
    [self.imgOpenVPN setUserInteractionEnabled:YES];
    [self.imgOpenVPN addGestureRecognizer:tapOpenVPN];
    
    NSUserDefaults *myDefaults = [[NSUserDefaults alloc]
    initWithSuiteName:[Util getAppGroup]];
    
    NSString *pro = [myDefaults objectForKey:@"pro"];
    if(pro != nil && [pro isEqualToString:@"OPENVPN"]){
        isChooseIKEv2 = true;
        [self handle_choose];
    }else{
        isChooseIKEv2 = false;
        [self handle_choose];
    }
}

- (void) handle_choose{
    isChooseIKEv2 = !isChooseIKEv2;
    NSUserDefaults *myDefaults = [[NSUserDefaults alloc]
    initWithSuiteName:[Util getAppGroup]];
    
    if(isChooseIKEv2){
        _imgIKEv2.image = [UIImage imageNamed:@"ic_check.png"];
        _imgOpenVPN.image = [UIImage imageNamed:@"ic_uncheck.png"];
        
        
        [myDefaults setObject:@"IKEV2" forKey:@"pro"];
    }else{
        _imgOpenVPN.image = [UIImage imageNamed:@"ic_check.png"];
        _imgIKEv2.image = [UIImage imageNamed:@"ic_uncheck.png"];
        [myDefaults setObject:@"OPENVPN" forKey:@"pro"];
    }
    
    [myDefaults synchronize];
}

- (void ) handle_settin{
    SettingController *gotoYourClass = [self.storyboard instantiateViewControllerWithIdentifier:@"setting"];
    [self.navigationController pushViewController:gotoYourClass animated:YES];
}

- (void) handle_term{
    SubscriptionController *gotoYourClass = [self.storyboard instantiateViewControllerWithIdentifier:@"subscription"];
    [self.navigationController pushViewController:gotoYourClass animated:YES];
}
- (void) handle_subscription{
    if ([self canMakePurchases]) {
//        SKPayment *payment = [SKPayment paymentWithProduct:[validProducts objectAtIndex:0]];
//        [[SKPaymentQueue defaultQueue] addPayment:payment];

        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
    }
//    [self purchaseMyProduct:[validProducts objectAtIndex:0]];
}
- (IBAction)actionSubscription:(id)sender {
    [SubscriptionController setIndexChoose:2];
    SubscriptionController *gotoYourClass = [self.storyboard instantiateViewControllerWithIdentifier:@"subscription"];
    [self.navigationController pushViewController:gotoYourClass animated:YES];
}

- (void)customSetup
{
    [[UINavigationBar appearance] setBarTintColor:[Util colorWithHexString:@"#38BCAE"]];
    //[_navidationBar setTintColor:[UIColor whiteColor]];
//    _navidationBar.titleTextAttributes = @{UITextAttributeTextColor : [UIColor whiteColor]};
    [[UINavigationBar appearance] setTranslucent:NO];
      [_navidationBar setShadowImage:[[UIImage alloc] init]];
     [_navidationBar setBackgroundImage:[[UIImage alloc]init] forBarMetrics:UIBarMetricsDefault];
    //set swreveal
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController ){
        [self.revealButtonItem setTarget: self.revealViewController];
        [self.revealButtonItem setAction: @selector( revealToggle: )];
        [self.view addGestureRecognizer: self.revealViewController.panGestureRecognizer];
    }
    
    self.view.backgroundColor =[Util colorWithHexString:@"#38BCAE"];
}
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}
- (IBAction)actionConnect:(id)sender {
    if(isChooseIKEv2){
        [self connectIKEv2];
    }else{
        [self connectOpenVPN];
    }
}

- (void) connectIKEv2{
    NEVPNStatus status = _vpnManager.connection.status;
        if (status == NEVPNStatusConnected
            || status == NEVPNStatusConnecting
            || status == NEVPNStatusReasserting) {
            _imgStatus.image = [UIImage imageNamed:@"Cross.png"];
            _imgLogo.image = [UIImage imageNamed:@"RED.png"];
            [self disconnect];
        } else {
            if([self loadExpireDate]){
                _lbStatus.text = @"CONNECTING";
                [_btnConnect setTitle:@"CONNECTING" forState:UIControlStateNormal];
                [self connect];
            }else{
                if(!loadingIAP){
                    // still load
                    UIAlertController * alert = [UIAlertController
                                                 alertControllerWithTitle:@"ERROR"
                                                 message:@"Loading IAP, please try again after a few seconds"
                                                 preferredStyle:UIAlertControllerStyleAlert];
                    
                    //Add Buttons
                    
                    UIAlertAction* yesButton = [UIAlertAction
                                                actionWithTitle:NSLocalizedString(@"yes", nil)
                                                style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * action) {
                                                    //Handle your yes please button action here
                                                }];
                    [alert addAction:yesButton];
                    [self presentViewController:alert animated:YES completion:nil];
                }else{
                    BOOL isSubbed = [[[NSUserDefaults standardUserDefaults]
                    objectForKey:@"isSubbed"] boolValue];
                    if(isSubbed == NO) {
                        SubscribeVC *subscribeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SubscribeVCID"];
                        [self.navigationController pushViewController:subscribeVC animated:YES];
                    } else {
                        [self connect];
                    }
                }
                

            }
        }
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

- (void)vpnStatusDidChanged:(NSNotification *)notification{
    NEVPNStatus status = _vpnManager.connection.status;

    //UIAlertView *alert;
    if(status == NEVPNStatusInvalid){
        NSLog(@"NEVPNStatusInvalid");
        //_tfButton.enabled = YES;
    }
    if(status == NEVPNStatusConnecting){
        NSLog(@"NEVPNStatusConnecting");
        _lbStatus.text = @"VPN CONNECTING";
    }
    if(status == NEVPNStatusReasserting){
        NSLog(@"NEVPNStatusReasserting");
        
    }
    if(status == NEVPNStatusConnected){
        NSLog(@"NEVPNStatusConnected");
        _lbStatus.text = @"VPN CONNECTED";
        [_btnConnect setTitle:@"DISCONNECT" forState:UIControlStateNormal];
        
        _imgStatus.image = [UIImage imageNamed:@"Group.png"];
        _imgLogo.image = [UIImage imageNamed:@"Green.png"];
    }
    if(status == NEVPNStatusDisconnected){
        NSLog(@"NEVPNStatusDisconnected");
        _lbStatus.text = @"VPN DISCONNECTED";
        [_btnConnect setTitle:@"CONNECT" forState:UIControlStateNormal];
        _imgStatus.image = [UIImage imageNamed:@"Cross.png"];
        _imgLogo.image = [UIImage imageNamed:@"RED.png"];
    }
    if(status == NEVPNStatusDisconnecting){
        NSLog(@"NEVPNStatusDisconnecting");
    }
    return;
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

- (NSString *)stringFromTimeInterval:(NSTimeInterval)interval {
    NSInteger ti = (NSInteger)interval;
    NSInteger seconds = ti % 60;
    NSInteger minutes = (ti / 60) % 60;
    NSInteger hours = (ti / 3600);
    return [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds];
}
- (NSString *)formattedTime:(int)totalSeconds
{
    NSDate* now = [NSDate date];
    NSTimeInterval diff = [now timeIntervalSinceDate:_vpnManager.connection.connectedDate];
    return [NSString stringWithFormat:@"%@", [self stringFromTimeInterval:diff]];
}
- (NSTimer *)createTimer {
    return [NSTimer scheduledTimerWithTimeInterval:1.0
                                            target:self
                                          selector:@selector(timerTicked:)
                                          userInfo:nil
                                           repeats:YES];
}

- (void)timerTicked:(NSTimer *)timer {
    _currentTimeInSeconds++;
    
    if(_vpnManager.connection.status == NEVPNStatusConnected){
        self.lbTime.text = [self formattedTime:_currentTimeInSeconds];
    }else{
        if(_vpnManager.connection.status == NEVPNStatusDisconnected){
            _lbTime.text = @"";
//            _status.text = NSLocalizedString(@"home_discon", nil);
        }else{
           if(_vpnManager.connection.status == NEVPNStatusDisconnecting){
//               _status.text = NSLocalizedString(@"home_discon", nil);
           }else{
               _lbTime.text = @"";
//               _status.text = NSLocalizedString(message, nil);
           }
        }
    }
}

-(void)fetchAvailableProducts {
   NSSet *productIdentifiers = [NSSet setWithObjects:@"Hippo",nil];
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

-(void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
   for (SKPaymentTransaction *transaction in transactions) {
      switch (transaction.transactionState) {
         case SKPaymentTransactionStatePurchasing:
            NSLog(@"Purchasing");
         break;
         
         case SKPaymentTransactionStatePurchased:
            NSLog(@"Purchased ");
            [self saveCreateTimeExpires];
            _lbStatus.text = @"PURCHASED";
            if(isWaitConnect){
                isWaitConnect = false;
                [self connect];
            }
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
            _lbStatus.text = @"PURCHASE FAILED";
            [_btnConnect setTitle:@"CONNECT" forState:UIControlStateNormal];
            [[NSUserDefaults standardUserDefaults] setObject: [NSNumber numberWithBool:NO] forKey:@"isSubbed"];
            break;
          default:
              [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
              break;
      }
   }
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
    [[NSUserDefaults standardUserDefaults] setObject: [NSNumber numberWithBool:YES] forKey:@"isSubbed"];
    UIAlertView *tmp = [[UIAlertView alloc]
       initWithTitle:@"Restore success"
       message:@""
       delegate:self
       cancelButtonTitle:nil
       otherButtonTitles:@"Ok", nil];
       [tmp show];
//    for (SKPaymentTransaction *transaction in queue.transactions) {
//        NSLog(@"%@", transaction.payment.productIdentifier);
//    }
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error {
    [[NSUserDefaults standardUserDefaults] setObject: [NSNumber numberWithBool:NO] forKey:@"isSubbed"];
    UIAlertView *tmp = [[UIAlertView alloc] initWithTitle:@"Restore failure" message: error.localizedDescription delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
       [tmp show];
}

- (BOOL) loadExpireDate{
    NSUserDefaults *myDefaults = [[NSUserDefaults alloc]
    initWithSuiteName:[Util getAppGroup]];
    
    NSString *time = [myDefaults objectForKey:@"time"];
    
    if(time != nil){

        NSDateFormatter *dateFormat2 = [[NSDateFormatter alloc] init];
        [dateFormat2 setDateFormat:@"YYYY-MM-dd'T'HH:mm:ssZZZ"];
        [dateFormat2 setTimeZone:[NSTimeZone timeZoneWithName:@"Australia/Melbourne"]];
        
        NSDate *dte = [dateFormat2 dateFromString:time];
        
        if([[NSDate date] compare: dte] == NSOrderedAscending)
        {
            return true;
            
        }else{
            return false;
        }
    }
    
    return false;
}

- (void) saveCreateTimeExpires{
    NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
    dayComponent.day = 365 + 3;
    
    NSCalendar *theCalendar = [NSCalendar currentCalendar];
    NSDate *nextDate = [theCalendar dateByAddingComponents:dayComponent toDate:[NSDate date] options:0];
    
    
    NSDateFormatter *dateFormat2 = [[NSDateFormatter alloc] init];
    [dateFormat2 setDateFormat:@"YYYY-MM-dd'T'HH:mm:ssZZZ"];
    [dateFormat2 setTimeZone:[NSTimeZone timeZoneWithName:@"Australia/Melbourne"]];
    
    NSString *dateString = [dateFormat2 stringFromDate:nextDate];
    
    NSUserDefaults *myDefaults = [[NSUserDefaults alloc]
                                   initWithSuiteName:[Util getAppGroup]];
     [myDefaults setObject:dateString forKey:@"time"];
     [myDefaults synchronize];
}

-(void)productsRequest:(SKProductsRequest *)request
didReceiveResponse:(SKProductsResponse *)response {
   SKProduct *validProduct = nil;
   int count = [response.products count];
   
   if (count>0) {
      validProducts = response.products;
      validProduct = [response.products objectAtIndex:0];
       loadingIAP = true;
       NSLog(@"Product Title: %@",validProduct.localizedTitle);
       NSLog(@"Product Desc: %@",validProduct.localizedDescription);
       NSLog(@"Product Price: %@",validProduct.price);
   } else {
      UIAlertView *tmp = [[UIAlertView alloc]
         initWithTitle:@"Not Available"
         message:@"No products load to purchase"
         delegate:self
         cancelButtonTitle:nil
         otherButtonTitles:@"Ok", nil];
         [tmp show];
   }
   
}

#pragma OpenVPN
- (void)initVPNTunnelProviderManager{
    NSString *tunnelBundleId = @"co.oliver.vpn.PacketTunnel"; // Bundle of Extension
    
    [NETunnelProviderManager loadAllFromPreferencesWithCompletionHandler:^(NSArray* newManagers, NSError *error)
     {
         if(error != nil){
             NSLog(@"Load Preferences error: %@", error);
         }else{
             if([newManagers count] > 0)
             {
                 vpnManager = newManagers[0];
             }else{
                 vpnManager = [[NETunnelProviderManager alloc] init];
             }
             
             [vpnManager loadFromPreferencesWithCompletionHandler:^(NSError *error){
                 if(error != nil){
                     NSLog(@"Load Preferences error: %@", error);
                 }else{
                     __block NETunnelProviderProtocol *protocol = [[NETunnelProviderProtocol alloc] init];
                     protocol.providerBundleIdentifier = tunnelBundleId;
                     // get file
                     NSString *path = [[NSBundle mainBundle] pathForResource:@"client" ofType:@"ovpn"];
                     NSString* content;
                     NSString *username = @"0435383557702149";
                     NSString *password = @"VQ2Frron";
                     protocol.serverAddress = @"hippovpn";
                     
                     content = [NSString stringWithContentsOfFile:path
                                                         encoding:NSUTF8StringEncoding
                                                            error:NULL];
                     
                     protocol.providerConfiguration = @{@"content": content, @"username": username, @"password": password}; // you can send username/password in here
                     vpnManager.protocolConfiguration = protocol;
                     vpnManager.localizedDescription = @"VPN";
                     [vpnManager setEnabled:true];
                     [vpnManager saveToPreferencesWithCompletionHandler:^(NSError *error){
                         if (error != nil) {
                             NSLog(@"Save to Preferences Error: %@", error);
                         }else{
                             NSLog(@"Save successfully");
                             [self openTunnel];
                         }
                     }];
                 }}];
         }
         
     }];
}

- (void) connectOpenVPN{
    NSUserDefaults *userdefault = [[NSUserDefaults alloc]
                                   initWithSuiteName:[Util getAppGroup]];
    [userdefault setObject:@"NONE" forKey:@"auth"];
    
    if(isConnect){
        [vpnManager.connection stopVPNTunnel];
        [_btnConnect setTitle:@"CONNECT" forState:UIControlStateNormal];
        _imgStatus.image = [UIImage imageNamed:@"Cross.png"];
        _imgLogo.image = [UIImage imageNamed:@"RED.png"];
        isConnect = false;
    }else{
        if([self loadExpireDate]){
            _lbStatus.text = @"CONNECTING";
            [_btnConnect setTitle:@"CONNECTING" forState:UIControlStateNormal];
            [self connectCoreOpenVPN];
        }else{
            if(!loadingIAP){
                // still load
                UIAlertController * alert = [UIAlertController
                                             alertControllerWithTitle:@"ERROR"
                                             message:@"Loading IAP, please try again after a few seconds"
                                             preferredStyle:UIAlertControllerStyleAlert];
                
                //Add Buttons
                
                UIAlertAction* yesButton = [UIAlertAction
                                            actionWithTitle:NSLocalizedString(@"yes", nil)
                                            style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * action) {
                                                //Handle your yes please button action here
                                            }];
                [alert addAction:yesButton];
                [self presentViewController:alert animated:YES completion:nil];
            }else{
                BOOL isSubbed = [[[NSUserDefaults standardUserDefaults]
                objectForKey:@"isSubbed"] boolValue];
                if(isSubbed == NO) {
                    SubscribeVC *subscribeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SubscribeVCID"];
                    [self.navigationController pushViewController:subscribeVC animated:YES];
                } else {
                    [self connectCoreOpenVPN];
                }
            }
        }
    }
}

- (void) connectCoreOpenVPN{
    _lbStatus.text = @"CONNECTING";
    [_btnConnect setTitle:@"DISCONNECT" forState:UIControlStateNormal];
    
    dispatch_async(self.coreVPN, ^{
        [self initVPNTunnelProviderManager];
    });
    dispatch_async(self.queue, ^{
        int index = 0;
        while (true) {
            index ++;
            if(index == 20){
                // Time out
                UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Notify"
                                                                               message:@"VPN can't start. Pls try again"
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                      handler:^(UIAlertAction * action) {}];
                
                [alert addAction:defaultAction];
                [self presentViewController:alert animated:YES completion:nil];
                [vpnManager.connection stopVPNTunnel];
                _lbStatus.text = @"VPN DISCONNECTED";
                [_btnConnect setTitle:@"CONNECT" forState:UIControlStateNormal];
                _imgStatus.image = [UIImage imageNamed:@"Cross.png"];
                _imgLogo.image = [UIImage imageNamed:@"RED.png"];
                break;
            }
            sleep(2);
            NSLog(@"======>NULL---");
            NSUserDefaults *myDefaults = [[NSUserDefaults alloc]
                                          initWithSuiteName:[Util getAppGroup]];
            NSString *message = [myDefaults objectForKey:@"auth"];
            if(![message isEqualToString:@"NONE"]){
                if([message isEqualToString:@"COMPLETE"]){
                    
                    dispatch_async(dispatch_get_main_queue(), ^(){
                        NSLog(@"COMPLETE");
//
//                            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Notification"
//                                                                                           message:@"VPN is started"
//                                                                                    preferredStyle:UIAlertControllerStyleAlert];
//
//                            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
//                                                                                  handler:^(UIAlertAction * action) {}];
//
//                            [alert addAction:defaultAction];
//                            [self presentViewController:alert animated:YES completion:nil];
//
                        isConnect = true;
                        
//                            [_btnConnect setTitle:@"DISCONNECT" forState:UIControlStateNormal];
                        _lbStatus.text = @"VPN CONNECTED";
                        [_btnConnect setTitle:@"DISCONNECT" forState:UIControlStateNormal];
                        
                        _imgStatus.image = [UIImage imageNamed:@"Group.png"];
                        _imgLogo.image = [UIImage imageNamed:@"Green.png"];

                    });
                    
                    
                }else{
                    
                    dispatch_async(dispatch_get_main_queue(), ^(){
                        // ERROR
                        [vpnManager.connection stopVPNTunnel];
                        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"ERROR"
                                                                                       message:message
                                                                                preferredStyle:UIAlertControllerStyleAlert];
                        
                        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                              handler:^(UIAlertAction * action) {}];
                        
                        [alert addAction:defaultAction];
                        [self presentViewController:alert animated:YES completion:nil];
                        [vpnManager.connection stopVPNTunnel];
                        isConnect = false;
                        //_tfLog.text = message;
                        _lbStatus.text = @"VPN DISCONNECTED";
                        [_btnConnect setTitle:@"CONNECT" forState:UIControlStateNormal];
                        _imgStatus.image = [UIImage imageNamed:@"Cross.png"];
                        _imgLogo.image = [UIImage imageNamed:@"RED.png"];
                    });
                    
                }
                break;
            }
        }
        NSLog(@"END END END");
        
    });
}

- (void) openTunnel{
    [vpnManager loadFromPreferencesWithCompletionHandler:^(NSError *error){
        if(error != nil){
            NSLog(@"%@", error);
        }else{
            NSError *startError = nil;
            [vpnManager.connection startVPNTunnelWithOptions:nil andReturnError:&startError];
            if(startError != nil){
                NSLog(@"%@", startError);
            }else{
                NSLog(@"Complete");
            }
        }
    }];
}

@end
