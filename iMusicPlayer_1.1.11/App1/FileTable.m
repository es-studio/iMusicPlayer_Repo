//
//  FileTable.m
//  App1
//
//  Created by Han Eunsung on 11. 9. 17..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FileTable.h"
#import "FSItemCell.h"
#import "FSItem.h"
#import "MyMusicPlayer.h"
#import "DirectoryChooser.h"
#import "Id3db.h"
#import "LoadingView.h"
#import "SettingsData.h"
#import "FileInfo.h"

#import <AVFoundation/AVAudioPlayer.h>
#import <MediaPlayer/MediaPlayer.h>
#import <sqlite3.h>


@implementation FileTable

@dynamic fsItem;
@synthesize isEdit;
@synthesize selectedArray;
@synthesize selectedImage;
@synthesize unselectedImage;
@synthesize docController;
@synthesize AlbumArtArray;
@synthesize queue;
@synthesize loading;
@synthesize editButton;
@synthesize playButton;

@synthesize id3dbArray;

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

#pragma mark - Life Cycle

- (void)viewDidLoad{

    queue = [NSOperationQueue new];
        
    // table background set white
    self.navigationController.view.backgroundColor = [UIColor whiteColor];
    self.view.backgroundColor = [UIColor clearColor];    
    
    // 디렉토리 정렬 
    [self sortDirectoryFiles];
 
    // -------------------------------------------------------------------------------
    // 오른쪽 상단 버튼 
    isEdit = FALSE;
    
    self.editButton = [[UIBarButtonItem alloc]
                       initWithTitle:@"Edit"
                       style:UIBarButtonItemStyleBordered
                       target:self
                       action:@selector(toggleEdit:)];
//    self.navigationItem.rightBarButtonItem = editButton;
    
    
    
    UIImage *normal = [UIImage imageNamed:@"nowplaying.png"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.bounds = CGRectMake( 0, 0, normal.size.width, normal.size.height);    
    [button setImage:normal forState:UIControlStateNormal];
    [button addTarget:self action:@selector(showPlayer) forControlEvents:UIControlEventTouchUpInside];    
    self.playButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    // 5.0
//    self.playButton.tintColor = [UIColor blackColor];
    
        

    // 멀티 셀렉트 ----------------------------------------------------------------------
//	self.selectedImage = [UIImage imageNamed:@"IsSelected.png"];
//	self.unselectedImage = [UIImage imageNamed:@"NotSelected.png"];
    
	self.selectedImage = [UIImage imageNamed:@"Selected.png"];
	self.unselectedImage = [UIImage imageNamed:@"UnSelected.png"];

	// --------------------------------------------------------------------------------
    
    // 선택 항목 저장용 배열 초기화
    self.selectedArray = [[[NSMutableArray alloc] init] autorelease];
    
    // actionbar 추가해 놓음 
    [self initBottomToolbar];
    [self.navigationController.view addSubview:actionToolbar];
        
    //-------------------------------------------------------------------------------
    
    
    // init albumartarray
    AlbumArtArray = [[NSMutableArray alloc] init];
    for (int i=0;i < [fsItem.children count];i++) {
        [AlbumArtArray addObject:[[[Id3db alloc] init] autorelease]];
    }
    
    
    NSLog(@"cache load");
    
    // id3 캐쉬가 있을 경우 미리 로드
    if(self.id3dbArray == nil || [self checkPlaylist_plst] == FALSE){
        NSString *currentPath = fsItem.path;
        NSString *playlistFile = [currentPath stringByAppendingPathComponent:@".cache.plst"];
        
        NSData* decodedBook = [NSData dataWithContentsOfFile:playlistFile];
        NSArray *arrays = [NSKeyedUnarchiver unarchiveObjectWithData:decodedBook];
    

        if([arrays count] > 0){
            Id3db *OneItem = [arrays objectAtIndex:0];
            NSString *arrayPath 
            = [[[OneItem.path 
                 stringByReplacingOccurrencesOfString:@"file://localhost/private" withString:@""] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByDeletingLastPathComponent];
            
            if([arrayPath isEqualToString:fsItem.path] == TRUE){
                
                self.id3dbArray = [[NSMutableArray alloc] initWithArray:arrays];            
                
            }else{
                //폐기
                
                NSArray *docs 
                = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *docPath = [docs objectAtIndex:0];
                NSString *currentPath = fsItem.path;    
                
                NSFileManager *fm = [[[NSFileManager alloc] init] autorelease];
                [fm changeCurrentDirectoryPath:currentPath];
                
                NSError *err = nil;
                [fm removeItemAtPath:[fsItem.path stringByAppendingPathComponent:@".cache.plst"] error:&err];
                NSLog(@"err : %@", [err description]);
                
                [fm changeCurrentDirectoryPath:docPath];
                
            }
            
        }
        
        NSLog(@"Load id3 Cache : %d", [self.id3dbArray retainCount]);
        
    }

}

- (void)showPlayer{

    MyMusicPlayer *imp = [MyMusicPlayer sharedMusicPlayer];
    [self.navigationController pushViewController:imp animated:YES];

}

- (void)viewDidUnload {
    
//    fsItem = nil;
//    selectedArray = nil;
//    selectedImage = nil;
//    unselectedImage = nil;    
//    docController = nil;
//    AlbumArtArray = nil;
//    queue = nil;


}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"ViewWillAppear");
	[super viewWillAppear:animated];
    
    UIApplication *app = [UIApplication sharedApplication];
    [app setStatusBarStyle:UIStatusBarStyleDefault];

    // player check
    MyMusicPlayer *mmplayer = [MyMusicPlayer sharedMusicPlayer];
    if (mmplayer.player.rate > 0.0) {
        self.navigationItem.rightBarButtonItem = self.playButton;
    }else{
        self.navigationItem.rightBarButtonItem = self.editButton;
    }

    
    if ([self.title isEqualToString:@"/"]) {
        self.title = @"Music Files";
    }
    
    SettingsData *sets = [SettingsData sharedSettingsData];
    
    NSLog(@"viewapperar : isupdate = %d", sets.isUpdatedForFileTable);
    if(sets.isUpdatedForFileTable == FALSE){
        sets.isUpdatedForFileTable = TRUE;
        [self ShowUpdateFileInfo];    
    }
    
    if(isEdit == TRUE){
        [self showActionToolbar:TRUE delay:0];
    }

    
    
    
    [self refreshFiles];
        
    NSLog(@"FileTable viewWillAppear");
    
}

