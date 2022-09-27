//
//  SelectIteamViewController.m
//  AliyunVideoClient_Entrance
//
//  Created by mac_a on 2022/9/5.
//  Copyright © 2022 Aliyun. All rights reserved.
//

#import "SelectIteamViewController.h"
#import "CBGroupAndStreamView.h"
#import "XLAlertView.h"
#import "UIColor+Gradient.h"
#import "CommonMacro.h"
#import "HttpPresenter.h"
#import "BLUser.h"

#import <VODUpload/VODUploadClient.h>

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
#define HttpApi         [HttpPresenter sharedInstance]
#define CurUser         [BLUser sharedInstance]


@interface SelectIteamViewController ()<CBGroupAndStreamDelegate,UITextViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>

{
    UIImageView *viedoImage;
    NSArray * shortVideoCategoryList;
    NSMutableArray * categoryListID;//标签id list
    NSString *explainContent;//视频发布规则
    NSString *describeStr;//视频描述
    NSString *imgStr;//封面图片链接
 
}


@property (nonatomic, strong) UITextView *textPush;
@property (nonatomic, strong) UILabel *textTitle;
@property (nonatomic, strong) UIButton *pushBtn;
@property (nonatomic, strong) UIScrollView *scrView;
@property (strong, nonatomic) CBGroupAndStreamView * menueView;
@property (nonatomic, strong) UILabel *uilabel;

//上传视频
@property(nonatomic, strong) VODUploadClient *uploader;
@property (nonatomic, strong) VODUploadListener *listener;

@property(nonatomic, strong) UploadFileInfo *fileInfo;
@property(nonatomic, strong) NSString *uploadAuth;
@property(nonatomic, strong) NSString *uploadAddress;


@end

@implementation SelectIteamViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"发布";
    self.view.backgroundColor = [UIColor blackColor];
    shortVideoCategoryList = [NSArray alloc];
    categoryListID = [[NSMutableArray alloc]init];
    
    [self loadDate];
    [self loadRulesDate];
    NSLog(@"视频路径 === %@",self.outputPath);

    NSDictionary *DicParams = @{
        @"description":@"记录美好生活",
        @"categoryIds":@[@"15",@"13",@"28"],
        @"latitude":@"39.995156",
        @"longitude":@"116.474069",
        @"activityType":@"0",
        @"remark":@"0.5625",
        @"img":@"https://img.leshuapro.com/wangzhuang_images/a7276478-7bb2-477b-8fb4-f5c6f85e51dc.png",
    };
    
    NSMutableDictionary *Params = [NSMutableDictionary dictionaryWithDictionary:DicParams];
    [HttpApi PostApiAddress:getUploadMessage  postParams:Params success:^(NSDictionary *resultDict) {
        
        self.uploadAddress = [NSString stringWithFormat:@"%@",resultDict[@"data"][@"uploadAddress"]];
        self.uploadAuth =  [NSString stringWithFormat:@"%@",resultDict[@"data"][@"uploadAuth"]];
    
        [self setUpLoadClient];
        
    } failure:^(NSDictionary *failureDict) {
    }];
}


- (void)setUpLoadClient{
    
    //创建VODUploadClient对象
    self.uploader = [VODUploadClient new];
    __weak typeof(self) weakSelf = self;
    
    //setup callback
    OnUploadFinishedListener FinishCallbackFunc = ^(UploadFileInfo* fileInfo, VodUploadResult* result){
        NSLog(@"upload finished callback videoid:%@, imageurl:%@", result.videoId, result.imageUrl);
    };
    OnUploadFailedListener FailedCallbackFunc = ^(UploadFileInfo* fileInfo, NSString *code, NSString* message){
        NSLog(@"upload failed callback code = %@, error message = %@", code, message);
    };
    OnUploadProgressListener ProgressCallbackFunc = ^(UploadFileInfo* fileInfo, long uploadedSize, long totalSize) {
        NSLog(@"upload progress callback uploadedSize : %li, totalSize : %li", uploadedSize, totalSize);
    };
    OnUploadTokenExpiredListener TokenExpiredCallbackFunc = ^{
        NSLog(@"upload token expired callback.");
        //token过期，设置新的上传凭证，继续上传
        //[weakSelf.uploader resumeWithAuth:`new upload auth`];
    };
    OnUploadRertyListener RetryCallbackFunc = ^{
        NSLog(@"upload retry begin callback.");
    };
    OnUploadRertyResumeListener RetryResumeCallbackFunc = ^{
        NSLog(@"upload retry end callback.");
    };
    OnUploadStartedListener UploadStartedCallbackFunc = ^(UploadFileInfo* fileInfo) {
        NSLog(@"pload upload started callback.");
        //设置上传地址和上传凭证
        [weakSelf.uploader setUploadAuthAndAddress:fileInfo uploadAuth:weakSelf.uploadAuth uploadAddress:weakSelf.uploadAddress];
        
    };
    
    self.listener = [[VODUploadListener alloc] init];
    self.listener.finish = FinishCallbackFunc;
    self.listener.failure = FailedCallbackFunc;
    self.listener.progress = ProgressCallbackFunc;
    self.listener.expire = TokenExpiredCallbackFunc;
    self.listener.retry = RetryCallbackFunc;
    self.listener.retryResume = RetryResumeCallbackFunc;
    self.listener.started = UploadStartedCallbackFunc;
    //init with upload address and upload auth
    [self.uploader setListener:self.listener];
}

