//
//  DrivingLogAssetPlayerController.h
//  DrivingLog
//
//  Created by 윤 성관 on 11. 8. 30..
//  Copyright (c) 2011년 LingoStar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "LSLogData.h"

@interface LSAssetPlayerController : UIViewController

@property (strong) LSLogData *selectedLogData;
@property (strong) AVPlayer *assetPlayer;

@end
