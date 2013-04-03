//
//  LSCaptureManager.h
//  DrivingLog
//
//  Created by LingoStar on 11. 7. 13..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <CoreVideo/CoreVideo.h>

@interface LSCaptureManager : NSObject <AVCaptureFileOutputRecordingDelegate>

- (BOOL) setupSessionWithPreset:(NSString *)sessionPreset error:(NSError **)error;
- (void) startRecording;
- (void) stopRecording;

- (CGAffineTransform)assetWriterTransformForDeviceOrientation;
- (void)drawDateNTime:(CGContextRef)context;

@property (nonatomic,strong) AVCaptureSession *session;
@property (nonatomic,strong) AVCaptureDeviceInput *videoInput;
@property (nonatomic,retain) AVCaptureVideoDataOutput *videoDataOutput;

@property (nonatomic,assign) UIBackgroundTaskIdentifier backgroundRecordingID;

@property (nonatomic,retain) UIView *dateNTimeView;
@property BOOL isRecording;
@end
