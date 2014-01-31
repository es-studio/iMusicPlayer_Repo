//
//  PlaylistTableCell.m
//  App1
//
//  Created by Han Eunsung on 11. 10. 12..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PlaylistTableCell.h"

@implementation PlaylistTableCell

@synthesize NumLabel;
@synthesize HereImage;
@synthesize TitleLabel;
@synthesize TimeLabel;
@synthesize BarImage3;
@synthesize BarImage4;


- (void)dealloc {
    //NSLog(@"PlayListTrableCell dealloc");
    [NumLabel release];
    [HereImage release];
    [BarImage3 release];
    [BarImage4 release];
    [TitleLabel release];
    [TimeLabel release];
    [super dealloc];
}
@end
