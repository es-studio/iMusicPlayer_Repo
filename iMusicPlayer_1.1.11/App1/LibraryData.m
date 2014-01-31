//
//  LibraryData.m
//  iMusicPlayer
//
//  Created by Han Eunsung on 12. 2. 17..
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LibraryData.h"
#import "Id3db.h"

#import <sqlite3.h>

@implementation LibraryData

@synthesize PlaylistDB;

static LibraryData *sharedLibrary;

+ (LibraryData *)sharedLibrary{
    
    if(sharedLibrary == nil){
        
        NSLog(@"LibraryData init");
        sharedLibrary = [[LibraryData alloc] init];
    }else{
        
        NSLog(@"Already LibraryData inited");
    }
    
    return sharedLibrary;
}


- (id)init{
    
    self.PlaylistDB = [[NSMutableDictionary alloc] init];
    
    // plst 플레이 리스트 로딩 실패 시, sql 로 로딩
    if([self LoadPlaylist_plst] == FALSE){
        
        // sql 플레이리스트 로딩
        [self LoadPlaylist];
//        [self DeleteSQLPlayList];
    }
    
    return self;    
}

-(id)copyWithZone:(NSZone *)zone {
	return self;
}
-(id)retain {
	return self;
}
-(unsigned)retainCount {
	return UINT_MAX;
}


- (void)DeleteSQLPlayList{
    
    NSArray *docs 
    = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath 
    = [[docs objectAtIndex:0] stringByAppendingPathComponent:@"tmp"];
    
    NSFileManager *fm = [[[NSFileManager alloc] init] autorelease];
    [fm changeCurrentDirectoryPath:docPath];
        
    NSError *err = nil;
    [fm removeItemAtPath:[docPath stringByAppendingPathComponent:@"playlists.sqlite3"] error:&err];
    NSLog(@"err : %@", [err description]);
    
    
    if (err == nil) {
        NSLog(@"Deleted SQL Playlist");
    }
    
    [fm changeCurrentDirectoryPath:[docs objectAtIndex:0]];


}

- (void)LoadPlaylist{
    
    
//    if ([self LoadPlaylist_plst] == TRUE) {
//        
//        NSLog(@"Already plst exists");
//        return;
//    }

    
    //--------------------------------------------------------------------------
    
    
    NSMutableArray *tableArray = [NSMutableArray array];
    
    
    NSLog(@"SQL LoadingFileInfo");
    // Set File Manager
    NSArray *docs 
    = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [docs objectAtIndex:0];
    NSString *playlistFile = [docPath stringByAppendingPathComponent:@"/tmp/playlists.sqlite3"];
    
    //--------------------------------------------------------------------
    // sql 열기
    sqlite3 *database;
    if (sqlite3_open([playlistFile UTF8String], &database) != SQLITE_OK) {
        sqlite3_close(database);
        NSLog(@"Error open playlist.sqlite3");
    }
    
    // make sql string
    NSString *query 
    = [NSString stringWithString:@"SELECT name FROM sqlite_master WHERE type='table';"];
    
    // Run SQL Query
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        
        while (sqlite3_step(statement) == SQLITE_ROW) {
            
            char *tables = (char *)sqlite3_column_text(statement, 0);
            [tableArray addObject:[NSString stringWithCString:tables encoding:NSUTF8StringEncoding]];
            
            // 테이블 이름 키 가져오고, 각 리스트 요소 초기화, db 에 넣기
            [self.PlaylistDB setObject:[[NSMutableArray alloc] init] forKey:[NSString stringWithCString:tables encoding:NSUTF8StringEncoding]];
            
        }
        sqlite3_finalize(statement);
    }
    
    
    
    //--------------------------------------------------------------------------
    // 테이블의 플레이 리스트 가져오기 
    
    NSLog(@"PlayLists name = %@", tableArray);
    
    for (NSString *PlaylistName in tableArray) {
        
        NSMutableArray *listArray = [self.PlaylistDB objectForKey:PlaylistName];
        NSString *query 
        = [NSString stringWithFormat:@"SELECT FILEPATH, PATH, FILENAME, TITLE, ARTIST, ALBUM, LYRICS, DURATION FROM \"%@\"", PlaylistName];
        
        // Run SQL Query
        sqlite3_stmt *statement;
        if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
            
            while (sqlite3_step(statement) == SQLITE_ROW) {
                
                char *filepath  = (char *)sqlite3_column_text(statement, 0);
//                char *path      = (char *)sqlite3_column_text(statement, 1);
//                char *filename  = (char *)sqlite3_column_text(statement, 2);
                char *title     = (char *)sqlite3_column_text(statement, 3);
                char *artist    = (char *)sqlite3_column_text(statement, 4);
                char *album     = (char *)sqlite3_column_text(statement, 5);
                char *lyrics    = (char *)sqlite3_column_text(statement, 6);
                char *duration  = (char *)sqlite3_column_text(statement, 7);
                
                NSString *fpath 
                = [[NSString stringWithCString:filepath encoding:NSUTF8StringEncoding] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                
                NSURL *fileurl;
                if([fpath rangeOfString:@"ipod-library"].location == NSNotFound){
                    fileurl = [NSURL fileURLWithPath:[docPath stringByAppendingPathComponent:fpath]];                    
                }else{
                    fileurl = [NSURL URLWithString:fpath];
                }                
                
                // lyrics null pass
                if(lyrics == NULL) lyrics = "";
                if(artist == NULL) artist = "Unknown Artist";
                if(album == NULL)  album  = "Unknown Album";
                
                Id3db *item = [[Id3db alloc] initWithURL:fileurl];
                item.title  = [NSString stringWithCString:title encoding:NSUTF8StringEncoding];
                item.artist = [NSString stringWithCString:artist encoding:NSUTF8StringEncoding];
                item.album  = [NSString stringWithCString:album encoding:NSUTF8StringEncoding];
                item.lyrics = [NSString stringWithCString:lyrics encoding:NSUTF8StringEncoding];
                item.duration  = [[NSString stringWithCString:duration encoding:NSUTF8StringEncoding] floatValue];
                
                [listArray addObject:item];
                [item release];
                
            }
            sqlite3_finalize(statement);
        }
        
    }
    
    sqlite3_close(database);
        
    
}

