//
//  SettingsData.h
//  iMusicPlayer
//
//  Created by Han Eunsung on 11. 12. 31..
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SettingsData : NSObject

@property (nonatomic) BOOL isUpdatedForFileTable;
@property (nonatomic) BOOL OnAlbumArt;
@property (nonatomic) BOOL OnLockScreenInfo;
@property (nonatomic) BOOL OnInterruptResume;
@property (nonatomic) int  FileTableFontSize;
@property (nonatomic) int  LyricsAlign;

@property (nonatomic) int  LeftSeekTime1;
@property (nonatomic) int  LeftSeekTime2;

@property (nonatomic) int  RightSeekTime1;
@property (nonatomic) int  RightSeekTime2;

+ (SettingsData *) sharedSettingsData;

- (id) init;

- (void) saveData;

@end

