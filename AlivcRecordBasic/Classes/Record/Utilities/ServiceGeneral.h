//
//  ServiceGeneral.h
//  boluolicai
//
//  Created by 张松超 on 15/11/21.
//  Copyright © 2015年 Pusupanshi. All rights reserved.


#ifndef ServiceGeneral_h
#define ServiceGeneral_h

/******************ErrorCode******************/
#define Code_Suc            @"100"

//测试环境接口
//#define ServerIP                 @"http://newsapp-test.leshuapro.com/"
//正式环境接口
#define ServerIP                   @"http://newsapp-test.leshuapro.com/"


//登录接口
#define loginUrL                   @"api/user/login"
#define HomepageUrL                @"/api/shortVideo/queryEsShortVideoList"

#define UserInfoBuyUrl             @"api/user/userInfoByUserNum"

#define QueryUserFollowUrl         @"api/userFollow/queryUserFollow"

#define queryShortVideoCategoryList         @"api/shortVideo/queryShortVideoCategoryList"

#define queryShortVideoUploadAwardConfig         @"api/shortVideoUploadAwardConfig/queryShortVideoUploadAwardConfig"

#define getUploadMessage         @"api/shortVideo/getUploadMessage"



#endif /* ServiceGeneral_h */
