//
//  LibraryDetailView.m
//  iMusicPlayer
//
//  Created by Han Eunsung on 11. 10. 30..
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "LibraryDetailView.h"
#import "Id3db.h"
#import "FSItem.h"
#import "FileChooserTable.h"
#import "MyMusicPlayer.h"
#import "sqlite3.h"
#import "LibraryData.h"

#import <AVFoundation/AVAudioPlayer.h>
#import <AVFoundation/AVFoundation.h> 


@implementation LibraryDetailView

@synthesize PlaylistKey, PlaylistArray;
@synthesize isEdit;
@synthesize delegate;
@synthesize fchTable;
@synthesize isMoved;
@synthesize libData;


#pragma mark - Remote control

- (BOOL) canBecomeFirstResponder{
    //    return firstResponder;
    return YES;
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


- (id)initWithKey:(NSString *)key{
    
    PlaylistKey = key;
    
//    PlaylistArray 
//    = [[NSMutableArray alloc] initWithArray:[self.libData.PlaylistDB objectForKey:key]];
    
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)showMusic{
    MyMusicPlayer *imp = [MyMusicPlayer sharedMusicPlayer];
    imp.hidesBottomBarWhenPushed = TRUE;
    [self.navigationController pushViewController:imp animated:YES];

}

- (void)viewDidLoad
{
    
    NSLog(@"LibDetailView Load");
    [super viewDidLoad];
//    self.navigationController.navigationBar.tintColor = [UIColor purpleColor];
    
    
    self.libData = [LibraryData sharedLibrary];
}

- (void)viewDidUnload
{
    
    NSLog(@"LibraryDetailView Unloaded");
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc{
    
    NSLog(@"LibraryDetailView dealloc");
    
    [fchTable release];
    // don't remove these objects
//    [PlaylistKey release];
//    [PlaylistArray release];
    
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    if (self.PlaylistArray == nil) {
        self.PlaylistArray 
        = [self.libData.PlaylistDB objectForKey:PlaylistKey];

    }
    
    
    [self.navigationController setNavigationBarHidden:FALSE animated:NO];    
    [self.navigationController.navigationBar setBarStyle:UIBarStyleDefault];
    
    
    NSLog(@"PlaylistArray cnt : %d, retains : %d", [self.PlaylistArray count], [self.PlaylistArray retainCount]);

    
    // 파일 선택기에서 선택한 어레이 추가 
    if (fchTable != nil) {
        
        NSLog(@"Add from FileChooser Array  retains : %d", [fchTable retainCount]);
        
        NSMutableArray *marr = [PlaylistArray mutableCopy];
                
        //[marr addObjectsFromArray:selections];
        [marr addObjectsFromArray:fchTable.SelectionArray];
        
        PlaylistArray = marr;
        [self.libData.PlaylistDB setObject:PlaylistArray forKey:PlaylistKey];
        
        
        // first trying plst method if fail, retry sql method
        if([self.libData SavingFileInfo_plst] == FALSE){
            [self.libData SavingFileInfo:PlaylistKey];
        }

        NSLog(@"File Chooser Table Release");
        [fchTable release];
        
        NSLog(@"File Chooser Table = nil");
        fchTable = nil;
        
    }
        
    //NSLog(@"array = %@", PlaylistArray);
    self.title = PlaylistKey;
    [self.tableView reloadData];
    
    
    // player check
    MyMusicPlayer *mmplayer = [MyMusicPlayer sharedMusicPlayer];
    if (mmplayer.player.rate > 0.0) {
        
        UIImage *normal = [UIImage imageNamed:@"nowplaying.png"];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.bounds = CGRectMake( 0, 0, normal.size.width, normal.size.height);    
        [button setImage:normal forState:UIControlStateNormal];
        [button addTarget:self action:@selector(showMusic) forControlEvents:UIControlEventTouchUpInside];    
        UIBarButtonItem *MusicButton = [[UIBarButtonItem alloc] initWithCustomView:button];

//        MusicButton.tintColor = [UIColor blackColor];
        self.navigationItem.rightBarButtonItem = MusicButton;
        [MusicButton release];
        
        
    }else{
        self.navigationItem.rightBarButtonItem = nil;
    }

    
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
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
//    return [PlaylistArray count] + 2; // edit cell + random play;
    return [PlaylistArray count] + 2; // edit cell + random play;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    int row = indexPath.row;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // cell remove
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    if([cell.contentView.subviews count] > 0 ){
        
        for (UIView *view in cell.contentView.subviews) {
            [view removeFromSuperview];
        }
        
    }
    
    
    cell.textLabel.text = @"";
    cell.detailTextLabel.text = @"";
    
    switch (row) {
        case 0:

            [self makeFirstCell:cell];            
            
            if(self.tableView.isEditing == TRUE){
                NSArray *subs = cell.contentView.subviews;
                for (UIButton *button in subs) button.hidden = YES;
                UIButton *doneButton = [subs lastObject];
                doneButton.hidden = NO;
            }
            
            break;
            
        case 1:
            
            [self makeSecondCell:cell];            
            
            break;
            
        default:
        {            
            Id3db *id3Item = [PlaylistArray objectAtIndex:row - 2];        
            cell.textLabel.text = id3Item.title;   
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ - %@",id3Item.album, id3Item.artist];

        }   
            break;
    }
    return cell;
}

- (void)makeFirstCell:(UITableViewCell *)cell{
    
    UIButton *editButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    editButton.frame = CGRectMake(5.0f, 3.0f, 100.0f, 36.0f);
    [editButton setTitle:@"Edit" forState:UIControlStateNormal];
    
    UIButton *clearButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    clearButton.frame = CGRectMake(110.0f, 3.0f, 100.0f, 36.0f);
    [clearButton setTitle:@"Clear" forState:UIControlStateNormal];
    
    UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    deleteButton.frame = CGRectMake(215.0f, 3.0f, 100.0f, 36.0f);
    [deleteButton setTitle:@"Delete" forState:UIControlStateNormal];
    
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    doneButton.frame = CGRectMake(35.0f, 3.0f, 250.0f, 36.0f);
    [doneButton setTitle:@"Done" forState:UIControlStateNormal];
    doneButton.hidden = YES;
    
    [editButton addTarget:self action:@selector(editButton) forControlEvents:UIControlEventTouchUpInside];
    
    [clearButton addTarget:self action:@selector(clearButton) forControlEvents:UIControlEventTouchUpInside];
    
    [deleteButton addTarget:self action:@selector(deleteButton) forControlEvents:UIControlEventTouchUpInside];            
    
    [doneButton addTarget:self action:@selector(doneButton) forControlEvents:UIControlEventTouchUpInside];
    
    [cell.contentView addSubview:editButton];
    [cell.contentView addSubview:clearButton];
    [cell.contentView addSubview:deleteButton];
    [cell.contentView addSubview:doneButton];

    
}

- (void)makeSecondCell:(UITableViewCell *)cell{
    
    cell.textLabel.text = @"Random Play";            
    UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(140, 14, 20, 16)];
    [img setImage:[UIImage imageNamed:@"Random_gray.png"]];
    [cell.contentView addSubview:img];

    
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return UITableViewCellEditingStyleDelete;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath 
{    
    NSUInteger fromRow = [fromIndexPath row] - 2;
    NSUInteger toRow   = [toIndexPath row]   - 2;

    NSMutableArray *marr = [PlaylistArray mutableCopy];    
    id object = [[marr objectAtIndex:fromRow] retain];
    [marr removeObjectAtIndex:fromRow];
    [marr insertObject:object atIndex:toRow];
    PlaylistArray = marr;
    [object release];
  
    [self.libData.PlaylistDB removeObjectForKey:PlaylistKey];
    [self.libData.PlaylistDB setObject:PlaylistArray forKey:PlaylistKey];
    
    self.isMoved = TRUE;
}

 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
     
     if (indexPath.row < 2) {
         return NO;
     }
     
 return YES;
 }

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{

    if (editingStyle == UITableViewCellEditingStyleDelete)
    {


        // 삭제할 아이템 미리 얻기
        Id3db *item = [PlaylistArray objectAtIndex:indexPath.row - 2];

        // 현재 플레이 리스트 목록 삭제
        NSMutableArray *marray = [PlaylistArray mutableCopy];
        [marray removeObjectAtIndex:indexPath.row - 2];
        PlaylistArray = marray;
        
        
        // 테이블 셀 삭제
        NSMutableArray *muIndex = [[[NSMutableArray alloc] init] autorelease];
        [muIndex addObject:[NSIndexPath indexPathForRow:indexPath.row  inSection:0]];
        [self.tableView deleteRowsAtIndexPaths:muIndex withRowAnimation:YES];
        //NSLog(@"playlist cnt = %d", [PlaylistArray count]);

        
        NSLog(@"DicPlayListDB delete set");
        
        // 원본 db 변경
        [self.libData.PlaylistDB setObject:PlaylistArray forKey:PlaylistKey];
        
//        NSLog(@"Delete item get : %d/%d", indexPath.row - 2 ,[PlaylistArray count]);
        NSLog(@"delete item = %@", item.path);
        
        [self deletePathFromPlaylist:[item.path stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        
        
        
    }
    
    
    
}

- (void)deletePathFromPlaylist:(NSString *)path{

    
    // Set File Manager
    NSArray *docs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [docs objectAtIndex:0];    
    NSString *playlistFile = [docPath stringByAppendingPathComponent:@"/tmp/playlists.sqlite3"];
    
    //--------------------------------------------------------------------
    // 초기 애플리케이션 오픈시 데이터 베이스 파일 읽어 들이기 
    // sql 열기
    sqlite3 *database;
    if (sqlite3_open([playlistFile UTF8String], &database)
        != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
    }
    
    
    path = [path stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@/", docPath] withString:@""];
    path = [path stringByReplacingOccurrencesOfString:@"file://localhost" withString:@""];
    
    
    NSString *query 
    = [NSString stringWithFormat:@"DELETE FROM \"%@\" WHERE FILEPATH = \"%@\"", PlaylistKey ,path];
    
    NSLog(@"Query = %@", query);
    
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(database, [query UTF8String], -1, &stmt, nil) != SQLITE_OK) {
        NSAssert1(0, @"Error while creating delete statement. '%s'", sqlite3_errmsg(database));
    }
    
    if (sqlite3_step(stmt) != SQLITE_DONE){
        NSLog(@"Delete Error");
    }else{
        NSLog(@"Delete Success");
    }
    
    sqlite3_finalize(stmt);
    
    sqlite3_close(database);
    

    
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSLog(@"PlaylistArray cnt : %d, retains : %d", [self.PlaylistArray count], [self.PlaylistArray retainCount]);

    
    //play music
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSLog(@"row = %d, text = %@", indexPath.row, cell.textLabel.text);
    
    // random select
    if (indexPath.row == 1){
        
        
        if([PlaylistArray count] == 0) {
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            return;
        }
        
        NSLog(@"Random Toggle");
        
        MyMusicPlayer *imp = [MyMusicPlayer sharedMusicPlayer];
        int rdm = arc4random() % [PlaylistArray count];
        NSLog(@"rdm = %d", rdm);
        [imp MediaItems:PlaylistArray startPoint:rdm];
        [imp RandomToggle];
        
        
        imp.hidesBottomBarWhenPushed = TRUE;
        [self.navigationController pushViewController:imp animated:YES];

    }
    else if (indexPath.row > 1) {
        
        MyMusicPlayer *imp = [MyMusicPlayer sharedMusicPlayer];
        [imp MediaItems:PlaylistArray startPoint:indexPath.row - 2];
        imp.hidesBottomBarWhenPushed = TRUE;
        [self.navigationController pushViewController:imp animated:YES];

    }
        
    
}

#pragma mark - Button Select

- (void)addButton{
    NSLog(@"addbutton");
//    [self showMediaPicker];
    

    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:nil
                                  delegate:self
                                  cancelButtonTitle:@"Cancel"
                                  destructiveButtonTitle:nil        // Important Button
                                  otherButtonTitles:@"Add from iPod Library", @"Add from File Library", nil];
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
    actionSheet.tag = 2000;
    [actionSheet release];
}

- (void)doneButton{
    NSLog(@"donebutton");
    
    
    // 0 번째 셀을 찾고
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    // 0 번째 셀의 모든 버튼을 숨김
    NSMutableArray *subs = [cell.contentView.subviews mutableCopy];
    for (UIButton *button in subs) button.hidden = NO;
    UIButton *doneButton = [subs lastObject];

    [self.tableView setEditing:FALSE animated:YES];
    
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionTransitionCrossDissolve 
                     animations:^{
                         self.navigationItem.leftBarButtonItem = nil;  
                         doneButton.hidden = YES;
                     } completion:nil];
    
    
    NSLog(@"Playlist count = %d", [PlaylistArray count]);
    
    
    // update list order
    if (self.isMoved == TRUE) {
        self.isMoved = FALSE;
        
        // re-save when change row order
        [self.libData removePlayListArray:PlaylistKey];
        [self.libData.PlaylistDB setObject:PlaylistArray forKey:PlaylistKey];

        // first trying plst method if fail, retry sql method
        if([self.libData SavingFileInfo_plst] == FALSE){
            [self.libData SavingFileInfo:PlaylistKey];
        }
        
    }
            
}

- (void)editButton{
    NSLog(@"edit");
    
    if(self.tableView.editing == FALSE){
        
        self.isMoved = FALSE;
        
        // 0 번째 셀을 찾고
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        
        // 0 번째 셀의 모든 버튼을 숨김
        NSArray *subs = cell.contentView.subviews;
        for (UIButton *button in subs) button.hidden = YES;
        UIButton *doneButton = [subs lastObject];
        
        
        // 네비게이션 왼쪽 상단에 추가 버튼 생성
        UIBarButtonItem *addButton = [[UIBarButtonItem alloc] 
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemAdd 
                                      target:self 
                                      action:@selector(addButton)];
        
        // 테이블 에디트 모드
        [self.tableView setEditing:TRUE animated:YES];
         self.navigationItem.leftBarButtonItem = addButton;        
        
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionTransitionCrossDissolve 
                         animations:^{
                             
                             // 각각 버튼 추가
                             [cell.contentView addSubview:doneButton]; 
                             doneButton.hidden = FALSE;
                             
                         } completion:nil];

        [addButton release];
        
        
        // 플레이중일경우 버튼 숨기기
        
        
        
    }else{
            
        
    }
    
}

