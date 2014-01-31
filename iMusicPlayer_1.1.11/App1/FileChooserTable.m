//
//  FileChooserTable.m
//  iMusicPlayer
//
//  Created by Han Eunsung on 11. 11. 9..
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//


#import "FileChooserTable.h"
#import "FSItem.h"
#import "Id3db.h"
#import "LoadingView.h"
#import <sqlite3.h>

@implementation FileChooserTable

@synthesize fsItem;
@synthesize SelectionArray;
@synthesize inDirSelections;
@synthesize SelectionIndexDic;
@synthesize loading;
@synthesize PlaylistName;

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - button & method

- (void)id3ForFileAtPath:(NSString *)filepath
{
    
    AVURLAsset *asset = [[AVURLAsset alloc]initWithURL:[NSURL fileURLWithPath:filepath ] options:nil]; 
    NSArray *formatArray = asset.availableMetadataFormats; // get org.id3
    
    // 가사가 있을 경우
    if([[asset lyrics] length] > 0){
        // 가사 있음
    }else {        
        // 가사 없음
    }
    
    NSString *title, *artist, *albumName;
    title = @"";
    artist = @"Unknown Artist";
    albumName = @"Unknown Album";
    
    // 태그없을 경우 
    if ([formatArray count] == 0 ) {
        [asset release];
        return;
    }
    
    NSArray *array = [asset metadataForFormat:[formatArray objectAtIndex:0]]; //for get id3 tags
    
    for(AVMetadataItem *metadata in array) { 
        if ([metadata.commonKey isEqualToString:@"artwork"]){
            // 앨범아트 추출 못하는 경우가 많아 다른 메소드로 대체 
//            NSDictionary *d = [metadata.value copyWithZone:nil];
//            UIImage *img = [UIImage imageWithData:[d objectForKey:@"data"]];
//            NSLog(@"img %f %f", img.size.width, img.size.height);            
        }
        else if([metadata.commonKey isEqualToString:@"title"]){
            
            title = metadata.stringValue;
        }
        else if([metadata.commonKey isEqualToString:@"artist"]){
            artist = metadata.stringValue;
        }
        else if([metadata.commonKey isEqualToString:@"albumName"]){
            albumName = metadata.stringValue;
        }
        
        //        NSLog(@"Unknown : %@ %@ %@ %@",metadata.commonKey, metadata.dateValue, metadata.numberValue, metadata.stringValue);
    }
    
//    if(![title isEqualToString:@""]) SongTitle.text = title;
//    SongAlbum.text = albumName;
//    SongSinger.text = artist;
//    
    [asset release];
    
}

- (void)ResetButton{
    
    // 선택 인덱스 제거 
    [self.inDirSelections   removeAllObjects];
    [self.SelectionIndexDic removeAllObjects];
    [self.SelectionArray    removeAllObjects];
//    NSLog(@"selection = %d", [self.SelectionArray count]);
    
    // 선택 개수 표시 
    
    [self UpdateTotalCount];    
//    self.navigationItem.prompt 
//    = [NSString stringWithFormat:@"Add songs to play - %d items", [self.SelectionArray count]];
    [self.tableView reloadData];
    
    
    [self.view setNeedsLayout];
    [self.view setNeedsDisplay];
    
}

- (void)NoneButton{
        
    // 선택 인덱스 제거
    [self.inDirSelections removeAllObjects];
    
    // 새로 선택 인텍스 업데이트 
    [self.SelectionIndexDic setObject:self.inDirSelections forKey:fsItem.path];   
    
    
    
    // 선택된 아니템들     
    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.SelectionArray];

    for (Id3db *id3Item in tempArray) {
    
        NSString *itemPath = [[[id3Item.path stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByDeletingLastPathComponent] stringByReplacingOccurrencesOfString:@"file:/localhost" withString:@""];
        
        // 현재 경로만 비교해서 부하를 줄임
        if([fsItem.path isEqualToString:itemPath]){
            [self.SelectionArray removeObject:id3Item];
        }
    }
    
    [self.tableView reloadData];
    
    
    
    NSLog(@"Selection Dic keys = %@", [self.SelectionIndexDic allKeys]);
    NSLog(@"Selection Array = %@", self.SelectionArray);
    
    for (Id3db *item in self.SelectionArray) {
        NSLog(@" selection : %@", item.path);
    }
    
    
    // 선택 개수 표시 
    [self UpdateTotalCount];
//    self.navigationItem.prompt 
//    = [NSString stringWithFormat:@"Add songs to play - %d items", [self.SelectionArray count]];
    
    
}

