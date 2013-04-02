//
//  LSCaptureViewController.h
//  DrivingLog
//
//  Created by Lingostar on 13. 4. 2..
//  Copyright (c) 2013년 Lingostar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LSCaptureManager.h"

@interface LSCaptureViewController : UIViewController


- (IBAction)toggleRecord:(id)sender;
- (IBAction)presentAssetList:(id)sender;


@property (nonatomic,strong) LSCaptureManager *captureManager;
@property (nonatomic,strong) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;

@end
