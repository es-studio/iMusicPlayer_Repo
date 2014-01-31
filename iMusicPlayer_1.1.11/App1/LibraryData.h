//
//  LibraryData.h
//  iMusicPlayer
//
//  Created by Han Eunsung on 12. 2. 17..
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface LibraryData : NSObject <NSCoding>

@property (nonatomic, retain) NSMutableDictionary *PlaylistDB;


+ (LibraryData *) sharedLibrary;

// object
- (id)init;
- (unsigned)retainCount;

// use SQL method
- (void)LoadPlaylist;
- (void)makeSQLPlaylists:(NSString *)name;
- (void)SavingFileInfo:(NSString *)key;
- (void)DeleteSQLPlayList;


// use plst method
- (BOOL)LoadPlaylist_plst;
- (BOOL)SavingFileInfo_plst;


- (void)removePlayListDictionary:(NSString *)key;
- (void)removePlayListArray:(NSString *)key;


@end
