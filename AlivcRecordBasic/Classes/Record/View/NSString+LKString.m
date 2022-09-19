//
//  NSString+LKString.m
//  StudentPlatform
//
//  Created by 李康康 on 2018/11/14.
//  Copyright © 2018年 李康康. All rights reserved.
//

#import "NSString+LKString.h"
#import "sys/utsname.h"

@implementation NSString (LKString)

+ (NSString *)AppCachePath{
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)lastObject] stringByAppendingPathComponent:@"AtoshiAppDataCache"];
    return path;
}

- (NSString *)base64EncodedString;
{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [data base64EncodedStringWithOptions:0];
}

- (NSString *)base64DecodedString
{
    NSData *data = [[NSData alloc]initWithBase64EncodedString:self options:0];
    return [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
}

- (CGSize)getSizeWithFont:(UIFont *)font maxSize:(CGSize)maxSize{
    
    return [self boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:font} context:nil].size;
}

+ (NSString *)getCurrentTimestamp
{
    long long currentDate = [[NSDate date] timeIntervalSince1970];
    NSString * timestamp = [NSString stringWithFormat:@"%lld", currentDate];
    return timestamp;
}

+ (NSString *)getAppDocumentPath
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0];
    return path;
}

+ (BOOL)isAllEmpty:(NSString *)str{
    
    if (![str isKindOfClass:[NSString class]]) {
        return YES;
    }else if (str==nil) {
        return YES;
    }else if(!str) {
        // null object
        return TRUE;
    } else if(str==NULL) {
        // null object
        return TRUE;
    } else if([str isEqualToString:@"NULL"]) {
        // null object
        return TRUE;
    }else if([str isEqualToString:@"(null)"]){
        
        return TRUE;
    }else if([str isEqualToString:@"<null>"]){
        
        return TRUE;
    }
    else if([str isEqualToString:@"null"]){
        
        return TRUE;
    }
    else if(str.length < 1) {
        // null object
        return TRUE;
    }
    else{
        //  使用whitespaceAndNewlineCharacterSet删除周围的空白字符串
        //  然后在判断首位字符串是否为空
        NSString *trimedString = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([trimedString length] == 0) {
            // empty string
            return TRUE;
        } else {
            // is neither empty nor null
            return FALSE;
        }
    }
}

+ (NSString *)getZeroWithAmount:(NSString *)aAmount
{
     return [[NSString returnNullStringWithString:aAmount] isEqualToString:@""] ? @"0":[NSString returnNullStringWithString:aAmount];
}

+(NSString *)returnNullStringWithString:(NSString *)string
{
    NSString *strShow =[NSString stringWithFormat:@"%@",string];
    if ([strShow isEqualToString:@"null"] || strShow == nil|| [strShow isEqualToString:@"(null)"] ||[strShow isEqualToString:@"<null>"]  ) {
        strShow=@"";
    }
    return strShow;
}

- (NSString *)retainDecimal{
    
    NSString *str = [NSString stringWithFormat:@"%.2f",self.floatValue];
    if ([str containsString:@"."]) {
        NSRange range = [str rangeOfString:@"."];
        range.location += 1;
        range.length = 1;
        NSString *decimal1 = [str substringWithRange:range];
        range.location += 1;
        NSString *decimal2 = [str substringWithRange:range];
        if (decimal2.integerValue == 0) {//小数点第二位等于0
            if(decimal1.integerValue == 0){ //小数点第一位等于0
                return [str substringWithRange:NSMakeRange(0, str.length - 3)];
            }else{
                return [str substringWithRange:NSMakeRange(0, str.length - 1)];
            }
        }
        return str;
    }
    return @"0";
}

- (BOOL)validateNumber{
    NSString *number = @"^[0-9]{1,}$";
    NSPredicate *numberPre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",number];
    return [numberPre evaluateWithObject:self];
}

- (BOOL)isPureFloat{
    
    NSScanner* scan = [NSScanner scannerWithString:self];
    
    float val;
    
    return[scan scanFloat:&val] && [scan isAtEnd];
    
}

- (BOOL)isMobileNumber
{
    NSString *mobileNum = self;
    if (mobileNum.length != 11)
    {
        return NO;
    }
    
    NSString *MOBILE = @"^1([3-9][0-9])\\d{8}$";
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    if ([regextestmobile evaluateWithObject:mobileNum] == YES)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

#pragma mark - 判断字符串中是否存在emoji
- (BOOL)stringContainsEmoji
{
    __block BOOL returnValue = NO;
    
    [self enumerateSubstringsInRange:NSMakeRange(0, [self length])
                             options:NSStringEnumerationByComposedCharacterSequences
                          usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                              const unichar hs = [substring characterAtIndex:0];
                              if (0xd800 <= hs && hs <= 0xdbff) {
                                  if (substring.length > 1) {
                                      const unichar ls = [substring characterAtIndex:1];
                                      const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                                      if (0x1d000 <= uc && uc <= 0x1f77f) {
                                          returnValue = YES;
                                      }
                                  }
                              } else if (substring.length > 1) {
                                  const unichar ls = [substring characterAtIndex:1];
                                  if (ls == 0x20e3) {
                                      returnValue = YES;
                                  }
                              } else {
                                  if (0x2100 <= hs && hs <= 0x27ff) {
                                      returnValue = YES;
                                  } else if (0x2B05 <= hs && hs <= 0x2b07) {
                                      returnValue = YES;
                                  } else if (0x2934 <= hs && hs <= 0x2935) {
                                      returnValue = YES;
                                  } else if (0x3297 <= hs && hs <= 0x3299) {
                                      returnValue = YES;
                                  } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
                                      returnValue = YES;
                                  }
                              }
                          }];
    
//    下面这个方法可以限制第三方键盘（常用的是搜狗键盘）的表情
    NSString *pattern = @"[^\\u0020-\\u007E\\u00A0-\\u00BE\\u2E80-\\uA4CF\\uF900-\\uFAFF\\uFE30-\\uFE4F\\uFF00-\\uFFEF\\u0080-\\u009F\\u2000-\\u201f\r\n]";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:self];
    
    return (returnValue || isMatch);
}

-(BOOL)isNineKeyBoard
{
    NSString *other = @"➋➌➍➎➏➐➑➒";
    int len = (int)self.length;
    for(int i=0;i<len;i++)
    {
        if(!([other rangeOfString:self].location != NSNotFound))
            return NO;
    }
    return YES;
}

#pragma mark 截取字符串
+ (NSString *)cutWithString:(NSString *)aString type:(NSInteger)aType index:(NSInteger)aIndex{
    
    if (!aType) {
        return  [aString substringToIndex:aIndex];
    }else{
        return  [aString substringFromIndex:aIndex];
    }
}



@end
