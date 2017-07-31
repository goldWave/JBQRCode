//
//  ViewController.m
//  QRCodeDemo
//
//  Created by jimbo on 2017/7/21.
//  Copyright © 2017年 naver. All rights reserved.
//

#define RGBA(R/*红*/, G/*绿*/, B/*蓝*/, A/*透明*/) \
[UIColor colorWithRed:R/255.f green:G/255.f blue:B/255.f alpha:A]

#import "ViewController.h"
#import "Masonry.h"
#import <CoreImage/CoreImage.h>
#import "ImageManager.h"
//#import

@interface ViewController () <ImageManagerDelegate>
@property (nonatomic, strong) UITextField *textFiled;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIButton *selectImageBtn;
@property (nonatomic, strong) ImageManager *imageManager;
@property (nonatomic, strong) UIImageView *selectImageView;
@end

#define imageSize  300

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.textFiled = [[UITextField alloc] init];
    self.textFiled.placeholder = @"输入文字";
    self.textFiled.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:self.textFiled];
    
    
    self.view.backgroundColor = RGBA(239,239,244,1);
    
    
    UIButton *sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [sureBtn setTitle:@"生成二维码" forState:UIControlStateNormal];
    [sureBtn addTarget:self action:@selector(generateQRCode) forControlEvents:UIControlEventTouchUpInside];
    sureBtn.backgroundColor = [UIColor orangeColor];
    sureBtn.layer.cornerRadius = 6;
    [self.view addSubview:sureBtn];
    
    self.imageView = [[UIImageView alloc] init];
    [self.view addSubview:self.imageView];
    
    self.selectImageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.selectImageBtn setTitle:@"选择图片" forState:UIControlStateNormal];
    [self.selectImageBtn addTarget:self action:@selector(addCenterImage) forControlEvents:UIControlEventTouchUpInside];
    [self.selectImageBtn setBackgroundColor:[UIColor orangeColor]];
    self.selectImageBtn.layer.cornerRadius = 6;
    [self.view addSubview:self.selectImageBtn];
    
    [self.view addSubview:self.selectImageView];
    
    
    [self.selectImageBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(100, 30));
        make.right.mas_equalTo(-20);
        make.top.mas_equalTo(100);
    }];
    
    [self.selectImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(100, 100));
        make.centerY.mas_equalTo(self.selectImageBtn.mas_centerY);
        make.centerX.mas_equalTo(self.textFiled.mas_centerX);
    }];
    
    [self.textFiled mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(200, 30));
        make.left.mas_equalTo(20);
        make.top.mas_equalTo(200);
    }];
    [sureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.selectImageBtn.mas_left);
        make.top.mas_equalTo(self.textFiled.mas_top);
        make.size.mas_equalTo(CGSizeMake(100, 30));
    }];
    
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.textFiled.mas_bottom).mas_offset(50);
        make.centerX.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(imageSize, imageSize));
    }];
    
    
    [self generateQRCode];
}

- (void)addCenterImage {
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.imageManager setUpWithType:JBSelectTypePhoto];
    }]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"选取图片" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.imageManager setUpWithType:JBSelectTypeImage];
    }]];
    [actionSheet addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [self presentViewController:actionSheet animated:YES completion:nil];
}

- (void)generateQRCode {
    [self generateWithDefaultQRCodeData:self.textFiled.text imageViewWidth:imageSize];
    if (self.selectImageView.image) {
        [self addPortraitImage];
    }
    
}

- (void)addPortraitImage {
    CGFloat scale = 0.22;
    CGFloat borderW = 3;
    UIView *borderView = [[UIView alloc] init];
    CGFloat borderViewW = imageSize * scale;
    CGFloat borderViewH = imageSize * scale;
    CGFloat borderViewX = 0.5 * (imageSize - borderViewW);
    CGFloat borderViewY = 0.5 * (imageSize - borderViewH);
    borderView.frame = CGRectMake(borderViewX, borderViewY, borderViewW, borderViewH);
    borderView.layer.borderWidth = borderW;
    borderView.layer.borderColor = [UIColor purpleColor].CGColor;
    borderView.layer.cornerRadius = 10;
    borderView.layer.masksToBounds = YES;
    borderView.layer.contents = (id)self.selectImageView.image.CGImage;
    
    [self.imageView addSubview:borderView];
}
- (void )generateWithDefaultQRCodeData:(NSString *)data imageViewWidth:(CGFloat)imageViewWidth {
    // 1、创建滤镜对象
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    
    // 恢复滤镜的默认属性
    [filter setDefaults];
    
    // 2、设置数据
    NSString *info = data.length > 0 ? data : @"你可以输入文字，和选择照片";
    // 将字符串转换成
    NSData *infoData = [info dataUsingEncoding:NSUTF8StringEncoding];
    
    // 通过KVC设置滤镜inputMessage数据
    [filter setValue:infoData forKeyPath:@"inputMessage"];
    
    // 3、获得滤镜输出的图像
    CIImage *outputImage = [filter outputImage];
    
    self.imageView.image = [self createNonInterpolatedUIImageFormCIImage:outputImage withSize:imageViewWidth];
}

/** 根据CIImage生成指定大小的UIImage */
- (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat)size {
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    
    // 1.创建bitmap;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    
    // 2.保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
}


- (void)showPermissionAlertWithMsg:(NSString *)msg {
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"提示" message:[NSString stringWithFormat:@"当前没有%@权限，请到设置页面设置！", msg] preferredStyle:UIAlertControllerStyleAlert];
    [alertVC addAction:[UIAlertAction actionWithTitle:@"" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }]];
    [self presentViewController:alertVC animated:YES completion:nil];
}

- (void)getNewImage:(UIImage *)newImage {
    self.selectImageView.image = newImage;
}

- (ImageManager *)imageManager {
    if (!_imageManager) {
        _imageManager = [[ImageManager alloc] init];
        _imageManager.delegate = self;
    }
    return _imageManager;
}
- (UIImageView *)selectImageView {
    if (!_selectImageView) {
        _selectImageView = [[UIImageView alloc] init];
    }
    return _selectImageView;
}

@end