- (void)loadRulesDate{
    NSMutableDictionary *Params = [NSMutableDictionary dictionaryWithDictionary:@{
    }];
    [HttpApi PostApiAddress:queryShortVideoUploadAwardConfig  postParams:Params success:^(NSDictionary *resultDict) {
        self->explainContent = resultDict[@"data"][@"shortVideoUploadAwardConfig"][@"explainContent"];
        NSLog(@"打印发布规则 === %@",resultDict);
    
    } failure:^(NSDictionary *failureDict) {
    }];
}

- (void)loadDate{
   
    NSMutableDictionary *Params = [NSMutableDictionary dictionaryWithDictionary:@{
    }];
    [HttpApi PostApiAddress:queryShortVideoCategoryList  postParams:Params success:^(NSDictionary *resultDict) {
        
        if(resultDict!=nil||resultDict!=NULL){
            NSMutableArray *categoryList = [[NSMutableArray alloc]init];
            self->shortVideoCategoryList = resultDict[@"data"][@"shortVideoCategoryList"];
            for (int i = 0;i < self->shortVideoCategoryList.count; i++) {
                [categoryList addObject:self->shortVideoCategoryList[i][@"title"]];
            }
            [self creatUI:categoryList];
        }else{
        }
    
    } failure:^(NSDictionary *failureDict) {
    }];
}

- (void)replaceCoverBtnAct{
    NSLog(@"更换封面");
    
    UIAlertController *alterConroller = [UIAlertController alertControllerWithTitle:@"请选择方式" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"照相机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self openCamera];
    }];
    UIAlertAction *albumAction = [UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self openAlbum];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    [alterConroller addAction:cameraAction];
    [alterConroller addAction:albumAction];
    [alterConroller addAction:cancelAction];
    [self presentViewController:alterConroller animated:YES completion:nil];
}

/// 打开照相机
- (void)openCamera{
    //UIImagePickerControllerSourceTypePhotoLibrary, 从所有相册选择
    //UIImagePickerControllerSourceTypeCamera, //拍一张照片
    //UIImagePickerControllerSourceTypeSavedPhotosAlbum//从moments选择一张照片
    //判断照相机能否使用
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) return;
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

/// 打开相册
- (void)openAlbum{
    //UIImagePickerControllerSourceTypePhotoLibrary, 从所有相册选择
    //UIImagePickerControllerSourceTypeCamera, //拍一张照片
    //UIImagePickerControllerSourceTypeSavedPhotosAlbum//从moments选择一张照片
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - ******UIImagePickerControllerDelegate******
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    [picker dismissViewControllerAnimated:YES completion:nil];
    viedoImage.image = info[UIImagePickerControllerOriginalImage];
    NSLog(@"%@",info);
}

- (void)confirmSelt{
    [_menueView confirm];
    
    XLAlertView *xlAlertView = [[XLAlertView alloc] initWithTitle:@"发布规则" message:explainContent sureBtn:@"我知道了" cancleBtn:@""];
    xlAlertView.resultIndex = ^(NSInteger index){
    };
    [xlAlertView showXLAlertView];
}

#pragma mark---delegate
- (void)cb_confirmReturnValue:(NSArray *)valueArr groupId:(NSArray *)groupIdArr{
    
    NSArray *temArr= [NSArray alloc];
    temArr = valueArr[0];
    [categoryListID removeAllObjects];
    
    if (valueArr.count > 0) {
        for (int i = 0;i < temArr.count; i++) {
            int index = (int)[temArr[i] integerValue];
            [categoryListID addObject:shortVideoCategoryList[index][@"id"]];
        }
        NSLog(@"categoryListID======== %@",categoryListID);
    }else{
    }
}

- (void)cb_selectCurrentValueWith:(NSString *)value index:(NSInteger)index groupId:(NSInteger)groupId {
}


-(void)textViewDidChange:(UITextView *)textView
{
    if (_textPush.text.length == 0) {
        _uilabel.text = @"可添加300个文字,我想说...";
    }else{
        _uilabel.text = @"";
    }
}

