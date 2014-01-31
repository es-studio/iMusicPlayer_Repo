//
//  Lib.h
//  iMusicPlayer
//
//  Created by Han Eunsung on 11. 10. 29..
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LibraryDetailView;
@class MyMusicPlayer;
@class LibraryData;
@class LoadingView;


@interface Lib : UITableViewController {
    
//    NSMutableArray          *PlayListKeysArray;
//    NSMutableArray          *FilteredPlayList;
    
}

//@property (nonatomic, retain) NSMutableDictionary *DicPlayListDB;
@property (nonatomic, retain) NSMutableArray *PlayListKeysArray;
@property (nonatomic, retain) NSMutableArray *FilteredPlayList;
@property (nonatomic, retain) LibraryDetailView *DetailView;
@property (nonatomic, retain) LibraryData *libData;
@property (nonatomic, retain) LoadingView *loadingView;

//+ (Lib *) sharedLibrary;

- (void) LoadingPlayList;

- (void) ThreadProcess;

- (void) alertMakePlaylist;

- (void) removePlayListArray:(NSString *)key;

- (void) removePlayListDictionary:(NSString *)key;

@end
