//
//  Util.h
//  NETExtension
//Oliver2017!
//Admin@e-vpn.co.uk
//  Created by CYTECH on 7/1/18.
//  Copyright © 2018 Tran Viet Anh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

static NSString *URL_GET_HOUSE_INFO = @"static-info/get-all";
static NSString *URL_GET_ADDRRESS_INFO = @"dia-chis";
static NSString *URL_SUBMIT = @"bds-submit/submit";
static NSString *URL_SUBMIT_ANH_KHAC = @"upload-images-in-data-collection";
static NSString *URL_UPLOAD_IMG = @"bds-image/upload-image";
static NSString *URL_RE_SUBMIT = @"bds-submit/re-submit";
static NSString *TEXT_COLOR_SUCCESS = @"#EB9022";
static NSString *URL_SEARCH = @"bat-dong-sans/search?page=0&size=5&sort=id,desc";
static NSString *URL_UPLOAD_IMAGE_MORE = @"upload-more-images";
static NSString *URL_GET_XULYLAI = @"bat-dong-sans/get-not-enough-condition-from-user";
static NSString *URL_GET_MOREINFO = @"bat-dong-sans/statistics-for-submit-user";
static NSString *URL_GET_STATIC_CONFIG = @"app-config/get-mobile-config";
static NSString *URL_LOGIN = @"authenticate";
static NSString *URL_SIGNIN = @"register";
static NSString *URL_LOAI_CAU_HINH = @"loai-cau-hinh";
static NSString *URLCOUNTBDSSUBMIT = @"bat-dong-sans/count-bds-submit";
static NSString *URL_HO_SO_YEU_CAU = @"trang-thai-ho-so-yeu-cau-tham-dinh";
static NSString *URL_GET_STATIC_INFO = @"static-info/get-all-with-tinh";

static NSString *URL_GET_GPS = @"bds-submit/get-bds-from-gps";
// For
static NSString *CONTENT_CAN_BO_NHAP_LIEU = @"Cán bộ nhập liệu";
static NSString *CONTENT_CAN_BO_KIEM_TRA_DU_LIEU = @"Cán bộ nhập liệu";
static NSString *CONTENT_CAN_BO_THUC_DIA = @"Cán bộ thẩm định giá tại nhà khách hàng";
//static NSString *APP_GROUP = @"group.co.uk.evpn.ovpn";
NSString static *APP_GROUP = @"group.co.oliver.vpn";
@interface Util : NSObject
+ (NSString *) getURLEVALUCATION;
+ (NSString *) getAppGroup;
+ (BOOL) writeStringToFile:(NSString *)aString name_file:(NSString *) file_name;
    +(NSString *)readStringFromFile:(NSString *)file_name;
    +(NSArray *) getAllFileInPath;
+ (UIColor *) colorWithHexString:(NSString *)hexStr;
+ (NSString *) getUUID:(NSString *) data;
+ (NSString *) downOvpnByQrCode:(NSString *) wan_ip code:(NSString *) code username:(NSString *) user pwd:(NSString *) pass session:(NSString *) PHPSession;
+ (void) setVPNProfileCurrentEdit:(NSString *) fileName;
+ (NSString *) getVPNProfileCurrentEdit;
+ (void) deleteVPNProfileCurrentEdit;
+ (Boolean) removeVPNProfile:(NSString *) fileName;
+ (BOOL)isVPNConnected;
+ (NSString *)getIPAddress;
+ (NSString *) getIPVPN;
+ (BOOL) pingToIP:(NSString *) ipDst;

+ (NSString *) getDataFrom:(NSString *)url;
+ (NSString *) getUTCCurrentTime;

//+ (NSString *) getServerAddress;
+ (NSString *) getServerAddress;
+ (void) saveToAppGroup:(NSString *) key value:(NSString *) values;
+ (NSString *) loadFromAppGroup:(NSString *) key;

+ (NSString *)encodeUIImageToBase64String:(UIImage *)image;
+ (NSString *) saveImgToDocument:(UIImage *) img;
+ (UIImage *) loadImgFromDocument:(NSString *) fullPath;
+ (void) deleteFile:(NSString *) path;
+(bool) isNumeric:(NSString*) checkText;
+ (NSString *) showText:(NSString *) str;
//+ (NSString *) getServerImg;
+ (BOOL) checkNetwork;
+ (NSString *) getURLDATACOLLECTION;
+ (NSString *) getURLAUTHEN;

+ (NSString *) exportEventLog;
+ (Boolean) checkFreeSpace;

+ (NSString *) getVersionName;
+ (NSString *) getUserAgent;
@end