- (void)viewDidAppear:(BOOL)animated {

    // remote control regist
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self canBecomeFirstResponder];
        
	[super viewDidAppear:animated];

    // register noti center
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showFileInfo:) name:@"FileInfo" object:nil];

    [self refreshCells];
    
    
    NSLog(@"id3 retains : %d", [self.id3dbArray retainCount]);
}

- (void)viewWillDisappear:(BOOL)animated {
    // 탭을 변경하면 오디오 멈춤 
    //[self AudioStop];
    
}

- (void)viewDidDisappear:(BOOL)animated {
    
    //[self AudioStop];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"FileInfo" object:nil];

    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    
    NSLog(@"FileTable dealloc : %@", self.title);
    
//    NSLog(@"fsitem = %d", [fsItem retainCount]);
//    NSLog(@"selectedarray = %d", [selectedArray retainCount]);
//    NSLog(@"selectedimage = %d", [selectedImage retainCount]);
//    NSLog(@"unselectedimage = %d", [unselectedImage retainCount]);
//    NSLog(@"doccontroller = %d", [docController retainCount]);
//    NSLog(@"queue = %d", [queue retainCount]);
//    
//
//    while([fsItem retainCount] > 1){
//        NSLog(@"fsitem release");
//        [fsItem release];
//    }
//    
//    while([selectedArray retainCount] > 1){
//        [selectedArray release];
//    }
//    
//    while([selectedImage retainCount] > 1){
//        [selectedImage release];
//    }
//    
//    while([unselectedImage retainCount] > 1){
//        [unselectedImage release];
//    }
//    
//    while([AlbumArtArray retainCount] > 1){
//        NSLog(@"albumartarray release");
//        [AlbumArtArray release];
//    }

    [selectedArray release];
    [selectedImage release];
    [unselectedImage release];
    [AlbumArtArray release];
    [fsItem release];
    
    
    [id3dbArray release]; //?? 해도되나
    
    [docController release];
    [queue release];

    [editButton release];
    [playButton release];
    
    
    
//    NSLog(@"fsitem = %d", [fsItem retainCount]);
//    NSLog(@"selectedarray = %d", [selectedArray retainCount]);
//    NSLog(@"selectedimage = %d", [selectedImage retainCount]);
//    NSLog(@"unselectedimage = %d", [unselectedImage retainCount]);
//    NSLog(@"doccontroller = %d", [docController retainCount]);

    
//    [loading release];
    
	[super dealloc];
}

#pragma mark UITableView Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [fsItem.children count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *MyIdentifier = @"FSItemCell";
	
	FSItemCell *cell = (FSItemCell *)[tableView dequeueReusableCellWithIdentifier:MyIdentifier];
	if (cell == nil) {
		cell = (FSItemCell *)[[[NSBundle mainBundle] loadNibNamed:@"FSItemCell" owner:self options:nil] lastObject];
        
        // 선택버튼 생성후 에디트 모드가 아닌경우 숨김;
        UIImageView *imageView = [[UIImageView alloc] initWithImage:unselectedImage];
        imageView.frame = CGRectMake(5.0, 10.0, 23.0, 23.0);
        imageView.hidden = !isEdit;
        imageView.tag = kCellImageViewTag;
        
        [cell.contentView addSubview:imageView];
        [imageView release];
        
	}
    
    FSItem *child = [fsItem.children objectAtIndex:indexPath.row];
    cell.fsItem = child;
    
    // 에디트 모드시 오른쪽으로 시프트 
    [self shiftCell:cell];
    
    // 선택 동그라미 보이기 
    UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:kCellImageViewTag];
    imageView.hidden = !isEdit;

    // 선택된 된 인덱스 체크 
    BOOL selected = [selectedArray containsObject:indexPath];
    imageView.image = (selected) ? selectedImage : unselectedImage;
    
    // 에디트 모드일 경우 셀선택시 색 변화 
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    SettingsData *data = [SettingsData sharedSettingsData];
    cell.label.font = [UIFont fontWithName:@"Helvetica-Bold" size:data.FileTableFontSize]; 
    
    
    // cell label 위치 조정 디렉토리일경우 파일일 경우
    if (child.isDirectory) {
        CGPoint r = cell.label.center;
        r.y = 20;
        cell.label.center = r;
        
    }else{
        
        CGPoint r = cell.label.center;
        r.y = 14;
        cell.label.center = r;

    }
    
    
    if(isEdit){
        
        //에디트 모드에서 선택된 셀  
        if(selected){
            cell.label.textColor = [UIColor lightGrayColor];            
        }else{
            cell.label.textColor = [UIColor blackColor];
        }              
    }else{
        cell.label.textColor = [UIColor blackColor];
    }
    
//    NSInvocationOperation *operation 
//    = [[[NSInvocationOperation alloc] initWithTarget:self 
//                                            selector:@selector(AlbumArtWorker:)
//                                              object:cell] autorelease];
    
    if(     child.isDirectory == FALSE 
       && [[child.path pathExtension].lowercaseString isEqualToString:@"mp3"]){
        
        [cell.iconButton setImage:[UIImage imageNamed:@"defaultSmallAlbum.png"] forState:UIControlStateNormal];

        // 파일 생성시 인덱스가 변경됨 
        if ([AlbumArtArray count] > 0) {
            Id3db *item = [AlbumArtArray objectAtIndex:indexPath.row];
            
            if (item.AlbumArt == nil) {
                
                SettingsData *data = [SettingsData sharedSettingsData];
                if(data.OnAlbumArt == TRUE) {
//                    [self performSelectorInBackground:@selector(AlbumArtWorker:) withObject:cell];
                    [self performSelectorOnMainThread:@selector(AlbumArtWorker:) withObject:cell waitUntilDone:FALSE];
//                    [queue addOperation:operation];   
                }
                
            }else{
                [cell.iconButton setImage:item.AlbumArt forState:UIControlStateNormal];
            }
        }
    }
    
	return cell;
}




