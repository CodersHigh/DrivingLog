//
//  LSLogData.m
//  DrivingLog
//
//  Created by JokerPortable on 11. 7. 18..
//  Copyright 2011 LingoStar. All rights reserved.
//

#import "LSLogData.h"

@interface LSLogData (){
    CLLocationManager *_locationManager;
    NSString *_durationString;
    NSString *_sizeString;
}

@end
@implementation LSLogData

- (id)init
{
    self = [super init];
    if (self != nil){
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        [_locationManager startUpdatingLocation];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self != nil){
        _assetName = [[NSString alloc] initWithString:[aDecoder decodeObjectForKey:@"AssetName"]];
        _durationString = [[NSString alloc] initWithString:[aDecoder decodeObjectForKey:@"DurationString"]];
        _sizeString = [[NSString alloc] initWithString:[aDecoder decodeObjectForKey:@"SizeString"]];
        _startAddress = [[NSString alloc] initWithString:[aDecoder decodeObjectForKey:@"StartAddress"]];
        _lastAddress = [[NSString alloc] initWithString:[aDecoder decodeObjectForKey:@"LastAddress"]];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_assetName forKey:@"AssetName"];
    [aCoder encodeObject:_durationString forKey:@"DurationString"];
    [aCoder encodeObject:_sizeString forKey:@"SizeString"];
    [aCoder encodeObject:_startAddress forKey:@"StartAddress"];
    [aCoder encodeObject:_lastAddress forKey:@"LastAddress"];
}

- (NSString *)sizeString
{
    if (_sizeString != nil) return _sizeString;
    NSString *assetPath = [[NSString alloc] initWithFormat:@"%@/%@", [self documentDirectory], self.assetName];
    NSDictionary *attributeDict = [[NSFileManager defaultManager] attributesOfItemAtPath:assetPath error:nil];
    float fileSizeInMega = [[attributeDict valueForKey:NSFileSize] floatValue]/1024/1024;
    
    if (fileSizeInMega > 1024) {
        _sizeString = [[NSString alloc] initWithFormat:@"FileSize: %.2f GB", fileSizeInMega/1024];
    } else {
        _sizeString = [[NSString alloc] initWithFormat:@"FileSize: %.2f MB", fileSizeInMega];
    }
    
    return _sizeString;
}

- (NSString *)durationString
{
    if (_durationString != nil) return _durationString;
    NSString *assetPath = [[NSString alloc] initWithFormat:@"%@/%@", [self documentDirectory], self.assetName];
    NSURL *assetURL = [[NSURL alloc] initFileURLWithPath:assetPath];
    
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:assetURL options:nil];
    CMTime duration = urlAsset.duration;
    CMTimeValue value = duration.value;
    CMTimeScale scale = duration.timescale;
    int totalSecond = value/scale;
    
    int hour = totalSecond/3600;
    int minute = (totalSecond%3600)/60;
    int second = totalSecond%60;
    _durationString = [[NSString alloc] initWithFormat:@"%d:%.2d:%.2d", hour, minute, second];
    
    return _durationString;
}

- (AVPlayer *)logPlayer
{
    NSString *assetPath = [[NSString alloc] initWithFormat:@"%@/%@", [self documentDirectory], self.assetName];
    NSURL *assetURL = [[NSURL alloc] initFileURLWithPath:assetPath];
    
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:assetURL options:nil];
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:urlAsset];
    AVPlayer *mPlayer = [[AVPlayer alloc] initWithPlayerItem:playerItem];
    
    return mPlayer;
}

- (NSString *)documentDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths lastObject];
}

#pragma mark -
#pragma mark Location Delegate
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"%s", __FUNCTION__);
    if (oldLocation == nil) {
        _startPosition = newLocation.coordinate;
        CLGeocoder *rGeocoder = [[CLGeocoder alloc] init];
        [rGeocoder reverseGeocodeLocation:newLocation completionHandler:
         ^(NSArray* placemarks, NSError* error){
             if ([placemarks count] > 0)
             {
                 CLPlacemark *placemark = [placemarks objectAtIndex:0];
                 NSLog(@"Start Placemark = %@", placemark);
                 NSString *addressString = [[NSString alloc] initWithFormat:@"%@ %@", placemark.administrativeArea, placemark.thoroughfare];
                 _startAddress = addressString;
                 NSLog(@"Start Address = %@", addressString);
             }}];
        
    }
    _lastPosition = newLocation.coordinate;
    CLGeocoder *rGeocoder = [[CLGeocoder alloc] init];
    [rGeocoder reverseGeocodeLocation:newLocation completionHandler:
     ^(NSArray* placemarks, NSError* error){
         if ([placemarks count] > 0)
         {
             CLPlacemark *placemark = [placemarks objectAtIndex:0];
             NSString *addressString = [[NSString alloc] initWithFormat:@"%@ %@", placemark.administrativeArea, placemark.thoroughfare];
             _lastAddress = addressString;
             NSLog(@"Last Address = %@", addressString);
         }}];
}

@end
