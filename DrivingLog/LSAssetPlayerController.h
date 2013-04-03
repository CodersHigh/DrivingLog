//
//  DrivingLogAssetPlayerController.h
//  DrivingLog
//
//  Created by 윤 성관 on 11. 8. 30..
//  Copyright (c) 2011년 LingoStar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import "LSLogData.h"

@interface LSAssetPlayerController : UIViewController

- (IBAction)playerSliderChanged:(id)sender;

@property (strong) LSLogData *selectedLogData;
@property (strong) AVPlayer *assetPlayer;
@property (nonatomic, strong) IBOutlet UISlider *assetPlayerSlider;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *sliderButtonItem;

@property (strong) id playerTimer;


@end
