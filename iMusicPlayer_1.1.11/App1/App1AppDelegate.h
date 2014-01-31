//
//  App1AppDelegate.h
//  App1
//
//  Created by Eunsung Han on 11. 9. 12..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FileTable;

@interface App1AppDelegate : NSObject <UIApplicationDelegate> {
    
    UIWindow *window;
//    subUIWindow *window;
    UITabBarController *tab;
    FileTable *filetable;
        
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tab;
@property (nonatomic, retain) IBOutlet FileTable *filetable;

    
- (void) insertField;

- (int) checkMP3:(NSString *)name;

- (BOOL) checkFileChanges;

- (BOOL) canBecomeFirstResponder;

- (void) UpdateFileInfo;

- (void) remoteControlReceivedWithEvent:(UIEvent *)event;

@end
