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

#define TIME_SCALE 600

@interface LSCaptureManager (){
    AVAssetWriter *_assetWriter;
	AVAssetWriterInput *_assetWriterInput;
	AVAssetWriterInputPixelBufferAdaptor *_assetWriterPixelBufferAdaptor;
    CFAbsoluteTime _firstFrameClockTime;
}

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
- (id)init
{
    self = [super init];
    if (self != nil){
        self.dateNTimeView = [[[NSBundle mainBundle] loadNibNamed:@"DateNTimeLabel" owner:self options:nil] objectAtIndex:0];
        self.dateNTimeView.frame = CGRectMake(100, 50, 200, 25);
    }
    return self;
}

- (BOOL) setupSessionWithPreset:(NSString *)sessionPreset error:(NSError **)error
{
    BOOL success = NO;
    
    AVCaptureDeviceInput *videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self backFacingCamera] error:error];
    self.videoInput = videoInput;
    
    _videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    [_videoDataOutput setSampleBufferDelegate:self queue:dispatch_queue_create("capturequeue",NULL)];
    
    NSString* key = (NSString*)kCVPixelBufferPixelFormatTypeKey;
    NSNumber* value = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA];
    NSDictionary* videoSettings = [NSDictionary dictionaryWithObject:value forKey:key];
    [_videoDataOutput setVideoSettings:videoSettings];
    
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    
    if ([session canAddInput:videoInput]) {
        [session addInput:videoInput];
    }
    
    if ([session canAddOutput:_videoDataOutput]) {
        [session addOutput:_videoDataOutput];
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

- (void) startRecording
{
    NSLog(@"Starting to record");
    NSError *error = nil;
    
    _assetWriter = [[AVAssetWriter alloc] initWithURL:[self tempFileURL] fileType:AVFileTypeQuickTimeMovie error:&error];
    if (error != nil)
    {
        NSLog(@"Creation of assetWriter resulting in a non-nil error");
    }
    
    CGRect bounds = [[UIScreen mainScreen] applicationFrame];
    NSMutableDictionary *inputSettings=[[NSMutableDictionary alloc] init];
    [inputSettings setValue: AVVideoCodecH264 forKey: AVVideoCodecKey];
    [inputSettings setValue:[NSNumber numberWithInt:bounds.size.width] forKey:AVVideoWidthKey];
    [inputSettings setValue:[NSNumber numberWithInt:bounds.size.height] forKey:AVVideoHeightKey];
    _assetWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:inputSettings];
    _assetWriterInput.expectsMediaDataInRealTime = YES;
    _assetWriterInput.transform = [self assetWriterTransformForDeviceOrientation];
    if (_assetWriterInput == nil)
    {
        NSLog(@"assetWriterInput is nil");
    }
    
    [_assetWriter addInput:_assetWriterInput];
    
    _assetWriterPixelBufferAdaptor = [[AVAssetWriterInputPixelBufferAdaptor  alloc]
                                      initWithAssetWriterInput:_assetWriterInput
                                      sourcePixelBufferAttributes:nil];
    
    [_assetWriter startWriting];
    _firstFrameClockTime = CFAbsoluteTimeGetCurrent();
    [_assetWriter startSessionAtSourceTime:CMTimeMake(0, TIME_SCALE)];
    _isRecording = YES;
}

- (void) stopRecording
{
    [_assetWriterInput markAsFinished];
    [_assetWriter finishWriting];
    _isRecording = NO;
    
    LSAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    LSLogData *newLogData = [[LSLogData alloc] init];
    newLogData.assetName = [[[self tempFileURL] path] lastPathComponent];
    [appDelegate.drivingLogArray addObject:newLogData];
}

- (CGAffineTransform)assetWriterTransformForDeviceOrientation
{
	UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
	if (orientation == UIDeviceOrientationPortrait)
		return CGAffineTransformMakeRotation(M_PI_2);
	else
        if (orientation == UIDeviceOrientationPortraitUpsideDown)
            return CGAffineTransformMakeRotation((3 * M_PI_2));
        else
            if (orientation == UIDeviceOrientationLandscapeRight)
                return CGAffineTransformMakeRotation(M_PI);
	return	CGAffineTransformIdentity;
}

#pragma mark -
#pragma mark Recording Delegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    if (!CMSampleBufferDataIsReady(sampleBuffer))
    {
        NSLog(@"sampleBuffer data is not ready");
    }
    
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    
    // Lock the image buffer
    CVPixelBufferLockBaseAddress(imageBuffer,0);
    
    // Get information about the image
    uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(imageBuffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    // Create a CGImageRef from the CVImageBufferRef
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef newContext = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    
    [self drawDateNTime:newContext];
    
    // We unlock the image buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    // We release some components
    CGContextRelease(newContext);
    CGColorSpaceRelease(colorSpace);
    if (_isRecording)
    {
        if (![_assetWriterInput isReadyForMoreMediaData])
        {
            NSLog(@"Not ready for data :(");
        } else {
            CFAbsoluteTime thisFrameClockTime = CFAbsoluteTimeGetCurrent();
            CFTimeInterval elapsedTime = thisFrameClockTime - _firstFrameClockTime;
            NSLog (@"elapsedTime: %f", elapsedTime);
            CMTime presentationTime =  CMTimeMake (elapsedTime * TIME_SCALE, TIME_SCALE);
            
            BOOL appended = [_assetWriterPixelBufferAdaptor appendPixelBuffer:imageBuffer withPresentationTime:presentationTime];
            
            if (appended) {
                NSLog (@"appended sample at time %lf", CMTimeGetSeconds(presentationTime));
            } else {
                NSLog (@"failed to append");
            }
        }
    }
}

- (void)drawDateNTime:(CGContextRef)context
{
    CGContextSaveGState(context);
    CGContextSetFillColorWithColor(context, [[UIColor blackColor] CGColor]);
    CGContextSetAlpha(context, 0.5);
    CGContextFillRect(context, CGRectMake(180, 270, 80, 440));
    CGContextRestoreGState(context);
    
    NSString *dateNTimeString = [self dateNTimeWithNumbers];
    
    CGContextSaveGState(context);
    //CGAffineTransform bufferTransform = CGAffineTransformMakeRotation(M_PI_2);
    //CGAffineTransform textTransform = CGAffineTransformMake(1.0, 0.0, 0.0, 1.0, 0.0, 0.0);
    //CGAffineTransform concatTransform =  CGAffineTransformConcat(bufferTransform, textTransform);
    //CGContextSetTextMatrix(context, concatTransform);
    
    CGContextSelectFont(context, "Digital-7 Italic", 60.0, kCGEncodingMacRoman);
    CGContextSetTextDrawingMode(context, kCGTextFill);
    CGContextSetFillColorWithColor(context, [[UIColor greenColor] CGColor]);
    CGContextSetTextPosition(context, 230.0f, 280.0f);
    CGContextShowText(context, [dateNTimeString UTF8String], strlen([dateNTimeString UTF8String]));
    
    CGContextRestoreGState(context);
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

- (NSString *)dateNTimeWithNumbers
{
    NSDateFormatter *clockFormatter = [[NSDateFormatter alloc] init];
    clockFormatter.dateFormat = @"yyyy/MM/dd HH:mm:ss";
    
    NSString *clockString = [clockFormatter stringFromDate:[NSDate date]];
    return clockString;
}

- (NSString *)documentDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths lastObject];
}
@end
