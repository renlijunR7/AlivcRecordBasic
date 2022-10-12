//
//  BLUser.h
//  boluolicai
//
//  Created by 张松超 on 15/11/24.
//  Copyright © 2015年 Pusupanshi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BLUser.h"

@interface BLUser : NSObject

/*================================================================*/
#define CLASS_AS_SINGLETON( __class ) \
+ (__class *)sharedInstance;

#undef    CLASS_DEF_SINGLETON
// #define CLASS_DEF_SINGLETON( __class,initBlock)
#define CLASS_DEF_SINGLETON( __class) \
+ (__class *)sharedInstance \
{ \
static dispatch_once_t once; \
static __class * __singleton__; \
dispatch_once( &once, ^{ __singleton__ = ([[__class alloc] init]); } ); \
return __singleton__; \
}
/*================================================================*/


CLASS_AS_SINGLETON(BLUser);

@property(nonatomic,strong) NSString *charset;
@property(nonatomic,strong) NSString *appVersion;
@property(nonatomic,strong) NSString *appType;
@property(nonatomic,strong) NSString *appName;
@property(nonatomic,strong) NSString *AcceptLanguage;
@property(nonatomic,strong) NSString *androidChannel;
@property(nonatomic,strong) NSString *appTheme;
@property(nonatomic,strong) NSString *appFixVersion;
@property(nonatomic,strong) NSString *deviceToken;
@property(nonatomic,strong) NSString *deviceName;
@property(nonatomic,strong) NSString *accessToken;
@property(nonatomic,strong) NSString *online;
@property(nonatomic,strong) NSString *signKey;

- (void)saveData;

- (void)loadData;

- (void)quitLogin;

@end
