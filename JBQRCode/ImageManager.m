//
//  ImageManager.m
//  QRCodeDemo
//
//  Created by jimbo on 2017/7/31.
//  Copyright © 2017年 naver. All rights reserved.
//


#import "ImageManager.h"
@import AVFoundation;
@import Photos;



@interface ImageManager () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@end

@implementation ImageManager

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    return self;
}


- (void)setUpWithType:(JBSelectType )type {
    switch (type) {
        case JBSelectTypePhoto:
        {
            [self takePicture];
            AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
            if (status == AVAuthorizationStatusAuthorized) {
                
            } else {
                [self.delegate showPermissionAlertWithMsg:@"拍照"];
            }
        }
            break;
        case JBSelectTypeImage:
        {
            [self pickPicture];

        }
            break;
        default:
            break;
    }
}


- (void)takePicture {
    
    // 判断设备是否支持拍照
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (authStatus == AVAuthorizationStatusNotDetermined) {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                [self takePicture];
            }];
            return;
        }
        
        if (authStatus != AVAuthorizationStatusAuthorized) {
            [self.delegate showPermissionAlertWithMsg:@"拍照"];
            return;
        }
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        // 委托
        [picker setDelegate:self];
        // 设置picker资源类型
        [picker setSourceType:UIImagePickerControllerSourceTypeCamera];
        // 设置是否可编辑照片
            [picker setAllowsEditing:YES];
        // 设置可用媒体类型
        NSArray *mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
        [picker setMediaTypes:@[mediaTypes[0]]];
        // 设置主摄像头
        if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]) {
            [picker setCameraDevice:UIImagePickerControllerCameraDeviceRear];
        }
        
        // 显示pikcer
        [Root_View_Controller presentViewController:picker animated:YES completion:nil];
    }
}

- (void)pickPicture {
    // 判断设备是否支持相册
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        
         PHAuthorizationStatus authStatus = [PHPhotoLibrary authorizationStatus];
        
        if (authStatus == PHAuthorizationStatusNotDetermined) {
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                [self pickPicture];
            }];
            return;
        }
        if (authStatus != PHAuthorizationStatusAuthorized) {
            [self.delegate showPermissionAlertWithMsg:@"相册"];
            return;
        }
        
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        [picker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        picker.allowsEditing = YES;
        
        [Root_View_Controller presentViewController:picker animated:YES completion:nil];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage  *content = [info objectForKey:UIImagePickerControllerEditedImage];
    [self.delegate getNewImage:content];
    [Root_View_Controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [Root_View_Controller dismissViewControllerAnimated:YES completion:nil];
}

@end