-(void)creatUI:(NSArray *)arrList{
    _scrView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - 180)];
    _scrView.scrollEnabled = YES;
    _scrView.userInteractionEnabled = YES;
    _scrView.backgroundColor = [UIColor blackColor];
    _scrView.contentSize = CGSizeMake(0, ScreenHeight);
    [self.view addSubview: _scrView];
    
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.view.backgroundColor =[UIColor blackColor];
    //29292D
    UIButton * rightBut = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightBut setTitle:@"规则" forState:UIControlStateNormal];
    [rightBut setFrame:CGRectMake(0, 0, 40, 40)];
    [rightBut setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    rightBut.titleLabel.font = [UIFont systemFontOfSize:14];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBut];
    [rightBut addTarget:self action:@selector(confirmSelt) forControlEvents:UIControlEventTouchUpInside];
    
    _textPush = [[UITextView alloc]initWithFrame:CGRectMake(20 ,25, ScreenWidth - 40, 150)];
    _textPush.backgroundColor =  rgba(41, 41, 45, 1);
    _textPush.delegate = self;
    _textPush.layer.cornerRadius = 6;
    _textPush.layer.masksToBounds = YES;
    _textPush.textColor = [UIColor whiteColor];
    [_scrView addSubview:_textPush];
    
    _uilabel = [[UILabel alloc]initWithFrame:CGRectMake(10 ,10,200, 20)];
    _uilabel.text = @"可添加300个文字,我想说...";
    _uilabel.font = [UIFont systemFontOfSize:15];
    _uilabel.textColor = [UIColor whiteColor];
    _uilabel.enabled = NO;//lable必须设置为不可用
    [_textPush addSubview:_uilabel];
    
    _pushBtn = [[UIButton alloc]initWithFrame:CGRectMake(20 ,ScreenHeight - 165, ScreenWidth - 40, 45)];
    _pushBtn.backgroundColor = [UIColor redColor];
    _pushBtn.layer.cornerRadius = 6;
    _pushBtn.layer.masksToBounds = YES;
    [_pushBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_pushBtn setTitle:@"发布" forState:UIControlStateNormal];
    [_pushBtn addTarget:self action:@selector(pushViedo) forControlEvents:UIControlEventTouchUpInside];
    _pushBtn.backgroundColor = [UIColor gradientColorWithSize:_pushBtn.frame.size
                                                    direction:GradientColorDirectionLevel
                                                   startColor:rgba(255, 111, 77, 1)
                                                     endColor:rgba(252, 24, 73, 1)];
    [self.view addSubview:_pushBtn];
    NSArray * titleArr = @[@"视频话题（可多选）"];
    NSArray *contentArr = @[arrList];
    
    CBGroupAndStreamView * silde = [[CBGroupAndStreamView alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(_textPush.frame)+ 10, ScreenWidth-20,500)];
    silde.layer.cornerRadius = 6;
    silde.layer.masksToBounds = YES;
    silde.delegate = self;
    silde.isDefaultSel = NO;
    silde.isSingle = NO;
    silde.radius = 12;
    silde.font = [UIFont systemFontOfSize:12];
    silde.titleTextFont = [UIFont systemFontOfSize:18];
    silde.selColor = [UIColor orangeColor];
    [_scrView addSubview:silde];
    [silde setContentView:contentArr titleArr:titleArr];
    _menueView = silde;
    
    viedoImage = [[UIImageView alloc]initWithFrame:CGRectMake(20 ,[silde viewHeight]+200, 100, 120)];
    viedoImage.backgroundColor = [UIColor yellowColor];
    viedoImage.layer.cornerRadius = 6;
    viedoImage.layer.masksToBounds = YES;
    viedoImage.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(TapImage:)];
    [viedoImage addGestureRecognizer:tap];
    [_scrView addSubview:viedoImage];
    
    
    UIButton *replaceCoverBtn = [[UIButton alloc]initWithFrame:CGRectMake(20 ,CGRectGetMaxY(viedoImage.frame)+8, 100, 20)];
    [replaceCoverBtn setTitle:@"更换封面" forState:UIControlStateNormal];
    [replaceCoverBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    replaceCoverBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [replaceCoverBtn addTarget:self action:@selector(replaceCoverBtnAct) forControlEvents:UIControlEventTouchUpInside];
    [_scrView addSubview:replaceCoverBtn];
}

-(void)TapImage:(UITapGestureRecognizer*)sender{
    
    NSDictionary *DicParams = @{
        @"userNum":@"12874664",
    };
    
    NSMutableDictionary *Params = [NSMutableDictionary dictionaryWithDictionary:DicParams];
    [HttpApi PostApiAddress:QueryUserFollowUrl  postParams:Params success:^(NSDictionary *resultDict) {
        
    } failure:^(NSDictionary *failureDict) {
    }];
}


- (void)pushViedo{
    
    NSLog(@"执行发布操作");
   
    [self.uploader addFile:self.outputPath vodInfo:nil];
    [self.uploader start];
    
    NSLog(@"self.outputPath == %@",self.outputPath);
    NSLog(@"uploadAuth ===%@ ",self.uploadAuth);
    NSLog(@"uploadAddress ===%@ ",self.uploadAddress);

}

@end