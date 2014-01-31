//
//  AlbumArtView.h
//  iMusicPlayer
//
//  Created by Han Eunsung on 12. 2. 16..
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlbumArtView : UIViewController

@property (nonatomic, retain) IBOutlet UIImageView *albumImage;

@property (nonatomic ,retain) IBOutlet UILabel *titleLabel;
@property (nonatomic ,retain) IBOutlet UILabel *artistLabel;
@property (nonatomic ,retain) IBOutlet UILabel *albumLabel;

@end
