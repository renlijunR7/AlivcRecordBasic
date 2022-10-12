//
//  HttpPresenter.m
//  boluolicai
//
//  Created by 张松超 on 15/11/23.
//  Copyright © 2015年 Pusupanshi. All rights reserved.
//

#import "HttpPresenter.h"
#import <sys/utsname.h>
#import <CommonCrypto/CommonDigest.h>
@implementation HttpPresenter

CLASS_DEF_SINGLETON(HttpPresenter);



-(void)PostApiAddress:(NSString*)url postParams:(NSMutableDictionary*)postParams success:(HttpSuccessHandler)result failure:(HttpFailHandler)failure {
    
    [self PostApiAddress:url withLoading:NO  postParams:postParams success:^(NSDictionary *successDict) {
        if (result) {
            result(successDict);
        }
    } failure:^(NSDictionary *failDict) {
        if (failure) {
            failure(failDict);
        }
    } error:^(NSDictionary *errorDict) {
        if (failure) {
            failure(errorDict);
        }
    }];
}

-(void)ImagePostApiAddress:(NSString*)url postParams:(NSMutableDictionary*)postParams success:(HttpSuccessHandler)result failure:(HttpFailHandler)failure{
    
    [self PostImgaeApiAddress:url withLoading:NO  postParams:postParams success:^(NSDictionary *successDict) {
        if (result) {
            result(successDict);
        }
    } failure:^(NSDictionary *failDict) {
        if (failure) {
            failure(failDict);
        }
    } error:^(NSDictionary *errorDict) {
        if (failure) {
            failure(errorDict);
        }
    }];
}


@end
