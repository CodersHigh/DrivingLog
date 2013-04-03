//
//  DrivingLogAssetPlayerController.m
//  DrivingLog
//
//  Created by 윤 성관 on 11. 8. 30..
//  Copyright (c) 2011년 LingoStar. All rights reserved.
//

#import "LSAssetPlayerController.h"

@implementation LSAssetPlayerController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self setToolbarItems:[NSArray arrayWithObject:self.sliderButtonItem] animated:YES];
    self.navigationController.toolbar.barStyle = UIBarStyleBlackTranslucent;
    [self.navigationController setToolbarHidden:NO animated:YES];
    
    _assetPlayer = self.selectedLogData.logPlayer;
    
    AVPlayerItem *mPlayerItem = _assetPlayer.currentItem;
    CMTimeValue duration = mPlayerItem.duration.value;
    CMTimeScale scale = mPlayerItem.duration.timescale;
    self.assetPlayerSlider.maximumValue = duration/scale;
    
    self.playerTimer = [_assetPlayer addPeriodicTimeObserverForInterval:CMTimeMake(scale/2, scale) queue:dispatch_queue_create("eventQueue", NULL) usingBlock:^(CMTime time) {
        float loopCount = (float)(CMTimeGetSeconds(time));
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.assetPlayerSlider setValue:loopCount animated:YES];
        });
        
        NSLog(@"loop count = %f", loopCount);
    }];
    
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:_assetPlayer];
    [self.view.layer addSublayer:playerLayer];
    playerLayer.frame = self.view.bounds;
    playerLayer.videoGravity = AVLayerVideoGravityResize;
    
    [_assetPlayer play];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setToolbarHidden:YES animated:YES];
}

- (void)viewDidUnload
{
    [self setAssetPlayerSlider:nil];
    [self setSliderButtonItem:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)playerSliderChanged:(id)sender {
    CMTimeScale scale = _assetPlayer.currentTime.timescale;
    CMTimeValue sliderValue = self.assetPlayerSlider.value * scale;
    CMTime sliderTime = CMTimeMake(sliderValue, scale);
    
    [_assetPlayer seekToTime:sliderTime];
}

- (NSString *)documentDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths lastObject];
}
@end
