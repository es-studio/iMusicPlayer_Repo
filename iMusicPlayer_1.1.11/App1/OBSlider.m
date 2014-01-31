//
//  OBSlider.m
//
//  Created by Ole Begemann on 02.01.11.
//  Copyright 2011 Ole Begemann. All rights reserved.
//

#import "OBSlider.h"
#import "MyMusicPlayer.h"


@interface OBSlider ()

@property (atomic, assign, readwrite) float scrubbingSpeed;
@property (atomic, assign) CGPoint beganTrackingLocation;

- (NSUInteger) indexOfLowerScrubbingSpeed:(NSArray*)scrubbingSpeedPositions forOffset:(CGFloat)verticalOffset;
- (NSArray *) defaultScrubbingSpeeds;
- (NSArray *) defaultScrubbingSpeedChangePositions;

@end



@implementation OBSlider    

@synthesize scrubbingSpeed;
@synthesize scrubbingSpeeds;
@synthesize scrubbingSpeedChangePositions;
@synthesize beganTrackingLocation;

@synthesize tmpString;


- (void) dealloc
{
    self.scrubbingSpeeds = nil;
    self.scrubbingSpeedChangePositions = nil;
    [super dealloc];
}


- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
    {
        self.scrubbingSpeeds = [self defaultScrubbingSpeeds];
        self.scrubbingSpeedChangePositions = [self defaultScrubbingSpeedChangePositions];
        self.scrubbingSpeed = [[self.scrubbingSpeeds objectAtIndex:0] floatValue];
        
    }
    return self;
}



#pragma mark -
#pragma mark NSCoding

- (id) initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self != nil) 
    {
    	if ([decoder containsValueForKey:@"scrubbingSpeeds"]) {
            self.scrubbingSpeeds = [decoder decodeObjectForKey:@"scrubbingSpeeds"];
        } else {
            self.scrubbingSpeeds = [self defaultScrubbingSpeeds];
        }

        if ([decoder containsValueForKey:@"scrubbingSpeedChangePositions"]) {
            self.scrubbingSpeedChangePositions = [decoder decodeObjectForKey:@"scrubbingSpeedChangePositions"];
        } else {
            self.scrubbingSpeedChangePositions = [self defaultScrubbingSpeedChangePositions];
        }
        
        self.scrubbingSpeed = [[self.scrubbingSpeeds objectAtIndex:0] floatValue];
    }
    return self;
}


- (void) encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];

    [coder encodeObject:self.scrubbingSpeeds forKey:@"scrubbingSpeeds"];
    [coder encodeObject:self.scrubbingSpeedChangePositions forKey:@"scrubbingSpeedChangePositions"];
    
    // No need to archive self.scrubbingSpeed as it is calculated from the arrays on init
}


#pragma mark -
#pragma mark Touch tracking

- (BOOL) beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    
    BOOL beginTracking = [super beginTrackingWithTouch:touch withEvent:event];
    if (beginTracking)
    {
        
		// Set the beginning tracking location to the centre of the current
		// position of the thumb. This ensures that the thumb is correctly re-positioned
		// when the touch position moves back to the track after tracking in one
		// of the slower tracking zones.
		CGRect thumbRect = [self thumbRectForBounds:self.bounds 
										  trackRect:[self trackRectForBounds:self.bounds]
											  value:self.value];
        self.beganTrackingLocation = CGPointMake(thumbRect.origin.x + thumbRect.size.width / 2.0f, 
												 thumbRect.origin.y + thumbRect.size.height / 2.0f); 
        realPositionValue = self.value;
        
        mmplayer = [MyMusicPlayer sharedMusicPlayer];
        self.tmpString = mmplayer.PlayCount.text;
        mmplayer.PlayCount.text = @"Tracking X 1.0";
        
        
    }
    return beginTracking;
}


