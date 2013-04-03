//
//  LSCaptureManager.h
//  DrivingLog
//
//  Created by LingoStar on 11. 7. 13..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface LSCaptureManager : NSObject <AVCaptureFileOutputRecordingDelegate>

- (BOOL) setupSessionWithPreset:(NSString *)sessionPreset error:(NSError **)error;
- (void) startRecording;
- (void) stopRecording;

@property (nonatomic,strong) AVCaptureSession *session;
@property (nonatomic,strong) AVCaptureDeviceInput *videoInput;
@property (nonatomic,strong) AVCaptureMovieFileOutput *movieFileOutput;

@property (nonatomic,assign) UIBackgroundTaskIdentifier backgroundRecordingID;
@end