- (void) showFileInfo:(NSNotification *)noti{
    
    NSLog(@"Noti show file info ");
    FSItem *item = [noti object];
    
    FileInfo *fileInfo = [[FileInfo alloc] initWithNibName:@"FileInfo" bundle:nil];
    fileInfo.fsItem = item;
    fileInfo.id3dbArray = self.id3dbArray;
    
    
    [self.navigationController pushViewController:fileInfo animated:YES];
    
    
    if(isEdit == TRUE){
        [self showActionToolbar:FALSE delay:0];
    }

    
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
	FSItem *child = [fsItem.children objectAtIndex:indexPath.row];
	
	if([child.posixPermissions intValue] == 0) return;
    
    // 에디트 모드일 경우는 폴더이동 및 파일 재생 패스 
    if(!isEdit){
        
        if(child.canBeFollowed) {
        
            // 폴더일 경우 
            FileTable *rvc = [[FileTable alloc] init];
            rvc.title = fsItem.filename;
            rvc.fsItem = child;
            [self.navigationController pushViewController:rvc animated:YES];
            [rvc release];
            
        } else {
            // 파일일 경우 

            
            NSString *name = child.filename;
            if ([[name.pathExtension lowercaseString] isEqualToString:@"mp3"]) [self showMusicPlayer:indexPath.row];

            NSLog(@"name = %@", child.path);
            
//            //////////////////////////////////////////////////////
//            docController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:child.path]];
//            docController.delegate = self;
//            [docController presentPreviewAnimated:YES];
//            [docController presentOpenInMenuFromRect:CGRectZero inView:self.tableView animated:YES];            

        }
    }else{
        
        FSItemCell *cell = (FSItemCell *)[tableView cellForRowAtIndexPath:indexPath];
        
            
        // 선택한 오브젝트의 인덱스 수집 
        if(![selectedArray containsObject:indexPath]){
            [self.selectedArray addObject:indexPath];
                
            // 선택된 된 인덱스 체크             
            UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:kCellImageViewTag];
            imageView.image = selectedImage;            
            cell.label.textColor = [UIColor lightGrayColor];

        }else{
            [selectedArray removeObject:indexPath];
            
            
            // 선택된 된 인덱스 체크             
            UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:kCellImageViewTag];
            imageView.image = unselectedImage;
            cell.label.textColor = [UIColor blackColor];

        }
        
        

        
        
    }

    [self.tableView deselectRowAtIndexPath:indexPath animated:TRUE];
//    [tableView reloadData];
    
    NSArray *itemArray = actionToolbar.items;
    
    
    if ([selectedArray count] > 0) {
    
        for (UITabBarItem *item in itemArray){
            if(item.tag > 2000) item.enabled =TRUE;
        }

    }else{

        for (UITabBarItem *item in itemArray){
            if(item.tag > 2000) item.enabled =FALSE;
        }
    }
    
    
    
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    // If row is deleted, remove it from the list.
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        // delete your data item here
        // Animate the deletion from the table.
        
        
        FSItem *item = [self.fsItem.children objectAtIndex:[indexPath row]];

        // id3 캐쉬에서 삭제
        [self deleteId3ArrayFromCache:item];
        [self SavingFileInfo_plst:self.id3dbArray];
        

//        NSString *DeleteFile = [item.path stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];        
//        
//        NSLog(@"%@", DeleteFile);
//        
//        for(int i=0;i < [self.id3dbArray count];i++){
//            Id3db *item = [self.id3dbArray objectAtIndex:i];
//            NSString *path 
//            = [[item.path stringByReplacingOccurrencesOfString:@"file://localhost/private" withString:@""] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//
//            if([DeleteFile isEqualToString:path]) {
//                [self.id3dbArray removeObjectAtIndex:i];
//                NSLog(@"Delete a cache : %@", path);
//                break;
//            }
//
//        }
        
        // delete fileinfo from DB
        [self deleteFileFromTableInDatabase:[NSArray arrayWithObject:item.path]];
            
        // delete real file
        NSFileManager *fm = [NSFileManager defaultManager];
        [fm removeItemAtPath:item.path error:nil];
        
        
        // 우선 데이터에서 삭제한다
        NSMutableArray *marray = [self.fsItem.children mutableCopy];
        [marray removeObjectAtIndex:[indexPath row]];
        self.fsItem.children = marray;


        // 테이블에서 삭제한다.
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] 
                              withRowAnimation:UITableViewRowAnimationFade];

        
    }
}


