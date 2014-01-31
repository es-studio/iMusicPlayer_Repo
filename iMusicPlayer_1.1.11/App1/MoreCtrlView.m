//
//  MoreCtrlView.m
//  iMusicPlayer
//
//  Created by Han Eunsung on 12. 2. 12..
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MoreCtrlView.h"
#import "MyMusicPlayer.h"
#import "OBSlider.h"
#import "SettingsData.h"

@implementation MoreCtrlView

@synthesize aButton;
@synthesize bButton;
@synthesize xLabel;
@synthesize aLine, bLine;
@synthesize aToggled, bToggled;
@synthesize leftTimeLabel, rightTimeLabel;
@synthesize timeSlider;
@synthesize BWDStep1, BWDStep2, FWDStep1, FWDStep2;
@synthesize xStep;


- (void)dealloc{
    
    [aButton release];
    [bButton release];
    [xLabel release];
    
    [aLine release];
    [bLine release];
    
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    mmusic = [MyMusicPlayer sharedMusicPlayer];
    
    aLine = [[UIView alloc] init];
    bLine = [[UIView alloc] init];
    
    [aLine setBackgroundColor:[UIColor redColor]];
    [bLine setBackgroundColor:[UIColor redColor]];

    self.xStep = 1.0;
}


- (void)initialize{ 
    
    self.aToggled = FALSE;
    self.bToggled = FALSE;
    
    float duration = mmusic.durationTimeSec;

    
    self.leftTimeLabel.text
    = [NSString stringWithString:@"00:00"];
    self.rightTimeLabel.text 
    = [NSString stringWithFormat:@"%02d:%02d", (int)duration / 60, (int)duration % 60, nil];
    [self.timeSlider setMaximumValue:mmusic.durationTimeSec * 1000000000];
    
    
//    self.bButton.enabled = FALSE;
    mmusic.onLoopMode = FALSE;
    mmusic.aTime = CMTimeMake(0, 1000 ^ 3);
    mmusic.bTime = CMTimeMake(0, 1000 ^ 3);
    
    if (mmusic.player.rate > 0) [mmusic.player setRate:1.0];
    
    
    
    self.xStep = 1.0;
    self.xLabel.text = @"x 1.0";
    

    [aLine removeFromSuperview];
    [bLine removeFromSuperview];
    
    UIImage *thum = [UIImage imageNamed:@"Nobe"];
    
    [timeSlider setThumbImage:thum forState:UIControlStateNormal];
    [timeSlider setMaximumTrackImage:[UIImage imageNamed:@"MaxSlide"] forState:UIControlStateNormal];
    [timeSlider setMinimumTrackImage:[UIImage imageNamed:@"MinSlide"] forState:UIControlStateNormal];            

    [timeSlider setThumbImage:thum forState:UIControlStateNormal];
    [timeSlider setThumbImage:thum forState:UIControlStateSelected];
    [timeSlider setThumbImage:thum forState:UIControlStateHighlighted];


    [self changeTimeStep];
    
    
    NSLog(@"MoreCtrlView");

}

- (void)changeTimeStep{

    sets = [SettingsData sharedSettingsData];
    [BWDStep1 setTitle:[NSString stringWithFormat:@"- %d", sets.LeftSeekTime1] 
              forState:UIControlStateNormal];
    [BWDStep2 setTitle:[NSString stringWithFormat:@"- %d", sets.LeftSeekTime2] 
              forState:UIControlStateNormal];
    [FWDStep1 setTitle:[NSString stringWithFormat:@"+ %d", sets.RightSeekTime1] 
              forState:UIControlStateNormal];
    [FWDStep2 setTitle:[NSString stringWithFormat:@"+ %d", sets.RightSeekTime2] 
              forState:UIControlStateNormal];

    
}


