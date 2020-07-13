//
//  Util.m
//  NETExtension
//
//  Created by CYTECH on 7/1/18.
//  Copyright © 2018 Tran Viet Anh. All rights reserved.
//

#import "Util.h"
#import <CommonCrypto/CommonDigest.h>
#include <ifaddrs.h>
#include <arpa/inet.h>
#include <SystemConfiguration/SystemConfiguration.h>
#import <sys/utsname.h>
@implementation Util

// For IP

+ (NSString *) getDataFrom:(NSString *)url{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"GET"];
    [request setURL:[NSURL URLWithString:url]];
    
    NSError *error = nil;
    NSHTTPURLResponse *responseCode = nil;
    
    NSData *oResponseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];
    
    if([responseCode statusCode] != 200){
        NSLog(@"Error getting %@, HTTP status code %li", url, (long)[responseCode statusCode]);
        return nil;
    }
    
    return [[NSString alloc] initWithData:oResponseData encoding:NSUTF8StringEncoding];
}

//NSString static *APP_GROUP = @"group.vn.cen.gtech";

//NSString static *NE_BUNDLE_ID = @"vn.cen.gtech.PacketTunnel";

+ (NSString *) getAppGroup{
    return APP_GROUP;
}


+ (Boolean) removeVPNProfile:(NSString *) fileName{
    if(![fileName containsString:@".ovpn"]){
        [fileName stringByAppendingString:@".opvn"];
    }
    NSString *destinationPath = [[[[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:[Util getAppGroup]] path] stringByAppendingPathComponent:fileName];
    [[NSFileManager defaultManager] removeItemAtPath:destinationPath error:nil];
    return true;
}

+ (BOOL) writeStringToFile:(NSString *)aString name_file:(NSString *) file_name{
    NSString *destinationPath = [[[[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:[Util getAppGroup]] path] stringByAppendingPathComponent:file_name];
    NSError* error;
    // save to file
    
    [aString writeToURL:destinationPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if(error){
        NSLog(@"==>%@", error);
        return false;
    }
    return true;
    
}

+ (BOOL)isVPNConnected
{
    NSDictionary *dict = CFBridgingRelease(CFNetworkCopySystemProxySettings());
    NSArray *keys = [dict[@"__SCOPED__"]allKeys];
    for (NSString *key in keys) {
        if ([key rangeOfString:@"tun"].location != NSNotFound){
            return YES;
        }
    }
    return NO;
}

+(NSString *)readStringFromFile:(NSString *)file_name{
    NSString *destinationPath = [[[[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:[Util getAppGroup]] path] stringByAppendingPathComponent:file_name];
    
    return [[NSString alloc] initWithData:[NSData dataWithContentsOfFile:destinationPath] encoding:NSUTF8StringEncoding];
}
+(NSArray *) getAllFileInPath{
    NSString *filePath = [[[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:[Util getAppGroup]] path];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    NSArray *fileList = [manager contentsOfDirectoryAtPath:filePath
                                                     error:nil];
    //--- Listing file by name sort
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for(int i =0; i < [fileList count]; i++){
        NSString *temp = fileList[i];
        if([temp containsString:@"ovpn"]){
            [result addObject:temp];
        }
    }
    
    NSLog(@"%@", result);
    return result;
}

+ (NSString *) showText:(NSString *) str{
    str = [@"  " stringByAppendingString:str];
    
    NSString *result = str;
    if(str.length > 35)
    {
        result = [result substringToIndex:26];
        result  = [result stringByAppendingString:@"..."];
        return result;
    }
    else{
        for(int i =0; i< 35 - str.length; i++){
            result = [result stringByAppendingString:@" "];
        }
        return result;
    }
}

+ (NSString *)getIPAddress {
    
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                    
                }
                
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
    
}

+ (BOOL) pingToIP:(NSString *) ipDst{
    bool success = false;
    const char *host_name = [ipDst
                             cStringUsingEncoding:NSASCIIStringEncoding];
    
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL,
                                                                                host_name);
    SCNetworkReachabilityFlags flags;
    success = SCNetworkReachabilityGetFlags(reachability, &flags);
    
    //prevents memory leak per Carlos Guzman's comment
    CFRelease(reachability);
    
    bool isAvailable = success && (flags & kSCNetworkFlagsReachable) &&
    !(flags & kSCNetworkFlagsConnectionRequired);
    if (isAvailable) {
        NSLog(@"Host is reachable: %d", flags);
    }else{
        NSLog(@"Host is unreachable");
    }
    return isAvailable;
}

+ (NSString *) getIPVPN{
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if( temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"utun1"])
                {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                    NSLog(@"ifaName: %@, Address: %@",[NSString stringWithUTF8String:temp_addr->ifa_name],address);
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    // Free memory
    freeifaddrs(interfaces);
    
    return address;
}
+ (UIColor *)colorWithHex:(UInt32)color andAlpha:(float)alpha
{
    unsigned char r, g, b;
    b = color & 0xFF;
    g = (color >> 8) & 0xFF;
    r = (color >> 16) & 0xFF;
    return [UIColor colorWithRed:(float)r/255.0f green:(float)g/255.0f blue:(float)b/255.0f alpha:alpha];
}

+ (UIColor *)colorWithHexString:(NSString *)hexStr
{
    float alpha;
    NSString *newHexStr;
    NSCharacterSet *cSet = [NSCharacterSet characterSetWithCharactersInString:@"/-_,~^*&\\ "];
    if(![hexStr hasPrefix:@"#"]) hexStr = [NSString stringWithFormat:@"#%@", hexStr];
    if([hexStr rangeOfCharacterFromSet:cSet].location != NSNotFound) {
        
        NSScanner *scn = [NSScanner scannerWithString:hexStr];
        [scn scanUpToCharactersFromSet:cSet intoString:&newHexStr];
        alpha = [[[hexStr componentsSeparatedByCharactersInSet:cSet] lastObject] floatValue];
        
    } else {
        
        newHexStr = hexStr;
        alpha = 1.0f;
        
    }
    
    const char *cStr = [newHexStr cStringUsingEncoding:NSASCIIStringEncoding];
    long x = strtol(cStr+1, NULL, 16);
    return [self colorWithHex:x andAlpha:alpha];
}

+ (NSString *) getUUID:(NSString *) data1{
    NSData* data = [data1 dataUsingEncoding:NSUTF8StringEncoding];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, data.length, digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
    {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
}

+ (NSString *) downOvpnByQrCode:(NSString *) wan_ip code:(NSString *) code username:(NSString *) user pwd:(NSString *) pass session:(NSString *) PHPSession{
    
    NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@:8082/mobilevpn/mobileKey.php",wan_ip, nil]]];
    NSString *userUpdate =[NSString stringWithFormat:@"acct=%@&password=%@&authimage=%@",user,pass,code, nil];
    
    //create the Method "GET" or "POST"
    [urlRequest setHTTPMethod:@"POST"];
    
    //Convert the String to Data
    NSData *data1 = [userUpdate dataUsingEncoding:NSUTF8StringEncoding];
    
    //Apply the data to the body
    [urlRequest setHTTPBody:data1];
    //NSString *cookie;
    //NSRange begin = [cookie rangeOfString:@"PHPSESSID"];
    //NSRange next = [cookie rangeOfString:@";"];
    //NSString *sub = [cookie substringWithRange:NSMakeRange(begin.location, next.location - begin.location)];
    //NSString *string1 = [cookie substringWithRange:NSMakeRange(@"Cookie: PHPSESSID".length, @"Cookie: PHPSESSID=39nt5tv9fjbnnav8ku8jul0e53".length)];
    [urlRequest setValue:PHPSession forHTTPHeaderField:@"cookie"];
    NSLog(@"%@", PHPSession);
    //NSURLSession *session = [NSURLSession sharedSession];
    static BOOL isComplete = false;
    NSURLSession *session = [NSURLSession sharedSession];
    __block NSString *ovpn = nil;
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if(httpResponse.statusCode == 200)
        {
            NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"OVPN: %@",str);
            ovpn = str;
        }
        else
        {
            NSLog(@"Error");
        }
        isComplete = true;
    }];
    [dataTask resume];
    return ovpn;
    
}

+ (NSString *) getVPNProfileCurrentEdit{
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:[Util getAppGroup]];
    NSString *data = [defaults objectForKey:@"current_profile_edit"];
    return data;
}

