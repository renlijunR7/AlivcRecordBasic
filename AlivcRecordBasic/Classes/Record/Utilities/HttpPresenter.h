//
//  HttpPresenter.h
//  boluolicai
//
//  Created by 张松超 on 15/11/23.
//  Copyright © 2015年 Pusupanshi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseHttpRequest.h"

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



typedef void(^HttpSuccessHandler)(NSDictionary *resultDict);
typedef void(^HttpFailHandler)(NSDictionary *failureDict);


@interface HttpPresenter : BaseHttpRequest

CLASS_AS_SINGLETON(HttpPresenter);

#define CHANNEL_ID @"0000"
 /**
 *  基类请求方法
 */
-(void)PostApiAddress:(NSString*)url postParams:(NSMutableDictionary*)postParams success:(HttpSuccessHandler)result failure:(HttpFailHandler)failure;



@end