- (IBAction)timeSliderValueChange:(id)sender{
    
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (IBAction)reset:(id)sender{
    [self initialize];
    
}

-(IBAction)toggleLSpeed:(id)sender{
    
    if(mmusic.player.rate != 0){ 
        
        if (self.xStep > 0.1){
            self.xStep -= 0.1;
            self.xLabel.text = [NSString stringWithFormat:@"x %.1f", self.xStep];
            [mmusic.player setRate:self.xStep];
        }
    }
    
}

- (IBAction)toggleRSpeed:(id)sender{
    
    if(mmusic.player.rate != 0){ 
        
        if (self.xStep < 2.9){
            self.xStep += 0.1;
            self.xLabel.text = [NSString stringWithFormat:@"x %.1f", self.xStep];
            [mmusic.player setRate:self.xStep];
            
        }
    }

}



- (IBAction)toggleA:(id)sender{
    
    
    leftTimeLabel.text = mmusic.CurrentTime.text;
    mmusic.aTime = mmusic.player.currentTime;
    
    CGRect r = mmusic.Timeline.bounds;
    
    float current = mmusic.Timeline.value;
    float duration = mmusic.durationTimeSec;
    float position = (r.size.width - 20) * current / duration + 27;
    
    [aLine removeFromSuperview];
    aLine.frame = CGRectMake(position, 20, 1, 30);
    [mmusic.TopController insertSubview:aLine atIndex:2];
    
    
    self.leftTimeLabel.text 
    = [NSString stringWithFormat:@"%02d:%02d", (int)current / 60, (int)current % 60, nil];
    [self.timeSlider setMinimumValue:mmusic.player.currentTime.value];

//    self.bButton.enabled = TRUE;
    
}

- (IBAction)toggleB:(id)sender{
    
    rightTimeLabel.text = mmusic.CurrentTime.text;
    
    mmusic.bTime = mmusic.player.currentTime;
    
    CGRect r = mmusic.Timeline.bounds;
    float current = mmusic.Timeline.value;
    float duration = mmusic.durationTimeSec;
    float position = (r.size.width - 20) * current / duration + 27;
    
    [bLine removeFromSuperview];
    bLine.frame = CGRectMake(position, 20, 1, 30);
    [mmusic.TopController insertSubview:bLine atIndex:2];
    
    
    
    self.rightTimeLabel.text 
    = [NSString stringWithFormat:@"%02d:%02d", (int)current / 60, (int)current % 60, nil];
    [self.timeSlider setMaximumValue:mmusic.player.currentTime.value];
    


    mmusic.onLoopMode = TRUE;
    [mmusic.player seekToTime:mmusic.aTime];


    // + 3 sec
//    mmusic.bTime = CMTimeMake(mmusic.aTime.value * 3 + mmusic.aTime.timescale , mmusic.aTime.timescale);
    
    NSLog(@"B toggled");
    
    
//    CMTime currentTime = self.player.currentTime;    
//    currentTimeSec = currentTime.value / currentTime.timescale;
//    
//    if(self.player.rate > 0.0){
//        
//        CurrentTime.text 
//        = [NSString stringWithFormat:@"%02d:%02d", (int)currentTimeSec / 60, (int)currentTimeSec % 60, nil];


}

-(IBAction)toggle1:(id)sender{
    
    unsigned long long backTime = 1000000000;
    backTime *= sets.LeftSeekTime1;
    
    CMTime cTime = mmusic.player.currentTime;
    if(cTime.value < backTime) {
        cTime.value = 0;
    }else{ 
        cTime.value = cTime.value - backTime;
    }
    [mmusic.player seekToTime:cTime];
}

-(IBAction)toggle2:(id)sender{
    
    unsigned long long backTime = 1000000000;
    backTime *= sets.LeftSeekTime2;
    
    
    CMTime cTime = mmusic.player.currentTime;
    if(cTime.value < backTime) {
        cTime.value = 0;
    }else{ 
        cTime.value = cTime.value - backTime;
    }
    [mmusic.player seekToTime:cTime];

}

-(IBAction)toggle3:(id)sender{
    
    unsigned long long backTime = 1000000000;
    backTime *= sets.RightSeekTime1;
    
    CMTime cTime = mmusic.player.currentTime;
    float duration = mmusic.durationTimeSec;
    CMTime dTime = CMTimeMake(duration * 1000000000, 1000000000);

    
    if(cTime.value + backTime > dTime.value) {
        cTime.value = dTime.value;
    }else{ 
        cTime.value = cTime.value + backTime;
    }
    [mmusic.player seekToTime:cTime];
}

-(IBAction)toggle4:(id)sender{
    
    unsigned long long backTime = 1000000000;
    backTime *= sets.RightSeekTime2;

    CMTime cTime = mmusic.player.currentTime;
    float duration = mmusic.durationTimeSec;
    CMTime dTime = CMTimeMake(duration * 1000000000, 1000000000);
    
    
    if(cTime.value + backTime > dTime.value) {
        cTime.value = dTime.value;
    }else{ 
        cTime.value = cTime.value + backTime;
    }
    [mmusic.player seekToTime:cTime];

}

@end
