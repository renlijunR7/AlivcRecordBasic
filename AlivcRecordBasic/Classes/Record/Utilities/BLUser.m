//
//  BLUser.m
//  boluolicai
//
//  Created by 张松超 on 15/11/24.
//  Copyright © 2015年 Pusupanshi. All rights reserved.
//



#import "BLUser.h"

#define BLUserManagerKey @"BLUserManagerKey"

@implementation BLUser

CLASS_DEF_SINGLETON(BLUser);

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.contentType = @"";
        self.charset = @"";
        self.appVersion = @"";
        self.appType = @"";
        self.appName = @"";
        self.AcceptLanguage = @"";
        self.androidChannel = @"";
        self.appTheme = @"";
        self.appFixVersion = @"";
        self.deviceToken = @"";
        self.deviceName = @"";
        self.accessToken = @"";
        
        
        [self loadData];
    }
    return self;
}

- (void)loadData
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSData *userData = [defaults objectForKey:BLUserManagerKey];
    if (userData)
    {
        NSDictionary *dict = [[NSDictionary alloc] init];
        if (userData) {
            @try {
                dict=[NSKeyedUnarchiver unarchiveObjectWithData:userData];
                NSArray *keyArray = [dict allKeys];
                for (NSString *key in keyArray)
                {
                    [self setValue:[dict valueForKey:key] forKey:key];
                }
            }
            @catch (NSException *exception) {
                NSLog(@" dict --- %@",userData);
            }
        }
    }
}


- (void)saveData
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    [dict setValue:self.contentType forKey:@"content-typ"];
    [dict setValue:self.charset forKey:@"charset"];
    [dict setValue:self.appVersion forKey:@"appVersion"];
    [dict setValue:self.appType forKey:@"appType"];
    [dict setValue:self.appName forKey:@"appName"];
    [dict setValue:self.AcceptLanguage forKey:@"Accept-Language"];
    [dict setValue:self.androidChannel forKey:@"androidChannel"];
    [dict setValue:self.appTheme forKey:@"appTheme"];
    [dict setValue:self.appFixVersion forKey:@"appFixVersion"];
    [dict setValue:self.deviceToken forKey:@"deviceToken"];
    [dict setValue:self.deviceName forKey:@"deviceName"];
    [dict setValue:self.accessToken forKey:@"accessToken"];

    NSData *userData = [NSKeyedArchiver archivedDataWithRootObject:dict];
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:userData forKey:BLUserManagerKey];
    [defaults synchronize];
    
}


- (void)quitLogin {
    self.contentType = @"";
    self.charset = @"";
    self.appVersion = @"";
    self.appType = @"";
    self.appName = @"";
    self.AcceptLanguage = @"";
    self.androidChannel = @"";
    self.appTheme = @"";
    self.appFixVersion = @"";
    self.deviceToken = @"";
    self.deviceName = @"";
    self.accessToken = @"";
    
    [self saveData];
}


@end
