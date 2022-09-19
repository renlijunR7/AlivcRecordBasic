//
//  XLAlertView.h
//  AlivcRecordBasic
//
//  Created by 2022年 R7.
//

#import <UIKit/UIKit.h>

typedef void(^AlertResult)(NSInteger index);

@interface XLAlertView : UIView

@property (nonatomic,copy) AlertResult resultIndex;

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message sureBtn:(NSString *)sureTitle cancleBtn:(NSString *)cancleTitle;

- (void)showXLAlertView;

@end
