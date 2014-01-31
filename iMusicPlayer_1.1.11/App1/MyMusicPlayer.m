//
//  Player.m
//  App1
//
//  Created by Han Eunsung on 11. 10. 1..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MyMusicPlayer.h"
#import "MoreCtrlView.h"
#import "InformView.h"
#import "AlbumArtView.h"
#import "OBSlider.h"
#import "NaviBar.h"

#import <AVFoundation/AVAudioPlayer.h>
#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

#import <MediaPlayer/MPVolumeView.h>

#import <MediaPlayer/MPNowPlayingInfoCenter.h>
#import <MediaPlayer/MPMediaItem.h>



#import "PlaylistTable.h"
#import "PlaylistTableCell.h"
#import "Id3db.h"
#import "FileTable.h"

@implementation MyMusicPlayer

@synthesize index, OriginalIndex;
@synthesize isRandom, inAlbumView, inLyrics;
@synthesize player;
@synthesize playlist;
@synthesize path;
@synthesize PlayCount;
@synthesize PlayButton, BackwardButton, NextButton;
@synthesize PlayImage;
@synthesize PauseImage;
@synthesize CurrentTime;
@synthesize ElapsedTime;
@synthesize Timeline;
@synthesize Bottomview;
@synthesize RandomButton;
@synthesize RepeatButton;
@synthesize FlipView;
@synthesize FlipButton;
@synthesize AlbumArt;
//@synthesize AlbumArtView, AlbumArtViewInvert;
@synthesize TopController;
@synthesize SongAlbum, SongTitle, SongSinger;
@synthesize RandomizeIndex;

@synthesize volumeView;
@synthesize volumeUIView;

@synthesize cfgData;
@synthesize interruptedWhilePlaying;

@synthesize CtrlView;
@synthesize isToggle, toggleMode;

@synthesize currentTimeSec, durationTimeSec;

@synthesize aTime, bTime, onLoopMode;
@synthesize informView, albumView, lyricsView;

@synthesize toggleLongNextPress, toggleLongPrevPress, LongPressCount, OriginalVol;
@synthesize PlayQueue;

@synthesize onEventLock;
@synthesize RouteInfo;

void RouteChangeListener(void *                  inClientData,
                         AudioSessionPropertyID	 inID,
                         UInt32                  inDataSize,
                         const void *            inData)
{

	MyMusicPlayer* This = (MyMusicPlayer *)inClientData;
    
	if (inID == kAudioSessionProperty_AudioRouteChange) {
        
		CFDictionaryRef routeDict = (CFDictionaryRef)inData;
		NSNumber *reasonValue 
        = (NSNumber *)CFDictionaryGetValue(routeDict, CFSTR(kAudioSession_AudioRouteChangeKey_Reason));
        
		int reason = [reasonValue intValue];
        
        NSLog(@"=== Interrupted Number = %d", reason);

        switch (reason) {
            case kAudioSessionRouteChangeReason_OldDeviceUnavailable:
                NSLog(@"--- Old Audio Device Unavailable ");
                
                // pause
                if(This.player.rate > 0) {
                    
                    
                    [This Play:@""];
                    
//                    [This.player setRate:0];
//                    [This TimerOff];
//                    [This.player pause];    
//                    This.PlayButton.frame = PlayRect;
//                    [This.PlayButton setImage:This.PlayImage forState:UIControlStateNormal];

                }
                
                break;
                
            case kAudioSessionRouteChangeReason_NewDeviceAvailable:
                NSLog(@"--- New Audio Device Available ");
                break;
                                
            default:
                break;
        }
        
//		if (reason == kAudioSessionRouteChangeReason_OldDeviceUnavailable) {
//            NSLog(@"Interrupt stop");
//
//            [This.player setRate:0];
//            [This TimerOff];
//            [This.player pause];    
//            This.PlayButton.frame = PlayRect;
//            [This.PlayButton setImage:This.PlayImage forState:UIControlStateNormal];
//            
//// don't need ? 
////            if(This.player.rate > 0) {
////                [This Play:@""];
////            }
//            
//            
//        }else if(reason == kAudioSessionRouteChangeReason_NewDeviceAvailable){
//            NSLog(@"Interrupt New Device ");
////            [This RouteButton];
//            
//        }else if (reason == kAudioSessionRouteChangeReason_CategoryChange) {
//
//            if(This.interruptedWhilePlaying == TRUE){
//                
//                NSLog(@"Interrupt Restore Playing");
//                [This Play:@""];
//                
//                
//            }
//
//        }
        
	}
}

static MyMusicPlayer *sharedPlayer;


#pragma mark - Initialize singleton

+ (MyMusicPlayer *)sharedMusicPlayer{
    
    // init Singletone
    if (sharedPlayer == nil) {
        sharedPlayer = [[MyMusicPlayer alloc] init];
        NSLog(@"MyMusicPlayer Singleton Created");
    }else{
        NSLog(@"MyMusicPlayer Singleton already Created");
    }
    return sharedPlayer;
}

#pragma mark - Initialize class

- (void) RouteButton{
    
}

- (void) TimelineImageSet{
    for (UIView *view in volumeView.subviews) {
        if([view isKindOfClass:[UISlider class]]){
            UISlider *slider = (UISlider *)view;
            
//            [slider setMaximumTrackTintColor:[]];
            [slider setThumbImage:[UIImage imageNamed:@"Nobe"] forState:UIControlStateNormal];
            [slider setMaximumTrackImage:[UIImage imageNamed:@"MaxSlide"] forState:UIControlStateNormal];
            [slider setMinimumTrackImage:[UIImage imageNamed:@"MinSlide"] forState:UIControlStateNormal];            
            
            UIImage *max = [slider maximumTrackImageForState:UIControlStateNormal];
            UIImage *min = [slider minimumTrackImageForState:UIControlStateNormal];
            UIImage *thum = [slider thumbImageForState:UIControlStateNormal];

            [Timeline setMaximumTrackImage:max forState:UIControlStateNormal];
            [Timeline setMinimumTrackImage:min forState:UIControlStateNormal];
            [Timeline setThumbImage:thum forState:UIControlStateNormal];
            [Timeline setThumbImage:thum forState:UIControlStateSelected];
            [Timeline setThumbImage:thum forState:UIControlStateHighlighted];
        }
    }
}