+ (void) setVPNProfileCurrentEdit:(NSString *) fileName{
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:[Util getAppGroup]];
    [defaults setObject:fileName forKey:@"current_profile_edit"];
}

+ (void) deleteVPNProfileCurrentEdit{
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:[Util getAppGroup]];
    [defaults removeObjectForKey:@"current_profile_edit"];

}

+ (NSString *) getVersionName{
    return @"1.8";
}



static NSString *userAgent = nil;

+ (NSString*) deviceName
{
    struct utsname systemInfo;
    
    uname(&systemInfo);
    
    NSString* code = [NSString stringWithCString:systemInfo.machine
                                        encoding:NSUTF8StringEncoding];
    
    static NSDictionary* deviceNamesByCode = nil;
    
    if (!deviceNamesByCode) {
        
        deviceNamesByCode = @{@"i386"      : @"Simulator",
                              @"x86_64"    : @"Simulator",
                              @"iPod1,1"   : @"iPod Touch",        // (Original)
                              @"iPod2,1"   : @"iPod Touch",        // (Second Generation)
                              @"iPod3,1"   : @"iPod Touch",        // (Third Generation)
                              @"iPod4,1"   : @"iPod Touch",        // (Fourth Generation)
                              @"iPod7,1"   : @"iPod Touch",        // (6th Generation)
                              @"iPhone1,1" : @"iPhone",            // (Original)
                              @"iPhone1,2" : @"iPhone",            // (3G)
                              @"iPhone2,1" : @"iPhone",            // (3GS)
                              @"iPad1,1"   : @"iPad",              // (Original)
                              @"iPad2,1"   : @"iPad 2",            //
                              @"iPad3,1"   : @"iPad",              // (3rd Generation)
                              @"iPhone3,1" : @"iPhone 4",          // (GSM)
                              @"iPhone3,3" : @"iPhone 4",          // (CDMA/Verizon/Sprint)
                              @"iPhone4,1" : @"iPhone 4S",         //
                              @"iPhone5,1" : @"iPhone 5",          // (model A1428, AT&T/Canada)
                              @"iPhone5,2" : @"iPhone 5",          // (model A1429, everything else)
                              @"iPad3,4"   : @"iPad",              // (4th Generation)
                              @"iPad2,5"   : @"iPad Mini",         // (Original)
                              @"iPhone5,3" : @"iPhone 5c",         // (model A1456, A1532 | GSM)
                              @"iPhone5,4" : @"iPhone 5c",         // (model A1507, A1516, A1526 (China), A1529 | Global)
                              @"iPhone6,1" : @"iPhone 5s",         // (model A1433, A1533 | GSM)
                              @"iPhone6,2" : @"iPhone 5s",         // (model A1457, A1518, A1528 (China), A1530 | Global)
                              @"iPhone7,1" : @"iPhone 6 Plus",     //
                              @"iPhone7,2" : @"iPhone 6",          //
                              @"iPhone8,1" : @"iPhone 6S",         //
                              @"iPhone8,2" : @"iPhone 6S Plus",    //
                              @"iPhone8,4" : @"iPhone SE",         //
                              @"iPhone9,1" : @"iPhone 7",          //
                              @"iPhone9,3" : @"iPhone 7",          //
                              @"iPhone9,2" : @"iPhone 7 Plus",     //
                              @"iPhone9,4" : @"iPhone 7 Plus",     //
                              @"iPhone10,1": @"iPhone 8",          // CDMA
                              @"iPhone10,4": @"iPhone 8",          // GSM
                              @"iPhone10,2": @"iPhone 8 Plus",     // CDMA
                              @"iPhone10,5": @"iPhone 8 Plus",     // GSM
                              @"iPhone10,3": @"iPhone X",          // CDMA
                              @"iPhone10,6": @"iPhone X",          // GSM
                              @"iPhone11,2": @"iPhone XS",         //
                              @"iPhone11,4": @"iPhone XS Max",     //
                              @"iPhone11,6": @"iPhone XS Max",     // China
                              @"iPhone11,8": @"iPhone XR",         //
                              @"iPad4,1"   : @"iPad Air",          // 5th Generation iPad (iPad Air) - Wifi
                              @"iPad4,2"   : @"iPad Air",          // 5th Generation iPad (iPad Air) - Cellular
                              @"iPad4,4"   : @"iPad Mini",         // (2nd Generation iPad Mini - Wifi)
                              @"iPad4,5"   : @"iPad Mini",         // (2nd Generation iPad Mini - Cellular)
                              @"iPad4,7"   : @"iPad Mini",         // (3rd Generation iPad Mini - Wifi (model A1599))
                              @"iPad6,7"   : @"iPad Pro (12.9\")", // iPad Pro 12.9 inches - (model A1584)
                              @"iPad6,8"   : @"iPad Pro (12.9\")", // iPad Pro 12.9 inches - (model A1652)
                              @"iPad6,3"   : @"iPad Pro (9.7\")",  // iPad Pro 9.7 inches - (model A1673)
                              @"iPad6,4"   : @"iPad Pro (9.7\")"   // iPad Pro 9.7 inches - (models A1674 and A1675)
                              };
    }
    
    NSString* deviceName = [deviceNamesByCode objectForKey:code];
    
    if (!deviceName) {
        deviceName = @"Unknown";
    }
    
    return deviceName;
}
// TODO maybe error in here
+ (NSString *) getUserAgent{
    // TODO
    if(userAgent == nil){
        NSString *model = [Util deviceName];
        float versionIOS = [[[UIDevice currentDevice] systemVersion] floatValue];
        userAgent = [NSString stringWithFormat:@"Ios@iphone@%@@%f@%@", model, versionIOS, [Util getVersionName]];
    }
    
    return userAgent;
}

