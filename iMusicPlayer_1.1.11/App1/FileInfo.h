//
//  FileInfo.h
//  iMusicPlayer
//
//  Created by Han Eunsung on 12. 1. 22..
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import "FSItem.h"

#import <UIKit/UIKit.h>
//#import <QuickLook/QuickLook.h>


@interface FileInfo : UITableViewController<UIDocumentInteractionControllerDelegate>

@property (nonatomic, retain) UIDocumentInteractionController *docInteractionController;



@property (nonatomic, retain) FSItem *fsItem;
@property (nonatomic, retain) NSDictionary *infoDic;
@property (nonatomic, retain) NSArray *infoKeys;
@property (nonatomic, retain) NSDictionary *attribute;
@property (nonatomic)         long long unsigned total_size;
@property (nonatomic)         int total;

@property (nonatomic, retain) NSMutableArray *id3dbArray;

- (id)initWithFilePath:(FSItem *)item;

- (void) dismissThis;

- (void) alertChangeName;

@end


