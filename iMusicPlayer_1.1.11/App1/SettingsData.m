//
//  SettingsData.m
//  iMusicPlayer
//
//  Created by Han Eunsung on 11. 12. 31..
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SettingsData.h"



@implementation SettingsData

@synthesize isUpdatedForFileTable;
@synthesize OnAlbumArt;
@synthesize OnLockScreenInfo;
@synthesize FileTableFontSize;
@synthesize OnInterruptResume;
@synthesize LyricsAlign;
@synthesize LeftSeekTime1, LeftSeekTime2, RightSeekTime1, RightSeekTime2;

static SettingsData *sharedSettingsData;

+ (SettingsData *) sharedSettingsData{
    
    if(sharedSettingsData == nil){
        sharedSettingsData = [[SettingsData alloc] init];
    }
    
    return sharedSettingsData;
}

- (id)init{

    self.isUpdatedForFileTable = FALSE;
    NSArray *docs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [docs objectAtIndex:0];    
    NSString *cfgFilePath = [docPath stringByAppendingPathComponent:@"/tmp/cfg.plist"];

    
    NSDictionary *cfgDic = [[NSDictionary alloc] initWithContentsOfFile:cfgFilePath];
    
    for (NSObject *item in cfgDic) {
        NSLog(@"%@", item);
    }
    
    // Get Enable Album Art 
    NSNumber *boolAlbum = (NSNumber *)[cfgDic objectForKey:@"OnAlbumArt"];
    
    // Get Enable Album Art 
    NSNumber *boolLockScreenInfo = (NSNumber *)[cfgDic objectForKey:@"OnLockScreenInfo"];
    
    // Get Font Size
    NSNumber *intFileTableFontSize = (NSNumber *)[cfgDic objectForKey:@"FileTableFontSize"];
    
    // Get Interrupt Resume
    NSNumber *boolInterruptResume = (NSNumber *)[cfgDic objectForKey:@"InterruptResume"];
    
    // lyrics align X
    NSNumber *intLyricsAlign = (NSNumber *)[cfgDic objectForKey:@"LyricsAlign"];
    
    
    // seek time
    NSNumber *intLeftSeekTime1 = [NSNumber numberWithInt:10];
    NSNumber *intLeftSeekTime2 = [NSNumber numberWithInt:5];
    NSNumber *intRightSeekTime1 = [NSNumber numberWithInt:5];
    NSNumber *intRightSeekTime2 = [NSNumber numberWithInt:10];
    
    if([cfgDic objectForKey:@"LeftSeekTime1"] != nil) 
        intLeftSeekTime1 = (NSNumber *)[cfgDic objectForKey:@"LeftSeekTime1"];

    if([cfgDic objectForKey:@"LeftSeekTime2"] != nil) 
        intLeftSeekTime2 = (NSNumber *)[cfgDic objectForKey:@"LeftSeekTime2"];

    if([cfgDic objectForKey:@"RightSeekTime1"] != nil) 
        intRightSeekTime1 = (NSNumber *)[cfgDic objectForKey:@"RightSeekTime1"];

    if([cfgDic objectForKey:@"RightSeekTime2"] != nil) 
        intRightSeekTime2 = (NSNumber *)[cfgDic objectForKey:@"RightSeekTime2"];

    
    // Check IOS Version for prevent crash
    NSString *verStr = [[UIDevice currentDevice] systemVersion];
    if([[verStr substringToIndex:1] isEqualToString:@"4"] == TRUE){
        self.OnLockScreenInfo = FALSE;
    }else {
        self.OnLockScreenInfo = [boolLockScreenInfo boolValue];
    }
    
    
    self.OnAlbumArt         = [boolAlbum boolValue];
    
    self.FileTableFontSize  = [intFileTableFontSize integerValue];
    self.OnInterruptResume  = [boolInterruptResume boolValue];
    self.LyricsAlign        = [intLyricsAlign integerValue];
    
    self.LeftSeekTime1      = [intLeftSeekTime1 integerValue];
    self.LeftSeekTime2      = [intLeftSeekTime2 integerValue];
    
    self.RightSeekTime1     = [intRightSeekTime1 integerValue];
    self.RightSeekTime2     = [intRightSeekTime2 integerValue];    
    
    
    // 파일이 없을 경우 기본값 
    NSFileManager *fm = [NSFileManager defaultManager];
    if([fm fileExistsAtPath:cfgFilePath] == FALSE){
     
        self.OnAlbumArt = TRUE;
        self.OnLockScreenInfo = TRUE;
        self.FileTableFontSize = 18;
        self.OnInterruptResume = TRUE;
        self.LyricsAlign = 0;
        
        self.LeftSeekTime1 = 10;
        self.LeftSeekTime2 = 5;
        
        self.RightSeekTime1 = 5;
        self.RightSeekTime2 = 10;
        
        
    }

    [cfgDic release];

    
    return self;
}


- (void) saveData{
    
    NSMutableDictionary *cfgData = [NSMutableDictionary dictionary];
    [cfgData setObject:[NSNumber numberWithBool:self.OnAlbumArt] forKey:@"OnAlbumArt"];
    [cfgData setObject:[NSNumber numberWithBool:self.OnLockScreenInfo] forKey:@"OnLockScreenInfo"];
    [cfgData setObject:[NSNumber numberWithInt:self.FileTableFontSize] forKey:@"FileTableFontSize"];
    [cfgData setObject:[NSNumber numberWithBool:self.OnInterruptResume] forKey:@"InterruptResume"];
    [cfgData setObject:[NSNumber numberWithInt:self.LyricsAlign] forKey:@"LyricsAlign"];
    
    [cfgData setObject:[NSNumber numberWithInt:self.LeftSeekTime1] forKey:@"LeftSeekTime1"];
    [cfgData setObject:[NSNumber numberWithInt:self.LeftSeekTime2] forKey:@"LeftSeekTime2"];
    [cfgData setObject:[NSNumber numberWithInt:self.RightSeekTime1] forKey:@"RightSeekTime1"];
    [cfgData setObject:[NSNumber numberWithInt:self.RightSeekTime2] forKey:@"RightSeekTime2"];
    
//    NSLog(@"Save data : %@", [NSNumber numberWithBool:self.OnAlbumArt]);
    
    
    NSArray *docs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docPath = [docs objectAtIndex:0];    
    NSString *cfgFilePath = [docPath stringByAppendingPathComponent:@"/tmp/cfg.plist"];
    
    [cfgData writeToFile:cfgFilePath atomically:YES];
    
//    NSLog(@"Save : %d", success);
    
    
}

@end




