//
//  FSItemCell.m
//  FSWalker
//
//  Created by Nicolas Seriot on 17.08.08.
//  Copyright 2008 Sen:te. All rights reserved.
//

#import "FSItemCell.h"
#import "FileInfo.h"

@implementation FSItemCell

@synthesize iconButton;
@synthesize label;
@dynamic fsItem;
@synthesize size;


- (void)setFsItem:(FSItem *)item {
	[item retain];
	[fsItem release];
	fsItem = item;
	
	label.text = item.filename;
	[iconButton setImage:item.icon forState:UIControlStateNormal];
	
	self.accessoryType = item.canBeFollowed ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
	
    // cell text color
//	label.textColor = [item.posixPermissions intValue] ? [UIColor whiteColor] : [UIColor lightGrayColor];
  	//label.textColor = [item.posixPermissions intValue] ? [UIColor blackColor] : [UIColor darkGrayColor];  
    
    // 파일의 사이즈 출력----------------------------------------------
    NSMutableString *strSize = [[NSMutableString alloc] init];

    long long s = [item.fileSize longLongValue];
    if (s < 1024) {
        [strSize appendFormat:@"%d Bytes", s];
      
    }else if(s < 1024 * 1024){
        float fsize = s / 1024;
        [strSize appendFormat:@"%.1f KB", fsize];
        
    }else if(s < 1024 * 1024 * 1024){
        float fsize = s / 1024.0 / 1024.0;
        [strSize appendFormat:@"%.1f MB", fsize];
        
    }
//    size.text = strSize;
    
//    size.text = item.canBeFollowed ? 
//    [NSString stringWithFormat:@"%d", [fsItem.children count]]: 

    if (item.canBeFollowed) {
        size.text = @"";                
        
    }else{
        size.text = strSize;        
    }
    

    size.textColor = [UIColor grayColor];
    [strSize release];
    // -----------------------------------------------------------
}

- (FSItem *)fsItem {
	return fsItem;
}

- (void)dealloc {
	[fsItem release];
	[iconButton release];
	[label release];
	[super dealloc];
}

- (IBAction)showInfo:(id)sender {

    NSLog(@"showInfo Call");
	[[NSNotificationCenter defaultCenter] postNotificationName:@"FileInfo" object:fsItem];
}



@end
