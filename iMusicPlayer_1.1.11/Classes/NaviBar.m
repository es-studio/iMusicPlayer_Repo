//
//  NaviBar.m
//  iMusicPlayer
//
//  Created by Han Eunsung on 12. 3. 3..
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NaviBar.h"

static NSMutableDictionary *navigationBarImages = NULL;

@implementation NaviBar

@synthesize toggleNaviIamge;

//Overrider to draw a custom image
+ (void)initImageDictionary
{
    if(navigationBarImages==NULL){
        navigationBarImages=[[NSMutableDictionary alloc] init];
    }
}

- (void)drawRect:(CGRect)rect
{
    
    UIImage *image;
    
    if(self.toggleNaviIamge == TRUE){
        image = [UIImage imageNamed:@"Navi.png"];
    }else{
        image = [UIImage imageNamed:@"NaviBlue.png"];
    }
    
    [image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    

    

}

//Allow the setting of an image for the navigation bar
@end 

