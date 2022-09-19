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
}
@property (nonatomic, strong) UITextView *textPush;
@property (nonatomic, strong) UILabel *textTitle;
@property (nonatomic, strong) UIButton *pushBtn;
@property (nonatomic, strong) UIScrollView *scrView;
@property (strong, nonatomic) CBGroupAndStreamView * menueView;
@property (nonatomic, strong) UILabel *uilabel;


@end

@implementation SelectIteamViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"发布";
    self.view.backgroundColor = [UIColor blackColor];
    
    [self creatUI];
}

- (void)pushViedo{
    NSLog(@"执行发布操作");
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
    
    XLAlertView *xlAlertView = [[XLAlertView alloc] initWithTitle:@"发布规则" message:@"昆明出口每次看梦想现买现卖行行项目，名小吃麦科马克出没 v 蜂蜜蜂蜜方面发没开门昆明出口每次看梦想现买现卖行行项目，名小吃麦科马克出没 v 蜂蜜蜂蜜方面发没开门昆明出口每次看梦想现买现卖行行项目，名小吃麦科马克出没 v 蜂蜜蜂蜜方面发没开门昆明" sureBtn:@"我知道了" cancleBtn:@""];
    xlAlertView.resultIndex = ^(NSInteger index){
    };
    [xlAlertView showXLAlertView];
}


#pragma mark---delegate
- (void)cb_confirmReturnValue:(NSArray *)valueArr groupId:(NSArray *)groupIdArr{
    NSLog(@"valueArr = %@ \ngroupIdArr = %@",valueArr,groupIdArr);
}

- (void)cb_selectCurrentValueWith:(NSString *)value index:(NSInteger)index groupId:(NSInteger)groupId{
    NSLog(@"value = %@----index = %ld------groupId = %ld",value,index,groupId);
}

-(void)textViewDidChange:(UITextView *)textView
{
    if (_textPush.text.length == 0) {
        _uilabel.text = @"可添加300个文字,我想说...";
    }else{
        _uilabel.text = @"";
    }
}

-(void)creatUI{
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
    NSArray *contentArr = @[@[@"9枝",@"枝",@"11枝",@"21枝",@"33枝",@"99枝",@"99999999枝以上",@"恋人",@"燕草罗帏。",@"亲人恩师恩师",@"恩师恩师",@"病人",@"病人",@"其他",@"恋人",@"常恨言",@"亲人恩师恩师",@"恩师恩师",@"病人",@"绝代有佳人",@"0枝",@"11枝",@"21枝",@"33枝",@"99枝",@"99999999枝以上",@"恋人",@"燕草罗帏。",@"亲人恩师恩师",@"恩师恩师",@"病人",@"燕草罗帏。",@"亲人恩师恩师",@"恩师恩师",@"病人"]];
    
    CBGroupAndStreamView * silde = [[CBGroupAndStreamView alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(_textPush.frame)+ 10, ScreenWidth-20,500)];
    silde.layer.cornerRadius = 6;
    silde.layer.masksToBounds = YES;
    silde.delegate = self;
    silde.isDefaultSel = NO;
    silde.isSingle = NO;
    silde.radius = 18;
    silde.font = [UIFont systemFontOfSize:12];
    silde.titleTextFont = [UIFont systemFontOfSize:18];
    //silde.singleFlagArr = @[@0];
    //silde.defaultSelectIndex = 1;
    //silde.defaultSelectIndexArr = @[@0];
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

@end