/*+ (NSString *) getServerImg{
 //return @"http://27.72.31.96:80";
 //return @"http://192.168.3.137:9999";
 
 return @"http://api.giasan.vn";
 }
 */

+ (NSString *) getServerAddress{
    //return @"http://27.72.31.96:8000/";
    return @"http://172.16.100.61:8000/";
   //return @"https://api.giasan.vn/";
}

+ (NSString *) getURLEVALUCATION{
    //return @"g-evaluation/v1/api/v1/";
    return @"g-data-collection/dev/api/";
}

+ (NSString *) getURLDATACOLLECTION{
   //return @"g-data-collection/v1/api/";
   return @"g-data-collection/dev/api/";
}

+ (NSString *) getURLAUTHEN{
   //return @"g-auth/v1/api/";
   return @"g-auth/dev/api/";
}

+ (NSString *) getUTCCurrentTime{
    NSTimeZone *timeZone = [NSTimeZone defaultTimeZone];
    // or Timezone with specific name like
    NSDate *currentDate = [[NSDate alloc] init];
    // [NSTimeZone timeZoneWithName:@"Europe/Riga"] (see link below)
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:timeZone];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    NSString *localDateString = [dateFormatter stringFromDate:currentDate];
    return localDateString;
}

+ (void) saveToAppGroup:(NSString *) key value:(NSString *) values{
    NSUserDefaults *myDefaults = [[NSUserDefaults alloc]
                                  initWithSuiteName:[Util getAppGroup]];
    
    [myDefaults setObject:values forKey:key];
}
+ (NSString *) loadFromAppGroup:(NSString *) key{
    NSUserDefaults *myDefaults = [[NSUserDefaults alloc]
                                  initWithSuiteName:[Util getAppGroup]];
    
    return [myDefaults objectForKey:key];
}


