//
//  BaseHttpRequest.m
//  boluolicai
//
//  Created by 张松超 on 15/11/21.
//  Copyright © 2015年 Pusupanshi. All rights reserved.
//

#import "BaseHttpRequest.h"
#import "AFNetworking.h"
#import "BLUser.h"
#define CC_MD5_DIGEST_LENGTH 16
#import <CommonCrypto/CommonCrypto.h>
#import "NSString+LKString.h"
#include <CommonCrypto/CommonDigest.h>


#define CurUser         [BLUser sharedInstance]
#define kStringFormat(format,...) [NSString stringWithFormat:format,##__VA_ARGS__]


@interface BaseHttpRequest ()

@property (nonatomic,strong) AFHTTPSessionManager * manager;

@end

@implementation BaseHttpRequest


- (void)PostApiAddress:(NSString *)apiAddress
           withLoading:(BOOL)loading
            postParams:(NSMutableDictionary *)params
               success:(void (^)(NSDictionary *successDict))success
               failure:(void (^)(NSDictionary *failDict))failure
                 error:(void (^)(NSDictionary *errorDict))dealError
{
    
    //if (loading){ShowLoading;};
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    AFHTTPRequestSerializer *requestSerializer =  [AFJSONRequestSerializer serializer];
    manager.requestSerializer = requestSerializer;
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/html",@"image/jpeg",@"image/png",@"application/octet-stream",@"text/json",nil];
    manager.requestSerializer.timeoutInterval = 10.0f;
    [manager.requestSerializer setValue:@"close" forHTTPHeaderField:@"Connection"];
    
    //添加Header
    [requestSerializer setValue:@"appVersion" forHTTPHeaderField:CurUser.appVersion];
    [requestSerializer setValue:@"appType" forHTTPHeaderField:CurUser.appType];
    [requestSerializer setValue:@"appName" forHTTPHeaderField:CurUser.appName];
    [requestSerializer setValue:@"Accept-Language" forHTTPHeaderField:CurUser.AcceptLanguage];
    [requestSerializer setValue:@"androidChannel" forHTTPHeaderField:CurUser.androidChannel];
    [requestSerializer setValue:@"appTheme" forHTTPHeaderField:CurUser.appTheme];
    [requestSerializer setValue:@"appFixVersion" forHTTPHeaderField:CurUser.appFixVersion];
    [requestSerializer setValue:@"deviceToken" forHTTPHeaderField:CurUser.deviceToken];
    [requestSerializer setValue:@"deviceName" forHTTPHeaderField:CurUser.deviceName];
    [requestSerializer setValue:@"accessToken" forHTTPHeaderField:CurUser.accessToken];
    
    //http body转换类
    //1.获取uuid
    NSString *appNonce = [self uuidStr];
    appNonce = [appNonce lowercaseString];
    NSLog(@"appNonce:%@",appNonce);
    
    //2.生成时间戳
    NSString *appTimeStamp = [self appTimeStamp];
    NSLog(@"appTimeStamp:%@",appTimeStamp);
    
    //3.:字典ASCII码排序并MD5加密
    NSMutableDictionary *tempDic = [[NSMutableDictionary alloc]init];
    [tempDic setValue:appNonce forKey:@"appNonce"];
    [tempDic setValue:appTimeStamp forKey:@"appTimeStamp"];
    
    //4.把其他的参数添加到tempDic
    [tempDic addEntriesFromDictionary:params];
    //appNonce转成小写
    [tempDic setValue:appNonce forKey:@"appNonce"];
    NSLog(@"tempDic === :%@",tempDic);
    
    //5.加入_signKey 并且进行mad5加密
    NSString * sign = [self createMd5Sign:tempDic];
    [tempDic setValue:sign forKey:@"appSign"];
    
    NSString *apiPath = [NSString stringWithFormat:@"%@%@",ServerIP,apiAddress];
    NSLog(@"请求链接：＝%@,请求参数＝%@",[NSString stringWithFormat:@"%@%@",ServerIP,apiAddress],tempDic);
    
    //发送请求
    [manager POST:apiPath parameters:tempDic progress:^(NSProgress * _Nonnull uploadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([[responseObject allKeys] containsObject:@"code"]) {
            if([[NSString stringWithFormat:@"%@",[responseObject valueForKey:@"code"]] isEqualToString: Code_Suc]){
                //请求成功
                success(responseObject);
                NSLog(@"请求结果 === %@",responseObject);
            }else{
                //请求失败
                failure(responseObject);
                NSLog(@"请求结果 === %@",responseObject);
            }
        }else{
            failure(@{@"msg":@"请求失败，请稍后再试"});
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        //HideLoading;
        if (dealError)
        {
            NSLog(@"错误信息 === %@",dealError);
        }
    }];
}

-(NSString *)uuidStr{
    CFUUIDRef puuid = CFUUIDCreate(nil);
    CFStringRef uuidString = CFUUIDCreateString(nil, puuid);
    NSString *result = (NSString *)CFBridgingRelease(CFStringCreateCopy(NULL, uuidString));
    NSMutableString *tmpResult = result.mutableCopy;
    // 去除“-”
    NSRange range = [tmpResult rangeOfString:@"-"];
    while (range.location != NSNotFound) {
        [tmpResult deleteCharactersInRange:range];
        range = [tmpResult rangeOfString:@"-"];
    }
    return  tmpResult;
}

-(NSString *)appTimeStamp{
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a=[date timeIntervalSince1970]*1000; // *1000 是精确到毫秒，不乘就是精确到秒
    NSString *timeString = [NSString stringWithFormat:@"%.0f", a]; //转为字符型
    return  timeString;
}

//字符串MD5加密
- (NSString*)getmd5WithString:(NSString *)string
{
    const char* original_str=[string UTF8String];
    unsigned char digist[CC_MD5_DIGEST_LENGTH];
    //CC_MD5_DIGEST_LENGTH = 16
    CC_MD5(original_str, (uint)strlen(original_str), digist);
    NSMutableString* outPutStr = [NSMutableString stringWithCapacity:10];
    for(int  i =0; i<CC_MD5_DIGEST_LENGTH;i++){
        [outPutStr appendFormat:@"%02X", digist[i]];
        //小写x表示输出的是小写MD5，大写X表示输出的是大写MD5
    }
    return outPutStr;
}


/**
 对字典(Key-Value)排序 区分大小写
 @param dict 要排序的字典
 */
- (NSString *)sortedDictionary:(NSDictionary *)dict{
    
    //将所有的key放进数组
    NSArray *allKeyArray = [dict allKeys];
    //序列化器对数组进行排序的block 返回值为排序后的数组
    NSArray *afterSortKeyArray = [allKeyArray sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id _Nonnull obj2) {
        NSComparisonResult resuest = [obj1 compare:obj2];
        return resuest;
    }];
    //排序好的字典
    NSLog(@"afterSortKeyArray:%@",afterSortKeyArray);
    NSString *tempStr = @"";
    //通过排列的key值获取value
    NSMutableArray *valueArray = [NSMutableArray array];
    for (NSString *sortsing in afterSortKeyArray) {
        //格式化一下 防止有些value不是string
        NSString *valueString = [NSString stringWithFormat:@"%@",[dict objectForKey:sortsing]];
        if(valueString.length>0){
            [valueArray addObject:valueString];
            tempStr=[NSString stringWithFormat:@"%@%@=%@&",tempStr,sortsing,valueString];
        }
    }
    //去除最后一个&符号
    if(tempStr.length>0){
        tempStr=[tempStr substringToIndex:([tempStr length]-1)];
    }
    //排序好的对应值
    //  NSLog(@"valueArray:%@",valueArray);
    //最终参数
    NSLog(@"tempStr:%@",tempStr);
    //md5加密
    // NSLog(@"tempStr:%@",[self getmd5WithString:tempStr]);
    return tempStr;
}


