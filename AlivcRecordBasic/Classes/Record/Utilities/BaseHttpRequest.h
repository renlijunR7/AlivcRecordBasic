//
//  BaseHttpRequest.h
//  boluolicai
//
//  Created by 张松超 on 15/11/21.
//  Copyright © 2015年 Pusupanshi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServiceGeneral.h"


@interface BaseHttpRequest : NSObject

/**
 *  HttpPost请求
 *
 *  @param path         API地址
 *  @param params       加密的参数字典
 *  @param loading      是否需要loading框
 *  @param encrypted    是否加密
 *  @param sign         是否签名
 *  @param ignores      不加密的字典
 *  @param success      成功返回结果
 *  @param fail         失败返回结果
 */

- (void)PostApiAddress:(NSString *)apiAddress
           withLoading:(BOOL)loading
            postParams:(NSMutableDictionary *)params
               success:(void (^)(NSDictionary *successDict))success
               failure:(void (^)(NSDictionary *failDict))failure
                 error:(void (^)(NSDictionary *errorDict))dealError;

@end
