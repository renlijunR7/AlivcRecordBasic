//
//  SelectIteamViewController.m
//  AliyunVideoClient_Entrance
//
//  Created by mac_a on 2022/9/5.
//  Copyright © 2022 Aliyun. All rights reserved.
//

#import "SelectIteamViewController.h"
#import <AVFoundation/AVAsset.h>
#import <AVFoundation/AVAssetImageGenerator.h>
#import <AVFoundation/AVTime.h>
#import "CBGroupAndStreamView.h"
#import "XLAlertView.h"
#import "UIColor+Gradient.h"
#import "CommonMacro.h"
#import "HttpPresenter.h"
#import "BLUser.h"
#import "MBProgressHUD.h"
#import "MBProgressHUD+AlivcHelper.h"
#import "AFHTTPSessionManager.h"



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
#define ShowHud(Msg)    [[UWAlertManager sharedInstance] showHud:Msg]


/*================================================================*/
#define CC_MD5_DIGEST_LENGTH 16
#import <CommonCrypto/CommonCrypto.h>
#import "NSString+LKString.h"
#include <CommonCrypto/CommonDigest.h>
#define kStringFormat(format,...) [NSString stringWithFormat:format,##__VA_ARGS__]



@interface SelectIteamViewController ()<CBGroupAndStreamDelegate,UITextViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>

{
    UIImageView *viedoImage;
    NSArray * shortVideoCategoryList;
    NSMutableArray * categoryListID;//标签id list
    NSString *describeStr;//视频描述
    NSString *imgStr;//封面图片链接
    NSString *dscrStr;//视频描述
    MBProgressHUD *hud;//加载loading
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
@property(nonatomic, strong) UIImage *imgaeS;//视频封面


@end

@implementation SelectIteamViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.title = @"发布";
    self.view.backgroundColor = [UIColor blackColor];
    shortVideoCategoryList = [NSArray alloc];
    categoryListID = [[NSMutableArray alloc]init];
    NSLog(@"视频路径 === %@",self.outputPath);
    
    NSURL *url = [NSURL fileURLWithPath:self.outputPath];
    self.imgaeS = [self getVideoPreViewImage:url];
    NSLog(@"imgaeS  === %@",self.imgaeS);

    [self setUpLoadClient];
    
    [self loadDate];

    //隐藏键盘
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide)];
    tapGestureRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGestureRecognizer];
}


