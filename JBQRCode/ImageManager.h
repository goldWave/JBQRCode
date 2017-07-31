//
//  ImageManager.h
//  QRCodeDemo
//
//  Created by jimbo on 2017/7/31.
//  Copyright © 2017年 naver. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"

#define Root_View_Controller [[(AppDelegate *)[[UIApplication sharedApplication] delegate] window] rootViewController]


typedef NS_ENUM(NSInteger, JBSelectType) {
    JBSelectTypePhoto,
    JBSelectTypeImage
};

@protocol ImageManagerDelegate <NSObject>

- (void)showPermissionAlertWithMsg:(NSString *)msg; 

- (void)getNewImage:(UIImage *)newImage;
@end

@interface ImageManager : NSObject 

@property (nonatomic, weak) id<ImageManagerDelegate>delegate;

- (void)setUpWithType:(JBSelectType )type;

@end