- (void) RandomIndex{
    // 랜덤 플레이 리스트 초기화
    NSMutableArray *rlist = [NSMutableArray array];
    RandomizeIndex = [[NSMutableArray alloc] init];
    
    for (int i=0; i < [playlist count];i++) 
        [rlist addObject:[NSNumber numberWithInt:i]];
    
    while ([rlist count] != 0) {
        int rdm = arc4random() % [rlist count];
        [RandomizeIndex addObject:[rlist objectAtIndex:rdm]];
        [rlist removeObjectAtIndex:rdm];
    }
    
    
//    NSLog(@"Random Index = %@",RandomizeIndex);

}

- (void) popView{
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (void) InitializePlayer{
    
    
    //  
    
    
    
    NSLog(@"Init Player");
    //--------------------------------------------------------------------
    // init variants
    self.view.backgroundColor = [UIColor blackColor] ;
    self.FlipView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Background.png"]];

    self.toggleMode = 1;
    self.isToggle = FALSE;
    self.isRandom = FALSE;
    [RandomButton setImage:[UIImage imageNamed:@"Rdm_x"] forState:UIControlStateNormal];

    //--------------------------------------------------------------------------
    // playlist make
    listTable = [[PlaylistTable alloc] initWithNibName:@"PlaylistTable" bundle:nil];
    
    CGRect p = listTable.view.bounds;
    listTable.view.bounds = p;    
    listTable.view.center = CGPointMake(p.size.width / 2, p.size.height / 2);
    [listTable setMplayer:self];
    
    //--------------------------------------------------------------------------
    // 어학기능 뷰 추가
    
    
    if(albumView == nil) {
        albumView = [[AlbumArtView alloc] initWithNibName:@"AlbumArtView" bundle:nil];   
        [FlipView addSubview:albumView.view];
    }
    albumView.view.center = CGPointMake(160, 356);
    albumView.view.alpha = 0;
    
    if(CtrlView == nil) {
        CtrlView = [[MoreCtrlView alloc] initWithNibName:@"MoreCtrlView" bundle:nil];
        [FlipView addSubview:CtrlView.view];
    }
    CtrlView.view.center = CGPointMake(160, 356);
    CtrlView.view.alpha = 0;
    
    [CtrlView initialize];

    if(lyricsView == nil) {
        lyricsView = [[LyricsView alloc] initWithNibName:@"LyricsView" bundle:nil];
        [FlipView addSubview:lyricsView.view];
    }
    lyricsView.view.center = CGPointMake(160, 222);
    lyricsView.view.alpha = 0;
    
    if(informView == nil) {
        informView = [[InformView alloc] initWithNibName:@"InformView" bundle:nil];   
        [FlipView addSubview:informView.view];
    }
    informView.view.center = CGPointMake(160, 60);
    informView.view.alpha = 0;
    
    
    if(FlipButton == nil){

        //--------------------------------------------------------------------------
        // 플립 버튼
        FlipButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
        FlipButton.bounds = CGRectMake(0, 0, 30, 30);    
        [FlipButton addTarget:self action:@selector(toggleFlip:) forControlEvents:UIControlEventTouchUpInside];

        // 플립버튼    
        UIBarButtonItem *rightButton = [[[UIBarButtonItem alloc] initWithCustomView:FlipButton] autorelease];
        self.navigationItem.rightBarButtonItem = rightButton;
        
        //--------------------------------------------------------------------------
        // 뒤로가기 이미지
        UIImage *backImage = [UIImage imageNamed:@"BackArrow.png"];    
        UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [backBtn addTarget:self action:@selector(popView) forControlEvents:UIControlEventTouchUpInside];
        backBtn.bounds = CGRectMake(0, 0, 43, 31);
        [backBtn setImage:backImage forState:UIControlStateNormal];
        UIBarButtonItem *btt= [[UIBarButtonItem alloc] initWithCustomView:backBtn];
        self.navigationItem.leftBarButtonItem = btt;
        [btt release];
        
        [self registerForBackgroundNotifications];


        Bottomview.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"BT.png"]];

    }
    
    // 백그라운드 플레이 설정 ?
    firstResponder = YES;
    
    if(self.PlayImage == nil){
        PlayImage = [[UIImage imageNamed:@"Play.png"] retain];
        PauseImage = [[UIImage imageNamed:@"BlackPause.png"] retain];
        [PlayButton setImage:PlayImage  forState:UIControlStateNormal];
    
    }

    if(volumeView == nil){
        volumeView = [[[MPVolumeView alloc] initWithFrame:CGRectMake(0, 0, 280, 10)] autorelease];
        volumeView.center = CGPointMake(160,385);
        [volumeView sizeToFit];
        volumeView.showsRouteButton = TRUE;

        [self.view addSubview:volumeView];
        
        [self TimelineImageSet];
    }

}

- (void)Seek:(int)sec{
    
    
    if(self.toggleLongNextPress == FALSE){
        self.toggleLongNextPress = TRUE;
        
        
        NSThread* myThread = [[NSThread alloc] initWithTarget:self
                                                     selector:@selector(ThreadSeek)
                                                       object:nil];
        [myThread start];  // Actually create the thread
        
        
    }else{
        self.toggleLongNextPress = FALSE;
    }
    NSLog(@"long pressed");

    
    
}

- (void) PlayerClose{
    [self.player pause];
    [Timer invalidate];    
    Timer = nil;
    index = isRandom = inLyrics = 0;
    
}