- (void)AllButton{
    
    // 선택 인덱스 제거
    [self.inDirSelections removeAllObjects];

    // 현재 디렉토리의 mp3 파일 모두 추가
    for(int i = 0;i < [fsItem.children count];i++){
        
        FSItem *item = [fsItem.children objectAtIndex:i];   
        if([[[item.prettyFilename pathExtension] lowercaseString] isEqualToString:@"mp3"] == TRUE
           && item.isDirectory == FALSE)
        {
            [self.inDirSelections addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        }
    }
    
    NSLog(@"Add All mp3 Files to inDir array");
    
//    // 실제 선택된 아니템 모두 비교 해서 같은 것이 있으면 삭제   
//    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.SelectionArray];
//    
//    for (Id3db *id3Item in tempArray) {
//        
//        NSString *itemPath = [[[id3Item.path stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByDeletingLastPathComponent] stringByReplacingOccurrencesOfString:@"file:/localhost" withString:@""];
//        
//        // 현재 경로만 비교해서 부하를 줄임
//        if([fsItem.path isEqualToString:itemPath]){
//            [self.SelectionArray removeObject:id3Item];
//        }
//    }
//    
//    NSLog(@"Check match mp3 files");

    
    // -------------------------------------------
    
    // 현 디렉토리 모든 아이템
//    for (FSItem *item in fsItem.children) {
//        
//        // 디렉토리가 아니면 모두 추가 
//        if([[[item.prettyFilename pathExtension] lowercaseString] isEqualToString:@"mp3"] == TRUE && item.isDirectory == FALSE){
//            
//            // 아이템 추가 
//            Id3db *newItem = [[[Id3db alloc] initWithURL:[NSURL fileURLWithPath:item.path]] autorelease];
//            [self.SelectionArray addObject:newItem];
//            
//            // 아이템 인덱스 구하기
//            NSIndexPath *index = [NSIndexPath indexPathForRow:[fsItem.children indexOfObject:item] inSection:0];
//                        
//            // 인덱스 패쓰 오브젝트 넣기 
//            [self.inDirSelections addObject:index];
//            
//
//            
//        }
//    }
    
    // -----------------------------------------
    
    [self.SelectionIndexDic setObject:self.inDirSelections forKey:fsItem.path];
    
        
    [self.tableView reloadData];
    
    // 선택 개수 표시 
    [self UpdateTotalCount];
//    self.navigationItem.prompt 
//    = [NSString stringWithFormat:@"Add songs to play - %d items", [self.SelectionArray count]];


}

- (void)ClickDoneButton{    
    
    // touch lock
    
    self.navigationController.view.userInteractionEnabled = false;
    self.view.userInteractionEnabled = false;

    
    loading = [LoadingView loadingViewInView:[self.view.window.subviews objectAtIndex:0] 
                                   withTitle:@"Reading ..."];

	
	[loading performSelector:@selector(removeView)
                      withObject:nil
                      afterDelay:20.0];
    
    
    [NSThread detachNewThreadSelector:@selector(ThreadProcess) toTarget:self withObject:nil]; 

    
}

- (void)ThreadProcess{
    NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];
     
    //이곳에 처리할 코드를 넣는다.
//    for (Id3db *id3Item in self.SelectionArray) {
//        [id3Item id3ForFileAtPath];
//    }
    
    
    [self ReadingFileInfo];
    
//    [self SavingFileInfo];
    
    
    [loading removeView];
    [self dismissModalViewControllerAnimated:YES];
    [autoreleasepool release];
    
    
    NSLog(@"Thread Done");
    [NSThread exit];
    
}

- (NSString *)dataFilePath {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(
														 NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:@"/tmp/data.sqlite3"];
}


