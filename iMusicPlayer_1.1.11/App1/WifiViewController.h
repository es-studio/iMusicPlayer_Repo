//
//  WifiViewController.h
//  iMusicPlayer
//
//  Created by Han Eunsung on 12. 1. 14..
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HTTPServer;

@interface WifiViewController : UITableViewController{
    
    HTTPServer  *httpsvr;

}

@property (nonatomic, retain) HTTPServer            *httpsvr;
@property (nonatomic)         BOOL                   onWifi;
@property (nonatomic, retain) NSMutableDictionary   *wifiDic;
@property (nonatomic, retain) NSArray               *wifiKeys;
@property (nonatomic ,retain) UISwitch              *mySwitch;

- (void) initHTTPServer;

- (BOOL) checkWiFi;

- (NSString*) getAddress;

- (BOOL) canBecomeFirstResponder;

- (void) remoteControlReceivedWithEvent:(UIEvent *)event;

- (void) switchToggled:(id)sender;

- (void) AlertView;

- (void) Refresh;

@end
