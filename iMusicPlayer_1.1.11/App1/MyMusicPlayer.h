//
//  Player.h
//  App1
//
//  Created by Han Eunsung on 11. 10. 1..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SettingsData.h"
#import "MoreCtrlView.h"
#import "AlbumArtView.h"
#import "LyricsView.h"
//#import "InformView.h"

#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <MediaPlayer/MPVolumeView.h>

// Play Button Position
#define PauseRect CGRectMake(140, 10, 45, 30); // pause
#define PlayRect  CGRectMake(148, 10, 32, 30); // play

@class PlaylistTable;
@class Id3db;
@class InformView;
@class OBSlider;

@interface MyMusicPlayer  : UIViewController <AVAudioSessionDelegate> {
//@interface MyMusicPlayer  : UIViewController {
    
    // 내부 전역변수 ? 자체호출 가능     
    float           currentTimeSec;
    float           durationTimeSec;
    
//    int             LoadingCount;
    int             index;
    int             OriginalIndex;
    int             RepeatState; // 0 : non, 1 : one play, 2 : one repeat, 3 : all repeat
    
    BOOL            firstResponder;
    BOOL            isRandom;
    BOOL            inBackground;
    BOOL            inAlbumView;
    BOOL            inLyrics;


//    NSString        *
    NSURL           *path;
    NSArray         *playlist;
    NSMutableArray  *RandomizeIndex;
    
    
//    AVAudioPlayer   *player;
    AVPlayer        *player;
    
    NSTimer         *Timer;
    
    OBSlider        *Timeline;
    UIView          *FlipView;
    UIView          *Bottomview;
    UIView          *TopController;
    UILabel         *PlayCount;
    UILabel         *CurrentTime;
    UILabel         *ElapsedTime;
    
    UILabel         *SongSinger;
    UILabel         *SongTitle;
    UILabel         *SongAlbum;
        
    UITextView      *Lyrics;
    
    UIImage         *PlayImage;
    UIImage         *PauseImage;
    UIImage         *AlbumArt;
    UIImage         *listButton;
//    UIImageView     *AlbumArtView;
    UIButton        *PlayButton;
    UIButton        *RepeatButton;
    UIButton        *RandomButton;
    PlaylistTable   *listTable;
        
    
//    UITableViewController *callerNavigationController;


    
}

// 프로퍼티는 self. 으로 찾아 사용가능

// 외부 호출 가능한 프로퍼티 변수

@property (nonatomic)                  int              index;
@property (nonatomic)                  int              OriginalIndex;
@property (nonatomic)                  BOOL             isRandom;
@property (nonatomic)                  BOOL             inAlbumView;
@property (nonatomic)                  BOOL             inLyrics;
@property (nonatomic)                  BOOL             interruptedWhilePlaying;

@property (nonatomic)                  BOOL             isToggle;

@property (nonatomic)                  int              onEventLock;

// for Player Object set
//@property (nonatomic, assign)          AVAudioPlayer    *player;
@property (nonatomic, assign)          AVPlayer         *player;


@property (nonatomic, retain)          NSArray          *playlist;
@property (nonatomic, retain)          NSMutableArray   *RandomizeIndex;
@property (nonatomic, retain)          NSURL            *path;
@property (nonatomic, retain)          UIImage          *PlayImage;
@property (nonatomic, retain)          UIImage          *PauseImage;


// 내부에서 UI 변경시 ibout 프로퍼티 선언

@property (nonatomic, retain)          UILabel          *SongSinger;
@property (nonatomic, retain)          UILabel          *SongTitle;
@property (nonatomic, retain)          UILabel          *SongAlbum;

// for 어학기능
@property (nonatomic, retain)          MoreCtrlView     *CtrlView;
@property (nonatomic, retain)          AlbumArtView     *albumView;
@property (nonatomic, retain)          InformView       *informView;
@property (nonatomic, retain)          LyricsView       *lyricsView;


@property (nonatomic, retain) IBOutlet OBSlider         *Timeline;

@property (nonatomic, retain) IBOutlet UILabel          *PlayCount;
@property (nonatomic, retain) IBOutlet UILabel          *CurrentTime;
@property (nonatomic, retain) IBOutlet UILabel          *ElapsedTime;

