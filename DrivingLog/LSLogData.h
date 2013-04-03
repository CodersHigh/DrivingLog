//
//  LSLogData.h
//  DrivingLog
//
//  Created by JokerPortable on 11. 7. 18..
//  Copyright 2011 LingoStar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreLocation/CoreLocation.h>

@interface LSLogData : NSObject <CLLocationManagerDelegate, NSCoding>

@property (strong) NSString *assetName;
@property (strong, readonly) NSString *sizeString;
@property (strong, readonly) NSString *durationString;
@property (strong, readonly) AVPlayer *logPlayer;

@property (readonly) CLLocationCoordinate2D startPosition;
@property (readonly) CLLocationCoordinate2D lastPosition;

@property (strong, readonly) NSString *startAddress;
@property (strong, readonly) NSString *lastAddress;
@end
