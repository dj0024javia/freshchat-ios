//
//  FDAlertView.m
//  FreshdeskSDK
//
//  Created by Arvchz on 23/02/15.
//  Copyright (c) 2015 Freshdesk. All rights reserved.
//

#import "FCAlertView.h"
#import "FCMacros.h"
#import "FCTheme.h"
#import "FCLocalization.h"

@interface FCAlertView ()

@property (nonatomic, strong) UIImageView* iconView;
@property (nonatomic, assign) CGFloat buttonLabelWidth;
@property (weak, nonatomic) id <FCAlertViewDelegate> delegate;

@end

@implementation FCAlertView

-(instancetype)initWithDelegate:(id <FCAlertViewDelegate>)delegate andKey:(NSString *)key{
    self = [super init];
    if (self) {
        self.delegate = delegate;
        
        self.promptLabel = [self createPromptLabel:key];
        [self addSubview:self.promptLabel];
        
        self.Button1 = [self createPromptButton:@"contact_us" withKey:key];
        [self.Button1 setTitleColor:[[FCTheme sharedInstance] dialogueButtonColor] forState:UIControlStateNormal];
        [self.Button1 addTarget:self.delegate action:@selector(buttonClickedEvent:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.Button1];
        [self setBackgroundColor:[UIColor whiteColor]];
        [self addSpacersInView:self];
    }
    return self;
}

-(void)setupConstraints{
    self.buttonLabelWidth = [self getDesiredWidthFor:self.Button1];
    self.views = @{@"Button1" : self.Button1, @"Prompt":self.promptLabel};
    self.metrics = @{ @"buttonLabelWidth" : @(self.buttonLabelWidth),  @"buttonSpacing" : @(BUTTON_SPACING) };
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[Button1]|" options:NSLayoutFormatAlignAllCenterY metrics:self.metrics views:self.views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[Prompt]|" options:0 metrics:self.metrics views:self.views]];
    [self addConstraint:@"V:|[Prompt][Button1]|" InView:self];
}

-(void)layoutSubviews{
    [self setupConstraints];
    [super layoutSubviews];
}

-(CGFloat)getPromptHeight{
    return ALERT_PROMPT_VIEW_HEIGHT;
}

@end