@property (nonatomic, retain) IBOutlet UIView           *Bottomview;
@property (nonatomic, retain) IBOutlet UIView           *FlipView;
@property (nonatomic, retain) IBOutlet UIView           *TopController;

@property (nonatomic, retain) IBOutlet UIButton         *RepeatButton;
@property (nonatomic, retain) IBOutlet UIButton         *RandomButton;
@property (nonatomic, retain) IBOutlet UIButton         *PlayButton;

@property (nonatomic, retain) IBOutlet UIButton         *NextButton;

@property (nonatomic, retain) IBOutlet UIButton         *BackwardButton;

@property (nonatomic, retain)          UIButton         *FlipButton;

@property (nonatomic, retain) IBOutlet UIImage          *AlbumArt;
//@property (nonatomic, retain) IBOutlet UIImageView      *AlbumArtView;
//@property (nonatomic, retain) IBOutlet UIImageView      *AlbumArtViewInvert;


@property (nonatomic, retain) MPVolumeView *volumeView;
@property (nonatomic, retain) IBOutlet UIView *volumeUIView;

@property (nonatomic, retain) SettingsData *cfgData;


// for more control mode
@property (nonatomic) CMTime aTime;
@property (nonatomic) CMTime bTime;
@property (nonatomic) float currentTimeSec;
@property (nonatomic) float durationTimeSec;
@property (nonatomic) BOOL  onLoopMode;
@property (nonatomic) int   toggleMode; // 0 : Lyrics  1 : Albumart  2 : Loop


// for Long Press time seek feature
@property (nonatomic) BOOL      toggleLongNextPress;
@property (nonatomic) BOOL      toggleLongPrevPress;
@property (nonatomic) int       LongPressCount;
@property (nonatomic) int       OriginalVol;

// Queue
@property (nonatomic, retain) NSOperationQueue *PlayQueue;

// Remember Current Play Route
@property (nonatomic, retain) NSString *RouteInfo;


+ (MyMusicPlayer *) sharedMusicPlayer;

- (id) initWithMediaItems:(NSArray *)items startPoint:(int)idx;

- (id) MediaItems:(NSArray *)items startPoint:(int)idx;

- (void) updateTime;

- (void) audioPlayerDidFinishPlaying;

- (void) registerForBackgroundNotifications;

- (void) PlayAtIndex:(int)NewIndex;

//- (UIImage *) artworksForFileAtPath:(NSString *)filepath;
- (UIImage *) artworksForFileAtPath:(Id3db *)id3item;

- (void) id3ForFileAtPath:(Id3db *)id3item;

//- (void) id3ForFileAtPath:(NSString *)filepath;

- (void) Seek:(int)sec;

- (void) PlayerClose;

- (void) AudioSessionRegister;

- (void) InitializePlayer;

- (void) RandomIndex;

- (void) RouteButton;

- (void) TimelineImageSet;

- (void) onLockInfo;

- (void) offLockInfo;

- (void) RandomToggle;


// Timer
- (void) TimerOn;

- (void) TimerOff;

//-(void) handleLongPress:(UILongPressGestureRecognizer *)recognizer;

// UI 에서 터치 동작 메소드 정의 

- (IBAction) Play:(id)sender;
- (IBAction) Prev:(id)sender;
- (IBAction) Next:(id)sender;

- (void) PlayWorker:(Id3db *)id3item;
- (void) PrevWorker:(id)sender;
- (void) NextWorker:(id)sender;

- (void) UIUpdate:(Id3db *)id3item;

- (IBAction) moveProgressbar:(id)sender;
- (IBAction) toggleRepeat:(id)sender;
- (IBAction) toggleRandom:(id)sender;

// for future use
- (IBAction) toggleFlip:(id)sender;

// Long Press
- (IBAction) LongNext:(id)sender;
- (IBAction) LongPrev:(id)sender;
- (IBAction) LongCancel:(id)sender;

// auto scroll

- (void) ScrollToCurrentCell;

- (void) CancelAutoScroll;

@end
