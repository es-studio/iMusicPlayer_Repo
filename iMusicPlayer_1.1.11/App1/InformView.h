//
//  InformView.h
//  iMusicPlayer
//
//  Created by Han Eunsung on 12. 2. 15..
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MyMusicPlayer.h"

@interface InformView : UIViewController

@property (nonatomic, retain) MyMusicPlayer *mmusic;
@property (nonatomic, retain) IBOutlet UIButton *lyricsButton;


- (IBAction)toggleLoop:(id)sender;

- (IBAction)toggleAlbum:(id)sender;

- (IBAction)toggleLyrics:(id)sender;


@end