- (void) AudioSessionRegister{
    
    // Audio Session Register
    AudioSessionInitialize(NULL,NULL,NULL,NULL);
	[[AVAudioSession sharedInstance] setDelegate: self];
	[[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error:nil];
    AudioSessionAddPropertyListener (kAudioSessionProperty_AudioRouteChange, RouteChangeListener, self);
}

- (id) MediaItems:(NSArray *)items startPoint:(int)idx{
    NSLog(@"MediaItems()");
    
    // 객체가 살아있을 경어만 특별히 종료 선행 작업 
    if(self.player) {        
        NSLog(@"No created Player First run");
        
        [self PlayerClose];
        
        NSLog(@"close player");

        [self.playlist release];
        [listTable.view removeFromSuperview];
        [listTable release];

    }
    
    //------------------------------------------------------- 
    // 초기설정 
    [self InitializePlayer];
    
    // 플레이리스트 가져오기    
    NSLog(@"playlist retains : %d", [items retainCount]);
//    self.playlist = [items retain];
        
    self.playlist = [items copy];;
    //[items release];
    
    NSLog(@"playlist retains : %d", [items retainCount]);
    
    self.index = idx;
    self.OriginalIndex = idx;
    
    // 랜덤 인덱스 생성
    [self RandomIndex];
    
    // id3 item 
    Id3db *id3item = [self.playlist objectAtIndex:self.index];
    
//    if(self.player != nil) [self.player release];
    // player set
    if (self.player == nil) {
        NSLog(@"AVPlayer init");
        self.player = [[AVPlayer alloc] initWithURL:[id3item.asset URL]];
    }else {
        NSLog(@"AVPlayer reuse");
        [self.player replaceCurrentItemWithPlayerItem:[AVPlayerItem playerItemWithAsset:id3item.asset]];
    }
    
    [self artworksForFileAtPath:[playlist objectAtIndex:index]];
    
    inAlbumView = TRUE;
    
    // Set Time
    CMTime currentTime = self.player.currentTime;  
    CMTime duration = self.player.currentItem.asset.duration;
    currentTimeSec = currentTime.value / currentTime.timescale;
    durationTimeSec = duration.value / duration.timescale;
    
    // timeline set
    CurrentTime.text 
    = [NSString stringWithFormat:@"%02d:%02d", (int)currentTimeSec / 60, (int)currentTimeSec % 60, nil];
    ElapsedTime.text 
    = [NSString stringWithFormat:@"-%02d:%02d", (int)(durationTimeSec - currentTimeSec) / 60, (int)(durationTimeSec - currentTimeSec) % 60, nil];

    Timeline.value = 0;
    Timeline.maximumValue = durationTimeSec;
    
    // ipod audio register for background play
    [self AudioSessionRegister];
    
    // scroll
    [self performSelector:@selector(ScrollToCurrentCell) withObject:nil afterDelay:2];
    
    
    
    NSLog(@"Play call");
    // 플레이 
    [self Play:nil];

    

    [listTable.tableView reloadData];    
    [FlipView insertSubview:listTable.view atIndex:0];
    
    return self;

}

- (id) initWithMediaItems:(NSArray *)items startPoint:(int)idx{
    
    NSLog(@"InitWith media item");
    
    // init
    self.playlist = [[NSArray alloc] initWithArray:items]; // id3db item array
    self.index = idx;
    self.OriginalIndex = idx;
    
    // id3 item 
    Id3db *id3item = [self.playlist objectAtIndex:self.index];
    self.player = [[AVPlayer alloc] initWithURL:[id3item.asset URL]];
    
//    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:[id3item.asset URL] error:nil];

//    [self AudioSessionRegister];
    
    
    return self;
}

- (void) didReceiveMemoryWarning{
    // Releases the view if it doesn't have a superview.
    NSLog(@"Memeory Warning");
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void) viewDidLoad{
   
    NSLog(@"Viewdidload()");
    [super viewDidLoad];
    
    PlayQueue = [[NSOperationQueue alloc] init]; 
//    [PlayQueue setMaxConcurrentOperationCount:1]; 

    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AVPlayerItemDidPlayToEndTimeNotification 
                                                  object:self.player];

    //    //regist noti    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioPlayerDidFinishPlaying)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:self.player];

}

- (void) viewDidUnload{
    
    [super viewDidUnload];
    
    NSLog(@"ViewDidUnloaded");

    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) viewWillAppear:(BOOL)animated{

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];

    // 5.0?
//    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"Navi.png"] forBarMetrics:UIBarMetricsDefault];
    NaviBar *navi = (NaviBar *)self.navigationController.navigationBar;
    navi.toggleNaviIamge = TRUE;
    [navi setNeedsDisplay];
    
    
        // 최초 생성시에만 세팅
    if (!SongTitle) {
        SongSinger = [[UILabel alloc] initWithFrame:CGRectMake(60, 2, 200, 15)];
        SongTitle  = [[UILabel alloc] initWithFrame:CGRectMake(60, 0, 200, 44)];
        SongAlbum  = [[UILabel alloc] initWithFrame:CGRectMake(60, 28, 200, 15)];
        
        SongSinger.textColor = [UIColor darkGrayColor];
        SongTitle.textColor  = [UIColor whiteColor];
        SongAlbum.textColor  = [UIColor darkGrayColor];

        SongSinger.backgroundColor = [UIColor clearColor];
        SongTitle.backgroundColor  = [UIColor clearColor];
        SongAlbum.backgroundColor  = [UIColor clearColor];
        
        SongSinger.font = [UIFont boldSystemFontOfSize:12.0];
        SongTitle.font  = [UIFont boldSystemFontOfSize:16.0];
        SongAlbum.font  = [UIFont boldSystemFontOfSize:12.0];
                
        SongSinger.textAlignment = UITextAlignmentCenter;
        SongTitle.textAlignment  = UITextAlignmentCenter;
        SongAlbum.textAlignment  = UITextAlignmentCenter;
    }
    
    SongSinger.alpha = 0;
    SongTitle.alpha = 0;
    SongAlbum.alpha = 0;
    
    // 네비게이션바에 넣기
//    [self.navigationController.navigationBar addSubview:SongSinger];            
    [self.navigationController.navigationBar addSubview:SongTitle];            
//    [self.navigationController.navigationBar addSubview:SongAlbum];   
    
    // 플레이리스트 객체에서 id3db 타입의 단일 파일 선택
    Id3db *id3item = [playlist objectAtIndex:index];
    SongTitle.text = id3item.title;
    SongAlbum.text = id3item.album;
    SongSinger.text = id3item.artist;


    [UIView animateWithDuration:1 animations:^{
        SongSinger.alpha = 1;
        SongTitle.alpha = 1;
        SongAlbum.alpha = 1;
        
    }];
    
    
    [CtrlView changeTimeStep];
    
    NSLog(@"ViewWillAppear Done");
//    [self RouteButton];
    
    
}

- (void) viewWillDisappear:(BOOL)animated{
        
    
    // 5.0?
//    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    NaviBar *navi = (NaviBar *)self.navigationController.navigationBar;
    navi.toggleNaviIamge = FALSE;
    [navi setNeedsDisplay];

    
    [self.navigationController.navigationBar setBarStyle:UIBarStyleDefault];
    
    [UIView animateWithDuration:1 animations:^{
        [SongSinger removeFromSuperview];
        [SongTitle removeFromSuperview];
        [SongAlbum removeFromSuperview];
        

    }];
    
    UIApplication *app = [UIApplication sharedApplication];
    [app setStatusBarStyle:UIStatusBarStyleDefault];
    
    
}

