//
//  LSAppDelegate.h
//  DrivingLog
//
//  Created by Lingostar on 13. 4. 2..
//  Copyright (c) 2013년 Lingostar. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LSCaptureViewController;

@interface LSAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) LSCaptureViewController *viewController;

@property (strong, readonly) NSMutableArray *drivingLogArray;

@end
