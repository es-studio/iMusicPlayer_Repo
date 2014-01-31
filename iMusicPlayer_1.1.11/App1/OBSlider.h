//
//  OBSlider.h
//
//  Created by Ole Begemann on 02.01.11.
//  Copyright 2011 Ole Begemann. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MyMusicPlayer;

@interface OBSlider : UISlider
{
    float scrubbingSpeed;
    NSArray *scrubbingSpeeds;
    NSArray *scrubbingSpeedChangePositions;
    
    CGPoint beganTrackingLocation;
	
    float realPositionValue;

    MyMusicPlayer *mmplayer;
    
}


@property (atomic, assign, readonly) float scrubbingSpeed;
@property (atomic, retain) NSArray *scrubbingSpeeds;
@property (atomic, retain) NSArray *scrubbingSpeedChangePositions;

@property (atomic, retain) NSString *tmpString;

- (void) Seeking;

@end