- (void)makeSQLPlaylists:(NSString *)name{
    
    NSLog(@"make SQL Playlists");
    
    // Set File Manager
    NSArray *docs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [docs objectAtIndex:0];
    
    //--------------------------------------------------------------------
    // 초기 애플리케이션 오픈시 데이터 베이스 파일 읽어 들이기 
    // sql 열기
    sqlite3 *database;
    if (sqlite3_open([[docPath stringByAppendingPathComponent:@"/tmp/playlists.sqlite3"] UTF8String], &database)
		!= SQLITE_OK) {
        sqlite3_close(database);
        
    }
	
    // 테이블 생성 없을 경우 새로 만듬
    char *errorMsg;
    NSString *createSQL 
    = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS \"%@\" (FILEPATH TEXT PRIMARY KEY, PATH TEXT, FILENAME TEXT, TITLE TEXT, ARTIST TEXT, ALBUM TEXT, LYRICS TEXT, DURATION TEXT);", name];
    
    // SQL 실행
    if (sqlite3_exec (database, [createSQL UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert1(0, @"Error creating table: %s", errorMsg);
    }else{
        NSLog(@"%@ Table created", name);
    }
    
    
    
}

- (void)removePlayListArray:(NSString *)key{
    
    [self.PlaylistDB setObject:[[NSArray alloc] init] forKey:key];
    
    // Set File Manager
    NSArray *docs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [docs objectAtIndex:0];    
    NSString *playlistFile = [docPath stringByAppendingPathComponent:@"/tmp/playlists.sqlite3"];
    
    //--------------------------------------------------------------------
    // sql 열기
    sqlite3 *database;
    if (sqlite3_open([playlistFile UTF8String], &database)
		!= SQLITE_OK) {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
    }
    
    
    NSString *query = [NSString stringWithFormat:@"DELETE FROM \"%@\" WHERE DURATION >= 0", key];
    
    
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

- (void)removePlayListDictionary:(NSString *)key{
    
    
    // 원본 db 에서 삭제         
    [self.PlaylistDB removeObjectForKey:key];
    
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
    
    
    NSString *query = [NSString stringWithFormat:@"DROP TABLE \"%@\"", key];
    
    
    NSLog(@"Query = %@", query);
    
    sqlite3_stmt *stmt;
    if (sqlite3_prepare_v2(database, [query UTF8String], -1, &stmt, nil) != SQLITE_OK) {
//        NSAssert1(0, @"Error while creating delete statement. '%s'", sqlite3_errmsg(database));
    }
    
    if (sqlite3_step(stmt) != SQLITE_DONE){
        NSLog(@"Delete Table Error");
    }else{
        NSLog(@"Delete Table Success");
    }
    sqlite3_finalize(stmt);
    sqlite3_close(database);
    
}

- (void)SavingFileInfo:(NSString *)key{
    
    
    //--------------------------------------------------------------------------
    NSLog(@"SavingFileInfo");
    
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
    
    
    NSArray *playlistArray = [self.PlaylistDB objectForKey:key];
    
    for (Id3db *id3 in playlistArray) {
        
        // 경로표현의 앞 프리픽스 삭제
        //NSString *file = [id3.path stringByReplacingOccurrencesOfString:ndocPath withString:@""];
        NSString *file 
        = [[id3.path stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] 
           stringByReplacingOccurrencesOfString:ndocPath withString:@""]; 
        
        
        
        NSString *query = [NSString stringWithFormat:@"INSERT OR REPLACE INTO \"%@\" (FILEPATH, PATH, FILENAME, TITLE, ARTIST, ALBUM, LYRICS, DURATION) VALUES (?, ?, ?, ?, ?, ?, ?, ?);", key];
        
        //        NSLog(@"title = %@ %@", id3.title, [[id3.asset URL] absoluteString]);
        
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
            
            //NSLog(@"Save Path : %@", file);
            
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
    
    
    // plst save
    [self SavingFileInfo_plst];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    if(self == [super init]){
        
//        for (NSString *key in self.PlaylistDB.allKeys) {
//            [aDecoder decodeObjectForKey:key];
//        }
        
//        [aDecoder decodeObjectForKey:@""];
    }    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    
    /*
     
     Structure
     
     NSMutableDictionary -- Key : NSArray -- ID3DB, ID3DB, ID3DB ...
                         -- Key : NSArray -- ID3DB, ID3DB, ID3DB ...
                         -- Key : NSArray -- ID3DB, ID3DB, ID3DB ...
                        ...
                        ...
     */
    
//    NSArray *AllKeys = self.PlaylistDB.allKeys;
//    
//    for (NSString *Key in AllKeys) {
//        NSArray *obj = [self.PlaylistDB objectForKey:Key];
//        [aCoder encodeObject:obj forKey:Key];
//    }
    
}

- (BOOL)LoadPlaylist_plst{
    NSArray *docs 
    = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [docs objectAtIndex:0];
    NSString *playlistFile = [docPath stringByAppendingPathComponent:@"/tmp/playlists.plst"];
    
    NSFileManager *fm = [[[NSFileManager alloc] init] autorelease];
    [fm changeCurrentDirectoryPath:@"tmp"];

    if ([fm fileExistsAtPath:@"playlists.plst"] == FALSE) {
        [fm changeCurrentDirectoryPath:docPath];
        return FALSE;
    }

    // 저장된 파일로부터 NSData를 가져온 뒤 decode하여 Book 객체를 만든다.
    NSData* decodedBook = [NSData dataWithContentsOfFile:playlistFile];
    NSMutableDictionary *db = [NSKeyedUnarchiver unarchiveObjectWithData:decodedBook];
    self.PlaylistDB = [[NSMutableDictionary alloc] initWithDictionary:db copyItems:YES];
    
    
    
    [fm changeCurrentDirectoryPath:docPath];
    
//    NSLog(@"plst Allkeys = %@", self.PlaylistDB.allKeys);
//    
//    
//    for (NSString *key in self.PlaylistDB.allKeys) {
//        NSArray *list = [self.PlaylistDB objectForKey:key];
//        
//        for (Id3db *id3 in list) {
//            NSLog(@"id3 : %@", id3.title);
//            NSLog(@"id3 : %@", id3.album);
//            NSLog(@"id3 : %@", id3.artist);
//            NSLog(@"id3 : %@", id3.path);
//        }
//        
//    }
//    

    return TRUE;
    
}

- (BOOL)SavingFileInfo_plst{
    
    NSArray *docs 
    = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [docs objectAtIndex:0];
    NSString *playlistFile = [docPath stringByAppendingPathComponent:@"/tmp/playlists.plst"];
    
    NSData* encodedBook = [NSKeyedArchiver archivedDataWithRootObject:self.PlaylistDB];
	[encodedBook writeToFile:playlistFile atomically:YES];

    
    NSFileManager *fm = [[[NSFileManager alloc] init] autorelease];
    [fm changeCurrentDirectoryPath:@"tmp"];
    
    
    if ([fm fileExistsAtPath:@"playlists.plst"] == FALSE) {
        
        [fm changeCurrentDirectoryPath:docPath];
        return FALSE;
    }
    [fm changeCurrentDirectoryPath:docPath];
    
    
    return TRUE;
    
}


@end
