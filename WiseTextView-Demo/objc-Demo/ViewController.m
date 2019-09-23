//
//  ViewController.m
//  objc-Demo
//
//  Created by frank on 2019/9/23.
//  Copyright © 2019 frank. All rights reserved.
//

#import "ViewController.h"
#import "objc_Demo-Swift.h"

@interface ViewController ()<UIScrollViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColor.whiteColor;
    
    UIScrollView *bgScrollView = [UIScrollView new];
    [self.view addSubview:bgScrollView];
    bgScrollView.delegate = self;
    bgScrollView.translatesAutoresizingMaskIntoConstraints = NO;
    bgScrollView.contentSize = CGSizeMake(kUIScreenWidth, kUIScreenHeight * 1.5);
    
    NSArray<NSLayoutConstraint *> *contraint1 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[bg]-0-|" options:NSLayoutFormatAlignAllLeft metrics:nil views:@{@"bg": bgScrollView}];
    NSArray<NSLayoutConstraint *> *contriant2 = [NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-%f-[bg]-%f-|",kNavigationBarHeight,  SafeAreaBottomSpace+kUIFitSize(10.0)] options:NSLayoutFormatAlignAllTop metrics:nil views:@{@"bg": bgScrollView}];
    [self.view addConstraints:contraint1];
    [self.view addConstraints:contriant2];
    
    WiseTextView *inputView = [[WiseTextView alloc] initWithFrame:CGRectMake(kUIFitSize(16), kUIFitSize(10), kUIScreenWidth - kUIFitSize(32), kUIFitSize(100)) cursorSpace:20];
    [bgScrollView addSubview:inputView];
    inputView.font = [UIFont systemFontOfSize:kUIFitSize(16)];
    inputView.textColor = kUIColorFromRGB(0x333333);
    inputView.layer.borderColor = kUIColorFromRGB(0x777777).CGColor;
    inputView.layer.borderWidth = 0.5;
    inputView.placeholder = @"分享此刻新鲜事...";
    inputView.returnKeyType = UIReturnKeyDone;
    //文本输入框成为第一响应者
    inputView.textBecomeFirstRespnderClouse = ^{
        
    };
    //输入内容变化
    inputView.textValueChangedBlock = ^(NSString * _Nonnull valueStr) {
        NSLog(@"%@", valueStr);
    };
    __block WiseTextView *cinputview = inputView;
    WS(weakSelf)
    inputView.updateTxtHeightClouse = ^(CGFloat currentH) {
        NSLog(@"%f", currentH);
        CGRect cframe = cinputview.frame;
        cframe.size.height = currentH;
        cinputview.frame = cframe;
        if(cinputview.frame.origin.y + cinputview.frame.size.height != bgScrollView.contentSize.height) {
            if(cinputview.frame.origin.y + cinputview.frame.size.height < weakSelf.view.frame.size.height) {
                
            } else {
                CGSize bgContentSize = bgScrollView.contentSize;
                bgContentSize.height = cinputview.frame.origin.y + cinputview.frame.size.height;
                bgScrollView.contentSize = bgContentSize;
            }
        }
    };
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

- (void)dealloc
{
    NSLog(@"%s---%s", __func__, __FILE_NAME__);
}

@end
