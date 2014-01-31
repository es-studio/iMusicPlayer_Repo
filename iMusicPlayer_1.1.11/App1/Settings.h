//
//  Settings.h
//  iMusicPlayer
//
//  Created by Han Eunsung on 11. 12. 31..
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SettingsData.h"
#import "LoadingView.h"
#import <UIKit/UIKit.h>

@class AbstractActionSheetPicker;


@interface Settings : UITableViewController{
    
    
    UISwitch *AlbumArtSW;
    UISwitch *ResumeSW;
    UISwitch *LockinfoSW;
    
}


@property (nonatomic, retain) NSDictionary *SettingsArray;
@property (nonatomic, retain) NSArray      *SettingsKeys;
@property (nonatomic, retain) SettingsData *Settings;
@property (nonatomic, retain) LoadingView  *loading;
@property (nonatomic, retain) NSArray      *FontSizeArray;
@property (nonatomic, retain) NSArray      *AlignmentArray;

@property (nonatomic, retain) NSArray      *SeekTimeArray;

@property (nonatomic, retain) AbstractActionSheetPicker *actionSheetPicker;




- (void) switchToggled:(id)sender;

- (void) alertClearFolderPlayCache;
- (void) alertClearAlbumArt;
- (void) alertClearID3Database;
- (void) alertClearPlaylistDatabase;

- (void) setFontSize:(NSNumber *)selectedIndex element:(id)element;

- (void) setLyricsAlign:(NSNumber *)selectedIndex element:(id)element;

- (void) setSeekTimeStep1:(NSNumber *)selectedIndex element:(id)element;
- (void) setSeekTimeStep2:(NSNumber *)selectedIndex element:(id)element;
- (void) setSeekTimeStep3:(NSNumber *)selectedIndex element:(id)element;
- (void) setSeekTimeStep4:(NSNumber *)selectedIndex element:(id)element;

- (void) Settings_ThreadProcess;

- (BOOL) canBecomeFirstResponder;


@end