//+ (Boolean) 
+ (NSString *)encodeUIImageToBase64String:(UIImage *)image {
    NSString *string = [UIImagePNGRepresentation(image) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    string = [string stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
    return string;
}


+ (NSString *) saveImgToDocument:(UIImage *) img{
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory=[paths objectAtIndex:0];
    NSString *filePath  = [documentDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", [[NSProcessInfo processInfo] globallyUniqueString]]];
    
   // NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    //NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:]];
    [UIImagePNGRepresentation(img) writeToFile:filePath atomically:YES];
    
    return filePath;
}

+ (UIImage *) loadImgFromDocument:(NSString *) fullPath{
    NSData *imgData = [[NSData alloc] initWithContentsOfFile:fullPath];
    
    UIImage *img = [[UIImage alloc] initWithData:imgData];
    return img;
}

+ (void) deleteFile:(NSString *) path{
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
}


+ (bool) isNumeric:(NSString*) stringValue{
    bool result = false;
    
    NSString *decimalRegex = @"^(?:|-)(?:|0|[1-9]\\d*)(?:\\.\\d*)?$";
    NSPredicate *regexPredicate =
    [NSPredicate predicateWithFormat:@"SELF MATCHES %@", decimalRegex];
    
    if ([regexPredicate evaluateWithObject: stringValue]){
        //Matches
        result = true;
    }
    
    return result;
}

+ (NSString *) exportEventLog{
    return [self loadFromAppGroup:@"eventlog"];
}

+ (Boolean) checkFreeSpace{
    NSDictionary* fileAttributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:@"/"
                                                                                           error:nil];
    unsigned long long freeSpace = [[fileAttributes objectForKey:NSFileSystemFreeSize] longLongValue];
    
    //NSLog(@"free disk space: %lluGB", (freeSpace / 1073741824));
    NSLog(@"free disk space: %lluGB", freeSpace);
    if(freeSpace - 524288000 <= 0){
        // Nhỏ hơn 500Mb
        return false;
    }else{
        //
        return true;
    }
    
    //float abc = freeSpace / 1073741824;
}

@end