- (void)ReadingFileInfo{
    
    
//    FSItem *root = [FSItem fsItemWithDir:fsItem.parent fileName:@"/"];
    
    
//    for (FSItem *item in root.children) {
  
    // 디렉토리 키 어레이 얻기
    for (NSString * path in [self.SelectionIndexDic allKeys]) {
        
        // 디렉토리 파일 시스템 오브젝트 얻기
        FSItem  *itemDir    = [FSItem fsItemWithDir:path fileName:@"/"];
        NSArray *IndexArray = [self.SelectionIndexDic objectForKey:path];
        
        // 디레토리 파일 시스템과 인덱스 비교
        for (NSIndexPath *indexPath in IndexArray) {

            int idx = indexPath.row;
            FSItem *itemFile = [itemDir.children objectAtIndex:idx];
            
            Id3db *id3item = [[[Id3db alloc] initWithURL:[NSURL fileURLWithPath:itemFile.path]] autorelease];
//            [id3item id3ForFileAtPath];
            [self.SelectionArray addObject:id3item];
            
//            NSLog(@"path : %@", itemFile.filename);
        }
        
        
    }
        
    
//    return;
    
    
    
    
    
    
    //-------------------------------------------------------------------------
    
    NSLog(@"ReadingFileInfo");
    
    // Set File Manager
    NSArray *docs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [docs objectAtIndex:0];
    NSString *ndocPath = [NSString stringWithFormat:@"file://localhost%@/", docPath];
    
    //--------------------------------------------------------------------
    // 초기 애플리케이션 오픈시 데이터 베이스 파일 읽어 들이기 
    // sql 열기
    sqlite3 *database;
    if (sqlite3_open([[self dataFilePath] UTF8String], &database)
		!= SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
    }
    
    
    for (Id3db *item in self.SelectionArray) {
        
        // 경로표현의 앞 프리픽스 삭제
        NSString *newPath = [[item.path stringByReplacingOccurrencesOfString:ndocPath withString:@""] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
          
        // make sql string
        NSString *query 
        = [NSString stringWithFormat:@"SELECT FILEPATH, PATH, FILENAME, TITLE, ARTIST, ALBUM, LYRICS, DURATION FROM ID3DATA WHERE FILEPATH=\"%@\""
           , newPath];
        
        // Run SQL Query
        sqlite3_stmt *statement;
        if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
            
            while (sqlite3_step(statement) == SQLITE_ROW) {
                
//              char *filepath  = (char *)sqlite3_column_text(statement, 0);
//              char *path      = (char *)sqlite3_column_text(statement, 1);
//              char *filename  = (char *)sqlite3_column_text(statement, 2);
                char *title     = (char *)sqlite3_column_text(statement, 3);
                char *artist    = (char *)sqlite3_column_text(statement, 4);
                char *album     = (char *)sqlite3_column_text(statement, 5);
                char *lyrics    = (char *)sqlite3_column_text(statement, 6);
                char *duration  = (char *)sqlite3_column_text(statement, 7);

                if(title  == NULL) title  = "Unknown Title";
                if(lyrics == NULL) lyrics = "";
                if(artist == NULL) artist = "Unknown Artist";
                if(album  == NULL) album  = "Unknown Album";

                
                item.title  = [NSString stringWithCString:title encoding:NSUTF8StringEncoding];
                item.artist = [NSString stringWithCString:artist encoding:NSUTF8StringEncoding];
                item.album  = [NSString stringWithCString:album encoding:NSUTF8StringEncoding];
                item.lyrics = [NSString stringWithCString:lyrics encoding:NSUTF8StringEncoding];
                item.duration = [[NSString stringWithCString:duration encoding:NSUTF8StringEncoding] floatValue];
                
//                NSLog(@"%s", title);
//                
//                NSLog(@"%s", artist);
//                
//                NSLog(@"%s", album);
//                
//                
                
//                if(item.title  == NULL) item.title  = @"Unknown Title";
//                if(item.artist == NULL) item.artist = @"Unknown Artist";
//                if(item.album  == NULL) item.album  = @"Unknown Album";

                
//                NSLog(@"Title : %@", [NSString stringWithCString:title encoding:NSUTF8StringEncoding]);
//                NSLog(@"타이틀Title : %@", item.title);
//                
//                NSLog(@"-----------\n");
//                for(int i=0;i < strlen(title);i++){
//                    if (i % 16 == 0) printf("\n   %05d\t", i);
//                    printf("%02X ", *(unsigned char *)(title + i));
//                    
//                };
//                printf("\n");
//                
//                if((*title & 0xF0) == 0xC0){
//                    
//                    NSString *newStr = [NSString stringWithCString:title encoding:-2147481280];
//                    
//                    NSLog(@"represent euckr: %@ %@", newStr, [NSString stringWithString:<#(NSString *)#>]);
//                    NSLog(@"represent iso2022: %@", [NSString stringWithCString:title encoding:-2147481536]);
//                    NSLog(@"represent : %@", [NSString stringWithCString:title encoding:-2147482590]);
//                    NSLog(@"represent : %@", [NSString stringWithCString:title encoding:-2147482590]);
//                }
                
                
            }
            sqlite3_finalize(statement);
        }
    }//end for
    sqlite3_close(database);
    
}