//创建package签名
-(NSString*) createMd5Sign:(NSMutableDictionary*)dict
{
    NSMutableString *contentString  =[NSMutableString string];
    NSArray *keys = [dict allKeys];
    //按字母顺序排序
    NSArray *sortedArray = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    //拼接字符串
    for (NSString *categoryId in sortedArray) {
        if ( [[dict objectForKey:categoryId] isKindOfClass:[NSDictionary class]] || [[dict objectForKey:categoryId] isKindOfClass:[NSMutableDictionary class]]) {
            NSString * string = [self getArrayOrDiction:[dict objectForKey:categoryId]];
            [contentString appendFormat:@"%@=%@&", categoryId, string];
            NSLog(@"1contentString === %@",contentString);

        }else if ([[dict objectForKey:categoryId] isKindOfClass:[NSArray class]] || [[dict objectForKey:categoryId] isKindOfClass:[NSMutableArray class]]){
            NSMutableString *currentString  =[NSMutableString string];
            NSArray * arr = [dict objectForKey:categoryId];
            for (NSInteger i = 0; i<arr.count; i++) {
                NSString * currentType = @",";
                if (currentString.length == 0) {
                    currentType = @"";
                }
                if ([arr[i] isKindOfClass:[NSDictionary class]] || [arr[i] isKindOfClass:[NSMutableDictionary class]]) {
                    NSString * string = [self getArrayOrDiction:arr[i]];
                    [currentString appendFormat:@"%@%@",currentType,string];
                }else if ([arr[i] isKindOfClass:[NSArray class]] || [arr[i] isKindOfClass:[NSMutableArray class]]){
                    NSArray * array = (NSArray *)arr[i];
                    NSMutableString *string  =[NSMutableString string];
                    for (NSInteger j = 0; j < array.count; j++) {
                        NSString * type = @",";
                        if (string.length == 0)type = @"";
                        [string appendFormat:@"%@\"%@\"",string,array[j]];
                    }
                    [currentString appendFormat:@"%@[%@]",currentType,string];
                }else {
                    [currentString appendFormat:@"%@\"%@\"",currentType,arr[i]];
                }
            }
            [contentString appendFormat:@"%@=[%@]&", categoryId, currentString];
            NSLog(@"2contentString === %@",contentString);
        }else {
            [contentString appendFormat:@"%@=%@&", categoryId, [dict objectForKey:categoryId]];
        }
        
        NSLog(@"3contentString === %@",contentString);
    }
    
    NSString * _signKey = @"xv^#3cc#TXIV4sbtZ%IgX7+HHioLMEH0Un!u_Eh7Gc&UIKoBZF%C%vG99gS0o3pl";
    //添加key字段
    [contentString appendFormat:@"signSercetKey=%@%@",_signKey,dict[@"appNonce"]];
    
    
    NSLog(@"4contentString === %@",contentString);
    //得到MD5 sign签名
    NSString *md5Sign =[self md5:contentString];
    return md5Sign;
}

