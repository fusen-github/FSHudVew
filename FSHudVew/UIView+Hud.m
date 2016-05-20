//
//  UIView+Hud.m
//  FSHudVew
//
//  Created by 四维图新 on 16/5/20.
//  Copyright © 2016年 四维图新. All rights reserved.
//

#import "UIView+Hud.h"
#import <objc/runtime.h>

@interface FSHudView : UIView

@property (nonatomic) CGFloat spacing;

@property (nonatomic) FSHudState state;

@property (nonatomic, strong) UIImage *image;

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UILabel *label;

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@property (nonatomic, copy) HudTapBlock tapBlock;

@property (nonatomic) UIEdgeInsets insets;

@property (nonatomic, strong) NSDictionary *infoDict;

@property (nonatomic, strong) NSDictionary *colorDict;

- (void)updateHudViewFrame;

- (void)setInfoText:(NSString *)text hudState:(FSHudState)state;

@end

@implementation UIView (Hud)

static char hudViewKey;

- (FSHudView *)associatedHudView
{
    FSHudView *hudView = objc_getAssociatedObject(self, &hudViewKey);
    
    if (hudView == nil) {
        
        hudView = [[FSHudView alloc] initWithFrame:self.bounds];
        
        objc_setAssociatedObject(self, &hudViewKey, hudView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    [self addSubview:hudView];
    
    return hudView;
}

- (void)setHudState:(FSHudState)state
{
    [self setHudState:state image:nil];
}

- (void)setHudState:(FSHudState)state image:(UIImage *)image
{
    FSHudView *hudView = [self associatedHudView];
    
    if (state == FSHudStateRemove)
    {
        [hudView removeFromSuperview];
        
        objc_setAssociatedObject(self, &hudViewKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        return;
    }
    
    hudView.state = state;
    
    hudView.imageView.image = image;
}

- (void)setHudViewTapBlock:(HudTapBlock)tapBlock
{
    FSHudView *hudView = [self associatedHudView];
    
    if (hudView)
    {
        hudView.tapBlock = tapBlock;
    }
}

- (void)setHudEdgeInsets:(UIEdgeInsets)insets
{
    FSHudView *hudView = [self associatedHudView];
    
    if (hudView)
    {
        hudView.insets = insets;
        
        [hudView updateHudViewFrame];
    }
}

- (void)setHudInfoText:(NSString *)text state:(FSHudState)state
{
    if (state != FSHudStateRemove)
    {
        FSHudView *hudView = [self associatedHudView];
        
        if (hudView)
        {
            [hudView setInfoText:text hudState:state];
        }
    }
}

- (void)setSpacingBetweenImageAndLable:(CGFloat)spacing
{
    FSHudView *hudView = [self associatedHudView];
    
    if (hudView)
    {
        hudView.spacing = spacing;
        
        [hudView updateHudViewFrame];
    }
}

- (void)setupHudFont:(UIFont *)font
{
    FSHudView *hudView = [self associatedHudView];
    
    if (hudView)
    {
        hudView.label.font = font;
        
        [hudView updateHudViewFrame];
    }
}

- (void)setTitleColor:(UIColor *)titleColor forState:(FSHudState)state
{
    FSHudView *hudView = [self associatedHudView];
    
    if (hudView)
    {
        NSMutableDictionary *dictM = [hudView.colorDict mutableCopy];
        
        [dictM setObject:titleColor forKey:@(state)];
        
        hudView.colorDict = dictM;
        
        [hudView updateHudViewFrame];
    }
}


@end

@implementation FSHudView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self addSubview:self.label];
        
        [self addSubview:self.imageView];
        
        [self addSubview:self.indicatorView];
        
        self.spacing = 20;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapHudView)];
        
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)didTapHudView
{
    if (self.tapBlock &&
        (self.state == FSHudStateNothing || self.state == FSHudStateError))
    {
        self.tapBlock(self.state);
    }
}

