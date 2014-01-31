//
//  NaviBar.h
//  iMusicPlayer
//
//  Created by Han Eunsung on 12. 3. 3..
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

//@interface UINavigationBar(CustomImage)
@interface NaviBar : UINavigationBar
    
@property (nonatomic) BOOL toggleNaviIamge;

+ (void) initImageDictionary;
- (void) drawRect:(CGRect)rect;

@end

