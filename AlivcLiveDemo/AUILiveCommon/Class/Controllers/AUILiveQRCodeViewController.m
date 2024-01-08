//
//  AUILiveSweepCodeViewController.m
//  AlivcLiveCaptureDev
//
//  Created by lyz on 2017/9/28.
//  Copyright © 2017年 Alivc. All rights reserved.
//

#import "AUILiveQRCodeViewController.h"
#import "AUILiveSweepCodeView.h"

#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface AUILiveQRCodeViewController ()<AVCaptureMetadataOutputObjectsDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, AUILiveSweepCodeViewDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) AUILiveSweepCodeView *sweepView;

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
// @property (nonatomic, strong) UIButton *backButton;

@end

@implementation AUILiveQRCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.hiddenMenuButton = YES;
    self.titleView.text = AUILiveCommonString(@"扫码");;
    
    [self setupCamera];

    [self setupSubView];
    
    [self addNotification];
    
    [self.view bringSubviewToFront:self.headerView];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)goBack {
    [super goBack];
    if (self.backValueBlock) {
        self.backValueBlock(NO, nil);
    }
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)addNotification {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(background) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(foreground) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)setupSubView {
    self.view.backgroundColor = [UIColor whiteColor];

    self.sweepView = [[AUILiveSweepCodeView alloc] initWithFrame:self.view.bounds];
    self.sweepView.delegate = self;
    [self.view addSubview:self.sweepView];
}


#pragma mark - AUILiveSweepCodeViewDelegate

- (void)onClickSweepCodeViewLightButton:(BOOL)isLight {
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([device hasTorch]) {
        [device lockForConfiguration:nil];
        if (isLight) {
            [device setTorchMode:AVCaptureTorchModeOn];
        } else {
            [device setTorchMode: AVCaptureTorchModeOff];
        }
        [device unlockForConfiguration];
    }


}


- (void)background {
    
    [self stopCamera];
}

- (void)foreground {
    [self setupCamera];
}

#pragma mark - 从相册中读取照片

- (void)jumpPickerController {
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:YES completion:nil];
}


#pragma mark - 二维码扫描

- (void)setupCamera {
    
    if (self.session) {
        return;
    }
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];//读取设备授权状态
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:AUILiveCommonString(@"提示") message:AUILiveCommonString(@"当前没有摄像头权限，请在设置中打开摄像头权限") delegate:self cancelButtonTitle:AUILiveCommonString(@"去设置") otherButtonTitles:AUILiveCommonString(@"取消"), nil];
        [alert show];
        return;
    }
    
    self.session = [[AVCaptureSession alloc] init];
    self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    output.rectOfInterest = CGRectMake(0.05, 0.2, 0.7, 0.6);
    self.session.sessionPreset = AVCaptureSessionPresetHigh;
    [self.session addInput:input];
    [self.session addOutput:output];
    output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeEAN13Code,  AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
    
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.previewLayer.frame = self.view.bounds;
    [self.view.layer addSublayer:self.previewLayer];
    
    [self.session startRunning];
    
}

- (void)stopCamera {
    
    [self.session stopRunning];
    self.session = nil;
    
    [self.previewLayer removeFromSuperlayer];
}

#pragma mark - - - 二维码扫描代理方法

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    
    if (metadataObjects.count > 0) {
        AVMetadataMachineReadableCodeObject *metadataObj = metadataObjects[0];
        
        NSLog(@"扫描的数据:%@", metadataObj);
        
        //判断回传的数据类型
        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode]) {
            // 二维码
            [self playSound];
            
            [self stopCamera];
            
            NSString *sweepCodeString;
            if (metadataObj.stringValue) {
                sweepCodeString = metadataObj.stringValue;
            }
            
            if (self.backValueBlock) {
                self.backValueBlock(YES, sweepCodeString);
            }
            [self.navigationController popViewControllerAnimated:YES];

        }
    }
}

#pragma mark - 音效

void soundCompleteCallBack(SystemSoundID soundID, void *clientData) {
    
    NSLog(@"音效播放完成");
}


- (void)playSound {
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"dong.wav" ofType:nil];
    NSURL *fileUrl = [NSURL URLWithString:filePath];
    SystemSoundID soundID = 6;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)(fileUrl), &soundID);
    AudioServicesAddSystemSoundCompletion(soundID,NULL,NULL,soundCompleteCallBack,NULL);
    AudioServicesPlaySystemSound(soundID);
}



#pragma mark - 从相册中识别二维码, 并进行界面跳转

- (void)scanQRCodeFromPhotosInTheAlbum:(UIImage *)image {
    
    // CIDetector(CIDetector可用于人脸识别)进行图片解析，从而使我们可以便捷的从相册中获取到二维码
    // 声明一个CIDetector，并设定识别类型 CIDetectorTypeQRCode
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{ CIDetectorAccuracy : CIDetectorAccuracyHigh }];
    
    // 取得识别结果
    NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];
    
    NSLog(@"扫描图片结果 － － %@", features);
    
    for (int index = 0; index < [features count]; index ++) {
        CIQRCodeFeature *feature = [features objectAtIndex:index];
        NSString *scannedResult = feature.messageString;
        NSLog(@"result:%@",scannedResult);
        
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    NSLog(@"info - - - %@", info);
    
    [self dismissViewControllerAnimated:YES completion:^{
        [self scanQRCodeFromPhotosInTheAlbum:[info objectForKey:@"UIImagePickerControllerOriginalImage"]];
    }];
}

#pragma mark - UIAlertViewDelegte

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        
        if([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
        }
    }
}

@end
