//
//  FileChooserTable.h
//  iMusicPlayer
//
//  Created by Han Eunsung on 11. 11. 9..
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FSItem;
@class LoadingView;

@interface FileChooserTable : UITableViewController{
    
    FSItem *fsItem;
    
}

@property (nonatomic, retain) FSItem *fsItem;
@property (nonatomic, retain) NSMutableArray *SelectionArray;
@property (nonatomic, retain) NSMutableArray *inDirSelections;
@property (nonatomic, retain) NSMutableDictionary *SelectionIndexDic;
@property (nonatomic, retain) LoadingView *loading;
@property (nonatomic, retain) NSString *PlaylistName;

- (id)initWithName:(NSString *)name;

- (void)ClickDoneButton;

- (void)initBottomToolbar;

- (void)initSelectionIndexDic;

- (void)sortDirectoryFiles;

- (void)ReadingFileInfo;

- (void)SavingFileInfo;

- (NSString *)dataFilePath;

- (void)UpdateTotalCount;

@end
