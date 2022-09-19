//
//  CommonMacro.h
//  boluolicai
//
//  Created by 张松超 on 15/11/5.
//  Copyright © 2015年 Pusupanshi. All rights reserved.
//

#ifndef CommonMacro_h
#define CommonMacro_h

#define APPName             @"乐唰"
#define APPVersion          [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]


#define PROPRETY_ASSIGN     @property(nonatomic,assign)
#define PROPRETY_STRONG     @property(nonatomic,strong)
#define PROPRETY_COPY       @property(nonatomic,copy)
#define PROPRETY_WEAK       @property(nonatomic,weak)




/*================================================================*/
#define CLASS_AS_SINGLETON( __class ) \
+ (__class *)sharedInstance;

#undef	CLASS_DEF_SINGLETON
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


#define APP_DELEGATE    (AppDelegate*)[[UIApplication sharedApplication] delegate]
#define HttpApi         [HttpPresenter sharedInstance]



#define ShowLoading     [[UWAlertManager sharedInstance] showLoadingWithMsg:@"正在加载..."]
#define HideLoading     [[UWAlertManager sharedInstance] hideHud]
#define ShowHud(Msg)    [[UWAlertManager sharedInstance] showHud:Msg]

#if DEBUG
#define NSLog(format, ...) NSLog(format, ## __VA_ARGS__)
#else
#define NSLog(format, ...)
#endif

#endif /* CommonMacro_h */