- (void)clearButton{
    NSLog(@"clear");    
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:nil
                                  delegate:self
                                  cancelButtonTitle:@"Cancel"
                                  destructiveButtonTitle:@"Clear Playlist"        // Important Button
                                  otherButtonTitles:nil];
    actionSheet.tag = 1001;
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
    [actionSheet release];

}

- (void)deleteButton{
    NSLog(@"remove");
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:nil
                                  delegate:self
                                  cancelButtonTitle:@"Cancel"
                                  destructiveButtonTitle:@"Delete Playlist"        // Important Button
                                  otherButtonTitles:nil];
    actionSheet.tag = 1002;
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
    [actionSheet release];

    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if(actionSheet.tag == 2000 && buttonIndex == 0){
        [self showMediaPicker];
    }else if(actionSheet.tag == 2000 && buttonIndex == 1){
        [self showFileChooser];
    }
    
    else if(actionSheet.tag == 1001 && buttonIndex == 0)
    {
        // 현재 플레이 리스트 목록 삭제
        int total = [PlaylistArray count];
        NSMutableArray *marray = [PlaylistArray mutableCopy];
        [marray removeAllObjects];
        PlaylistArray = marray;
        
        // 테이블 셀 삭제
        NSMutableArray *muIndex = [[NSMutableArray alloc] init];
        for(int i = 2;i < total + 2; i++){
            [muIndex addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        }  
        [self.tableView deleteRowsAtIndexPaths:muIndex withRowAnimation:YES];
        //NSLog(@"playlist cnt = %d", [PlaylistArray count]);

        // 원본 db 에서 삭제 
        [self.libData removePlayListArray:PlaylistKey];
        [self.libData SavingFileInfo_plst];
        
        // release
        [muIndex release];
        
        
    }
    else if(actionSheet.tag == 1002 && buttonIndex == 0)
    {
        // 원본 db 에서 삭제         
        [self.libData removePlayListDictionary:PlaylistKey];
        [self.libData SavingFileInfo_plst];
        
        // 현재 플레이 리스트 자체 삭제
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

#pragma mark - mpmediapicker delegate

// 아이팟 라이브러리를 부르기 
- (void)showMediaPicker{
    
    // 아이팟 라이브러리 보기 
    MPMediaPickerController *picker = [[MPMediaPickerController alloc] initWithMediaTypes: MPMediaTypeMusic];
    
    picker.delegate						= self;
    picker.allowsPickingMultipleItems	= YES;
    picker.prompt						= NSLocalizedString (@"Add songs to play", "Prompt in media item picker");
    
    // The media item picker uses the default UI style, so it needs a default-style
    //		status bar to match it visually
    [[UIApplication sharedApplication] setStatusBarStyle: UIStatusBarStyleDefault animated: YES];
    
    [self presentModalViewController: picker animated: YES];
    [picker release];
}


- (void)showFileChooser{

    // 도큐먼트 디렉토리 위치 구하기 
    NSArray *docs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [docs objectAtIndex:0];
    
    fchTable = [[FileChooserTable alloc] initWithName:self.navigationItem.title];
                
//    fchTable.PlaylistName = self.navigationItem.title;
    NSLog(@"FileChooserTable : %@", self.navigationItem.title);
    
    NSLog(@"rch retain = %d", [fchTable retainCount]);
    fchTable.fsItem = [FSItem fsItemWithDir:docPath fileName:@""];

        NSLog(@"rch retain = %d", [fchTable retainCount]);
    
    UINavigationController *Navi = [[UINavigationController alloc] initWithRootViewController:fchTable];
        NSLog(@"rch retain = %d", [fchTable retainCount]);
    
    [self presentModalViewController:Navi animated:YES];
    [Navi release];
    
    
}

// 아이팟 라이브러리에서 취소를 클릭했을 경우 
- (void) mediaPickerDidCancel: (MPMediaPickerController *) mediaPicker {
	[self dismissModalViewControllerAnimated: YES];
}

// 라이브러리에서 미디어 선택하고 완료를 눌렀을 경우 
// Responds to the user tapping Done after choosing music.
- (void) mediaPicker: (MPMediaPickerController *) mediaPicker didPickMediaItems: (MPMediaItemCollection *) mediaItemCollection {
    
	[self dismissModalViewControllerAnimated: YES];
    
    NSLog(@"Media Choose");
    
    if(mediaItemCollection){
        
        NSArray *arr = [mediaItemCollection items];
        
        NSLog(@"playlist count = %d", [PlaylistArray count]);
        
        
        NSMutableArray *marr = [PlaylistArray mutableCopy];
        for (MPMediaItem *item in arr){
            //NSLog(@"title = %@", [item valueForProperty:MPMediaItemPropertyTitle]);
            NSURL *url = [item valueForProperty:MPMediaItemPropertyAssetURL];
            NSLog(@"url = %@", url);

            Id3db *id3Item = [[Id3db alloc] initWithURL:url];
            id3Item.title  = [item valueForProperty:MPMediaItemPropertyTitle];
            id3Item.album  = [item valueForProperty:MPMediaItemPropertyAlbumTitle];
            id3Item.artist = [item valueForProperty:MPMediaItemPropertyArtist];
            id3Item.lyrics = [item valueForProperty:MPMediaItemPropertyLyrics];
                        
//            NSLog(@"ipod lib title : %@", id3Item.title );
            
            NSNumber *duration=[item valueForProperty:MPMediaItemPropertyPlaybackDuration];
            id3Item.duration = [duration floatValue];
            
            [marr addObject:id3Item];
            
            [id3Item release];
        }
        PlaylistArray = marr;
        [self.libData.PlaylistDB setObject:PlaylistArray forKey:PlaylistKey];
        
        // first trying plst method if fail, retry sql method
        if([self.libData SavingFileInfo_plst] == FALSE){
            [self.libData SavingFileInfo:PlaylistKey];
        }

        
//        
//        NSLog(@"Key = %@", PlaylistKey);
//        NSLog(@"PlayList Array = %@", PlaylistArray);


        
        [self.tableView reloadData];
        
    }
}





@end