- (void)deleteId3ArrayFromCache:(FSItem *)item{
    
    // id3 캐쉬에서 삭제
    NSString *DeleteFile = [item.path stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];        
        
    for(int i=0;i < [self.id3dbArray count];i++){
        Id3db *item = [self.id3dbArray objectAtIndex:i];
        NSString *path 
        = [[item.path stringByReplacingOccurrencesOfString:@"file://localhost/private" withString:@""] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        if([DeleteFile isEqualToString:path]) {
            [self.id3dbArray removeObjectAtIndex:i];
            NSLog(@"Delete a cache : %@", path);
            break;
        }
        
    }

    
}


- (void)deleteFileFromTableInDatabase:(NSArray *)pathArray{
    
    // Set File Manager
    NSArray *docs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [docs objectAtIndex:0];    
    NSString *playlistFile = [docPath stringByAppendingPathComponent:@"/tmp/data.sqlite3"];
    
    NSFileManager *fm = [NSFileManager defaultManager];
    
    //--------------------------------------------------------------------
    // 초기 애플리케이션 오픈시 데이터 베이스 파일 읽어 들이기 
    // sql 열기
    sqlite3 *database;
    if (sqlite3_open([playlistFile UTF8String], &database)
        != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
    }
    
    
    
    BOOL isDir;
    for (NSString *path in pathArray) {

        // dir delete
        if([fm fileExistsAtPath:path isDirectory:&isDir] && isDir){

            NSLog(@"this is a dir");
            path = [path stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@/", docPath] withString:@""];
            NSString *query = [NSString stringWithFormat:@"DELETE FROM ID3DATA WHERE PATH = \"%@\"", path];
            NSLog(@"DirDelete : Query = %@", query);        
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
            
        }
        // file delete
        else{
        
            path = [path stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@/", docPath] withString:@""];
            NSString *query = [NSString stringWithFormat:@"DELETE FROM ID3DATA WHERE FILEPATH = \"%@\"", path];
            NSLog(@"FileDelete : Query = %@", query);        
            sqlite3_stmt *stmt;
            if (sqlite3_prepare_v2(database, [query UTF8String], -1, &stmt, nil) != SQLITE_OK) {
//                NSAssert1(0, @"Error while creating delete statement. '%s'", sqlite3_errmsg(database));
                NSLog(@"%@", sqlite3_errmsg(database));
                
            }
            
            if (sqlite3_step(stmt) != SQLITE_DONE){
                NSLog(@"Delete Error");
            }else{
                NSLog(@"Delete Success");
            }
            sqlite3_finalize(stmt);
        }

        
    }
    
    sqlite3_close(database);

}

#pragma mark IBAction

- (IBAction)toggleEdit:(id)sender {
    
        
    //[self.tableView setEditing:!self.tableView.editing animated:YES];
    if (!isEdit) {
        isEdit = TRUE;
        [self.navigationItem.rightBarButtonItem setTitle:@"Done"];     
        [self hideTabBar:self.tabBarController];
        [self.navigationItem setHidesBackButton:YES animated:YES];
        [self showActionToolbar:TRUE delay:0.3];
        [self.tableView setContentInset:UIEdgeInsetsMake(0, 0, 44, 0)];
        
        
    }
    else {
        isEdit = FALSE;
        [self.navigationItem.rightBarButtonItem setTitle:@"Edit"];
        [self showTabBar:self.tabBarController];
        [self.navigationItem setHidesBackButton:NO animated:YES];
        [selectedArray removeAllObjects];
        [self showActionToolbar:false delay:0];

        self.navigationItem.leftBarButtonItem = nil;
        [self.tableView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
        
        if([SettingsData sharedSettingsData].isUpdatedForFileTable == FALSE){
            // SQL Update
            [self ShowUpdateFileInfo];
        }
        
    }
    [self.tableView reloadData];
    
}

- (void) selectAllFiles{
    NSArray *itemArray = actionToolbar.items;
    
    // 이미 전체 선택 됨
    if ([selectedArray count] == [fsItem.children count]) {
        // 선택 제거
        [selectedArray removeAllObjects];
        [self.tableView reloadData];
        
        for (UITabBarItem *item in itemArray){
            if(item.tag > 2000) item.enabled = FALSE;
        }

        

    }else if([selectedArray count] == 0){
        
        
        // 파일 선택 
        [selectedArray removeAllObjects];
        for(int i=0; i < [fsItem.children count];i++){
            
            FSItem *item = [fsItem.children objectAtIndex:i];
            if(item.isDirectory == FALSE) [selectedArray addObject: [NSIndexPath indexPathForRow:i inSection:0]];
        }
        
        // 파일이없고 디렉토리만 있는 경우 디렉토리만 선택 
        if([selectedArray count] == 0){        
            for(int i=0; i < [fsItem.children count];i++){
                [selectedArray addObject: [NSIndexPath indexPathForRow:i inSection:0]];
            }
        }
        
        [self.tableView reloadData];            
        
        for (UITabBarItem *item in itemArray){
            if(item.tag > 2000) item.enabled = TRUE;
        }


        

    }else{
        // 전체 선택
        [selectedArray removeAllObjects];
        for(int i=0; i < [fsItem.children count];i++){
            [selectedArray addObject: [NSIndexPath indexPathForRow:i inSection:0]];
        }
        [self.tableView reloadData];            
        
        for (UITabBarItem *item in itemArray){
            if(item.tag > 2000) item.enabled = TRUE;
        }


    }
    
}

- (void) selectNonFiles{
    
    [selectedArray removeAllObjects];
    [self.tableView reloadData];
    
    NSArray *itemArray = actionToolbar.items;
    
    for (UITabBarItem *item in itemArray){
        if(item.tag > 2000) item.enabled =FALSE;
    }
    
}

- (void) hideTabBar:(UITabBarController *) tabbarcontroller {
    
    [UIView animateWithDuration:0.3 animations:^{
        for(UIView *view in tabbarcontroller.view.subviews)
        {
            //        NSLog(@"view = %@", view);
            if([view isKindOfClass:[UITabBar class]]) {
                [view setFrame:CGRectMake(view.frame.origin.x, 480
                                          , view.frame.size.width, view.frame.size.height)];
            } 
            else {
                [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y
                                          , view.frame.size.width, 480)];
            }
        }

        
        
    }]; 
    
}

- (void) showTabBar:(UITabBarController *) tabbarcontroller {
    
    [UIView animateWithDuration:0.3 delay:0.3 options:UIViewAnimationOptionCurveLinear animations:^{
        for(UIView *view in tabbarcontroller.view.subviews)
        {
            if([view isKindOfClass:[UITabBar class]]) {
                [view setFrame:CGRectMake(view.frame.origin.x, 431, view.frame.size.width, view.frame.size.height)];
                
            } 
            else {
                [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, 431)];
            }
        }
    
    }
    completion:nil];
    
}

- (void) shiftCell:(FSItemCell *)cell{
    
    int offset = 0;
    int iconButtonNormal = 8;
    int labelNormal = 58;
    int sizeNormal = 58;
    CGPoint point;
    CGSize  size;
    
    offset = (isEdit) ? 28 : -10;
    
    point = cell.iconButton.frame.origin;
    size  = cell.iconButton.frame.size;
    point.x = offset + iconButtonNormal + size.width  / 2;
    point.y = 0  + point.y + size.height / 2;
    cell.iconButton.center = point;
    
    point = cell.label.frame.origin;
    size  = cell.label.frame.size;
    point.x = offset + labelNormal + size.width  / 2;
    point.y = 0  + point.y + size.height / 2;
    cell.label.center = point;
    
    point = cell.size.frame.origin;
    size  = cell.size.frame.size;
    point.x = offset + sizeNormal + size.width  / 2;
    point.y = 0  + point.y + size.height / 2;
    cell.size.center = point;
    
}

- (void) showActionToolbar:(BOOL)show delay:(float)delay{
    
	CGRect toolbarFrame = actionToolbar.frame;
	CGRect tableViewFrame = self.tableView.frame;
    CGRect navFrame = self.navigationController.view.frame;
    
    if (show)
	{
        toolbarFrame.origin.y = 
                    + self.navigationController.view.frame.size.height 
                    - toolbarFrame.size.height;
                
	}
	else
	{
        toolbarFrame.origin.y = 10 
                    + self.navigationController.view.frame.size.height 
                    + toolbarFrame.size.height;
        
        
	}
    

    [UIView animateWithDuration:0.3 delay:delay options:UIViewAnimationOptionCurveLinear animations:^{

        self.navigationController.view.frame = navFrame;
        self.tableView.frame = tableViewFrame;
        actionToolbar.frame = toolbarFrame;

        
    }completion:nil];


}

- (void) sortDirectoryFiles{
    NSLog(@"sortDirFiles()");
    
    // 디렉토리 정렬 ------------------------------------------------------------------
    // fsitem.childrun 정렬
//    NSMutableArray *sort = [[NSMutableArray alloc] initWithArray:fsItem.children];
//    NSMutableArray *dir  = [[NSMutableArray alloc] init];
    
    
    NSMutableArray *sort = [fsItem.children mutableCopy];
    NSMutableArray *dir  = [[NSMutableArray alloc] init];
    
    // 파일리스트중에 디렉토리 추출 
    for(int i =0 ; i < [sort count];i++){
        FSItem *item = [sort objectAtIndex:i];
        // 디렉토리 아이템은 따로 dir 에 추가 
        if([item isDirectory]) [dir addObject:item];
        
    }
    //NSLog(@"dir = %d", [dir count]);
    
    // 파일리스트에서 디렉토리를 제거하고 맨 앞으로 넣음 역순으로 for 을 사용한것은 
    // 순서있는 디렉토리를 앞에서 부터 맨앞으로 넣게 되면 디렉토리만 역순이 되기때문  
    for(int i = [dir count] - 1;i >= 0;i--){
        FSItem *item = [dir objectAtIndex:i];
        [sort removeObject:item];
        [sort insertObject:item atIndex:0];
    }
    
    // 재정렬한 컬렉션 대입 
    fsItem.children = sort;
    
    [dir release];
    
    NSLog(@"sortDirfiles Done");
    
    
}

#pragma mark File Actions

- (void)setFsItem:(FSItem *)item {
	if(item != fsItem) {
		[item retain];
		[fsItem release];
		fsItem = item;
		self.title = fsItem.prettyFilename;
	}
}

- (FSItem *)fsItem {
	return fsItem;
}

- (void) deleteSelection{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:@"Are you sure?"
                                  delegate:self
                                  cancelButtonTitle:@"Cancel"
                                  destructiveButtonTitle:@"Yes, Delete it"        // Important Button
                                  otherButtonTitles:nil];
    
    actionSheet.tag = 5000;
    [actionSheet showFromToolbar:actionToolbar];
    [actionSheet release];
    
}

- (void) copySelection{
    NSMutableArray *selections = [[NSMutableArray alloc] init];
    for(NSIndexPath * index in selectedArray){
        FSItem *item = [fsItem.children objectAtIndex:[index row]];
//        NSLog(@"path = %@", item.path);
        [selections addObject:item.path];
    }    
    DirectoryChooser *chdir = [[DirectoryChooser alloc] init];
    
    chdir.CopyOrMove = TRUE;
    chdir.selections = selections;
    
    
    [self.navigationController presentModalViewController:chdir animated:YES];
    [self selectNonFiles];
    
    
//    [chdir release];

    
}

- (void) moveSelection{
    NSMutableArray *selections = [[NSMutableArray alloc] init];
    for(NSIndexPath * index in selectedArray){
        FSItem *item = [fsItem.children objectAtIndex:[index row]];
        //        NSLog(@"path = %@", item.path);
        [selections addObject:item.path];
        
    }    
    DirectoryChooser *chdir = [[DirectoryChooser alloc] init];
    
    chdir.CopyOrMove = FALSE;
    chdir.selections = selections;
    chdir.filetable = self;
    
    [self.navigationController presentModalViewController:chdir animated:YES];
    [self selectNonFiles];

    
        
    
}

- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    
    if(actionSheet.tag == 5000 && buttonIndex == 0){
        
        
        
        NSFileManager *fm = [NSFileManager defaultManager];
        NSMutableIndexSet *multiIndex = [NSMutableIndexSet indexSet];
        
        for (NSIndexPath *index in selectedArray) {
            [multiIndex addIndex:[index row]];   
            FSItem *item = [self.fsItem.children objectAtIndex:[index row]];
            
            // delete db
            [self deleteFileFromTableInDatabase:[NSArray arrayWithObject:item.path]];
            
            // delete file
            [fm removeItemAtPath:item.path error:nil];
            
            //delete cache
            [self deleteId3ArrayFromCache:item];
            [self SavingFileInfo_plst:self.id3dbArray];
            

        }
        
        NSMutableArray *items = [self.fsItem.children mutableCopy];            
        [items removeObjectsAtIndexes:multiIndex];
        self.fsItem.children = items;
        
        [self.tableView deleteRowsAtIndexPaths:selectedArray withRowAnimation:UITableViewRowAnimationFade];
        
        [selectedArray removeAllObjects];
        [self.tableView reloadData];

    }
    
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    
    if(alertView.tag == 1000 && buttonIndex == 1){
        UITextField *TextField = [alertView.subviews objectAtIndex:5];
        
        // str check
        if([TextField.text isEqualToString:@"tmp"] == TRUE) {
            
            UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Fail" message:@"Cause : Don't use the name" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            
            myAlertView.tag = 8000;
            [myAlertView show];
            [myAlertView release];
            return;   
        }
        
        if([TextField.text length] == 0) return;
        [self makeDir:TextField.text];
//        [TextField release];
    }
    
}

