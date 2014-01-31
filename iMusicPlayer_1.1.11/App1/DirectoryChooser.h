//
//  DirectoryChooser.h
//  App1
//
//  Created by Han Eunsung on 11. 10. 7..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DirCell;
@class FileTable;

@interface DirectoryChooser : UIViewController <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate>{
    
    BOOL            CopyOrMove; // true : copy, false : move
    int             fileIndex;
    
    NSFileManager   *fm;
//    NSMutableArray  *files;
    
    NSString        *selectedPath;
    NSString        *docPath;
    
    NSArray         *selections;
    
    UIBarButtonItem *makedirButton;
    UIBarButtonItem *pasteButton;
    
    
    UITableView     *tableview;
    
    NSTimer         *timer;
        
    FileTable       *filetable;
    
}
@property (nonatomic, retain)          FileTable *filetable;
@property (nonatomic, retain)          NSTimer  *timer;
@property (nonatomic)                  int      fileIndex;
@property (retain, nonatomic) IBOutlet UIView   *ProcessView;
@property (retain, nonatomic) IBOutlet UILabel  *ProcessViewTitle;
@property (retain, nonatomic) IBOutlet UILabel  *ProcessViewNumber;

@property (nonatomic)                   BOOL     CopyOrMove;
@property (nonatomic, retain)           NSArray  *selections;
@property (nonatomic, retain)           NSString *selectedPath;
@property (nonatomic, retain)           NSString *docPath;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *makedirButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *pasteButton;
@property (nonatomic, retain) IBOutlet UITableView *tableview;
@property (nonatomic, retain) NSMutableArray *files;



- (IBAction)createDirectory:(id)sender;

- (IBAction)Cancel:(id)sender;

- (IBAction)Paste:(id)sender;

- (int) checkDir:(NSString *)name;

- (void) updateLabel;

- (void) processThread;

// cahce process

- (void)addCacheFilesToDst:(NSArray *)successFiles Dst:(NSString *)path;
- (void)removeCacheFilesToDst:(NSArray *)successFiles Dst:(NSString *)path;
- (BOOL)checkPlaylist_plst:(NSString *)path;
    

@end
