//
//  LSCaptureManager.m
//  DrivingLog
//
//  Created by LingoStar on 11. 7. 13..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LSCaptureManager.h"
#import "LSAppDelegate.h"
#import "LSLogData.h"

@interface LSCaptureManager ()
- (AVCaptureDevice *) cameraWithPosition:(AVCaptureDevicePosition) position;
- (AVCaptureDevice *) frontFacingCamera;
- (AVCaptureDevice *) backFacingCamera;

- (NSURL *) tempFileURL;
- (NSString *)currentDateTime;
- (NSString *)documentDirectory;
@end

@implementation LSCaptureManager

//@synthesize session = _session;
//@synthesize videoInput = _videoInput;
//@synthesize movieFileOutput = _movieFileOutput;

- (BOOL) setupSessionWithPreset:(NSString *)sessionPreset error:(NSError **)error
{
    BOOL success = NO;
    
    AVCaptureDeviceInput *videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self backFacingCamera] error:error];
    self.videoInput = videoInput;
    
    AVCaptureMovieFileOutput *movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
    self.movieFileOutput = movieFileOutput;
    
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    
    if ([session canAddInput:videoInput]) {
        [session addInput:videoInput];
    }
    if ([session canAddOutput:movieFileOutput]) {
        [session addOutput:movieFileOutput];
    }
    
    [session setSessionPreset:sessionPreset];
    [session startRunning];
    
    self.session = session;
    
    success = YES;
    return success;
}

#pragma mark -
#pragma mark Camera Access
- (AVCaptureDevice *) cameraWithPosition:(AVCaptureDevicePosition) position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            return device;
        }
    }
    return nil;
}

- (AVCaptureDevice *) frontFacingCamera
{
    return [self cameraWithPosition:AVCaptureDevicePositionFront];
}

- (AVCaptureDevice *) backFacingCamera
{
    return [self cameraWithPosition:AVCaptureDevicePositionBack];
}

#pragma mark - 
#pragma mark Movie Recording

- (BOOL) isRecording
{
    return [[self movieFileOutput] isRecording];
}

- (void) startRecording
{
    [[self movieFileOutput] startRecordingToOutputFileURL:[self tempFileURL]
                                        recordingDelegate:self];
}

- (void) stopRecording
{
    [[self movieFileOutput] stopRecording];
}


#pragma mark -
#pragma mark Recording Delegate
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections
{
    LSAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    LSLogData *newLogData = [[LSLogData alloc] init];
    newLogData.assetName = [[fileURL path] lastPathComponent];
    [appDelegate.drivingLogArray addObject:newLogData];
}

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
    NSLog(@"%s", __FUNCTION__);
}

#pragma mark - 
#pragma mark Movie File Naming
- (NSURL *) tempFileURL
{    
    NSString *outputPath = [[NSString alloc] initWithFormat:@"%@/%@.mov", [self documentDirectory], [self currentDateTime]];
    NSURL *outputURL = [[NSURL alloc] initFileURLWithPath:outputPath];
    return outputURL;
}

- (NSString *)currentDateTime
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [dateFormatter setAMSymbol:@"AM"];
    [dateFormatter setPMSymbol:@"PM"];
    [dateFormatter setDateStyle:NSDateFormatterShortStyle];
    
    NSString *dateNTimeString = [dateFormatter stringFromDate:[NSDate date]];
    return dateNTimeString;
}

- (NSString *)documentDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths lastObject];
}
@end