- (void)SavingFileInfo{
    
    NSLog(@"SaveingFileInfo");
    
    // Set File Manager
    NSArray *docs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [docs objectAtIndex:0];
    NSString *ndocPath = [NSString stringWithFormat:@"file://localhost%@/", docPath];
    
    
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
    
    
    for (Id3db *id3 in self.SelectionArray) {

        // 경로표현의 앞 프리픽스 삭제
        NSString *file
        = [[id3.path stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] 
           stringByReplacingOccurrencesOfString:ndocPath withString:@""]; 
        
        NSString *query = [NSString stringWithFormat:@"INSERT OR REPLACE INTO \"%@\" (FILEPATH, PATH, FILENAME, TITLE, ARTIST, ALBUM, LYRICS, DURATION) VALUES (?, ?, ?, ?, ?, ?, ?, ?);", self.PlaylistName];
        
        sqlite3_stmt *stmt;
        if (sqlite3_prepare_v2(database, [query UTF8String], -1, &stmt, nil) == SQLITE_OK) {
            
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
            NSLog(@"Save Path : %@", file);

        }
        
        if (sqlite3_step(stmt) != SQLITE_DONE){
            NSLog(@"Save Error");
            //            NSAssert1(0, @"Error updating table: %s", errorMsg);
        }else{
            NSLog(@"Save OK");
        }
        sqlite3_finalize(stmt);
        
    }
    sqlite3_close(database);
}



#pragma mark - initialization

- (void)initBottomToolbar{
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 436, 320, 44)];
//    UIToolbar *toolbar = [[UIToolbar alloc] init];
    toolbar.barStyle = UIBarStyleDefault;
    
    
    UIBarButtonItem *FlexSpace
    = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil] autorelease];
    
    UIBarButtonItem *B1
    = [[[UIBarButtonItem alloc] initWithTitle:@"Reset" style:UIBarButtonItemStyleBordered target:self action:@selector(ResetButton)] autorelease];
    
    UIBarButtonItem *B2 
    = [[[UIBarButtonItem alloc] initWithTitle:@"  All  " style:UIBarButtonItemStyleBordered target:self action:@selector(AllButton)] autorelease];
    
    UIBarButtonItem *B3
    = [[[UIBarButtonItem alloc] initWithTitle:@"None" style:UIBarButtonItemStyleBordered target:self action:@selector(NoneButton)] autorelease];
    
    
    B1.style = UIBarButtonItemStyleBordered;
    B2.style = UIBarButtonItemStyleBordered;
    B3.style = UIBarButtonItemStyleBordered;
    
	[toolbar setItems:[NSArray arrayWithObjects:B1, FlexSpace, B2, B3, nil]];
    [self.navigationController.view addSubview:toolbar];
    
    
}

- (void)initSelectionIndexDic{

    // 선택 어레이 초기화
    self.SelectionIndexDic = [[NSMutableDictionary alloc] init];
    
}

- (void)sortDirectoryFiles{
    
    
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
    
    
}


#pragma mark - View lifecycle

- (id)initWithName:(NSString *)name{
    self.PlaylistName = [[NSString alloc] initWithString:name];
    return self;
}

