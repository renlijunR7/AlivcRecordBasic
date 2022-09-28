//
//  QURecordParamViewController.m
//  AliyunVideo
//
//  Created by dangshuai on 17/3/6.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AlivcBase_RecordParamViewController.h"

#import <AssetsLibrary/AssetsLibrary.h>

#import "AlivcBase_RecordParamTableViewCell.h"
//#import "AliyunVideoRecordParam.h"
#import "AlivcBase_RecordViewController.h"
#import "AliyunVideoBase.h"
#import "AliyunVideoCropParam.h"
#import "AliyunVideoUIConfig.h"
#import "MBProgressHUD+AlivcHelper.h"

@interface AlivcBase_RecordParamViewController ()<UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *dataArray;
@property (weak, nonatomic) IBOutlet UILabel *paramTitleLabel;

@property (weak, nonatomic) IBOutlet UIButton *backButton;


@property (nonatomic, strong) AliyunVideoRecordParam *quVideo;

@property (nonatomic, assign) CGFloat videoOutputWidth;
@property (nonatomic, assign) CGFloat videoOutputRatio;
@property (weak, nonatomic) IBOutlet UIButton *rightButton;

@end

@implementation AlivcBase_RecordParamViewController

- (instancetype)init {
    NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"AlivcRecordBasic.bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:path];
    return [self initWithNibName:@"AlivcBase_RecordParamViewController" bundle:bundle];
}

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.paramTitleLabel.text = NSLocalizedString(@"录制参数", nil);
    [self.rightButton setTitle: NSLocalizedString(@"硬编", nil) forState:UIControlStateNormal];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self setupParamData];
    [self setupSDKBaseVersionUI];
    [_tableView reloadData];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenKeyboard:)];
    [self.tableView addGestureRecognizer:tapGesture];
    
    
    _quVideo = [[AliyunVideoRecordParam alloc] init];
    _quVideo.ratio = AliyunVideoVideoRatio3To4;
    _quVideo.size = AliyunVideoVideoSize540P;
    _quVideo.minDuration = 2;
    _quVideo.maxDuration = 15;
    _quVideo.position = AliyunCameraPositionFront;
    _quVideo.beautifyStatus = YES;
    _quVideo.beautifyValue = 100;
    _quVideo.torchMode = AliyunCameraTorchModeOff;
    _quVideo.outputPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/record_save.mp4"];
    
    [self.backButton setImage:[AlivcImage imageNamed:@"back"] forState:UIControlStateNormal];
    self.videoOutputRatio = 0.75;
    self.videoOutputWidth = 540;
    
}

- (IBAction)rightButtonClick:(UIButton *)sender {
    if ([[sender titleForState:UIControlStateNormal] isEqualToString:NSLocalizedString(@"硬编", nil)]) {
        [sender setTitle:NSLocalizedString(@"软编", nil) forState:UIControlStateNormal];
        _quVideo.encodeMode = AliyunEncodeModeSoftFFmpeg;
    }else{
        [sender setTitle:NSLocalizedString(@"硬编", nil) forState:UIControlStateNormal];
        _quVideo.encodeMode = AliyunEncodeModeHardH264;
    }
}

- (void)hiddenKeyboard:(id)sender {
    [self.view endEditing:YES];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    AlivcBase_RecordParamModel *model = _dataArray[indexPath.row];
    if (model) {
        NSString *identifier = model.reuseId;
        AlivcBase_RecordParamTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[AlivcBase_RecordParamTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        [cell configureCellModel:model];
        return cell;
    }
    return nil;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] init];
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(ScreenWidth / 2 - 50, 0, 100, 44)];
    [button setTitle:NSLocalizedString(@"启动录制", nil) forState:0];
    [button addTarget:self action:@selector(toRecordView) forControlEvents:UIControlEventTouchUpInside];
    button.backgroundColor = RGBToColor(240, 84, 135);
    [view addSubview:button];
    return view;
}