- (void) alertMakeDir{
    
    UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Enter New Directory Name" message:@"\n\n" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    UITextField *myTextField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 55.0, 260.0, 30.0)];
    [myTextField setBackgroundColor:[UIColor whiteColor]];
    [myAlertView addSubview:myTextField];
    
    myTextField.borderStyle = UITextBorderStyleBezel;
    myTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    myTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    myTextField.font = [UIFont systemFontOfSize:18];

    
    [myTextField becomeFirstResponder];
    
    myAlertView.tag = 1000;
    [myAlertView show];
    [myAlertView release];
    [myTextField release];
    
}

- (void) makeDir:(NSString *)dirName{
    NSLog(@"makedir()");
    
    // 파일 관리자 생성 
    NSFileManager *fm = [NSFileManager defaultManager];
    [fm changeCurrentDirectoryPath:fsItem.path];
    [fm createDirectoryAtPath:[NSString stringWithFormat:@"%@/%@", fsItem.path, dirName] withIntermediateDirectories:YES attributes:nil error:nil];
    [self refreshFiles];
//    [self.tableView reloadData];
//    [fm release]; 
    
}

- (void) refreshFiles{
    NSLog(@"refresh files()");
    
    fsItem.children = nil;
    [fsItem children];  
    
    NSLog(@"Total = %d", [fsItem.children count]);
    [self sortDirectoryFiles];   
    
    
    // init albumartarray
    AlbumArtArray = [[NSMutableArray alloc] init];
    for (int i=0;i < [fsItem.children count];i++) {
        [AlbumArtArray addObject:[[[Id3db alloc] init] autorelease]];
    }

    
    [self.tableView reloadData];
}

