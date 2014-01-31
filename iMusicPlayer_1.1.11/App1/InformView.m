//
//  InformView.m
//  iMusicPlayer
//
//  Created by Han Eunsung on 12. 2. 15..
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "InformView.h"
#import "SettingsData.h"

#import "MyMusicPlayer.h"

@implementation InformView

@synthesize mmusic;
@synthesize lyricsButton;

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
    mmusic = [MyMusicPlayer sharedMusicPlayer];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}




- (IBAction)toggleLyrics:(id)sender{
    
    
    // toggle from repeat
    if(mmusic.toggleMode == 0){
        
        // remove all
        [UIView animateWithDuration:0.3 animations:^{
            
//            mmusic.albumView.view.alpha = 0;
//            mmusic.albumView.view.center = CGPointMake(160, 356);
            mmusic.CtrlView.view.alpha = 0;
            mmusic.CtrlView.view.center = CGPointMake(160, 356);
            mmusic.lyricsView.view.alpha = 0;

        } completion:^(BOOL ok){
        
        
            if(ok == TRUE){
                
                [UIView animateWithDuration:0.3 animations:^{            
                    mmusic.lyricsView.view.alpha = 1;
                }];

            }
        
        }];


    }else if(mmusic.toggleMode == 1){
        
        
        SettingsData *sets = [SettingsData sharedSettingsData];
        
        switch (sets.LyricsAlign) {
//            case 0:
//                [mmusic.lyricsView.lyricsText setTextAlignment:UITextAlignmentLeft];
//                break;
//                
//            case 1:
//                [mmusic.lyricsView.lyricsText setTextAlignment:UITextAlignmentCenter];                
//                break;
//                
//            case 2:
//                [mmusic.lyricsView.lyricsText setTextAlignment:UITextAlignmentRight];
//                break;
//                
            default:
                [mmusic.lyricsView.lyricsText setTextAlignment:UITextAlignmentCenter];                
                break;
        }
        
        
        
        // show lyrics
        [UIView animateWithDuration:0.3 animations:^{
            
            
            
            
            mmusic.lyricsView.view.alpha = 1;
            
            
        }];
        
    }
    mmusic.toggleMode = 2;
    
}

- (IBAction)toggleAlbum:(id)sender{
    
    
    // toggle from repeat
    if(mmusic.toggleMode == 0){
        
        // remove all
        [UIView animateWithDuration:0.3 animations:^{
            
//            mmusic.albumView.view.alpha = 0;
//            mmusic.albumView.view.center = CGPointMake(160, 356);
            
            mmusic.CtrlView.view.alpha = 0;
            mmusic.CtrlView.view.center = CGPointMake(160, 356);
            
            mmusic.lyricsView.view.alpha = 0;
//            mmusic.CtrlView.view.center = CGPointMake(160, 356);
                        
        }];
        // show albumview
//        [UIView animateWithDuration:0.3 animations:^{
//        
//            
//            mmusic.albumView.view.alpha = 1;
//            mmusic.albumView.view.center = CGPointMake(160, 200);
//
//        }];
        
    }
    // toggle from lyrics
    else if(mmusic.toggleMode == 2){
        
        
        // view lyrics
        [UIView animateWithDuration:0.3 animations:^{
            
            mmusic.lyricsView.view.alpha = 0;
//            mmusic.CtrlView.view.center = CGPointMake(160, 356);
            
        }];
        
        
    }
    
    mmusic.toggleMode = 1;


}

- (IBAction)toggleLoop:(id)sender{
    
    
    if(mmusic.toggleMode != 0){
        
        [UIView animateWithDuration:0.3 animations:^{
            
            mmusic.CtrlView.view.alpha = 0;
            mmusic.CtrlView.view.center = CGPointMake(160, 356);            
            mmusic.lyricsView.view.alpha = 0;
                        
        }];
        
    }
    
    mmusic.toggleMode = 0;
    
    [UIView animateWithDuration:0.3 animations:^{
        mmusic.CtrlView.view.alpha = 1;
        mmusic.CtrlView.view.center = CGPointMake(160, 200);
        [mmusic.CtrlView initialize];        
    }];

}


@end