- (void)setupParamData {
     __weak typeof(self) weakSelf = self;
    AlivcBase_RecordParamModel *cellModel1 = [[AlivcBase_RecordParamModel alloc] init];
    cellModel1.title = NSLocalizedString(@"最小时长", nil);
    cellModel1.placeHolder = NSLocalizedString(@"最小时长大于0，默认值2s", nil);
    cellModel1.reuseId = @"cellInput";
    cellModel1.defaultValue = 2;
    cellModel1.valueBlock = ^(int value){
        weakSelf.quVideo.minDuration = value;
    };
    
    AlivcBase_RecordParamModel *cellModel2 = [[AlivcBase_RecordParamModel alloc] init];
    cellModel2.title = NSLocalizedString(@"最大时长", nil);
    cellModel2.placeHolder = NSLocalizedString(@"建议不超过300s，默认值15s", nil);
    cellModel2.reuseId = @"cellInput";
    cellModel2.defaultValue = 15;
    cellModel2.valueBlock = ^(int value){
        weakSelf.quVideo.maxDuration = value;
    };
    
    AlivcBase_RecordParamModel *cellModel3 = [[AlivcBase_RecordParamModel alloc] init];
    cellModel3.title = NSLocalizedString(@"关键帧间隔", nil);
    cellModel3.placeHolder = NSLocalizedString(@"建议1-300，默认5", nil);
    cellModel3.reuseId = @"cellInput";
    cellModel3.defaultValue = 5;
    cellModel3.valueBlock = ^(int value) {
        weakSelf.quVideo.gop = value;
    };
    
    AlivcBase_RecordParamModel *cellModel4 = [[AlivcBase_RecordParamModel alloc] init];
    cellModel4.title = NSLocalizedString(@"视频质量", nil);
    cellModel4.placeHolder = NSLocalizedString(@"高",nil);
    cellModel4.reuseId = @"cellSilder";
    cellModel4.defaultValue = 0.25;
    cellModel4.valueBlock = ^(int value){
        weakSelf.quVideo.videoQuality = value;
    };
    
    AlivcBase_RecordParamModel *cellModel5 = [[AlivcBase_RecordParamModel alloc] init];
    cellModel5.title = NSLocalizedString(@"视频比例", nil);
    cellModel5.placeHolder = @"3:4";
    cellModel5.reuseId = @"cellSilder";
    cellModel5.defaultValue = 0.6;
    cellModel5.ratioBack = ^(CGFloat videoRatio){
        weakSelf.videoOutputRatio = videoRatio;
    };
    
    AlivcBase_RecordParamModel *cellModel6 = [[AlivcBase_RecordParamModel alloc] init];
    cellModel6.title = NSLocalizedString(@"分辨率", nil);
    cellModel6.placeHolder = @"540P";
    cellModel6.reuseId = @"cellSilder";
    cellModel6.defaultValue = 0.75;
    cellModel6.sizeBlock = ^(CGFloat videoWidth){
        weakSelf.videoOutputWidth = videoWidth;
    };
    
    
    _dataArray = @[cellModel1,cellModel2,cellModel3,cellModel4,cellModel5,cellModel6];
}

