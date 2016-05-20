//
//  UIView+Hud.h
//  FSHudVew
//
//  Created by 四维图新 on 16/5/20.
//  Copyright © 2016年 四维图新. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, FSHudState){
    
    FSHudStateLoding    = 0, // 正在加载...
    FSHudStateNothing   = 1, // 没有加载到数据。
    FSHudStateError     = 2, // 出现错误，未加载到数据.
    FSHudStateRemove    = 3, // 移除HUD
};

typedef void(^HudTapBlock)(FSHudState state);

@interface UIView (Hud)

- (void)setHudState:(FSHudState)state;

- (void)setHudState:(FSHudState)state image:(UIImage *)image;

- (void)setHudViewTapBlock:(HudTapBlock)tapBlock;

- (void)setHudEdgeInsets:(UIEdgeInsets)insets;

- (void)setHudInfoText:(NSString *)text state:(FSHudState)state;

- (void)setSpacingBetweenImageAndLable:(CGFloat)spacing;

- (void)setupHudFont:(UIFont *)font;

- (void)setTitleColor:(UIColor *)titleColor forState:(FSHudState)state;

@end
