//
//  LibraryDetailView.h
//  iMusicPlayer
//
//  Created by Han Eunsung on 11. 10. 30..
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>


@class FileChooserTable;
@class LibraryData;

@protocol MusicTableViewControllerDelegate; // forward declaration


@interface LibraryDetailView : UITableViewController
<MPMediaPickerControllerDelegate, UIActionSheetDelegate> {
    
    NSString *PlaylistKey;
    NSArray *PlaylistArray;
    id <MusicTableViewControllerDelegate>	delegate;    
    
    FileChooserTable *fchTable;
        
}
@property (nonatomic)         BOOL isEdit;
@property (nonatomic)         BOOL isMoved;
@property (nonatomic, retain) NSString *PlaylistKey;
@property (nonatomic, retain) NSArray *PlaylistArray;
@property (nonatomic, assign) id <MusicTableViewControllerDelegate>	delegate;
@property (nonatomic ,retain) FileChooserTable *fchTable;
@property (nonatomic, retain) LibraryData *libData;


- (id)initWithKey:(NSString *)key;

- (void)showMediaPicker;

- (void)showFileChooser;

- (void)makeFirstCell:(UITableViewCell *)cell;

- (void)makeSecondCell:(UITableViewCell *)cell;

- (void)deletePathFromPlaylist:(NSString *)path;

//
//- (void)editButton;
//
//- (void)clearButton;
//
//- (void)deleteButton;

@end
