//
//  WifiViewController.m
//  iMusicPlayer
//
//  Created by Han Eunsung on 12. 1. 14..
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#include <ifaddrs.h>
#include <arpa/inet.h>

#import "HTTPServer.h"
#import "MyHTTPConnection.h"
#import "Reachability.h"
#import "WifiViewController.h"
#import "MyMusicPlayer.h"

@implementation WifiViewController

@synthesize wifiDic;
@synthesize wifiKeys;
@synthesize onWifi;
@synthesize mySwitch;
@synthesize httpsvr;


#pragma mark - Remote control

- (BOOL) canBecomeFirstResponder{
    //    return firstResponder;
    return YES;
}


- (void) remoteControlReceivedWithEvent:(UIEvent *)event{
    
    
    NSLog(@"event = %d", event.subtype);
    
    MyMusicPlayer *mplayer = [MyMusicPlayer sharedMusicPlayer];
    
    if([mplayer.playlist count] > 0){
        
        if(event.subtype == UIEventSubtypeRemoteControlTogglePlayPause){
            [mplayer Play:event];
            //        [self Play:event];
        }else if(event.subtype == UIEventSubtypeRemoteControlNextTrack){
            
            [mplayer Next:event];
            //        [self Next:event];
        }else if(event.subtype == UIEventSubtypeRemoteControlPreviousTrack){
            [mplayer Prev:event];
            //        [self Prev:event];
        }
        
    }
}


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
//    self.navigationController.navigationBar.tintColor = [UIColor purpleColor];

    self.wifiDic
    = [[NSMutableDictionary alloc] initWithObjectsAndKeys:       
       [[NSMutableArray alloc] initWithObjects:
        @"Enable Wi-Fi Transfer", 
        @"Wifi Status", nil],
        
//        @"Server IP", nil], 
       
       @"Wi-fi Configuration",
       
//       [[NSArray alloc] initWithObjects:
//        @"Clear AlbumArt Cache", 
//        @"Clear ID3 Database", 
//        @"Clear Playlist Database", nil], 
//       
//       @"Clear Data",
       
       nil];
    
    self.wifiKeys = [self.wifiDic allKeys];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    
    // http 서버 동작 중일경우 wifi 중지 시켰을 때 
    self.onWifi = FALSE;
    mySwitch.on = FALSE;
    
    // wifi status
    UITableViewCell *cell1 = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    cell1.detailTextLabel.text = [self checkWiFi] ? @"On": @"Off";
    
    
    
    [self.tableView reloadData];

//    // server ip
//    UITableViewCell *cell2 = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
//    cell2.detailTextLabel.text 
//    = [self checkWiFi] ? [NSString stringWithFormat:@"http://%@:%d",  [self getAddress], httpsvr.port] : @"Off";
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self canBecomeFirstResponder];

    
//    NSLog(@"%d", httpsvr);
    
//    [self.tableView.tableFooterView setBackgroundColor:[UIColor blueColor]];
    

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    
    [UIApplication sharedApplication].idleTimerDisabled = NO;
//    [httpsvr stop];
//    self.onWifi = FALSE;

}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if(self.onWifi == TRUE){
    
        // off wifi
        [httpsvr stop];
        [httpsvr release];
        self.onWifi = FALSE;
        
    }
    
    
    NSMutableArray *arr = [self.wifiDic objectForKey:@"Wi-fi Configuration"];
    
    if([arr containsObject:@"Server IP"] == TRUE){
        [arr removeObject:@"Server IP"];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:2 inSection:0], nil] withRowAnimation:UITableViewRowAnimationAutomatic];
        
    };

    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return [self.wifiKeys count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    NSString *key = [self.wifiKeys objectAtIndex:section];
    NSArray *rows = [self.wifiDic objectForKey:key];
    return [rows count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    NSUInteger section = [indexPath section];
    NSUInteger row = [indexPath row];
    
    NSString *key = [self.wifiKeys objectAtIndex:section];
    NSArray *SectionArray = [self.wifiDic objectForKey:key];
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier] autorelease];
    }
    
    
    // Configure the cell...
    
    cell.textLabel.text = [SectionArray objectAtIndex:row];
    
    
    if(section == 0){
        
        switch (row) {
            case 0:
            {
                mySwitch = [[[UISwitch alloc] initWithFrame:CGRectZero] autorelease];
                [cell addSubview:mySwitch];
                cell.accessoryView = mySwitch;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                [mySwitch addTarget:self action:@selector(switchToggled:) forControlEvents:UIControlEventValueChanged];

                mySwitch.tag = 5000;

                mySwitch.on = self.onWifi;
                
            }
                break;
                
            case 1:
                
                cell.detailTextLabel.text = [self checkWiFi] ? @"On": @"Off";
                
                break;
                
            case 2:
            {
                cell.detailTextLabel.text 
                = [self checkWiFi] ? [NSString stringWithFormat:@"http://%@:%d",  [self getAddress], httpsvr.port] : @"Off";                
                cell.detailTextLabel.font = [UIFont systemFontOfSize:14];

            }
                
            default:
                break;
        }
        
    }

    return cell;
}




#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