#pragma mark MusicPlayer

- (BOOL)checkPlaylist_plst{
    
    
    NSArray *docs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [docs objectAtIndex:0];
    
    NSString *currentPath = fsItem.path;    
    
    NSFileManager *fm = [[[NSFileManager alloc] init] autorelease];
    [fm changeCurrentDirectoryPath:currentPath];
    
    if ([fm fileExistsAtPath:@".cache.plst"] == FALSE) {
        
        NSLog(@"Cache doesn't Exists");
        [fm changeCurrentDirectoryPath:docPath];
        
        return FALSE;        
    }

    NSLog(@"Cache Exists");
    return TRUE;
    
}


- (BOOL)SavingFileInfo_plst:(NSArray *)id3array{
        
    NSArray *docs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [docs objectAtIndex:0];

    
    NSString *currentPath = fsItem.path;
    NSString *playlistFile = [currentPath stringByAppendingPathComponent:@".cache.plst"];
    
    NSData* encodedBook = [NSKeyedArchiver archivedDataWithRootObject:id3array];
	[encodedBook writeToFile:playlistFile atomically:YES];
    
    NSFileManager *fm = [[[NSFileManager alloc] init] autorelease];
    [fm changeCurrentDirectoryPath:currentPath];
    
    
    if ([fm fileExistsAtPath:@".cache.plst"] == FALSE) {
        [fm changeCurrentDirectoryPath:docPath];
        return FALSE;
    }
    [fm changeCurrentDirectoryPath:docPath];
    NSLog(@"Cache Save Done");
    return TRUE;
    
}


-(int)getAllId3Info:(NSString *)StartFileName{

    // id3 로딩은 했지만 파일을 삭제하여 존재하지 않은 경우가 있음. 존재하는것 모두 삭제
    [self.id3dbArray removeAllObjects];
    [self.id3dbArray release];
    self.id3dbArray = [[NSMutableArray alloc] init];
    
    
    int StartPoint = -1;
    //--------------------------------------------------------------------
    // 초기 애플리케이션 오픈시 데이터 베이스 파일 읽어 들이기 
    // sql 열기
    sqlite3 *database;
    if (sqlite3_open([[self dataFilePath] UTF8String], &database)
        != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
    }
    
    
    NSArray *docs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [docs objectAtIndex:0];
    NSString *ndocPath = [NSString stringWithFormat:@"%@/", docPath];
    
    
    // if not root dir
    NSString *currentPath 
    = [self.fsItem.path stringByReplacingOccurrencesOfString:ndocPath withString:@""];
    
    // if root dir
    if ([docPath isEqualToString:fsItem.path]) currentPath = @"";
    
    // make sql string
    NSString *query = [NSString stringWithFormat:@"SELECT FILEPATH, PATH, FILENAME, TITLE, ARTIST, ALBUM, LYRICS, DURATION FROM ID3DATA WHERE PATH=\"%@\"", currentPath];
    NSLog(@"%@", query);
    
    
    //----------------------------------------------------------------------
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        
        NSLog(@"Select SQL process");
        int i = 0 ;
        while (sqlite3_step(statement) == SQLITE_ROW) {
            
            char *filepath  = (char *)sqlite3_column_text(statement, 0);
            //                char *path      = (char *)sqlite3_column_text(statement, 1);
            char *filename  = (char *)sqlite3_column_text(statement, 2);
            char *title     = (char *)sqlite3_column_text(statement, 3);
            char *artist    = (char *)sqlite3_column_text(statement, 4);
            char *album     = (char *)sqlite3_column_text(statement, 5);
            char *lyrics    = (char *)sqlite3_column_text(statement, 6);
            
            Id3db *item 
            = [[Id3db alloc] initWithURL:
               [NSURL fileURLWithPath:[NSString stringWithCString:filepath 
                                                         encoding:NSUTF8StringEncoding]]];
            
            if(title  == NULL) title  = "Unknown Title";
            if(lyrics == NULL) lyrics = "";
            if(artist == NULL) artist = "Unknown Artist";
            if(album  == NULL) album  = "Unknown Album";
            
            item.title  = [NSString stringWithCString:title encoding:NSUTF8StringEncoding];
            item.artist = [NSString stringWithCString:artist encoding:NSUTF8StringEncoding];
            item.album  = [NSString stringWithCString:album encoding:NSUTF8StringEncoding];
            item.lyrics = [NSString stringWithCString:lyrics encoding:NSUTF8StringEncoding];
            
            [self.id3dbArray addObject:item];
            
//            NSLog(@"add to id3dbArray : %s", filepath);
            
            [item release];
            
            
            if([StartFileName isEqualToString:[NSString stringWithCString:filename 
                                                                   encoding:NSUTF8StringEncoding]])
            {
                StartPoint = i;
            }
            
            
            i++;
            
        }
        sqlite3_finalize(statement);
    }
    sqlite3_close(database);
    NSLog(@"SQL Process Done");
    
    NSLog(@"File Select Items : %d", [self.id3dbArray count]);
    [self SavingFileInfo_plst:self.id3dbArray];

    
    return StartPoint;
}

