//
//  Id3db.m
//  iMusicPlayer
//
//  Created by Han Eunsung on 11. 10. 27..
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Id3db.h"

@implementation Id3db

@synthesize path, title, artist, album, AlbumArt, lyrics;
@synthesize duration;
@synthesize asset;

- (id)initWithURL:(NSURL *)url{
    self.asset = [[AVURLAsset alloc] initWithURL:url options:nil];

    self.title = [[url.path lastPathComponent] stringByDeletingPathExtension];
    self.artist = @"Unknown Artist";
    self.album = @"Unknown Album";
    self.lyrics = @"";
    self.path = [[asset URL] absoluteString];
    
    
    // 플레이타임 가져오기
    duration = asset.duration.value / asset.duration.timescale;
    
//    NSLog(@"duration : %f", duration);
    
//    [self id3ForFileAtPath];
    return self;
}

- (NSString *)path{
    return [[asset URL] absoluteString];
}

- (AVURLAsset *)asset{
    return [[AVURLAsset alloc] initWithURL:[NSURL URLWithString:path] options:nil];
}


- (void)id3ForFileAtPath{
    
    // id3 데이터 배열 얻기
    NSArray *formatArray = asset.availableMetadataFormats;

    if([formatArray count] == 0) return;
    
//    NSLog(@"duration in id3 : %f", duration);

    // 가사가 있을 경우
    if([[asset lyrics] length] > 0) lyrics = [asset lyrics];
    
    // id3 배열 얻기
    NSArray *array = [asset metadataForFormat:[formatArray objectAtIndex:0]]; //for get id3 tags
    
    for(AVMetadataItem *metadata in array) { 
//        if ([metadata.commonKey isEqualToString:@"artwork"]){
//            // 앨범아트 추출 못하는 경우가 많아 다른 메소드로 대체 
//        }
        if([metadata.commonKey isEqualToString:@"title"]){
            if (metadata.stringValue == @"") continue; // 비어있는 문자는 패스 
//            self.title = metadata.stringValue;
            self.title = [self getKRString:metadata.dataValue];
        }
        else if([metadata.commonKey isEqualToString:@"artist"]){
            if (metadata.stringValue == @"") continue; // 비어있는 문자는 패스 
//            self.artist = metadata.stringValue;
            self.artist = [self getKRString:metadata.dataValue];
             
            
        }
        else if([metadata.commonKey isEqualToString:@"albumName"]){
            if (metadata.stringValue == @"") continue; // 비어있는 문자는 패스 
//            self.album = metadata.stringValue;
            self.album = [self getKRString:metadata.dataValue];
        }
    }
    
}


- (NSString *)getKRString:(NSData *)data{
    
    NSString *str;
        
        NSData *dTitle = data;
        const char *cTitle = [dTitle bytes];
        
        int offset = 8;
        
        // bplist 의 바이너리 데이터가 아스키 코드인지 유니코드인지 구분
        if((*(cTitle + offset)&0xF0) == 0x60){          // unicode
            
            // 문자의 길이 계산
            int len;
            if((*(cTitle + offset)& 0x0F) == 0x0F){ 
                len = *(cTitle + offset + 2) * 2;                    
                offset += 3;
            }else{
                len = (*(cTitle + offset) & 0x0F) * 2;
                offset += 1;
            }
            
            // 문자 내용 표시
//            for (int i = 0; i < len; i++) {
//                if (i % 16 == 0) printf("\n   %05d\t", i);
//                printf("%02X ", *(unsigned char *)(cTitle + offset + i));
//            }
//            printf("\n"); 
//            
//            NSLog(@"%02X", *(cTitle + offset + 1));
                
            
            // euc-kr 인지 utf-16 인지 구분
            unsigned char value = 0x00;
            for (int i = 0; i < len; i += 2) {                    
                value += *(cTitle + offset + i);
                if((value&0xFF) != 0x00) break;
            }
            
//            NSLog(@"value : %02X", value);
            
            // euc-kr 인 경우
            if(value == 0x00){
                
                // 2 바이트 euc-kr 이 므로 1바이트 타입으로 변환
                unsigned char * src = (unsigned char *)cTitle + offset;
                unsigned char * dst = malloc(len/2);
                
                for (int i = 0;i < len/2;i++){    
                    *(dst + i) = *(src + 2 * i + 1);
                }
                
//                int i;
//                for (i = 0; i < len / 2; i++) {
//                    if (i % 16 == 0) printf("\n   %05d\t", i);
//                    printf("%02X ", *(unsigned char *)(dst + i));
//                }
//                printf("\n"); 
                
                NSData *nData = [NSData dataWithBytes:(void *)(dst) length:len/2];                
                
                str = [[NSString alloc] initWithData:nData encoding:-2147481280];
                
                free(dst);
                
            }else {
                
                NSData *nData = [NSData dataWithBytes:(void *)(cTitle + offset) length:len];
                str = [[NSString alloc] initWithData:nData encoding:NSUTF16StringEncoding];
//                    NSLog(@"utf16 : %@", [[[NSString alloc] initWithData:nData encoding:NSUTF16StringEncoding] autorelease]);                    
            };
            
            
        }else if((*(cTitle + offset)&0xF0) == 0x50){ // ascii
            
            
            
            
            int len;                
            if((*(cTitle + offset)& 0x0F) == 0x0F){ 
                len = *(cTitle + offset + 2);                    
                offset += 3;
            }else{
                len = (*(cTitle + offset) & 0x0F);
                offset += 1;
            }
            
            
            
            // 문자 내용 표시
//            for (int i = 0; i < len; i++) {
//                if (i % 16 == 0) printf("\n   %05d\t", i);
//                printf("%02X ", *(unsigned char *)(cTitle + offset + i));
//            }
//            printf("\n"); 
//            
//            NSLog(@"%02X", *(cTitle + offset + 1));

            
            str = [NSString stringWithCString:(cTitle + offset) encoding:NSASCIIStringEncoding];
        
        } 

    
//    NSLog(@"str : %@", str);
    
    
    
    return str;
}

- (void)dealloc{
    
//    NSLog(@"ID3DB dealloc");
    
    duration = 0;
    [path release];
    [title release];
    [artist release];
    [album release];
    [AlbumArt release];
    [asset release];
    
    [super dealloc];
}

// implement for serialization
- (void)encodeWithCoder:(NSCoder *)aCoder{

    [aCoder encodeFloat:duration    forKey:@"Duration"];
    [aCoder encodeObject:path       forKey:@"Path"];
    [aCoder encodeObject:title      forKey:@"Title"];
    [aCoder encodeObject:artist     forKey:@"Artist"];
    [aCoder encodeObject:album      forKey:@"Album"];
    [aCoder encodeObject:lyrics     forKey:@"Lyrics"];
//    [aCoder encodeObject:asset       forKey:@"Asset"];
    
    
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    
    if(self == [super init]){
        self.duration = [aDecoder decodeFloatForKey:@"Duration"];
        self.path     = [aDecoder decodeObjectForKey:@"Path"];
        self.title    = [aDecoder decodeObjectForKey:@"Title"];
        self.artist   = [aDecoder decodeObjectForKey:@"Artist"];
        self.album    = [aDecoder decodeObjectForKey:@"Album"];
        self.lyrics   = [aDecoder decodeObjectForKey:@"Lyrics"];  
        self.asset    = [[AVURLAsset alloc] initWithURL:[NSURL URLWithString:path] options:nil];

    }
    
    return self;

    
}

@end
