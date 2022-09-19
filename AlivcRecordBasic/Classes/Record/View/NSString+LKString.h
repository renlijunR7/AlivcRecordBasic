//
//  NSString+LKString.h
//  StudentPlatform
//
//  Created by 李康康 on 2018/11/14.
//  Copyright © 2018年 李康康. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (LKString)
/**
 * @brief app缓存文件夹
 */
+ (NSString *)AppCachePath;
/**
 *  转换为Base64编码
 */
- (NSString *)base64EncodedString;
/**
 *  将Base64编码还原
 */
- (NSString *)base64DecodedString;
/**
 * @brief 计算字体尺寸
 */
- (CGSize)getSizeWithFont:(UIFont *)font maxSize:(CGSize)maxSize;

/**
 * @brief 获取时间当前时间戳
 */
+ (NSString *)getCurrentTimestamp;

/**
 * @brief 获取程序目录
 */
+ (NSString *)getAppDocumentPath;

/**
 * @brief 是否是空字符
 */
+ (BOOL)isAllEmpty:(NSString *)str;

/**
 * @brief 空字符转换为@“0”
 */
+ (NSString *)getZeroWithAmount:(NSString *)aAmount;

/**
 * @brief 空数据处理
 */
+(NSString *)returnNullStringWithString:(NSString *)string;

/**
 * @brief 两位小数0处理
 */
- (NSString *)retainDecimal;

/**
 * @brief 是否是电话号
 */
- (BOOL)isMobileNumber;

/**
 * @brief 是否是数字
 */
- (BOOL)validateNumber;

/**
 * @brief 是否是小数
 */
- (BOOL)isPureFloat;

/**
 *判断是不是九宫格
 *@return YES(是九宫格拼音键盘)
 */
-(BOOL)isNineKeyBoard;

/**
 *判断字符串是否含有表情
 *
 */
- (BOOL)stringContainsEmoji;

/**
 *截取字符串
 *
 */
+ (NSString *)cutWithString:(NSString *)aString type:(NSInteger)aType index:(NSInteger)aIndex;


@end

NS_ASSUME_NONNULL_END
