//
//  MoreCtrlView.h
//  iMusicPlayer
//
//  Created by Han Eunsung on 12. 2. 12..
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MyMusicPlayer;
@class SettingsData;

@interface MoreCtrlView : UIViewController{
    
    MyMusicPlayer   *mmusic;
    SettingsData    *sets;
}


//@property (nonatomic, retain) MyMusicPlayer  *music;
//@property (nonatomic ,retain) IBOutlet UIButton *Btt1;
//@property (nonatomic ,retain) IBOutlet UIButton *Btt2;
//@property (nonatomic ,retain) IBOutlet UIButton *Btt3;
//@property (nonatomic ,retain) IBOutlet UIButton *Btt4;

@property (nonatomic ,retain) IBOutlet UIButton *aButton;
@property (nonatomic ,retain) IBOutlet UIButton *bButton;
@property (nonatomic ,retain) IBOutlet UISlider *timeSlider;
@property (nonatomic, retain) IBOutlet UILabel  *xLabel;
@property (nonatomic, retain) IBOutlet UILabel  *leftTimeLabel;
@property (nonatomic, retain) IBOutlet UILabel  *rightTimeLabel;

//@property (nonatomic, retain) IBOutlet UIStepper *xStepper;

@property (nonatomic, retain) IBOutlet UIButton  *BWDStep1;
@property (nonatomic, retain) IBOutlet UIButton  *BWDStep2;
@property (nonatomic, retain) IBOutlet UIButton  *FWDStep1;
@property (nonatomic, retain) IBOutlet UIButton  *FWDStep2;



@property (nonatomic ,retain) UIView *aLine;
@property (nonatomic ,retain) UIView *bLine;

@property (nonatomic) BOOL aToggled;
@property (nonatomic) BOOL bToggled;
@property (nonatomic) float  xStep;

- (void) initialize;

- (void) changeTimeStep;

- (IBAction)reset:(id)sender;

- (IBAction)toggleA:(id)sender;

- (IBAction)toggleB:(id)sender;

- (IBAction)timeSliderValueChange:(id)sender;

- (IBAction)toggle1:(id)sender;
- (IBAction)toggle2:(id)sender;
- (IBAction)toggle3:(id)sender;
- (IBAction)toggle4:(id)sender;


-(IBAction)toggleLSpeed:(id)sender;
-(IBAction)toggleRSpeed:(id)sender;
@end