-(NSString *)getArrayOrDiction:(NSDictionary *)object{
    NSMutableString *contentString  =[NSMutableString string];
    NSArray *keys = [object allKeys];
    //按字母顺序排序
    NSArray *sortedArray = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    for (NSString *categoryId in sortedArray) {
        NSString * string = @",";
        if (contentString.length == 0) {
            string = @"";
        }
        [contentString appendFormat:@"%@\"%@\":\"%@\"",string, categoryId, [object objectForKey:categoryId]];
    }
    return kStringFormat(@"{%@}",contentString);
};


-(NSString *) md5:(NSString *)str
{
    const char *cStr = [str UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (unsigned int)strlen(cStr), digest );
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02X", digest[i]];
    
    return output;
}

- (NSData *)doCipher:(NSData *)dataIn
                  iv:(NSData *)iv
                 key:(NSData *)symmetricKey
             context:(CCOperation)encryptOrDecrypt
               error:(NSError **)error
{
    CCCryptorStatus ccStatus   = kCCSuccess;
    size_t          cryptBytes = 0;
    NSMutableData  *dataOut    = [NSMutableData dataWithLength:dataIn.length + kCCBlockSizeAES128];
    
    ccStatus = CCCrypt( encryptOrDecrypt,
                       kCCAlgorithmAES,
                       kCCOptionECBMode | kCCOptionPKCS7Padding,
                       symmetricKey.bytes,
                       symmetricKey.length,
                       iv.bytes,
                       dataIn.bytes,
                       dataIn.length,
                       dataOut.mutableBytes,
                       dataOut.length,
                       &cryptBytes);
    
    if (ccStatus == kCCSuccess) {
        dataOut.length = cryptBytes;
    }
    else {
        if (error) {
            *error = [NSError errorWithDomain:@"kEncryptionError"
                                         code:ccStatus
                                     userInfo:nil];
        }
        dataOut = nil;
    }
    return dataOut;
}

@end
