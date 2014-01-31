//
//  Settings.m
//  iMusicPlayer
//
//  Created by Han Eunsung on 11. 12. 31..
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Settings.h"
#import "SettingsData.h"
#import "Id3db.h"
#import "LoadingView.h"
#import "MyMusicPlayer.h"

#import "LibraryData.h"

#import "ActionSheetStringPicker.h"

#import <sqlite3.h>

@implementation Settings

@synthesize SettingsArray;
@synthesize SettingsKeys;
@synthesize Settings;
@synthesize loading;
@synthesize FontSizeArray;
@synthesize actionSheetPicker;
@synthesize AlignmentArray;
@synthesize SeekTimeArray;

#pragma mark - Remote control

- (BOOL) canBecomeFirstResponder{
    //    return firstResponder;
    return YES;
}

- (void)dealloc{
    
    [self.SettingsArray release];
    [self.SettingsKeys release];
    [self.FontSizeArray release];
    [self.AlignmentArray release];
    
    [super dealloc];
    
}

- (void) remoteControlReceivedWithEvent:(UIEvent *)event{
    
    
    NSLog(@"event = %d", event.subtype);
    
    MyMusicPlayer *mplayer = [MyMusicPlayer sharedMusicPlayer];
    
    if([mplayer.playlist count] > 0){
        
        if(event.subtype == UIEventSubtypeRemoteControlTogglePlayPause){
            [mplayer Play:event];
            //        [self Play:event];
        }else if(event.subtype == UIEventSubtypeRemoteControlNextTrack){
            
            [mplayer Next:event];
            //        [self Next:event];
        }else if(event.subtype == UIEventSubtypeRemoteControlPreviousTrack){
            [mplayer Prev:event];
            //        [self Prev:event];
        }
        
    }
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
    
    self.SettingsArray 
    = [[NSDictionary alloc] initWithObjectsAndKeys:       
       
       [NSArray arrayWithObjects:@"Display AlbumArt", @"Interrupt Resume", @"Files Font Size",nil], @"General",
       
       [NSArray arrayWithObjects:@"Lockscreen PlayInfo", nil], @"IOS 5 Only",
       
       [NSArray arrayWithObjects:@"TimeStep -2", @"TimeStep -1", @"TimeStep +1", @"TimeStep +2", nil], @"A-B Repeat",
       
       [NSArray arrayWithObjects:@"Clear FolderPlay Cache", @"Clear AlbumArt Cache", @"Clear ID3 Database", @"Clear Playlist Database", nil], @"Clear Data",
       
       [NSArray arrayWithObjects:@"Current Version", nil], @"Version",
       nil];
    
    
//    self.SettingsKeys = [self.SettingsArray allKeys];
    
    self.SettingsKeys = [[NSArray alloc] initWithObjects:@"General", @"IOS 5 Only", @"A-B Repeat", @"Clear Data", @"Version", nil];
    self.Settings     = [SettingsData sharedSettingsData];
    
    self.FontSizeArray  = [[NSArray alloc] initWithObjects: @"10", @"12",@"14", @"16", @"18", @"20", @"22", nil];
    self.AlignmentArray = [[NSArray alloc] initWithObjects: @"Left", @"Center", @"Right", nil];
    
    self.SeekTimeArray = [[NSArray alloc] initWithObjects:@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12", @"13", @"14", @"15", @"16", @"17", @"18", @"19", @"20", nil];
    
    AlbumArtSW = [[UISwitch alloc] initWithFrame:CGRectZero];
    [AlbumArtSW addTarget:self action:@selector(switchToggled:) forControlEvents:UIControlEventValueChanged];
    AlbumArtSW.tag = 1000;
    
    ResumeSW = [[UISwitch alloc] initWithFrame:CGRectZero];
    [ResumeSW addTarget:self action:@selector(switchToggled:) forControlEvents:UIControlEventValueChanged];
    ResumeSW.tag = 1001;
    
    LockinfoSW = [[UISwitch alloc] initWithFrame:CGRectZero];
    [LockinfoSW addTarget:self action:@selector(switchToggled:) forControlEvents:UIControlEventValueChanged];
    LockinfoSW.tag = 1002;

    
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
    // remote control regist
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self canBecomeFirstResponder];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    // save configuration Data
    [self.Settings saveData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [self.SettingsKeys count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSString *key = [self.SettingsKeys objectAtIndex:section];
    NSArray *SectionArray = [self.SettingsArray objectForKey:key];
    return [SectionArray count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    
    NSString *key = [self.SettingsKeys objectAtIndex:section];
    NSArray *SectionArray = [self.SettingsArray objectForKey:key];

    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    cell.textLabel.text = [SectionArray objectAtIndex:row];
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:17];
    cell.detailTextLabel.text = @"";
    
    cell.accessoryView = nil;
    
//    if(section == 0){
    
    if([self.SettingsKeys objectAtIndex:section] == @"General"){
        
        switch (row) {
            case 0:
            {
                AlbumArtSW.on = self.Settings.OnAlbumArt;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;                
                [cell addSubview:AlbumArtSW];
                cell.accessoryView = AlbumArtSW;
            }   
                break;
                
            case 1:
            {
                ResumeSW.on = self.Settings.OnInterruptResume;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                [cell addSubview:ResumeSW];
                cell.accessoryView = ResumeSW;
            }   
                break;
                
                
            case 2:
                
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%d pt", self.Settings.FileTableFontSize];
                cell.selectionStyle = UITableViewCellSelectionStyleBlue;

                break;
             
        }
        
    }else if([self.SettingsKeys objectAtIndex:section] == @"IOS 5 Only"){

        switch (row) {
            case 0:
            {
                LockinfoSW.on = self.Settings.OnLockScreenInfo;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                [cell addSubview:LockinfoSW];
                cell.accessoryView = LockinfoSW;
                
                NSString *verStr = [[UIDevice currentDevice] systemVersion];
                
                if([[verStr substringToIndex:1] isEqualToString:@"4"] == TRUE) 
                    LockinfoSW.enabled = FALSE;
                
                
            }   
                break;
        }
    
    }else if([self.SettingsKeys objectAtIndex:section] == @"A-B Repeat"){
        
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        
        
        switch (row) {
            case 0:
                cell.detailTextLabel.text = [NSString stringWithFormat:@"- %d sec", self.Settings.LeftSeekTime1];
                break;
                
            case 1:
                cell.detailTextLabel.text = [NSString stringWithFormat:@"- %d sec", self.Settings.LeftSeekTime2];                
                break;
                
            case 2:
                cell.detailTextLabel.text = [NSString stringWithFormat:@"+ %d sec", self.Settings.RightSeekTime1];
                break;
                
            case 3:
                cell.detailTextLabel.text = [NSString stringWithFormat:@"+ %d sec", self.Settings.RightSeekTime2];
                break;
                
            default:
                break;
        }
    
    }else if([self.SettingsKeys objectAtIndex:section] == @"Clear Data"){
   
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        
    }else if([self.SettingsKeys objectAtIndex:section] == @"Version"){
        
        switch (row) {
            case 0:
                cell.detailTextLabel.text = @"1.1.10";
                cell.selectionStyle = UITableViewCellSelectionStyleNone;

                break;
                
            default:
                break;
        }
        
        
    }
        
    return cell;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *key = [self.SettingsKeys objectAtIndex:section];
    return key;
}


- (void) switchToggled:(id)sender {
    //a switch was toggled.  
    //maybe use it's tag property to figure out which one
    UISwitch *sw = (UISwitch *)sender;
    
    switch (sw.tag) {
        case 1000:
            
            if(sw.isOn == TRUE) {
                self.Settings.OnAlbumArt = TRUE;
            }else{  
                self.Settings.OnAlbumArt = FALSE;
            }
            break;
            
        case 1002:         
            {            
                MyMusicPlayer *mplayer = [MyMusicPlayer sharedMusicPlayer];
                               
                if(sw.isOn == TRUE) {
                    self.Settings.OnLockScreenInfo = TRUE;
                    [mplayer onLockInfo];
                    
                }else{  
                    self.Settings.OnLockScreenInfo = FALSE;
                    [mplayer offLockInfo];
                }
                
            }
            break;
            
        case 1001:
            if(sw.isOn == TRUE) {
                self.Settings.OnInterruptResume = TRUE;
            }else{  
                self.Settings.OnInterruptResume = FALSE;
            }
            
            break;
            
        default:
            break;
    }
    
    
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSUInteger section = indexPath.section;
    
    
    if([self.SettingsKeys objectAtIndex:section] == @"Clear Data"){

        
        switch (indexPath.row) {
                
            case 0:
                [self alertClearFolderPlayCache];
                break;
            case 1:
                [self alertClearAlbumArt];
                break;
            case 2:
                [self alertClearID3Database];
                break;
            case 3:
                [self alertClearPlaylistDatabase];
                break;
            default:
                break;
        }
        
    }else if([self.SettingsKeys objectAtIndex:section] == @"A-B Repeat"){

        switch (indexPath.row) {
            case  0:
            {
                
                NSString *num = [NSString stringWithFormat:@"%d", self.Settings.LeftSeekTime1] ;
                
                [ActionSheetStringPicker showPickerWithTitle:@"Select -2 TimeStep" 
                                                        rows:self.SeekTimeArray 
                                            initialSelection:[self.SeekTimeArray indexOfObject:num]
                                                      target:self 
                                                sucessAction:@selector(setSeekTimeStep1:element:)
                                                cancelAction:nil 
                                                      origin:self.tabBarController.view];
                
            }
                break;
                
            case  1:
            {
                
                NSString *num = [NSString stringWithFormat:@"%d", self.Settings.LeftSeekTime2] ;
                
                [ActionSheetStringPicker showPickerWithTitle:@"Select -1 TimeStep" 
                                                        rows:self.SeekTimeArray 
                                            initialSelection:[self.SeekTimeArray indexOfObject:num]
                                                      target:self 
                                                sucessAction:@selector(setSeekTimeStep2:element:)
                                                cancelAction:nil 
                                                      origin:self.tabBarController.view];
                
            }
                break;
                
            case  2:
            {
                
                NSString *num = [NSString stringWithFormat:@"%d", self.Settings.RightSeekTime1] ;
                
                [ActionSheetStringPicker showPickerWithTitle:@"Select +1 TimeStep" 
                                                        rows:self.SeekTimeArray 
                                            initialSelection:[self.SeekTimeArray indexOfObject:num]
                                                      target:self 
                                                sucessAction:@selector(setSeekTimeStep3:element:)
                                                cancelAction:nil 
                                                      origin:self.tabBarController.view];
                
            }
                break;

            case  3:
            {
                
                NSString *num = [NSString stringWithFormat:@"%d", self.Settings.RightSeekTime2] ;
                
                [ActionSheetStringPicker showPickerWithTitle:@"Select +2 TimeStep" 
                                                        rows:self.SeekTimeArray 
                                            initialSelection:[self.SeekTimeArray indexOfObject:num]
                                                      target:self 
                                                sucessAction:@selector(setSeekTimeStep4:element:)
                                                cancelAction:nil 
                                                      origin:self.tabBarController.view];
                
            }
                break;


        }        
        
    
    }else if([self.SettingsKeys objectAtIndex:section] == @"General"){
    
        switch (indexPath.row) {
            case  2:
            {
                
                NSString *num = [NSString stringWithFormat:@"%d", self.Settings.FileTableFontSize] ;
                
                [ActionSheetStringPicker showPickerWithTitle:@"Select a Font Size" 
                                                        rows:self.FontSizeArray 
                                            initialSelection:[self.FontSizeArray indexOfObject:num]
                                                      target:self 
                                                sucessAction:@selector(setFontSize:element:)
                                                cancelAction:nil 
                                                      origin:self.tabBarController.view];

            }
                break;
                
        }
        
        
    }
    
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}


- (void)setFontSize:(NSNumber *)selectedIndex element:(id)element {

    self.Settings.FileTableFontSize = [[FontSizeArray objectAtIndex:[selectedIndex intValue]] integerValue];
    NSLog(@"FontSize = %d", self.Settings.FileTableFontSize);
    
    [self.tableView reloadData];
}


- (void)setSeekTimeStep1:(NSNumber *)selectedIndex element:(id)element{
    self.Settings.LeftSeekTime1 = [[self.SeekTimeArray objectAtIndex:[selectedIndex intValue]] integerValue];
    
    [self.tableView reloadData];
}

- (void)setSeekTimeStep2:(NSNumber *)selectedIndex element:(id)element{
    self.Settings.LeftSeekTime2 = [[self.SeekTimeArray objectAtIndex:[selectedIndex intValue]] integerValue];
    [self.tableView reloadData];
}

- (void)setSeekTimeStep3:(NSNumber *)selectedIndex element:(id)element{
    self.Settings.RightSeekTime1 = [[self.SeekTimeArray objectAtIndex:[selectedIndex intValue]] integerValue];
    [self.tableView reloadData];

}

- (void)setSeekTimeStep4:(NSNumber *)selectedIndex element:(id)element{
    self.Settings.RightSeekTime2 = [[self.SeekTimeArray objectAtIndex:[selectedIndex intValue]] integerValue];
    [self.tableView reloadData];
}


- (void)setLyricsAlign:(NSNumber *)selectedIndex element:(id)element{
    
    self.Settings.LyricsAlign = [selectedIndex intValue];
    
//    [[self.AlignmentArray objectAtIndex:[selectedIndex intValue]] integerValue];
    NSLog(@"LyricsAlign = %d %d", self.Settings.LyricsAlign, [selectedIndex intValue]);
    
    
    [self.tableView reloadData];

    
}

//
// Cache Clear 
//

- (void)alertClearAlbumArt{
    
    UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Clear AlbumArt?" message:@"This will remove AlbumArt Cache" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];    
    myAlertView.tag = 10000;
    [myAlertView show];
    [myAlertView release];
    
}

- (void)alertClearID3Database{
    
    UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Clear ID3 Database?" message:@"This will remove ID3Tag database" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    myAlertView.tag = 20000;
    [myAlertView show];
    [myAlertView release];

}

- (void)alertClearPlaylistDatabase{
    UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Clear Playlist Database?" message:@"This will remove all playlists" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    myAlertView.tag = 30000;
    [myAlertView show];
    [myAlertView release];

    
}

- (void)alertClearFolderPlayCache{
    
    UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Clear FolderPlay Cache?" message:@"This will remove FolderPlay Cache" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];    
    myAlertView.tag = 40000;
    [myAlertView show];
    [myAlertView release];
    
}




- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    // 도큐먼트 디렉토리 위치 구하기
    NSError *err = nil;

    NSArray *docs 
    = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *docPath
    = [docs objectAtIndex:0];
    
    NSString *tmpPath 
    = [[docs objectAtIndex:0] stringByAppendingPathComponent:@"tmp"];
        
    NSFileManager *fm = [[[NSFileManager alloc] init] autorelease];
    [fm changeCurrentDirectoryPath:tmpPath];
    
    NSArray *files = [fm contentsOfDirectoryAtPath:tmpPath error:nil];
    
    //
    // Real Clear Cache
    //
    
    // clear albumart cache
    if(alertView.tag == 10000 && buttonIndex == 1){
        for (NSString *path in files) {
            if([[path pathExtension] isEqualToString:@"png"]){
                [fm removeItemAtPath:path error:&err];
                NSLog(@"Error : %@", [err description]);
            }
        }
    }
    
    // clear id3db
    else if(alertView.tag == 20000 && buttonIndex == 1){
        
        NSLog(@"Execute Delete ID3DB");
        
        [fm removeItemAtPath:[tmpPath stringByAppendingPathComponent:@"data.sqlite3"] error:&err];
        NSLog(@"err : %@", [err description]);
        
        self.navigationController.view.userInteractionEnabled = FALSE;
        self.view.userInteractionEnabled = FALSE;
        self.tabBarController.view.userInteractionEnabled = FALSE;
        
        
        loading = [LoadingView loadingViewInView:self.navigationController.view withTitle:@"DB Reloading ..."];
        
        [loading performSelector:@selector(removeView)
                      withObject:nil
                      afterDelay:300.0];
        
        [self performSelectorInBackground:@selector(Settings_ThreadProcess) withObject:nil];
//        
//        [NSThread detachNewThreadSelector:@selector(Settings_ThreadProcess) 
//                                 toTarget:self  
//                               withObject:nil]; 

    }
    
    // clear playlist
    else if(alertView.tag == 30000 && buttonIndex == 1){
        
    
        [fm removeItemAtPath:[tmpPath stringByAppendingPathComponent:@"playlists.sqlite3"] error:&err];
        NSLog(@"err : %@", [err description]);

        [fm removeItemAtPath:[tmpPath stringByAppendingPathComponent:@"playlists.plst"] error:&err];
        NSLog(@"err : %@", [err description]);
        
        LibraryData *libData = [LibraryData sharedLibrary];
        [libData.PlaylistDB removeAllObjects];
        
    }
    
    // clear folderplay cache
    else if(alertView.tag == 40000 && buttonIndex == 1){
        
//        [fm removeItemAtPath:[docPath stringByAppendingPathComponent:@"playlists.sqlite3"] error:&err];
//        NSLog(@"err : %@", [err description]);
//        
//        [fm removeItemAtPath:[docPath stringByAppendingPathComponent:@"playlists.plst"] error:&err];
//        NSLog(@"err : %@", [err description]);
//        
//        LibraryData *libData = [LibraryData sharedLibrary];
//        [libData.PlaylistDB removeAllObjects];

        NSLog(@"Delete FolderPlay cache files");
        
        // 디렉토리 리스트 
        BOOL isDir;
        NSDirectoryEnumerator *dirEnum = [fm enumeratorAtPath:docPath];
        
        NSString *curDir = [NSString stringWithString:@"/"];
        while ((curDir = [dirEnum nextObject]) != nil){
            
            curDir = [docPath stringByAppendingPathComponent:curDir];

            // dir check
            if([fm fileExistsAtPath:curDir isDirectory:&isDir] == isDir){
                
                NSString *cacheFile = [curDir stringByAppendingPathComponent:@".cache.plst"];
                NSLog(@"%@", cacheFile);
                
                // .cache.plst exists check
                if([fm fileExistsAtPath:cacheFile] == TRUE){
                    
                    NSLog(@"%@", cacheFile);                                        
                    [fm removeItemAtPath:cacheFile error:&err];
                    NSLog(@"err : %@", [err description]);
                    
                }
                
                
            }
        }

        // "/" root check
        NSString *cacheFile = [docPath stringByAppendingPathComponent:@".cache.plst"];
        if([fm fileExistsAtPath:cacheFile] == TRUE){            
            NSLog(@"%@", cacheFile);                                        
            [fm removeItemAtPath:cacheFile error:&err];
            NSLog(@"err : %@", [err description]);
        }
        
        
        NSLog(@"Folder Play cache clear");
        
    }

    
    
    // restore to default doc path
    [fm changeCurrentDirectoryPath:docPath];

    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    
}



- (void)Settings_ThreadProcess{
//    NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];
    
    //이곳에 처리할 코드를 넣는다.
    
    // 도큐먼트 디렉토리 위치 구하기 
    NSArray *docs 
    = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath 
    = [docs objectAtIndex:0];
    NSString *tmpPath
    = [[docs objectAtIndex:0] stringByAppendingPathComponent:@"tmp"];
    
    
    NSLog(@"path = %@", docPath);
    
    NSFileManager *fm = [NSFileManager defaultManager];
    [fm changeCurrentDirectoryPath:docPath];
    
    sqlite3 *database;
    if (sqlite3_open([[tmpPath stringByAppendingPathComponent:@"data.sqlite3"] UTF8String], &database) == SQLITE_OK) {
        //        sqlite3_close(database);
        
        // 테이블 생성 없을 경우 새로 만듬
        char *errorMsg;
        NSString *createSQL 
        = @"CREATE TABLE IF NOT EXISTS ID3DATA (FILEPATH TEXT PRIMARY KEY, PATH TEXT, FILENAME TEXT, TITLE TEXT, ARTIST TEXT, ALBUM TEXT, LYRICS TEXT, DURATION TEXT);";
        
        if (sqlite3_exec (database, [createSQL UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
            sqlite3_close(database);
            NSAssert1(0, @"Error creating table: %s", errorMsg);
        }else{
            NSLog(@"Table created");
        }
        
    }
    
    NSLog(@"UpdateFileInfo");
    
    //        [fm changeCurrentDirectoryPath:[docs objectAtIndex:0]];
    NSDirectoryEnumerator *dirEnum = [fm enumeratorAtPath:docPath];
    
    if (sqlite3_open([[tmpPath stringByAppendingPathComponent:@"data.sqlite3"] UTF8String], &database)
        != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
    }
    
    NSString *file;

    while (file = [dirEnum nextObject]) {
        
        NSURL *fileurl = [NSURL fileURLWithPath:file];
        
        if([[[file pathExtension] uppercaseString] isEqualToString:@"MP3"] == FALSE) continue;   
        
        
        Id3db *id3 = [[Id3db alloc] initWithURL:fileurl];
        [id3 id3ForFileAtPath];
        
        
//        NSLog(@"id3.path :%@", file);
        
        char *update = "INSERT OR REPLACE INTO ID3DATA (FILEPATH, PATH, FILENAME, TITLE, ARTIST, ALBUM, LYRICS, DURATION) VALUES (?, ?, ?, ?, ?, ?, ?, ?);";
        
        
//        NSLog(@"update : %@", file);
        
        sqlite3_stmt *stmt;
        if (sqlite3_prepare_v2(database, update, -1, &stmt, nil) == SQLITE_OK) {
            
            // "/abc/def.mp3"
            sqlite3_bind_text(stmt, 1, [file UTF8String], -1, NULL);
            
            // "/abc"
            sqlite3_bind_text(stmt, 2, [[file stringByDeletingLastPathComponent] UTF8String], -1, NULL);
            
            // "def.mp3"
            sqlite3_bind_text(stmt, 3, [[file lastPathComponent] UTF8String], -1, NULL);
            
            sqlite3_bind_text(stmt, 4, [id3.title UTF8String], -1, NULL);          
            sqlite3_bind_text(stmt, 5, [id3.artist UTF8String], -1, NULL);          
            sqlite3_bind_text(stmt, 6, [id3.album UTF8String], -1, NULL);          
            sqlite3_bind_text(stmt, 7, [id3.lyrics UTF8String], -1, NULL);          
            sqlite3_bind_text(stmt, 8, [[NSString stringWithFormat:@"%f", id3.duration] UTF8String], -1, NULL);                      
            
//            NSLog(@"path : %@ title : %@ duration : %f",  file,id3.title ,id3.duration);
        }
        
        if (sqlite3_step(stmt) != SQLITE_DONE){
            NSLog(@"Update Error");
            //            NSAssert1(0, @"Error updating table: %s", errorMsg);
        }else{
            //NSLog(@"Update Success");
        }
        sqlite3_finalize(stmt);
        
        [id3 release];
        
    }
    
    sqlite3_close(database);

    NSLog(@"Refreshed ID3 DB");
    
    
    

    
    self.navigationController.view.userInteractionEnabled = TRUE;
    self.view.userInteractionEnabled = TRUE;
    self.tabBarController.view.userInteractionEnabled = TRUE;
    
    [loading removeView];
//    [autoreleasepool release];
    NSLog(@"Thread Done");
    [NSThread exit];
    
}


//#pragma mark -
//#pragma mark Picker View Methods
//
//- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
//	
//	return 1;
//}
//
//- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
//	
//	return [self.FontSizeArray count];
//}
//
//- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
//	
//	return [FontSizeArray objectAtIndex:row];
//}
//
//- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
//    
////    [thePickerView setHidden:YES];
//    
//    self.Settings.FileTableFontSize = [[FontSizeArray objectAtIndex:row] integerValue];
//	NSLog(@"fontsize set = %@", [FontSizeArray objectAtIndex:row]);
////	NSLog(@"Selected Color: %@. Index of selected color: %i", [arrayColors objectAtIndex:row], row);
//}
//


@end