- (void)updateHudViewFrame
{
    CGRect rect = self.superview.frame;
    
    rect.origin.x = self.insets.left;
    
    rect.origin.y = self.insets.top;
    
    rect.size.width -= (self.insets.left + self.insets.right);
    
    rect.size.height -= (self.insets.top + self.insets.bottom);
    
    self.frame = rect;
    
    CGFloat height = self.indicatorView.bounds.size.height;
    
    if (self.imageView.image)
    {
        height = self.imageView.bounds.size.height + self.spacing;
    }
    
    CGFloat y = (rect.size.height - height) * 0.5;
    
    CGFloat labelY = y;
    
    if (self.imageView.image)
    {
        CGFloat x = (rect.size.width - _imageView.bounds.size.width) * 0.5;
        
        _imageView.frame = CGRectMake(x, y, _imageView.bounds.size.width,
                                      _imageView.bounds.size.height);
        
        labelY = CGRectGetMaxY(_imageView.frame) + 20;
    }
    
    _label.text = [self.infoDict objectForKey:@(self.state)];
    
    _label.textColor = [self.colorDict objectForKey:@(self.state)];
    
    [_label sizeToFit];
    
    CGFloat x = (rect.size.width - _label.bounds.size.width) * 0.5;
    
    if (self.state == FSHudStateLoding)
    {
        x = (rect.size.width - _indicatorView.bounds.size.width - _label.bounds.size.width - 10) * 0.5;
        
        [_indicatorView startAnimating];
        
        rect = _indicatorView.frame;
        
        rect.origin = CGPointMake(x, labelY);
        
        _indicatorView.frame = rect;
        
        x = CGRectGetMaxX(_indicatorView.frame) + 10;
    }
    else
    {
        [_indicatorView stopAnimating];
    }
    
    rect = _label.frame;
    
    rect.size.height = _indicatorView.bounds.size.height;
    
    rect.origin = CGPointMake(x, labelY);
    
    _label.frame = rect;
}

- (NSDictionary *)colorDict
{
    if (_colorDict == nil)
    {
        _colorDict = @{@(FSHudStateLoding):[UIColor grayColor],
                       @(FSHudStateNothing):[UIColor grayColor],
                       @(FSHudStateError):[UIColor grayColor]};
    }
    return _colorDict;
}

- (NSDictionary *)infoDict
{
    if (_infoDict == nil)
    {
        _infoDict = @{@(FSHudStateLoding):@"正在加载...",
                      @(FSHudStateNothing):@"没有加载到数据",
                      @(FSHudStateError):@"加载失败，点击重新加载"};
    }
    return _infoDict;
}

- (void)setState:(FSHudState)state
{
    _state = state;
    
    [self updateHudViewFrame];
}

- (UILabel *)label
{
    if (_label == nil)
    {
        _label = [[UILabel alloc] init];
        
        _label.textColor = [UIColor grayColor];
        
        _label.textAlignment = NSTextAlignmentCenter;
        
        _label.font = [UIFont systemFontOfSize:14];
        
        _label.shadowColor = [UIColor whiteColor];
        
        _label.shadowOffset = CGSizeMake(0, 1);
    }
    return _label;
}

- (UIActivityIndicatorView *)indicatorView
{
    if (_indicatorView == nil)
    {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        
        [_indicatorView startAnimating];
    }
    return _indicatorView;
}

- (UIImageView *)imageView
{
    if (_imageView == nil)
    {
        _imageView = [[UIImageView alloc] init];
    }
    return _imageView;
}

- (void)setInfoText:(NSString *)text hudState:(FSHudState)state
{
    NSString *str = text ? text : @"";
    
    NSMutableDictionary *dictM = [self.infoDict mutableCopy];
    
    [dictM setObject:str forKey:@(self.state)];
    
    self.infoDict = dictM;
    
    [self updateHudViewFrame];
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [self.superview removeObserver:self forKeyPath:@"frame" context:nil];
    
    if (newSuperview)
    {
        [newSuperview addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    [self updateHudViewFrame];
}


@end


