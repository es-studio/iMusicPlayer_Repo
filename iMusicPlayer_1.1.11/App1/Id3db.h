//
//  Id3db.h
//  iMusicPlayer
//
//  Created by Han Eunsung on 11. 10. 27..
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h> 


@interface Id3db : NSObject <NSCoding>
{

    NSString    *path;
    NSString    *title;
    NSString    *artist;
    NSString    *album;
    UIImage     *AlbumArt;
    float        duration;

    
    AVURLAsset  *asset;
    NSString    *lyrics;
}

@property (nonatomic) float            duration;
@property (nonatomic, retain) NSString *path;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *artist;
@property (nonatomic, retain) NSString *album;
@property (nonatomic, retain) NSString *lyrics;


@property (nonatomic, retain) UIImage *AlbumArt;

@property (nonatomic, retain) AVURLAsset *asset;

- (id)initWithURL:(NSURL *)url;

- (void)id3ForFileAtPath;

- (NSString *)getKRString:(NSData *)data;

@end
