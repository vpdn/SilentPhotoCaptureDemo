//
//  MMViewController.m
//  SilentPhotoCaptureDemo
//
//  Created by Vinh Phuc Dinh on 24/05/14.
//  Copyright (c) 2014 Mocava Mobile. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "MMViewController.h"

@interface MMViewController ()
@property (nonatomic, strong) UIButton *captureButton;
@property (nonatomic, strong) AVCaptureStillImageOutput *output;
@property (nonatomic, strong) AVCaptureSession *captureSession;
@end

@implementation MMViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    AVCaptureDevice *device = [[devices filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"position = %d", AVCaptureDevicePositionBack]] firstObject];
    if (device==nil) {
        NSLog(@"Can't find camera, meh.");
        return;
    }
    NSError *error = nil;
    AVCaptureDeviceInput *input = [[AVCaptureDeviceInput alloc] initWithDevice:device error:&error];
    self.output = [AVCaptureStillImageOutput new];
    self.captureSession = [AVCaptureSession new];
    AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    previewLayer.frame = self.view.bounds;
    [self.captureSession addInput:input];
    [self.captureSession addOutput:self.output];
    [self.view.layer addSublayer:previewLayer];
    [self.captureSession startRunning];
    
    UIButton *captureButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [captureButton setTitle:@"Capture" forState:UIControlStateNormal];
    [captureButton sizeToFit];
    CGPoint btnCenter = captureButton.center;
    btnCenter.x = CGRectGetMidX(self.view.bounds);
    btnCenter.y = CGRectGetHeight(self.view.bounds) - CGRectGetHeight(captureButton.frame) - 50.0;
    captureButton.center = btnCenter;
    [captureButton addTarget:self action:@selector(captureImage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:captureButton];
}

- (void)captureImage {
    [self.output captureStillImageAsynchronouslyFromConnection:[self.output connectionWithMediaType:AVMediaTypeVideo]
                                             completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        
    }];
    [self playAntiSound];
}

- (void)playAntiSound {
    static SystemSoundID soundID = 0;
    if (soundID == 0) {
        // Play your sound of choice
        NSString *path = [[NSBundle mainBundle] pathForResource:@"photoShutterAntiSound" ofType:@"caf"]; // the antisound by k06aless
//        NSString *path = [[NSBundle mainBundle] pathForResource:@"photoShutterSilence" ofType:@"caf"];   // silence of same length
//        NSString *path = [[NSBundle mainBundle] pathForResource:@"photoShutterRing" ofType:@"caf"];      // a random ring tone
        NSURL *filePath = [NSURL fileURLWithPath:path isDirectory:NO];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)filePath, &soundID);
    }
    AudioServicesPlaySystemSound(soundID);
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