- (void) showMusicPlayer:(int)index{
    
    int startoPoint = -1;
    FSItem *fsitem = [fsItem.children objectAtIndex:index];   
        
    /// 캐쉬 파일 있는지 체크 없으면 sql 로 불러옴
    if([self checkPlaylist_plst] == FALSE){
    
        startoPoint = [self getAllId3Info:fsitem.filename];
    
    }// end if when no playlist cache
    else{
        
        // play index 구하기
        int i = 0;
        for (Id3db *item in self.id3dbArray) {
            
            NSString *path = item.path;
            NSString *itemPath = [[path lastPathComponent] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            if ([fsitem.filename isEqualToString:itemPath]) {
                startoPoint = i;
                break;
            }
            
            i++;
        }

    }


    NSLog(@"Start Index : %d, retain : %d", startoPoint, [self.id3dbArray retainCount]);
    
    
    if(startoPoint >= 0){
        
        // save current dir id3 info
        MyMusicPlayer *imp = [MyMusicPlayer sharedMusicPlayer];
        [imp MediaItems:self.id3dbArray  startPoint:startoPoint];
        imp.hidesBottomBarWhenPushed = TRUE;
        [self.navigationController pushViewController:imp animated:YES];
        NSLog(@"Open MusicPlayer");
        
    }else{     
        
        //temporally off
//        [self ShowUpdateFileInfo];
//        [self getAllId3Info:@""];
        
    }
    
   

}

#pragma mark Utilities

- (NSString *) URLEncoding:(NSString *)str{
    
    NSString *enc = (NSString *)CFURLCreateStringByAddingPercentEscapes(
                  NULL,
                  (CFStringRef)str,
                  NULL,
                  (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                  kCFStringEncodingUTF8 
                  );
    [enc autorelease];
    
    return enc;
    
}

- (int) checkMP3:(NSString *)name{
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"mp3$|m4a"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:nil];
    
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:name
                                                        options:0
                                                          range:NSMakeRange(0, [name length])];
    
    
    return numberOfMatches;

}

-(void) refreshCells{
    NSArray *cells = [self.tableView visibleCells];
    for (FSItemCell *cell in cells) {
        [cell.iconButton setNeedsLayout];
        [cell.iconButton setNeedsDisplay];
        
        
    }
//    NSLog(@"Cell Refresh");
    
    
}

#pragma mark SQL Process

- (void)ShowUpdateFileInfo{
    
    NSLog(@"Update file info");
    
    self.navigationController.view.userInteractionEnabled = false;
    self.view.userInteractionEnabled = false;
    self.tabBarController.view.userInteractionEnabled = false;
    
    loading = [LoadingView loadingViewInView:self.navigationController.view 
                                   withTitle:@"DB Updating ..."];
    
    [loading performSelector:@selector(removeView)
                  withObject:nil
                  afterDelay:300.0];
    
    [NSThread detachNewThreadSelector:@selector(UpdateThreadProcess) 
                             toTarget:self 
                           withObject:nil]; 

}

- (NSString *)dataFilePath {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(
														 NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:@"/tmp/data.sqlite3"];
}

- (void)UpdateFileInfo{
    
    NSLog(@"UpdateFileInfo");
    
    // Set File Manager
    NSArray *docs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [docs objectAtIndex:0];
    NSFileManager *fm = [NSFileManager defaultManager]; 
    [fm changeCurrentDirectoryPath:docPath];
    NSDirectoryEnumerator *dirEnum = [fm enumeratorAtPath:docPath];
    
    
    //--------------------------------------------------------------------
    // 초기 애플리케이션 오픈시 데이터 베이스 파일 읽어 들이기 
    // sql 열기
    sqlite3 *database;
    if (sqlite3_open([[self dataFilePath] UTF8String], &database)
		!= SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
    }
    
    // 쿼리 읽기
    NSString *query = @"SELECT FILEPATH FROM ID3DATA";
    
    sqlite3_stmt *statement;
    NSMutableArray *pathArray = [NSMutableArray array];
    if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        
        NSLog(@"Select SQL process");
		while (sqlite3_step(statement) == SQLITE_ROW) {
			char *filepath  = (char *)sqlite3_column_text(statement, 0);
            [pathArray addObject:[NSString stringWithCString:filepath 
                                                    encoding:NSUTF8StringEncoding]];
            
		}
		sqlite3_finalize(statement);
    }
    
    
    NSString *file;
    while (file = [dirEnum nextObject]) {
        
        
        
        //----------------------------------------------------------------------
        //  path condition
        if([[[file pathExtension] uppercaseString] isEqualToString:@"MP3"] == FALSE) continue;   
        
        if([pathArray containsObject:file] == TRUE) continue;
        
        NSURL *fileurl = [NSURL fileURLWithPath:file];
        
        Id3db *id3 = [[Id3db alloc] initWithURL:fileurl];
        [id3 id3ForFileAtPath];
        
        char *update = "INSERT OR REPLACE INTO ID3DATA (FILEPATH, PATH, FILENAME, TITLE, ARTIST, ALBUM, LYRICS, DURATION) VALUES (?, ?, ?, ?, ?, ?, ?, ?);";
        
        
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
            
            
            NSLog(@"FileName : %@", [file lastPathComponent]);
                        
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
    
    NSLog(@"UpdateFileInfo Done");
    
    
    
}

- (void)UpdateCacheInfo{
    
    [self getAllId3Info:@""];
    
//    // collection for diff files
//    NSMutableArray *diffAddray = [NSMutableArray array];
//    
//    
//    for (FSItem *fitem in fsItem.children) {
//
//        for (Id3db *item in self.id3dbArray) {
//            
//            NSString *path = item.path;
//            NSString *itemPath = [[path lastPathComponent] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//            
//            if ([fitem.filename isEqualToString:itemPath] == TRUE) {
//                NSLog(@"not matched : %@", fitem.path);
//                [diffAddray addObject:fitem];
//            }
//            
//        }
//    }

    
    
    
//    NSString *DeleteFile = [item.path stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];        
//    
//    for(int i=0;i < [self.id3dbArray count];i++){
//        Id3db *item = [self.id3dbArray objectAtIndex:i];
//        NSString *path 
//        = [[item.path stringByReplacingOccurrencesOfString:@"file://localhost/private" withString:@""] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//        
//        if([DeleteFile isEqualToString:path]) {
//            [self.id3dbArray removeObjectAtIndex:i];
//            NSLog(@"Delete a cache : %@", path);
//            break;
//        }
//        
//    }
   
}

- (void)UpdateThreadProcess{
    NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];
    
    //이곳에 처리할 코드를 넣는다.
    
    [self UpdateFileInfo];

    [loading removeView];
    
    self.navigationController.view.userInteractionEnabled = TRUE;
    self.view.userInteractionEnabled = TRUE;
    self.tabBarController.view.userInteractionEnabled = TRUE;

    [autoreleasepool release];
    NSLog(@"Thread Done");
    [NSThread exit];
    
}

