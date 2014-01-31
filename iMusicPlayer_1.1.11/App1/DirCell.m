//
//  DirCell.m
//  App1
//
//  Created by Han Eunsung on 11. 10. 9..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DirCell.h"

@implementation DirCell
@synthesize CellImage;
@synthesize Label;



#pragma mark - View lifecycle


- (void)dealloc {
    [CellImage release];
    [Label release];
    [super dealloc];
}
@end
