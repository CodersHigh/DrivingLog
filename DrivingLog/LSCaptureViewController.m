//
//  LSCaptureViewController.m
//  DrivingLog
//
//  Created by Lingostar on 13. 4. 2..
//  Copyright (c) 2013년 Lingostar. All rights reserved.
//

#import "LSCaptureViewController.h"
#import "LSAssetController.h"

@interface LSCaptureViewController ()

@end

@implementation LSCaptureViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    NSError *error;
    LSCaptureManager *captureManager = [[LSCaptureManager alloc] init];
    if ([captureManager setupSessionWithPreset:AVCaptureSessionPresetHigh error:&error]) {
        self.captureManager = captureManager;
        
        AVCaptureVideoPreviewLayer *captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:[captureManager session]];
        CALayer *viewLayer = [self.view layer];
        [viewLayer setMasksToBounds:YES];
        
        CGRect bounds = [self.view bounds];
        
        [captureVideoPreviewLayer setFrame:bounds];
        
        if ([captureVideoPreviewLayer isOrientationSupported]) {
            [captureVideoPreviewLayer setOrientation:AVCaptureVideoOrientationPortrait];
        }
        
        [captureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
        
        self.captureVideoPreviewLayer = captureVideoPreviewLayer;
        
        [viewLayer insertSublayer:captureVideoPreviewLayer below:[[viewLayer sublayers] objectAtIndex:0]];
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)toggleRecord:(id)sender {
    BOOL isOn = [(UISwitch *)sender isOn];
    if (isOn){
        [self.captureManager startRecording];
    } else {
        [self.captureManager stopRecording];
    }
}

- (IBAction)presentAssetList:(id)sender {
    LSAssetController *assetTableVC = [[LSAssetController alloc] initWithNibName:@"LSAssetController" bundle:nil];
    UINavigationController *assetNavigationController = [[UINavigationController alloc] initWithRootViewController:assetTableVC];
    
    [self presentModalViewController:assetNavigationController animated:YES]; 
}

@end
