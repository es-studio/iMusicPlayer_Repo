//
//  FileTable.h
//  App1
//
//  Created by Han Eunsung on 11. 9. 17..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Id3db.h"
#import "LoadingView.h"

#define kCellImageViewTag		1000



@class FSItem;
@class FSItemCell;

//@class Player;


@interface FileTable : UITableViewController 
                            <UIActionSheetDelegate, 
                            UIDocumentInteractionControllerDelegate, 
                            UIScrollViewDelegate,
                            NSCoding>
{

    BOOL isEdit;
    FSItem *fsItem;  
    NSMutableArray *selectedArray;
    UIImage *selectedImage;
	UIImage *unselectedImage;	
    UIToolbar *actionToolbar;    
    
    UIDocumentInteractionController *docController;
    
    NSMutableArray *AlbumArtArray;

    NSOperationQueue *queue;
    
}


@property (nonatomic, retain) NSOperationQueue *queue;
@property (nonatomic, retain) NSMutableArray *AlbumArtArray;
@property BOOL isEdit;
@property (nonatomic, retain) FSItem *fsItem;
@property (nonatomic, retain) NSMutableArray *selectedArray;
@property (nonatomic, retain) UIImage *selectedImage;
@property (nonatomic, retain) UIImage *unselectedImage;
@property (nonatomic, retain) UIDocumentInteractionController *docController;
@property (nonatomic, retain) LoadingView *loading;
@property (nonatomic, retain) UIBarButtonItem *editButton;
@property (nonatomic, retain) UIBarButtonItem *playButton;

@property (nonatomic, retain) NSMutableArray *id3dbArray;


- (IBAction) toggleEdit:(id)sender;

- (void) showTabBar:(UITabBarController *) tabbarcontroller;

- (void) hideTabBar:(UITabBarController *) tabbarcontroller;

- (void) shiftCell:(FSItemCell *) cell;

- (void) showActionToolbar:(BOOL)show delay:(float)delay;

- (void) sortDirectoryFiles;

- (void) refreshFiles;

- (void) showMusicPlayer:(int)index;

- (void) alertMakeDir;

- (void) makeDir:(NSString *)dirName;

- (NSString *)URLEncoding:(NSString *)str;

- (int) checkMP3:(NSString *)name;

- (void) initBottomToolbar;

//- (UIImage *) artworksForFileAtPath:(NSString *)filepath;
- (UIImage *) artworksForFileAtPath:(FSItemCell *)cell;

- (void) AlbumArtWorker:(FSItemCell *)cell;

- (void) refreshCells;


- (NSString *)dataFilePath;

- (void) ShowUpdateFileInfo;

- (void) showPlayer;

- (BOOL) canBecomeFirstResponder;

- (void) remoteControlReceivedWithEvent:(UIEvent *)event;

- (void) deleteFileFromTableInDatabase:(NSArray *)pathArray;

- (void) showFileInfo:(NSNotification *)noti;

- (void) changeCellImage:(FSItemCell *)cell;

- (void) UpdateThreadProcess;

// update cache info
- (void)UpdateCacheInfo; 
- (void)UpdateFileInfo;
- (int)getAllId3Info:(NSString *)StartFileName;

// delete a file from cache
- (void)deleteId3ArrayFromCache:(FSItem *)item;

// for fast loading id3 database
- (BOOL)SavingFileInfo_plst:(NSArray *)id3array;
- (BOOL)checkPlaylist_plst;


@end