- (void)setUpLoadClient{
    
    //创建VODUploadClient对象
    self.uploader = [VODUploadClient new];
    __weak typeof(self) weakSelf = self;
    OnUploadFinishedListener FinishCallbackFunc = ^(UploadFileInfo* fileInfo, VodUploadResult* result){
        [self hideHud];
        [MBProgressHUD showMessage:[@"视频上传成功" localString] inView:self.view];
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
        [self showHud:@"视频上传中"];
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


- (void)confirmSelt{
    
    NSMutableDictionary *Params = [NSMutableDictionary dictionaryWithDictionary:@{
    }];
    [HttpApi PostApiAddress:queryShortVideoUploadAwardConfig  postParams:Params success:^(NSDictionary *resultDict) {
        XLAlertView *xlAlertView = [[XLAlertView alloc] initWithTitle:@"发布规则" message:resultDict[@"data"][@"shortVideoUploadAwardConfig"][@"explainContent"] sureBtn:@"我知道了" cancleBtn:@""];
        xlAlertView.resultIndex = ^(NSInteger index){
        };
        [xlAlertView showXLAlertView];
    } failure:^(NSDictionary *failureDict) {
    }];
}

#pragma mark---delegate
- (void)cb_confirmReturnValue:(NSArray *)valueArr groupId:(NSArray *)groupIdArr{
    
    NSArray *temArr= [NSArray alloc];
    temArr = valueArr[0];
    [categoryListID removeAllObjects];
    if (valueArr.count > 0) {
        for (int i = 0;i < temArr.count; i++) {
            int index = (int)[temArr[i] integerValue];
            [categoryListID addObject:[NSString stringWithFormat:@"%@",shortVideoCategoryList[index][@"id"]]];
        }
        NSLog(@"categoryListID ===%@ ",categoryListID);

    }else{
    }
}

- (void)cb_selectCurrentValueWith:(NSString *)value index:(NSInteger)index groupId:(NSInteger)groupId {
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [_textPush resignFirstResponder];
    return YES;
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
    _uilabel.enabled = NO;
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
    silde.delegate = self;
    silde.isDefaultSel = NO;
    silde.isSingle = NO;
    silde.radius = 15;
    silde.font = [UIFont systemFontOfSize:12];
    silde.titleTextFont = [UIFont systemFontOfSize:18];
    silde.selColor = rgba(254, 69, 89, 1);
    [_scrView addSubview:silde];
    [silde setContentView:contentArr titleArr:titleArr];
    _menueView = silde;
    
    viedoImage = [[UIImageView alloc]initWithFrame:CGRectMake(20 ,[silde viewHeight]+200, 100, 120)];
    viedoImage.image = self.imgaeS;
    viedoImage.backgroundColor = [UIColor lightGrayColor];
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

// 获取视频第一帧
- (UIImage*) getVideoPreViewImage:(NSURL *)path
{
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:path options:nil];
    AVAssetImageGenerator *assetGen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
  
    assetGen.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef image = [assetGen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *videoImage = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);
    return videoImage;
}

-(void)TapImage:(UITapGestureRecognizer*)sender{
}

- (void)pushViedo{
    NSLog(@"执行发布操作");
    
    NSMutableDictionary *DicParams = [[NSMutableDictionary alloc]init];
    [DicParams setValue:[NSString stringWithFormat:@"%@",dscrStr] forKey:@"description"];
    [DicParams setValue:categoryListID forKey:@"categoryIds"];
    [DicParams setValue:[NSString stringWithFormat:@"%@",@"39.995156"] forKey:@"latitude"];
    [DicParams setValue:[NSString stringWithFormat:@"%@",@"116.474060"] forKey:@"longitude"];
    [DicParams setValue:@"0" forKey:@"activityType"];
    [DicParams setValue:@"0.5625" forKey:@"remark"];
    if (imgStr != nil || imgStr.length != 0) {
        [DicParams setValue:[NSString stringWithFormat:@"%@",imgStr] forKey:@"img"];
    }
    
    NSLog(@"执行发布操作 参数== %@",DicParams);
    NSMutableDictionary *Params = [NSMutableDictionary dictionaryWithDictionary:DicParams];
    [HttpApi PostApiAddress:getUploadMessage  postParams:Params success:^(NSDictionary *resultDict) {
        
        self.uploadAddress = [NSString stringWithFormat:@"%@",resultDict[@"data"][@"uploadAddress"]];
        self.uploadAuth =  [NSString stringWithFormat:@"%@",resultDict[@"data"][@"uploadAuth"]];
        [self.uploader addFile:self.outputPath vodInfo:nil];
        [self.uploader start];
    
    } failure:^(NSDictionary *failureDict) {
    }];
}

//========辅助工具(后续封装)==================================================
- (void)showHud:(NSString *)hudStr
{
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.bezelView.color = [UIColor whiteColor];
    hud.bezelView.alpha = 0.8;
    hud.label.text = hudStr;
}
- (void)hideHud
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self->hud hideAnimated:YES];
    });
}
//隐藏键盘
-(void)textViewDidChange:(UITextView *)textView
{
    if (_textPush.text.length == 0) {
        _uilabel.text = @"可添加300个文字,我想说...";
    }else{
        _uilabel.text = @"";
    }
    NSLog(@"000=== %@",textView.text);
    dscrStr =textView.text;
}
- (void)keyboardHide
{
    [self.view endEditing:YES];
}


- (void)loadDate{
    [self showHud:@"加载中..."];
    NSMutableDictionary *Params = [NSMutableDictionary dictionaryWithDictionary:@{
    }];
    [HttpApi PostApiAddress:queryShortVideoCategoryList  postParams:Params success:^(NSDictionary *resultDict) {
        [self hideHud];
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
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) return;
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

/// 打开相册
- (void)openAlbum{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - ******UIImagePickerControllerDelegate******
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    [picker dismissViewControllerAnimated:YES completion:nil];
    viedoImage.image = info[UIImagePickerControllerOriginalImage];
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];///原图
    [self UpPic:image];
    NSLog(@"照片 ====信息%@",info);
}

//上传图片
-(void)UpPic:(UIImage *)img
{
    NSDictionary *DicParams = @{
        @"img":img,
        @"type":@"2",
    };
    [self showHud:@"加载中..."];
    NSMutableDictionary *Params = [NSMutableDictionary dictionaryWithDictionary:DicParams];
    [HttpApi ImagePostApiAddress:getUploadImg  postParams:Params success:^(NSDictionary *resultDict) {
        NSLog(@"图片上传成功数据 ====%@",resultDict);
        self->imgStr = [NSString stringWithFormat:@"%@",resultDict[@"data"][@"URL"][@"readPath"]];
        [self hideHud];
        
    } failure:^(NSDictionary *failureDict) {
        [self hideHud];
    }];
}


@end