- (void)initHTTPServer{
    
    NSString *root = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0];
    
    // http server 초기화 
	httpsvr = [HTTPServer new];
    
    // http server 기본 설정 
	[httpsvr setType:@"_http._tcp."];
	[httpsvr setConnectionClass:[MyHTTPConnection class]];
	[httpsvr setDocumentRoot:[NSURL fileURLWithPath:root]];
    [httpsvr setPort:8080];
    
    
}

- (NSString *)getAddress
{
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0)
    {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL)
        {
            if(temp_addr->ifa_addr->sa_family == AF_INET)
            {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"])
                {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    // Free memory
    freeifaddrs(interfaces);
    
    return address;
}

-(BOOL) checkWiFi{
    
    BOOL onWiFi;
    
    NetworkStatus netStatus = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
    
    
    switch (netStatus) {
        case NotReachable:
            onWiFi = false;
            break;
            
        case ReachableViaWiFi:            
            onWiFi = TRUE;            
            break;
            
        default:
            onWiFi = FALSE;
            break;
    }
    
    return onWiFi;
    
}

- (void) switchToggled:(id)sender {
    //a switch was toggled.  
    //maybe use it's tag property to figure out which one
    UISwitch *sw = (UISwitch *)sender;
    
    switch (sw.tag) {
        case 5000:
                        
            if(sw.isOn == TRUE) {
                
                self.onWifi = TRUE;
                
                if([self checkWiFi] == FALSE){
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"HTTP Server Fail" message:@"Please turn on WiFi before starting HTTP server" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                    [alert show];
                    [alert autorelease];
                    sw.on = FALSE;
                    return;
                    
                }
                
                // init http
                [self initHTTPServer];
                
                // httpserver 시작 
                NSError *error;
                if(![httpsvr start:&error])
                {
                    NSLog(@"Error starting HTTP Server: %@", error);
                }
                
                
                NSMutableArray *arr = [self.wifiDic objectForKey:@"Wi-fi Configuration"];
                
                [arr addObject:@"Server IP"];
                
                
                [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:2 inSection:0], nil] withRowAnimation:UITableViewRowAnimationAutomatic];
                
                [self performSelector:@selector(AlertView) withObject:nil afterDelay:0.5];
                [self performSelector:@selector(Refresh) withObject:nil afterDelay:1];
            }else{  

                self.onWifi = FALSE;
                [httpsvr stop];
                
                NSMutableArray *arr = [self.wifiDic objectForKey:@"Wi-fi Configuration"];
                
                [arr removeObject:@"Server IP"];
                
                
                [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:2 inSection:0], nil] withRowAnimation:UITableViewRowAnimationAutomatic];

                [self performSelector:@selector(Refresh) withObject:nil afterDelay:0.5];
                
                
            }
            break;
                        
        default:
            break;
    }
    
    
}

- (void)Refresh{
    
    [self.tableView reloadData];
}

- (void)AlertView{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Wi-Fi Transfer"
                                                    message:
                          @"You can upload your files to iMusicPlayer.\n\n"
                          @"1. Open your PC web browser.\n"
                          @"2. Type the \"Server IP\" address into the URL inputbox.\n"
                          @"3. Upload your music files through browser.\n\n"
                          @"Note. Please use a webkit browser. ex) Chrome, Safari, Firefox ..."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles: nil];
    [alert show]; 
    [alert release];
    
//    ((UILabel*)[[alert subviews] objectAtIndex:2]).textAlignment = UITextAlignmentLeft;
//    ((UILabel*)[[alert subviews] objectAtIndex:2]).font = [UIFont systemFontOfSize:4];
    

//    UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Clear AlbumArt?" message:@"This will remove AlbumArt Cache" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];    

    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
//    switch (section) {
//        case 0:
//            
//            
//            return 
//            @"You can upload your files to iMusicPlayer.\n\n"
//            @"1. Open your PC web browser.\n"
//            @"2. Type the \"Server IP\" address into the URL inputbox.\n"
//            @"3. Upload your music files to browser.\n\n"
//            @"NOTE.1\nIf you leave this tab, Wi-Fi File Transfer will be turn off.\n"
//            @"NOTE.2\nIE9 does not support Drag & Drop feature. Please use another browser.";
//            break;
//            
//        default:
//            break;
//    }
//    
//    
//    
    return nil;    
    
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{

//    for (UIView *view in self.tableView.tableFooterView.subviews) {
//        NSLog(@"class : %@", [view class]);
//    }
    
    

    
    switch (section) {
        case 0:
            
            
            if (self.onWifi == TRUE) {
                return 
                @"If you leave this tab, Wi-Fi File Transfer will be turn off.";

            }else{
                

                return 
                @"Please keep Wi-Fi Connection, before running this feature.";

            }
            
//            @"You can upload your files to iMusicPlayer.\n\n";
//            @"1. Open your PC web browser.\n"
//            @"+ 2. Type the \"Server IP\" address into    +\n"
//            @"+    the URL inputbox.                               +\n"
//            @"+ 3. Upload your music files to browser. +\n\n"
//            @"NOTE.1 If you leave this tab, Wi-Fi File Transfer will be turn off.\n"
//            @"NOTE.2 IE9 does not support Drag & Drop feature. Please use another browser.";
            break;

        default:
            break;
    }
    
    
    
    return nil;
}




@end