//基础版参数绘制
- (void)setupSDKBaseVersionUI {
    AliyunVideoUIConfig *config = [[AliyunVideoUIConfig alloc] init];
    
    config.backgroundColor = RGBToColor(35, 42, 66);
    config.timelineBackgroundCollor = RGBToColor(35, 42, 66);
    config.timelineDeleteColor = [UIColor redColor];
    config.timelineTintColor = RGBToColor(239, 75, 129);
    config.durationLabelTextColor = [UIColor redColor];
    config.cutTopLineColor = [UIColor redColor];
    config.cutBottomLineColor = [UIColor redColor];
    config.noneFilterText = NSLocalizedString(@"无滤镜", nil);
    config.hiddenDurationLabel = NO;
    config.hiddenFlashButton = NO;
    config.hiddenBeautyButton = NO;
    config.hiddenCameraButton = NO;
    config.hiddenImportButton = NO;
    config.hiddenDeleteButton = NO;
    config.hiddenFinishButton = NO;
    config.recordOnePart = NO;
    config.filterArray = @[@"Filter/炽黄",@"Filter/粉桃",@"Filter/海蓝",@"Filter/红润",@"Filter/灰白",@"Filter/经典",@"Filter/麦茶",@"Filter/浓烈",@"Filter/柔柔",@"Filter/闪耀",@"Filter/鲜果",@"Filter/雪梨",@"Filter/阳光",@"Filter/优雅",@"Filter/朝阳",@"Filter/波普",@"Filter/光圈",@"Filter/海盐",@"Filter/黑白",@"Filter/胶片",@"Filter/焦黄",@"Filter/蓝调",@"Filter/迷糊",@"Filter/思念",@"Filter/素描",@"Filter/鱼眼",@"Filter/马赛克",@"Filter/模糊"];
    //    config.filterArray = @[NSLocalizedString(@"炽黄", nil),NSLocalizedString(@"粉桃", nil),NSLocalizedString(@"海蓝", nil),NSLocalizedString(@"红润", nil),NSLocalizedString(@"灰白", nil),NSLocalizedString(@"经典", nil),NSLocalizedString(@"麦茶", nil),NSLocalizedString(@"浓烈", nil),NSLocalizedString(@"柔柔", nil),NSLocalizedString(@"闪耀", nil),NSLocalizedString(@"鲜果", nil),NSLocalizedString(@"雪梨", nil),NSLocalizedString(@"阳光", nil),NSLocalizedString(@"优雅", nil),NSLocalizedString(@"朝阳", nil),NSLocalizedString(@"波普", nil),NSLocalizedString(@"光圈", nil),NSLocalizedString(@"海盐", nil),NSLocalizedString(@"黑白", nil),NSLocalizedString(@"胶片", nil),NSLocalizedString(@"焦黄", nil),NSLocalizedString(@"蓝调", nil),NSLocalizedString(@"迷糊", nil),NSLocalizedString(@"思念", nil),NSLocalizedString(@"素描", nil),NSLocalizedString(@"鱼眼", nil),NSLocalizedString(@"马赛克", nil),NSLocalizedString(@"模糊", nil)];
    
    config.imageBundleName = @"QPSDK";
    config.filterBundleName = @"FilterResource";
    config.recordType = AliyunVideoRecordTypeCombination;
    config.showCameraButton = NO;
    
    [[AliyunVideoBase shared] registerWithAliyunIConfig:config];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [self.view resignFirstResponder];
}

- (IBAction)buttonBackClick:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)toRecordView {
    [self.view endEditing:YES];
    
    [self settingVideoSize];
    [self settingVideoRatio];
    
    if (_quVideo.minDuration <= 0) {
        [MBProgressHUD showMessage:NSLocalizedString(@"最小时长要大于0", nil) inView:self.view];
        return;
    }
    
    if (_quVideo.maxDuration <= 0) {
        [MBProgressHUD showMessage:NSLocalizedString(@"最大时长要大于0", nil) inView:self.view];
        return;
    }
    
    
    if (_quVideo.maxDuration <= _quVideo.minDuration) {

        //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"提示", nil) message:NSLocalizedString(@"最大时长不得小于最小时长", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"确定" , nil) otherButtonTitles: nil];
        //[alert show];
        
        [MBProgressHUD showWarningMessage:NSLocalizedString(@"最大时长不得小于最小时长", nil) inView:self.view];
        return;
    }
    
    if (_quVideo.maxDuration > 300) {
        [MBProgressHUD showMessage:NSLocalizedString(@"最大时长不能超过300s", nil) inView:self.view];
        return;
    }
    UIViewController *recordViewController = [[AliyunVideoBase shared] createRecordViewControllerWithRecordParam:_quVideo];
    [AliyunVideoBase shared].delegate = (id)self;
    NSLog(@"参数 === %@",_quVideo);
    
    [self.navigationController pushViewController:recordViewController animated:YES];
}