- (void)viewDidLoad
{
    NSLog(@"filechooser init");
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
 
    // Done 버튼 만들기
    UIBarButtonItem *DoneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(ClickDoneButton)];
    
    self.navigationItem.rightBarButtonItem = DoneButton;
    
    
    // 스크롤바 올리기 
    [self.tableView setContentInset:UIEdgeInsetsMake(0, 0, 44, 0)];
    
    [self sortDirectoryFiles];
    
    
}

- (void)viewDidUnload
{
    NSLog(@"FileChooserTable Unload");
    [self setFsItem:nil];
    [self setSelectionArray:nil];
    [self setInDirSelections:nil];
    [self setSelectionIndexDic:nil];
    [self setLoading:nil];
    [self setPlaylistName:Nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 초기화 
    
    // 뷰 되지 않을 때 툴바를 제거해야한다. 계속 누적됨 
    NSArray *ViewArray = self.navigationController.view.subviews;
    if ([ViewArray.lastObject isKindOfClass:[UIToolbar class]]) {
        [ViewArray.lastObject removeFromSuperview];
    }
    [self initBottomToolbar];
    
    // 테이블 업데이트
    [self.tableView reloadData];

    if([fsItem.filename isEqualToString:@""]) self.title = @"/";  
    else self.title = fsItem.filename;
    
    // 아무런 값이 없었을 경우 새로 초기화 
    if(self.SelectionArray == nil) {
        self.SelectionArray = [[NSMutableArray alloc] init];
        NSLog(@"selectionarray init");
    }

    

    // 디렉토리내 선택 어레이 초기화 
    self.inDirSelections = [[NSMutableArray alloc] init];   

    //----------------------------------------------------------------------------
    // dic 에 특정 값이 초기화 되지 않았을 경우 디렉토리 리스트를 미리 dic 에 키값으로 넣음 
    // SelectionIndexDic = (키 : 디렉토리 이름, 오브젝트 : 디렉토리내 선택 인덱스 )
    if(self.SelectionIndexDic == nil) {
        
        [self initSelectionIndexDic];        
        NSLog(@"all kesy = %@", [self.SelectionIndexDic allKeys]);

    }
    
    
    if([self.SelectionIndexDic objectForKey:fsItem.path] != nil){
        
        self.inDirSelections = [self.SelectionIndexDic objectForKey:fsItem.path];
        
        NSLog(@"inDirSelections cnt = %d, key = %@", [self.inDirSelections count], fsItem.path);
        
    }

    // 선택 개수 표시 
    [self UpdateTotalCount];
//    self.navigationItem.prompt 
//    = [NSString stringWithFormat:@"Add songs to play - %d items", [self.SelectionArray count]];
    
    /*
     
     key1 (dir) array (indexpath, indexpath, indexpath, ...)
     key2 array indexpath ...
     key3 ...
     
     */
    
    
    NSLog(@"SelectitonIndexDic = %@", [self.SelectionIndexDic allKeys]);
    
//    for (NSString *key in [self.SelectionIndexDic allKeys]) {
//        for (NSArray *arr in [self.SelectionIndexDic objectForKey:key]) {
//            
//            NSLog(@"%@", arr);
//        }
//    }

//    // 아이템 인덱스 구하기
//    NSIndexPath *index = [NSIndexPath indexPathForRow:[fsItem.children indexOfObject:item] inSection:0];


}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    
    NSLog(@"title = %@", self.PlaylistName);
    
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

- (void)dealloc{
    
    NSLog(@"FileChooserTable dealloc");
    
    [fsItem release];
    [SelectionArray release];
    [inDirSelections release];
    [SelectionIndexDic release];
    [PlaylistName release];
//    [loading release];

    [super dealloc];
    
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
    return [fsItem.children count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    int row = indexPath.row;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    
    FSItem *child = [fsItem.children objectAtIndex:row];
    
    
    if(child.isDirectory == TRUE){
        cell.textLabel.text = [NSString stringWithFormat:@"+ %@", child.filename];
        
    }else{
        cell.textLabel.text = [NSString stringWithFormat:@"- %@", child.filename];
    }
    

    cell.textLabel.textColor 
    = ([self.inDirSelections containsObject:indexPath]) 
    ? [UIColor grayColor] 
    : [UIColor blackColor];
    
    
//    NSLog(@"index = %@", [self.inDirSelections objectAtIndex:0] );
    
//    // 중복 검사 
//    for (Id3db *oldItem in self.SelectionArray) {
//        
//        // 현재 디렉토리가 아니면 넘김 
//        if([[oldItem.path stringByDeletingLastPathComponent] isEqualToString:fsItem.path] == FALSE){
//            continue;
//        }
//        
//        
//        if ([oldItem.path isEqualToString:child.path] == TRUE) {
//            cell.textLabel.textColor = [UIColor grayColor];
//            return cell;
//        }
//    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
 
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    FSItem *child = [fsItem.children objectAtIndex:indexPath.row];
        
    // 에디트 모드일 경우는 폴더이동 및 파일 재생 패스 
    if(child.isDirectory == TRUE) {
        
        // 폴더일 경우 
        FileChooserTable *fcTable = [[FileChooserTable alloc] initWithName:self.PlaylistName];
        fcTable.fsItem = child;
        fcTable.SelectionArray    = self.SelectionArray;
        fcTable.SelectionIndexDic = self.SelectionIndexDic;
        
        [self.navigationController pushViewController:fcTable animated:YES];
        
        [fcTable release];
        
        NSLog(@"fsitem path = %@", child.path);
        
    } else if ([[[child.prettyFilename pathExtension] lowercaseString] isEqualToString:@"mp3"] == TRUE){
            

        // 선택 인덱스 넣기 
        if([self.inDirSelections containsObject:indexPath] == FALSE){
            
            NSLog(@"Not In");
            
            [self.inDirSelections addObject:indexPath];
            cell.textLabel.textColor = [UIColor grayColor];

        }else{
            
            NSLog(@"In");
            
            [self.inDirSelections removeObject:indexPath];
            cell.textLabel.textColor = [UIColor blackColor];

        }
        // 새로 선택 인텍스 업데이트 
        [self.SelectionIndexDic setObject:self.inDirSelections forKey:fsItem.path];    
        NSLog(@"selections = %d", [self.inDirSelections count]);
        
        
        //-------------------------------------------------------------------
        // 실제 파일 url 수집
//        Id3db *newItem = [[Id3db alloc] initWithURL:[NSURL fileURLWithPath:child.path]];
//        
//        NSLog(@"child.path : %@ newItem : %@", child.path, newItem.path);
//        
//        // 중복 검사
//        if([self.SelectionArray count] > 0){
//        
//            BOOL isSame = FALSE;
//            for (Id3db *oldItem in self.SelectionArray) {
//                // 같은 것 있음
//                if ([oldItem.path isEqualToString:newItem.path] == TRUE) {
//                    [self.SelectionArray removeObject:oldItem];
//                    cell.textLabel.textColor = [UIColor blackColor];
//                    isSame = TRUE;
//                    break;
//                }                
//            }
//            // 같은 것 없음 
//            if(isSame == FALSE){
//                [self.SelectionArray addObject:newItem];
//                cell.textLabel.textColor = [UIColor grayColor];
//            }
//            
//        }
//        // 새로 추가 
//        else{
//            // 최초 추가 
//            [self.SelectionArray addObject:newItem];
//            cell.textLabel.textColor = [UIColor grayColor];
//            
//        }
                          
        
        // 선택 개수 표시 
        [self UpdateTotalCount];
//        self.navigationItem.prompt 
//        = [NSString stringWithFormat:@"Add songs to play - %d items", [self.SelectionArray count]];
        
        
//        [newItem release];
            
        
    }// 디렉토리/파일 비교 끝    
    
    // 선택 표시 제거 

    // 셀 업데이트 
    [cell.textLabel setNeedsLayout];
    [cell.textLabel setNeedsDisplay];
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
   
}

- (void)UpdateTotalCount{
    
    int n = 0;
    
    NSArray *keys = [self.SelectionIndexDic allKeys];
    
    for (NSString *item in keys) {
        n += [[self.SelectionIndexDic objectForKey:item] count];
    }
    
    self.navigationItem.prompt 
    = [NSString stringWithFormat:@"Add songs to play - %d items", n];

    
    
    
    
}


@end