#pragma mark Artwork Process

- (void) AlbumArtWorker:(FSItemCell *)cell{ 

    // doc dir
    NSArray *docs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [docs objectAtIndex:0];
    
    NSIndexPath *index = [self.tableView indexPathForCell:cell];
    Id3db *id3 = [AlbumArtArray objectAtIndex:index.row];
    
    // 캐쉬파일 이름지정 
    NSString *cache 
    = [NSString stringWithFormat:@"%@/tmp/%@.png",docPath, [cell.fsItem.path lastPathComponent]];
    
    // 파일 객체 생성
    NSData *imgdata = [NSData dataWithContentsOfFile:cache];
    
    // 해당 파일이 존재하지 않으면 앨범 아트 추출
    if (imgdata.length > 0) {
        id3.AlbumArt = [UIImage imageWithContentsOfFile:cache];
        [self performSelectorOnMainThread:@selector(changeCellImage:) withObject:cell waitUntilDone:FALSE];        
        
    }else{
        NSLog(@"No Image : %@, %@", cell.fsItem.path, cache);
        
        [self performSelectorInBackground:@selector(artworksForFileAtPath:) withObject:cell];
        
//        id3.AlbumArt = [self artworksForFileAtPath:cell.fsItem.path];    
    }


//    [self performSelectorInBackground:@selector(changeCellImage:) withObject:cell];
//    [self performSelector:@selector(changeCellImage:) withObject:cell];
}

- (void) changeCellImage:(FSItemCell *)cell{
    
    NSIndexPath *index = [self.tableView indexPathForCell:cell];
    Id3db *id3 = [AlbumArtArray objectAtIndex:index.row];

    [cell.iconButton setImage:id3.AlbumArt forState:UIControlStateNormal];
//    NSLog(@"Change Cell Image()");
    
//    [cell.iconButton setNeedsDisplay];
//    [cell.iconButton setNeedsLayout];
    
    
}

//- (UIImage *) artworksForFileAtPath:(NSString *)filepath{
- (UIImage *)artworksForFileAtPath:(FSItemCell *)cell{

    UIImage *img = [UIImage imageNamed:@"defaultAlbum.png"];
    
    AVURLAsset *asset = [[AVURLAsset alloc]initWithURL:[NSURL fileURLWithPath:cell.fsItem.path] options:nil]; 
    // for get artwork image
    NSArray *array = [AVMetadataItem metadataItemsFromArray:asset.commonMetadata
                                                    withKey:AVMetadataCommonKeyArtwork 
                                                   keySpace:AVMetadataKeySpaceCommon];
    
    for(AVMetadataItem *metadata in array) { 
        
        if ([metadata.commonKey isEqualToString:@"artwork"])
        {
            NSDictionary *d = [metadata.value copyWithZone:nil];            
            img = [UIImage imageWithData:[d objectForKey:@"data"]];
        }
    }
    
    // resize
    CGSize itemSize = CGSizeMake(88, 88);
    UIGraphicsBeginImageContext(itemSize);
    CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
    [img drawInRect:imageRect];
    img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    NSData *imageData = UIImagePNGRepresentation(img);
    NSArray *docs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [docs objectAtIndex:0];
    
    NSString *newPath = [NSString stringWithFormat:@"%@/tmp/%@.png", docPath, [cell.fsItem.path lastPathComponent]];
        
    [imageData writeToFile:newPath atomically:YES];
    
    
    
    NSIndexPath *index = [self.tableView indexPathForCell:cell];
    Id3db *id3 = [AlbumArtArray objectAtIndex:index.row];
    id3.AlbumArt = img;
    
    [self performSelectorOnMainThread:@selector(changeCellImage:) withObject:cell waitUntilDone:FALSE];        

    
    [asset release];
    return img;
}

#pragma mark UIToolbar

- (void) initBottomToolbar{
    
    actionToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 500, 320, 44)];
    actionToolbar.barStyle = UIBarStyleBlack;
    actionToolbar.barStyle = UIBarStyleDefault;
    
    UIBarButtonItem *B1 
    = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(alertMakeDir)] autorelease];
    
    UIBarButtonItem *B2 
    = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil] autorelease];
    
    UIBarButtonItem *B7 
    = [[[UIBarButtonItem alloc] initWithTitle:@"Select All" style:UIBarButtonItemStyleBordered target:self action:@selector(selectAllFiles)] autorelease];
    
    UIBarButtonItem *B3 
    = [[[UIBarButtonItem alloc] initWithTitle:@"Copy" style:UIBarButtonItemStyleBordered target:self action:@selector(copySelection)] autorelease];

    UIBarButtonItem *B4
    = [[[UIBarButtonItem alloc] initWithTitle:@"Move" style:UIBarButtonItemStyleBordered target:self action:@selector(moveSelection)] autorelease];
    
    UIBarButtonItem *B6 
    = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteSelection)] autorelease];
        
    B1.style = UIBarButtonItemStyleBordered;
    B6.style = UIBarButtonItemStyleBordered;
    B3.tag = 2001;
    B4.tag = 2002;
    B6.tag = 2003;
    B3.enabled = FALSE;
    B4.enabled = FALSE;
    B6.enabled = FALSE;
    
	[actionToolbar setItems:[NSArray arrayWithObjects:B1, B7, B2, B3, B4,B2, B6, nil]];

    
}


#pragma mark UIDocuments Innteraction

- (UIViewController *)documentInteractionControllerViewControllerForPreview:(UIDocumentInteractionController *)controller
{
	return self;
}

- (UIView *)documentInteractionControllerViewForPreview:(UIDocumentInteractionController *)controller
{
	return self.view;
}

- (CGRect)documentInteractionControllerRectForPreview:(UIDocumentInteractionController *)controller
{
	return self.view.frame;
}

-(void)documentInteractionController:(UIDocumentInteractionController *)controller 
       willBeginSendingToApplication:(NSString *)application {
    NSLog(@"begin sending");
}

-(void)documentInteractionController:(UIDocumentInteractionController *)controller 
          didEndSendingToApplication:(NSString *)application {
    NSLog(@"end sending");
}

-(void)documentInteractionControllerDidDismissOpenInMenu:
(UIDocumentInteractionController *)controller {
    NSLog(@"dismiss open in");
}



@end