- (BOOL) continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (self.tracking)
    {
        CGPoint previousLocation = [touch previousLocationInView:self];
        CGPoint currentLocation  = [touch locationInView:self];
        CGFloat trackingOffset = currentLocation.x - previousLocation.x;
        
        // Find the scrubbing speed that curresponds to the touch's vertical offset
        CGFloat verticalOffset = fabsf(currentLocation.y - self.beganTrackingLocation.y);
        NSUInteger scrubbingSpeedChangePosIndex = [self indexOfLowerScrubbingSpeed:self.scrubbingSpeedChangePositions forOffset:verticalOffset];        
        if (scrubbingSpeedChangePosIndex == NSNotFound) {
            scrubbingSpeedChangePosIndex = [self.scrubbingSpeeds count];
        }
        self.scrubbingSpeed = [[self.scrubbingSpeeds objectAtIndex:scrubbingSpeedChangePosIndex - 1] floatValue];
         
        CGRect trackRect = [self trackRectForBounds:self.bounds];
        realPositionValue = realPositionValue + (self.maximumValue - self.minimumValue) * (trackingOffset / trackRect.size.width);
		
		CGFloat valueAdjustment = self.scrubbingSpeed * (self.maximumValue - self.minimumValue) * (trackingOffset / trackRect.size.width);
		CGFloat thumbAdjustment = 0.0f;
        if ( ((self.beganTrackingLocation.y < currentLocation.y) && (currentLocation.y < previousLocation.y)) ||
             ((self.beganTrackingLocation.y > currentLocation.y) && (currentLocation.y > previousLocation.y)) )
            {
            // We are getting closer to the slider, go closer to the real location
			thumbAdjustment = (realPositionValue - self.value) / ( 1 + fabsf(currentLocation.y - self.beganTrackingLocation.y));
        }
		self.value += valueAdjustment + thumbAdjustment;

        if (self.continuous) {
            [self sendActionsForControlEvents:UIControlEventValueChanged];
        }
        
        mmplayer.PlayCount.text 
        = [NSString stringWithFormat:@"Tracking X %.1f",self.scrubbingSpeed];
        mmplayer.CurrentTime.text
        = [NSString stringWithFormat:@"%02d:%02d", (int)self.value / 60, (int)self.value % 60, nil];
        mmplayer.ElapsedTime.text 
        = [NSString stringWithFormat:@"-%02d:%02d", (int)(mmplayer.durationTimeSec - self.value) / 60, (int)(mmplayer.durationTimeSec - self.value) % 60, nil];
        
        
        
        // seek time
        float scale = mmplayer.player.currentTime.timescale;
        int  divide = 10.0 * self.scrubbingSpeed + 5;
        if((unsigned long)self.value % divide == 0) {
            [mmplayer.player seekToTime:CMTimeMake(self.value * scale, scale)];
        }
        
    
    }
    return self.tracking;
}

- (void)Seeking{
    // seek time
    self.scrubbingSpeed = [[self.scrubbingSpeeds objectAtIndex:0] floatValue];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    
    mmplayer.PlayCount.text = self.tmpString;
    
    float scale = mmplayer.player.currentTime.timescale;
    [mmplayer.player seekToTime:CMTimeMake(self.value * scale, scale)];
}


- (void) endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
        
    self.scrubbingSpeed = [[self.scrubbingSpeeds objectAtIndex:0] floatValue];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    
    mmplayer.PlayCount.text = self.tmpString;
    
    float scale = mmplayer.player.currentTime.timescale;
    [mmplayer.player seekToTime:CMTimeMake(self.value * scale, scale)];
    

    usleep(200000);
    
    NSLog(@"Tracking ? : %d", self.tracking);
}



#pragma mark -
#pragma mark Helper methods

// Return the lowest index in the array of numbers passed in scrubbingSpeedPositions 
// whose value is smaller than verticalOffset.
- (NSUInteger) indexOfLowerScrubbingSpeed:(NSArray*)scrubbingSpeedPositions forOffset:(CGFloat)verticalOffset 
{
    for (NSUInteger i = 0; i < [scrubbingSpeedPositions count]; i++) {
        NSNumber *scrubbingSpeedOffset = [scrubbingSpeedPositions objectAtIndex:i];
        if (verticalOffset < [scrubbingSpeedOffset floatValue]) {
            return i;
        }
    }
    return NSNotFound; 
}



#pragma mark -
#pragma mark Default values

// Used in -initWithFrame: and -initWithCoder:
- (NSArray *) defaultScrubbingSpeeds
{
    return [NSArray arrayWithObjects:
            [NSNumber numberWithFloat:1.0f],
            [NSNumber numberWithFloat:0.9f],
            [NSNumber numberWithFloat:0.8f],
            [NSNumber numberWithFloat:0.7f],
            [NSNumber numberWithFloat:0.6f],
            [NSNumber numberWithFloat:0.5f],
            [NSNumber numberWithFloat:0.4f],
            [NSNumber numberWithFloat:0.3f],
            [NSNumber numberWithFloat:0.2f],
            [NSNumber numberWithFloat:0.1f],
            nil];
}


- (NSArray *) defaultScrubbingSpeedChangePositions
{
    return [NSArray arrayWithObjects:
            [NSNumber numberWithFloat:0.0f],
            [NSNumber numberWithFloat:15.0f],
            [NSNumber numberWithFloat:30.0f],
            [NSNumber numberWithFloat:45.0f],
            [NSNumber numberWithFloat:60.0f],
            [NSNumber numberWithFloat:75.0f],
            [NSNumber numberWithFloat:90.0f],
            [NSNumber numberWithFloat:105.0f],
            [NSNumber numberWithFloat:120.0f],
            [NSNumber numberWithFloat:135.0f],
//            [NSNumber numberWithFloat:150.0f],
//            [NSNumber numberWithFloat:165.0f],
            nil];
}
@end
