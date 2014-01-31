//
//  App1AppDelegate.m
//  App1
//
//  Created by Eunsung Han on 11. 9. 12..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "App1AppDelegate.h"
#import "FileTable.h"
#import "FSItem.h"
#import "Lib.h"
#import "MyMusicPlayer.h"
#import "WifiViewController.h"
#import "SettingsData.h"
#import <sqlite3.h>

@implementation App1AppDelegate


@synthesize window=_window;
@synthesize tab;
@synthesize filetable;

//@synthesize file2;
- (NSString *)dataFilePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(
														 NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:@"tmp/data.sqlite3"];
}

- (int)checkMP3:(NSString *)name{

    
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"mp3$|m4a"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:nil];
    
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:name
                                                        options:0
                                                          range:NSMakeRange(0, [name length])];
    
    
    return numberOfMatches;
    
}

- (void)insertField{
    
    NSLog(@"insertField");

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
//    NSString *query = @"SELECT * FROM ID3DATA";
//    NSString *query = @"SELECT FILEPATH, FILENAME, TITLE, ARTIST, ALBUM, LYRICS, DURATION FROM ID3DATA";

    sqlite3_stmt *statement;
    NSMutableArray *pathArray = [NSMutableArray array];
    if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        
        NSLog(@"Select SQL process");
		while (sqlite3_step(statement) == SQLITE_ROW) {
			char *filepath  = (char *)sqlite3_column_text(statement, 0);
            [pathArray addObject:[NSString stringWithCString:filepath 
                                                    encoding:NSUTF8StringEncoding]];
//            NSLog(@"%@",[NSString stringWithCString:filepath encoding:NSUTF8StringEncoding] );
            
		}
		sqlite3_finalize(statement);
    }
        
    NSString *file;
    while (file = [dirEnum nextObject]) {
        
        NSURL *fileurl = [NSURL fileURLWithPath:file];
        
        if([self checkMP3:file] == 0) {
            NSLog(@"pass : %@", file);
            continue;   
        }
        
        if([pathArray containsObject:[fileurl path]] == TRUE){
            NSLog(@"pass : %@", file);         
            continue;
        }
        
        Id3db *id3 = [[Id3db alloc] initWithURL:fileurl];
        [id3 id3ForFileAtPath];
        
        char *update = "INSERT OR REPLACE INTO ID3DATA (FILEPATH, FILENAME, TITLE, ARTIST, ALBUM, LYRICS, DURATION) VALUES (?, ?, ?, ?, ?, ?, ?);";
        
        sqlite3_stmt *stmt;
        if (sqlite3_prepare_v2(database, update, -1, &stmt, nil) == SQLITE_OK) {
                    
            sqlite3_bind_text(stmt, 1, [[fileurl path] UTF8String] , -1, NULL);
            sqlite3_bind_text(stmt, 2, [[fileurl lastPathComponent] UTF8String], -1, NULL);
            sqlite3_bind_text(stmt, 3, [id3.title UTF8String], -1, NULL);          
            sqlite3_bind_text(stmt, 4, [id3.artist UTF8String], -1, NULL);          
            sqlite3_bind_text(stmt, 5, [id3.album UTF8String], -1, NULL);          
            sqlite3_bind_text(stmt, 6, [id3.lyrics UTF8String], -1, NULL);          
            sqlite3_bind_text(stmt, 7, [[NSString stringWithFormat:@"%f", id3.duration] UTF8String], -1, NULL);                      

        }
        
        if (sqlite3_step(stmt) != SQLITE_DONE){
            NSLog(@"Update Error");
//            NSAssert1(0, @"Error updating table: %s", errorMsg);
        }else{
            NSLog(@"Update Success");
        }
        sqlite3_finalize(stmt);
        
        
        [id3 release];
		
    }
    
    sqlite3_close(database);
    

        
    
}


- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"File Received"
                                                    message:[NSString stringWithFormat:@"/Inbox/%@",url.lastPathComponent]
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles: nil];
    [alert show]; 
    [alert release];


    [self.tab setSelectedIndex:0];
    

    UINavigationController *naviCon = [self.tab.viewControllers objectAtIndex:0];

    FileTable *ftable = [naviCon.viewControllers objectAtIndex:0];
    [ftable.tableView reloadData];
    [ftable UpdateFileInfo];

    return YES;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    
    
    
    
    
    // 도큐먼트 디렉토리 위치 구하기 
    NSArray *docs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [docs objectAtIndex:0];
    
    // File 리스트의 기본 도큐먼트 폴더 지정하기
    filetable.fsItem = [FSItem fsItemWithDir:docPath fileName:@""];
    
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *tmpPath = [docPath stringByAppendingPathComponent:@"tmp"];
    NSString *inboxPath = [docPath stringByAppendingPathComponent:@"Inbox"];
    
    // make tmp dir
    [fm createDirectoryAtPath:tmpPath withIntermediateDirectories:YES attributes:nil error:nil];
    
    // make inbox dir
    [fm createDirectoryAtPath:inboxPath withIntermediateDirectories:YES attributes:nil error:nil];
    
    
    NSLog(@"data path = %@", [self dataFilePath]);
    //--------------------------------------------------------------------
    // 초기 애플리케이션 오픈시 데이터 베이스 파일 읽어 들이기 
    // sql 열기
    sqlite3 *database;
    if (sqlite3_open([[self dataFilePath] UTF8String], &database) == SQLITE_OK) {
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
	
    
    
    //--------------------------------------------------------------------
    // 웹 업로드용 자바스크립트 새로 복사
    
    NSString *jqCss     = [[NSBundle mainBundle] pathForResource:@"jquery.fileupload-ui" ofType:@"css"];    
    NSString *jqUi      = [[NSBundle mainBundle] pathForResource:@"jquery.fileupload-ui" ofType:@"js"];
    NSString *jqJS      = [[NSBundle mainBundle] pathForResource:@"jquery.fileupload" ofType:@"js"];
    NSString *srvJS     = [[NSBundle mainBundle] pathForResource:@"server" ofType:@"js"];
    NSString *srvCss    = [[NSBundle mainBundle] pathForResource:@"server" ofType:@"css"];
    
    NSError *err;
    
    // copy    
    NSString *newPath;
    
    newPath = [NSString stringWithFormat:@"%@/%@", tmpPath, [jqCss lastPathComponent]];
    
    [fm removeItemAtPath:newPath error:nil];
    [fm copyItemAtPath:jqCss toPath:newPath error:&err]; //NSLog(@"%@ : %@",newPath, [err description]);
    
    newPath = [NSString stringWithFormat:@"%@/%@", tmpPath, [jqUi lastPathComponent]];
    [fm removeItemAtPath:newPath error:nil];
    [fm copyItemAtPath:jqUi toPath:newPath  error:&err]; //NSLog(@"%@ : %@",newPath, [err description ]);
    
    newPath = [NSString stringWithFormat:@"%@/%@", tmpPath, [jqJS lastPathComponent]];
    [fm removeItemAtPath:newPath error:nil];
    [fm copyItemAtPath:jqJS toPath:newPath error:&err]; 
    
    newPath = [NSString stringWithFormat:@"%@/%@", tmpPath, [srvJS lastPathComponent]];
    [fm removeItemAtPath:newPath error:nil];
    [fm copyItemAtPath:srvJS toPath:newPath error:&err];
    
    newPath = [NSString stringWithFormat:@"%@/%@", tmpPath, [srvCss lastPathComponent]];
    [fm removeItemAtPath:newPath error:nil];  
    [fm copyItemAtPath:srvCss toPath:newPath error:&err]; 

    
    
    
    
    [self.window addSubview:tab.view];
    [self.window makeKeyAndVisible];

    
    
    
        
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    
    NSLog(@"ResignActive");
    
    if(self.tab.selectedIndex == 2){
        
        
        
        
        UINavigationController *navi = [self.tab.viewControllers objectAtIndex:2];
        WifiViewController *tableCon = [navi.viewControllers objectAtIndex:0];
        //        [tableCon.tableView reloadData];
        
        if(tableCon.onWifi == TRUE){
            // off wifi
            [tableCon.httpsvr stop];
            [tableCon.httpsvr release];
            tableCon.onWifi = FALSE;
        }
        
        
        NSMutableArray *arr = [tableCon.wifiDic objectForKey:@"Wi-fi Configuration"];
        
        if([arr containsObject:@"Server IP"] == TRUE){
            [arr removeObject:@"Server IP"];
            
        };

        
        [tableCon.tableView reloadData];
        
        
    }

    
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    NSLog(@"Into the Background");
    
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
    
    NSLog(@"Foreground");
    
    
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    
    NSLog(@"BecomeActive");
    
        
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (void)dealloc
{
    //[tabbarController release];
    [_window release];
    [super dealloc];
}


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

- (BOOL)checkFileChanges{
    
    NSArray *docs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [docs objectAtIndex:0];
    
    NSFileManager *fm = [NSFileManager defaultManager]; 
    [fm changeCurrentDirectoryPath:docPath];
    
    NSDirectoryEnumerator *dirEnum = [fm enumeratorAtPath:docPath];
    
    
    [dirEnum nextObject];
    
    NSString *file;
    double TotalSize = 0;
    NSString *path;
    NSDictionary *att;
    while (file = [dirEnum nextObject]) {
        
        if([self checkMP3:file] == 0) continue;
        
        path = [docPath stringByAppendingPathComponent:file];
        att = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
        TotalSize += [[att objectForKey:NSFileSize] doubleValue];
        //        NSLog(@"%f", TotalSize);
    }    
    NSLog(@"Current Total = %f", TotalSize);    
    
    // cfg file check
    NSString *cfgPath = [docPath stringByAppendingPathComponent:@"cfg.plist"];
    
    // 파일 체크
    NSMutableDictionary *cfgDic;
    if([fm fileExistsAtPath:cfgPath] == TRUE){
        cfgDic = [NSMutableDictionary dictionaryWithContentsOfFile:cfgPath];
    }else{
        cfgDic = [NSMutableDictionary dictionary];
    }
    
    // 저장된 전체 사이즈 읽어오기 
    double old_TotalSize = [[cfgDic objectForKey:@"TotalSize"] floatValue];
    
    NSLog(@"Saved Total Size = %f", old_TotalSize);
    
    // 파일에 변화가 생겼을 경우
    if(old_TotalSize != TotalSize){
        NSLog(@"File Changed");
        [cfgDic setObject:[NSString stringWithFormat:@"%f", TotalSize] 
                   forKey:[NSString stringWithString:@"TotalSize"]];
        [cfgDic writeToFile:cfgPath atomically:YES];
        return FALSE;
    }else{
        NSLog(@"File Not Changed");
        return TRUE;
    }
    
    
    
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
    //    NSString *query = @"SELECT * FROM ID3DATA";
    //    NSString *query = @"SELECT FILEPATH, FILENAME, TITLE, ARTIST, ALBUM, LYRICS, DURATION FROM ID3DATA";
    
    sqlite3_stmt *statement;
    NSMutableArray *pathArray = [NSMutableArray array];
    if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        
        NSLog(@"Select SQL process");
		while (sqlite3_step(statement) == SQLITE_ROW) {
			char *filepath  = (char *)sqlite3_column_text(statement, 0);
            [pathArray addObject:[NSString stringWithCString:filepath 
                                                    encoding:NSUTF8StringEncoding]];
            //            NSLog(@"%@",[NSString stringWithCString:filepath encoding:NSUTF8StringEncoding] );
            
		}
		sqlite3_finalize(statement);
    }
    
    NSString *file;
    while (file = [dirEnum nextObject]) {
        
        NSURL *fileurl = [NSURL fileURLWithPath:file];
        
        if([[[file pathExtension] uppercaseString] isEqualToString:@"MP3"] == FALSE) continue;   
        
        if([pathArray containsObject:file] == TRUE){
            //            NSLog(@"pass : %@", file);         
            continue;
        }
        
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
            
            
            NSLog(@"duration : %f", id3.duration);
        }
        
        if (sqlite3_step(stmt) != SQLITE_DONE){
            NSLog(@"Update Error");
            //            NSAssert1(0, @"Error updating table: %s", errorMsg);
        }else{
            NSLog(@"Update Success");
        }
        sqlite3_finalize(stmt);
		
        // release id3
        [id3 release];
    }
    
    sqlite3_close(database);
    
    
    
}



@end
