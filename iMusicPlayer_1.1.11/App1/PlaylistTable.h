//
//  PlaylistTable.h
//  App1
//
//  Created by Han Eunsung on 11. 10. 11..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MyMusicPlayer;

@interface PlaylistTable : UITableViewController<UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>{
    MyMusicPlayer *mplayer;
    UIImage       *here;
}

@property (nonatomic) CGColorRef cc;
@property (nonatomic, retain) MyMusicPlayer *mplayer;
@property (nonatomic, retain) UIImage       *here;

@end