-(void)settingVideoSize{
    if (self.videoOutputWidth == 360) {
        _quVideo.size = AliyunVideoVideoSize360P;
    }else if (self.videoOutputWidth == 480) {
        _quVideo.size = AliyunVideoVideoSize480P;
    }else if (self.videoOutputWidth == 540) {
        _quVideo.size = AliyunVideoVideoSize540P;
    }else if (self.videoOutputWidth == 720) {
        _quVideo.size = AliyunVideoVideoSize720P;
    }
}

-(void)settingVideoRatio{
    if (self.videoOutputRatio == 0.5625) {
        _quVideo.ratio = AliyunVideoVideoRatio9To16;
    }else if (self.videoOutputRatio == 0.75) {
        _quVideo.ratio = AliyunVideoVideoRatio3To4;
    } else {
        _quVideo.ratio = AliyunVideoVideoRatio1To1;
    }
}

#pragma mark - AliyunVideoBaseDelegate
-(void)videoBaseRecordVideoExit {
    NSLog(@"退出录制");
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)videoBase:(AliyunVideoBase *)base recordCompeleteWithRecordViewController:(UIViewController *)recordVC videoPath:(NSString *)videoPath {
    NSLog(@"录制完成  %@", videoPath);
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library writeVideoAtPathToSavedPhotosAlbum:[NSURL fileURLWithPath:videoPath]
                                completionBlock:^(NSURL *assetURL, NSError *error) {
                                    
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        //[recordVC.navigationController popViewControllerAnimated:YES];
                                    });
                                }];
}

- (AliyunVideoCropParam *)videoBaseRecordViewShowLibrary:(UIViewController *)recordVC {
    [self settingVideoSize];
    
    [self settingVideoRatio];
    NSLog(@"录制页跳转Library");
    // 可以更新相册页配置
    AliyunVideoCropParam *mediaInfo = [[AliyunVideoCropParam alloc] init];
    mediaInfo.minDuration = 2.0;
    mediaInfo.maxDuration = 10.0*60;
    mediaInfo.fps = _quVideo.fps;
    mediaInfo.gop = _quVideo.gop;
    mediaInfo.videoQuality = _quVideo.videoQuality;
    mediaInfo.videoOnly = YES;//视频裁剪功能只显示视频
    mediaInfo.size = _quVideo.size;
    mediaInfo.ratio = _quVideo.ratio;
    mediaInfo.cutMode = AliyunVideoCutModeScaleAspectFill;
    mediaInfo.outputPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/cut_save.mp4"];
    return mediaInfo;
    
}

// 裁剪
- (void)videoBase:(AliyunVideoBase *)base cutCompeleteWithCropViewController:(UIViewController *)cropVC videoPath:(NSString *)videoPath {
    
    NSLog(@"裁剪完成  %@", videoPath);
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library writeVideoAtPathToSavedPhotosAlbum:[NSURL fileURLWithPath:videoPath]
                                completionBlock:^(NSURL *assetURL, NSError *error) {
                                    
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [cropVC.navigationController popViewControllerAnimated:YES];
                                    });
                                }];
    
}

- (AliyunVideoRecordParam *)videoBasePhotoViewShowRecord:(UIViewController *)photoVC {
    
    NSLog(@"跳转录制页");
    return nil;
}

- (void)videoBasePhotoExitWithPhotoViewController:(UIViewController *)photoVC {
    
    NSLog(@"退出相册页");
    [photoVC.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 默认竖屏
- (BOOL)shouldAutorotate{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}


- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}
@end