- (void) viewDidAppear:(BOOL)animated{
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
    NSLog(@"ViewDidAppear");
    
    switch (RepeatState) {
        case 0:
            // non-repeat
            [RepeatButton setImage:[UIImage imageNamed:@"Rpt_x"] forState:UIControlStateNormal];
            
            break;
            
        case 1:
            // play 1            
            [RepeatButton setImage:[UIImage imageNamed:@"Rpt_1"] forState:UIControlStateNormal];
            
            break;
            
        case 2:
            // repeat 1
            [RepeatButton setImage:[UIImage imageNamed:@"Rpt_1+"] forState:UIControlStateNormal];
            
            break;
            
        case 3:
            // repeat all
            [RepeatButton setImage:[UIImage imageNamed:@"Rpt_o"] forState:UIControlStateNormal];
            
            break;
            
        default:
            break;
    }

    
}

- (void) viewDidDisappear:(BOOL)animated{
    NSLog(@"MyMusicPlayer DidDisappear");
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - AudioPlaying Action

- (void) audioPlayerDidFinishPlaying{
    NSLog(@"Audio End Event Start");
    self.onEventLock = 1;
    
    NSLog(@"RepeatState = %d, ", RepeatState);
    switch (RepeatState) {
            
        case 0: // non-repeat
            
//            NSLog(@"index : %d / %d ", index, [playlist count]);
            if(index + 1 == [playlist count]){
                
                NSLog(@"Max List End");
                
                [Timer invalidate];
                Timer = nil;

                [self.player seekToTime:CMTimeMake(0, self.player.currentTime.timescale)];
                Timeline.value = 0;
                [self.player pause]; // stop
                
                PlayButton.frame = PlayRect;
                [PlayButton setImage:PlayImage forState:UIControlStateNormal];
                
            }else{
                [self NextWorker:@""];
//                [self Next:@""];
            }
            break;
            
        case 1: // play 1

            [Timer invalidate];
            Timer = nil;

            Timeline.value = 0;
            [self.player seekToTime:CMTimeMake(0, self.player.currentTime.timescale)];
            [self.player pause]; // stop
            
            PlayButton.frame = PlayRect;
            [PlayButton setImage:PlayImage  forState:UIControlStateNormal];
            

            break;
            
        case 2: // repeat 1
            
                [self Next:nil];
            
            break;
            
        case 3: // repeat all
            
            [self Next:@""];

//            [self NextWorker:@""];
            
            break;
            
        default:
            break;
    }
    
    NSLog(@"Audio End Event End");
}

//- (void) audioPlayerBeginInterruption:(AVAudioPlayer *)p{
//	NSLog(@"Interruption begin. Updating UI for new state");
//	// the object has already been paused,	we just need to update UI
//    [self Play:nil];
//
//}
//
//- (void) audioPlayerEndInterruption:(AVAudioPlayer *)p{
//	NSLog(@"Interruption ended. Resuming playback");
//    
//    [self Play:nil];
//
//}

#pragma mark - Player 

- (void) TimerOn{
    
    if(Timer != nil && [Timer isValid] == TRUE){
        [Timer invalidate];
        Timer = nil;
        
    }
    
    Timer = [NSTimer scheduledTimerWithTimeInterval:0.25
                                             target:self 
                                           selector:@selector(updateTime) 
                                           userInfo:self.player 
                                            repeats:YES];
    
    NSLog(@"Timer On");

}

- (void) TimerOff{
    
    [Timer invalidate];
    Timer = nil;
    NSLog(@"Timer Off");

}

- (void) updateTime{
//    NSLog(@"time!");
    
    CMTime currentTime = self.player.currentTime;    
    currentTimeSec = (float)currentTime.value / currentTime.timescale;
//    CMTime sub = CMTimeSubtract(self.player.currentItem.duration, currentTime);
//    float last = (float)sub.value / sub.timescale;
    
    // Time Line Update
    if(Timeline.tracking == FALSE){ 
        
        CurrentTime.text 
        = [NSString stringWithFormat:@"%02d:%02d", (int)currentTimeSec / 60, (int)currentTimeSec % 60, nil];
        ElapsedTime.text 
        = [NSString stringWithFormat:@"-%02d:%02d", (int)(durationTimeSec - currentTimeSec) / 60, (int)(durationTimeSec - currentTimeSec) % 60, nil];            
        
        Timeline.value = currentTimeSec;
        
    }
    
    
    // AB Repeat Mode Loop
    if(self.onLoopMode == TRUE){
        
        if(currentTime.value > self.bTime.value + 250000000){
            NSLog(@"A-B Repeat to A");
            [self.player seekToTime:self.aTime];
            
        }else{
            
            [CtrlView.timeSlider setValue:currentTime.value];
            
        }
        
    }
    
    
    // Fast Forward
    if(self.toggleLongNextPress == TRUE){
        
        NSLog(@"LongPress Next");
        
        self.LongPressCount += 1;
        
        switch (self.LongPressCount) {
            case 30:
                PlayCount.text 
                = [NSString stringWithFormat:@"Fast Forward x 10"];                                        
                [self.player setRate:15];
                break;
                
            case 21:
                PlayCount.text 
                = [NSString stringWithFormat:@"Fast Forward x 7"];                    
                [self.player setRate:10];
                break;
                
            case 12:
                PlayCount.text 
                = [NSString stringWithFormat:@"Fast Forward x 5"];                    
                [self.player setRate:6];
                break;
                
            case 3:
                [self.player setRate:2];
                PlayCount.text 
                = [NSString stringWithFormat:@"Fast Forward x 2"];
                break;
        }
        
        
    }else if(self.toggleLongPrevPress == TRUE){
        
        NSLog(@"LongPress Prev");
        
        self.LongPressCount += 1;
        
        if (self.LongPressCount >= 30){
            [self.player seekToTime:CMTimeMake(currentTime.value - 10000000000, currentTime.timescale)];
            PlayCount.text 
            = [NSString stringWithFormat:@"Fast Backward x 10"];
        }
        else
            
            if (self.LongPressCount >= 21) {
                [self.player seekToTime:CMTimeMake(currentTime.value - 7000000000, currentTime.timescale)];
                PlayCount.text 
                = [NSString stringWithFormat:@"Fast Backward x 7"];
            }
            else
                
                if (self.LongPressCount >= 12) {
                    [self.player seekToTime:CMTimeMake(currentTime.value - 5000000000, currentTime.timescale)];
                    PlayCount.text 
                    = [NSString stringWithFormat:@"Fast Backward x 5"];
                }
                else
                    
                    if (self.LongPressCount >= 3) {
                        [self.player seekToTime:CMTimeMake(currentTime.value - 2000000000, currentTime.timescale)];
                        PlayCount.text 
                        = [NSString stringWithFormat:@"Fast Backward x 2"];
                        
                    }
        
        
    }else{
        
        self.LongPressCount = 0;
        
    }
           
}

- (void) PlayAtIndex:(int)NewIndex{
    
    
    if([PlayQueue operationCount] > 0) return;
    
    // for playlist
    PlaylistTableCell *orig_cell = (PlaylistTableCell *)[listTable.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    
    index = OriginalIndex = NewIndex;
    PlayCount.text = [NSString stringWithFormat:@"%d / %d", index + 1, [playlist count] ];
    Id3db *id3item = [playlist objectAtIndex:index];  
    
    
    // for playlist 
    PlaylistTableCell *next_cell = (PlaylistTableCell *)[listTable.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    
    orig_cell.HereImage.hidden = TRUE;
    next_cell.HereImage.hidden = FALSE;
    

    [self.player replaceCurrentItemWithPlayerItem:[AVPlayerItem playerItemWithAsset:id3item.asset]];
    [self.player play];

    
    // scroll
    [self performSelector:@selector(ScrollToCurrentCell) withObject:nil afterDelay:2];

    NSInvocationOperation* op = [[[NSInvocationOperation alloc] initWithTarget:self  
                                                                      selector:@selector(PlayWorker:) 
                                                                        object:id3item] autorelease];
    
    NSLog(@"Queue : %d", [PlayQueue operationCount]);
    [PlayQueue addOperation:op];

    
}

- (void)onLockInfo{
 
    if(AlbumArt != nil){
        // lock screen image
        MPMediaItemArtwork *mediaArtwork = [[[MPMediaItemArtwork alloc] initWithImage:AlbumArt] autorelease];
        MPNowPlayingInfoCenter *nowPlaying = [MPNowPlayingInfoCenter defaultCenter];
        NSMutableDictionary *myDic = [NSMutableDictionary dictionary];
        
        Id3db *id3item = [playlist objectAtIndex:index];
        
        [myDic setObject:id3item.title forKey:MPMediaItemPropertyTitle];
        [myDic setObject:id3item.artist forKey:MPMediaItemPropertyArtist];
        [myDic setObject:id3item.album forKey:MPMediaItemPropertyAlbumTitle];
        [myDic setObject:mediaArtwork forKey:MPMediaItemPropertyArtwork];
        [nowPlaying setNowPlayingInfo:myDic];
    }
}

- (void)offLockInfo{

    // lock screen image
    MPNowPlayingInfoCenter *nowPlaying = [MPNowPlayingInfoCenter defaultCenter];    
    [nowPlaying setNowPlayingInfo:nil];
}

#pragma mark - IBAction


- (void)UIUpdate:(Id3db *)id3item{
    NSLog(@"Update()");

    NSLog(@"Playlist retains : %d", [self.playlist retainCount]);

    
//    [self.CtrlView initialize];

    // 플레이 버튼 일시정지로
    PlayButton.frame = PauseRect;
    [PlayButton setImage:PauseImage     forState:UIControlStateNormal];
    [FlipButton setImage:AlbumArt       forState:UIControlStateNormal];

    [albumView.albumImage setImage:AlbumArt];
    albumView.artistLabel.text = id3item.artist;
    albumView.albumLabel.text = id3item.album;
    albumView.titleLabel.text = id3item.title;
    
    SongTitle.text = id3item.title;

    // 가사 여부 판단
    if ([id3item.lyrics isEqualToString:@""]) {
        
        // 기존에 가사 모드 일경우만 앨범모드로 변경
        if (self.toggleMode == 2) self.toggleMode = 1;
        lyricsView.view.alpha = 0;
        informView.lyricsButton.enabled = FALSE;
        informView.lyricsButton.titleLabel.textColor = [UIColor grayColor];
        
        
    }else{
        // 가사 표시 
        lyricsView.lyricsText.text = id3item.lyrics;
        informView.lyricsButton.enabled = TRUE;
        informView.lyricsButton.titleLabel.textColor = [UIColor whiteColor];
    }
    

    self.PlayCount.text = [NSString stringWithFormat:@"%d / %d", index + 1, [playlist count]];

    [listTable.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:YES];

    
    NSLog(@"UIUpdate End");
    
    [self TimerOn];
    self.onEventLock = 0;
    
        
    if(self.player.status == AVPlayerStatusFailed){
        NSLog(@"Not Playing !");
        [self.player release];
        self.player = nil;
        
        NSLog(@"ReInit Player");
        Id3db *id3item = [self.playlist objectAtIndex:self.index];
        self.player = [[AVPlayer alloc] initWithURL:[id3item.asset URL]];
        [self.player play];

    }


    
}

- (IBAction) Play:(id)sender{
    NSLog(@"Play");
    
    // 인터럽트 해제 
//    self.interruptedWhilePlaying = FALSE;

    // 재생 중일 경우 : 일시정지
    if(Timer != nil && sender != nil)
    {
        // 타이머 제거 후 일시정지
        NSLog(@"Pause!");
        [self TimerOff];
        [self.player pause];    
        PlayButton.frame = PlayRect;
        [PlayButton setImage:PlayImage forState:UIControlStateNormal];
        
    }
    // 재생 중이지 않는 경우 : 재생모드
    else
    {   
        
        NSLog(@"Play Now");
        [self.player play];
        
        

        

        CMTime duration = self.player.currentItem.asset.duration;
        durationTimeSec = duration.value / duration.timescale;
        Timeline.maximumValue = durationTimeSec;
        
        // 플레이리스트 객체에서 id3db 타입의 단일 파일 선택
        Id3db *id3item = [playlist objectAtIndex:index];
        [self artworksForFileAtPath:id3item];

        cfgData = [SettingsData sharedSettingsData];
        if(cfgData.OnLockScreenInfo == TRUE) {
            [self onLockInfo];
        }else{
            [self offLockInfo];
        }
        
//        usleep(100000);
        NSLog(@"UI thread");
        [self performSelectorOnMainThread:@selector(UIUpdate:) withObject:id3item waitUntilDone:FALSE];
//        [self UIUpdate:id3item];
        
    }
    
}

- (void)PlayWorker:(Id3db *)id3item{
    
//    [self TimerOn];
    
    
    [self artworksForFileAtPath:id3item];
//    [self.CtrlView initialize];
    
    CMTime duration = self.player.currentItem.asset.duration;
    durationTimeSec = duration.value / duration.timescale;
    Timeline.maximumValue = durationTimeSec;
            
    cfgData = [SettingsData sharedSettingsData];
    if(cfgData.OnLockScreenInfo == TRUE) {
        [self onLockInfo];
    }else{
        [self offLockInfo];
    }

    
    usleep(100000);

    [self performSelectorOnMainThread:@selector(UIUpdate:) withObject:id3item waitUntilDone:FALSE];
//    [self UIUpdate:id3item];
    
    NSLog(@"PlayWorker done");
    
}

- (IBAction) Prev:(id)sender{
    
    NSInvocationOperation* op = [[[NSInvocationOperation alloc] initWithTarget:self  
                                                                      selector:@selector(PrevWorker:) 
                                                                        object:sender] autorelease];
    NSOperationQueue *queue = [NSOperationQueue mainQueue]; 
    if([queue operationCount] == 0){
        [queue addOperation:op];
    }
    

    
}

- (void)PrevWorker:(id)sender{
    
    self.toggleLongPrevPress = FALSE;
    PlayCount.text = [NSString stringWithFormat:@"%d / %d", index + 1, [playlist count] ];
    [self.player setRate:1.0];
    if(self.LongPressCount > 3) return;
    
    // set back to 0
    if(currentTimeSec > 3){
        [self.player seekToTime:CMTimeMake(0, 1000000000)];
        return;
    }
    
    // for playlist
    PlaylistTableCell *orig_cell = (PlaylistTableCell *)[listTable.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    
    if(sender != nil){
        if(OriginalIndex - 1 < 0) index = OriginalIndex = [playlist count] - 1; 
        else index = --OriginalIndex;
        if(isRandom) index = [(NSNumber *)[RandomizeIndex objectAtIndex:OriginalIndex] intValue];
    }

    [listTable.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] 
                                     animated:NO scrollPosition:UITableViewScrollPositionNone];

    
    Id3db *id3item = [playlist objectAtIndex:index]; 
//    [self artworksForFileAtPath:id3item];
    
    
    // for playlist 
    PlaylistTableCell *next_cell = (PlaylistTableCell *)[listTable.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    
    orig_cell.HereImage.hidden = TRUE;
    next_cell.HereImage.hidden = FALSE;
    
    //play now!
    [self.player replaceCurrentItemWithPlayerItem:[AVPlayerItem playerItemWithAsset:id3item.asset]];
    
    // scroll
    [self performSelector:@selector(ScrollToCurrentCell) withObject:nil afterDelay:2];
    
    [self TimerOff];
    
    NSInvocationOperation* op = [[[NSInvocationOperation alloc] initWithTarget:self  
                                                                      selector:@selector(Play:) 
                                                                        object:nil] autorelease];
    
    if([PlayQueue operationCount] == 0 ){
        [PlayQueue addOperation:op];
    }
    
    [listTable.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:YES];

    [self.CtrlView initialize];
    
}

- (IBAction) Next:(id)sender{
    
    NSInvocationOperation* op = [[[NSInvocationOperation alloc] initWithTarget:self  
                                                                      selector:@selector(NextWorker:) 
                                                                        object:sender] autorelease];
    NSOperationQueue *queue = [NSOperationQueue mainQueue]; 
    if([queue operationCount] == 0){
        [queue addOperation:op];
    }
    
//    [self NextWorker:sender];

}

- (void)NextWorker:(id)sender{
    
    // 오래 누르고 멈출때 발생
    self.toggleLongNextPress = FALSE;   
    if(self.onEventLock == 0) [self.player setRate:1.0];
    PlayCount.text = [NSString stringWithFormat:@"%d / %d", index + 1, [playlist count] ];
    if(self.LongPressCount > 3) return;
    

//    NSLog(@"Time : %d", Timer);

    [self TimerOff];
    
    // for playlist
    PlaylistTableCell *orig_cell = (PlaylistTableCell *)[listTable.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    
    // 직접 다음을 터치하는 경우는 무조건 다음 트랙으로 넘김
    if(sender != nil){
        if(OriginalIndex + 1 >= [playlist count]) index = OriginalIndex = 0; 
        else index = ++OriginalIndex;
        if(isRandom == TRUE) index = [(NSNumber *)[RandomizeIndex objectAtIndex:OriginalIndex] intValue];
    }
    
    [listTable.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] 
                                     animated:NO scrollPosition:UITableViewScrollPositionNone];

    Id3db *id3item = [playlist objectAtIndex:index];    
    
    // for playlist 
    PlaylistTableCell *next_cell = (PlaylistTableCell *)[listTable.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    
    orig_cell.HereImage.hidden = TRUE;
    next_cell.HereImage.hidden = FALSE;
    
    
    
    // Play now!
    [self.player replaceCurrentItemWithPlayerItem:[AVPlayerItem playerItemWithAsset:id3item.asset]];
    
    
    // scroll
    [self performSelector:@selector(ScrollToCurrentCell) withObject:nil afterDelay:2];
    
    
    NSInvocationOperation* op = [[[NSInvocationOperation alloc] initWithTarget:self  
                                                                      selector:@selector(Play:) 
                                                                        object:nil] autorelease];
    
    [PlayQueue addOperation:op];
    
//    [self Play:nil];
    
    NSLog(@"NextWorker");
    
    [listTable.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:YES];

    [self.CtrlView initialize];
    
    

}


- (IBAction) moveProgressbar:(id)sender{
    
    UISlider *slider = (UISlider *)sender;
    float scale = self.player.currentTime.timescale;
    
    if ((int)slider.value % 2 == 0){
        [self.player seekToTime:CMTimeMake(slider.value * scale, scale)];
    }
    
    
}

- (IBAction) toggleRepeat:(id)sender{
    
    RepeatState++;
    if (RepeatState > 3) RepeatState = 0;
        
    switch (RepeatState) {
        case 0:
            // non-repeat
            [RepeatButton setImage:[UIImage imageNamed:@"Rpt_x"] forState:UIControlStateNormal];
            
            break;
            
        case 1:
            // play 1            
            [RepeatButton setImage:[UIImage imageNamed:@"Rpt_1"] forState:UIControlStateNormal];

            break;
            
        case 2:
            // repeat 1
            [RepeatButton setImage:[UIImage imageNamed:@"Rpt_1+"] forState:UIControlStateNormal];

            break;
            
        case 3:
            // repeat all
            [RepeatButton setImage:[UIImage imageNamed:@"Rpt_o"] forState:UIControlStateNormal];

            break;
            
        default:
            break;
    }
    
    
    
}

- (void)RandomToggle{
    
    if(isRandom == NO){
        isRandom = YES;
        [RandomButton setImage:[UIImage imageNamed:@"Rdm_o"] forState:UIControlStateNormal];
        
    }else{
        isRandom = NO;
        [RandomButton setImage:[UIImage imageNamed:@"Rdm_x"] forState:UIControlStateNormal];
        
        
    }

}

- (IBAction) toggleRandom:(id)sender{
        
    [self RandomToggle];
}

- (IBAction) toggleFlip:(id)sender{
    
    NSLog(@"togglemode : %d", self.toggleMode);
    
    if(self.isToggle == FALSE){
        
        self.isToggle = TRUE;
        [UIView animateWithDuration:0.3 animations:^{
            
            listTable.view.alpha = 0;

            informView.view.alpha = 1;
            informView.view.center = CGPointMake(160, 62);
            
            albumView.view.alpha = 1;
            albumView.view.center = CGPointMake(160, 200);

        } completion:^(BOOL ok){
            
            if(ok){
                
                [UIView animateWithDuration:0.3 animations:^{
                    
                    switch (self.toggleMode) {
                            
                        case 0:
                            
                            [UIView animateWithDuration:0.3 animations:^{
                                CtrlView.view.alpha = 1;
                                CtrlView.view.center = CGPointMake(160, 200);  
                                
                            }];
                            
                            [CtrlView initialize];
                            break;
                            
                        case 2:
                            [UIView animateWithDuration:0.3 animations:^{
                                lyricsView.view.alpha = 1;
                            }];
                            
                            break;
                            
                        default:
                            break;
                    }
                } completion:nil];
            }
        }];
        
    }else{
        
        self.isToggle = FALSE;
        [UIView animateWithDuration:0.3 animations:^{
            
            albumView.view.alpha = 0;
            albumView.view.center = CGPointMake(160, 356);
            
            CtrlView.view.alpha = 0;
            CtrlView.view.center = CGPointMake(160, 356);
            
            informView.view.alpha = 0;
            informView.view.center = CGPointMake(160, 40);
            
            lyricsView.view.alpha = 0;
            albumView.view.center = CGPointMake(160, 356);

            listTable.view.alpha = 1;
            
        }];
        
        [CtrlView.aLine removeFromSuperview];
        [CtrlView.bLine removeFromSuperview];

        self.onLoopMode = FALSE;
        
        
    }

}


- (void)LongNext:(id)sender{
    
    self.toggleLongNextPress = TRUE;
}

- (void)LongPrev:(id)sender{
    
    self.toggleLongPrevPress = TRUE;
    
}

- (void)LongCancel:(id)sender{
    
    NSLog(@"Long Touch Cancel");
    
    self.PlayCount.text = [NSString stringWithFormat:@"%d / %d", index + 1, [playlist count]];

    if ( self.player.rate > 0 )     [self.player setRate:1];        
    
    self.toggleLongNextPress = FALSE;
    self.toggleLongPrevPress = FALSE;
}

#pragma mark - External Control

- (BOOL) canBecomeFirstResponder{
    
    //    return firstResponder;
    return YES;
}

- (void) remoteControlReceivedWithEvent:(UIEvent *)event{
    
//    UIEventSubtypeRemoteControlPlay                 = 100,
//    UIEventSubtypeRemoteControlPause                = 101,
//    UIEventSubtypeRemoteControlStop                 = 102,
//    UIEventSubtypeRemoteControlTogglePlayPause      = 103,
//    UIEventSubtypeRemoteControlNextTrack            = 104,
//    UIEventSubtypeRemoteControlPreviousTrack        = 105,
//    UIEventSubtypeRemoteControlBeginSeekingBackward = 106,
//    UIEventSubtypeRemoteControlEndSeekingBackward   = 107,
//    UIEventSubtypeRemoteControlBeginSeekingForward  = 108,
//    UIEventSubtypeRemoteControlEndSeekingForward    = 109,

    
    
    NSLog(@"event = %d", event.subtype);
    
    if(event.subtype == UIEventSubtypeRemoteControlTogglePlayPause){
        [self Play:event];
    }else if(event.subtype == UIEventSubtypeRemoteControlNextTrack){
        [self Next:event];
    }else if(event.subtype == UIEventSubtypeRemoteControlPreviousTrack){
        [self Prev:event];
    }
    
    
}

- (void) registerForBackgroundNotifications{
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(setInBackgroundFlag)
												 name:UIApplicationWillResignActiveNotification
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(clearInBackgroundFlag)
												 name:UIApplicationWillEnterForegroundNotification
											   object:nil];
}

- (void) setInBackgroundFlag{
    NSLog(@"in background");
	inBackground = true;

}

- (void) clearInBackgroundFlag{
    NSLog(@"No in background");
	inBackground = false;
    
    
}

#pragma mark - etc.

- (UIImage *) artworksForFileAtPath:(Id3db *)id3item{
    UIImage *img = [UIImage imageNamed:@"defaultAlbum.png"];
    
    // for get artwork image
    NSArray *array = [AVMetadataItem metadataItemsFromArray:id3item.asset.commonMetadata
                                                    withKey:AVMetadataCommonKeyArtwork 
                                                   keySpace:AVMetadataKeySpaceCommon];
    
    if([array count] == 0) img = [UIImage imageNamed:@"defaultAlbum.png"];
    
    for(AVMetadataItem *metadata in array) { 
        
        if ([metadata.commonKey isEqualToString:@"artwork"])
        {
            NSLog(@"in Artwork");
            
            // 앨범아트 클래스가 NSDictionary 인 경우와, NSData 자체인 경우가 있음
            if ([metadata.value isKindOfClass:[NSDictionary class]]) {
                NSDictionary *d = [metadata.value copyWithZone:nil];
                img = [UIImage imageWithData:[d objectForKey:@"data"]];
                NSLog(@"img = %f %f", img.size.width, img.size.height);
                
            }else if([metadata.value isKindOfClass:[NSData class]]){
                img = [UIImage imageWithData:[metadata.value copyWithZone:nil]];
                NSLog(@"img = %f %f", img.size.width, img.size.height);
                
            }
            
        }
        
    }
    
    if(self.AlbumArt != nil) [self.AlbumArt release];
    self.AlbumArt = [img copy];
    
    return img;
}

- (void) id3ForFileAtPath:(Id3db *)id3item{

//    AVURLAsset *asset = [[AVURLAsset alloc]initWithURL:[NSURL fileURLWithPath:filepath ] options:nil]; 
    
//    NSArray *formatArray = asset.availableMetadataFormats; // get org.id3
    NSArray *formatArray = id3item.asset.availableMetadataFormats; // get org.id3
    
    // 가사가 있을 경우
    if([[id3item.asset lyrics] length] > 0){
        
        // 가사 있음
        inLyrics = TRUE;
        
        Lyrics.text = [id3item.asset lyrics];
        [Lyrics scrollsToTop];
        
        // 앨범아트 모드일경우 
        if(inAlbumView == TRUE){

//            Lyrics.hidden = FALSE;
//            LyricsView.hidden = FALSE;
            
            // 가사 보기 애니메이션
            [UIView animateWithDuration:0.8 animations:^{
                
//                Lyrics.alpha     = 1;
//                LyricsView.alpha = 0.7;
                        
            }];
        }else{
            [UIView animateWithDuration:0.8 animations:^{
                
//                Lyrics.alpha     = 0;
//                LyricsView.alpha = 0;
                
            }];
        }
        
    }else {
        
        // 가사 없음
        inLyrics = FALSE;
        
        // 가사가 없을 경우 애니메이션
        [UIView animateWithDuration:0.8 animations:^{
        
//            Lyrics.alpha      = 0;
//            LyricsView.alpha  = 0;
        
        }];
    }

    NSString *title, *artist, *albumName;
    title = @"";
    artist = @"Unknown Artist";
    albumName = @"Unknown Album";

    
    if ([formatArray count] == 0 ) {
        SongAlbum.text = albumName;
        SongSinger.text = artist;
        
//        [asset release];
        return;
    }
    
    NSArray *array = [id3item.asset metadataForFormat:[formatArray objectAtIndex:0]]; //for get id3 tags

    for(AVMetadataItem *metadata in array) { 
        if ([metadata.commonKey isEqualToString:@"artwork"]){
            // 앨범아트 추출 못하는 경우가 많아 다른 메소드로 대체 
            NSDictionary *d = [metadata.value copyWithZone:nil];
            UIImage *img = [UIImage imageWithData:[d objectForKey:@"data"]];
            NSLog(@"img %f %f", img.size.width, img.size.height);            
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
    
    if(![title isEqualToString:@""]) SongTitle.text = title;
    
    SongAlbum.text = albumName;
    SongSinger.text = artist;
    
//    [asset release];
    
}

#pragma mark - Audio Session Delegate

- (void)beginInterruption{
 
    NSLog(@"=== Begin Interruption");
    
    if(self.player.rate > 0.0){
        NSLog(@"=== Interrupted while playing : On");
        self.interruptedWhilePlaying = YES;
        [self Play:@""]; // pause
    }
    
    UInt32 routeSize = sizeof (CFStringRef);
    CFStringRef route;
    
    AudioSessionGetProperty (
                             kAudioSessionProperty_AudioRoute,
                             &routeSize,
                             &route
                             );

    // save last play route status
    self.RouteInfo = (NSString *)route;
    
    

    

}


- (void)endInterruptionWithFlags:(NSUInteger)flags{
    NSLog(@"=== End Interruption with Flag : %d", flags);
    
    UInt32 routeSize = sizeof (CFStringRef);
    CFStringRef route;
    
    AudioSessionGetProperty (
                             kAudioSessionProperty_AudioRoute,
                             &routeSize,
                             &route
                             );
    


    // 리쥼할 때 이전에 플레이되었었는지 그리고 플레이 라우팅 모드가 인터럽트 받기 전과 일치하는지 검사하여 리쥼
    if (self.interruptedWhilePlaying == YES 
        && [self.RouteInfo isEqualToString:(NSString *)route] == TRUE
        && cfgData.OnInterruptResume == TRUE)
    {
        NSLog(@"--- Play Start!");
        self.interruptedWhilePlaying = NO;
        [self Play:@""];
    }

}

//
//- (void)endInterruptionWithFlags:(NSUInteger)flags{
//    
//    NSLog(@"=== End Interruption, Flags : %d", flags);
//    
//    UInt32 routeSize = sizeof (CFStringRef);
//    CFStringRef route;
//    
//    AudioSessionGetProperty (
//                             kAudioSessionProperty_AudioRoute,
//                             &routeSize,
//                             &route
//                             );
//    
//    // audio resume when play stopped from headphone mode, 
//    if(self.interruptedWhilePlaying == YES 
//       && [@"Headphone" isEqualToString:(NSString *)route] == TRUE)
//    {
//        NSLog(@"=== Headphone && Interrupted while playing : Off");
//        self.interruptedWhilePlaying = FALSE;
//        [self Play:nil];
//    }
//    
////    else if(self.interruptedWhilePlaying == YES && flags == 1){
////
////        NSLog(@"=== Headphone && Interrupted while playing : Off");
////        self.interruptedWhilePlaying = FALSE;
////        [self Play:nil];
////
////        
////    }
//        
//}

- (void)ScrollToCurrentCell{
    
    // Auto Scroll set
    int scrollindex = index - 1;
    if (scrollindex < 0) scrollindex = 0;
    
    [listTable.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:scrollindex inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];

}

- (void)CancelAutoScroll{
    
//    [self canPerformAction:@selector(ScrollToCurrentCell) withSender:nil];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(ScrollToCurrentCell) object:nil];
    
    
}

@end

