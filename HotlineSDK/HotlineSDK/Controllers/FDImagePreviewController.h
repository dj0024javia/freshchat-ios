//
//  FDImagePreviewController.h
//  HotlineSDK
//
//  Created by Aravinth Chandran on 04/12/15.
//  Copyright © 2015 Freshdesk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FDImagePreviewController : UIViewController<UIScrollViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;

-(instancetype)initWithImage:(UIImage *)image;

-(void)presentOnController:(UIViewController *)controller;

@end