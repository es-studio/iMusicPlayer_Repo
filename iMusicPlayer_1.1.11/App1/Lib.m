//
//  Lib.m
//  iMusicPlayer
//
//  Created by Han Eunsung on 11. 10. 29..
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Lib.h"
#import "LibraryDetailView.h"
#import "MyMusicPlayer.h"
#import "LoadingView.h"

#import "Id3db.h"
#import "LibraryData.h"

#import <sqlite3.h>



@implementation Lib

@synthesize PlayListKeysArray;
@synthesize FilteredPlayList;
@synthesize DetailView;
@synthesize libData;
@synthesize loadingView;

//@synthesize DicPlayListDB;


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


- (void)didReceiveMemoryWarning{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad{
    [super viewDidLoad];
    
    NSLog(@"Lib ViewDidLoad");
//    [self LoadPlaylist];

}

- (void)viewDidUnload{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    NSLog(@"Lib Class Unloaded");
}


- (void)dealloc{
    
    NSLog(@"Lib Class dealloc");
    
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    // player check
    MyMusicPlayer *mmplayer = [MyMusicPlayer sharedMusicPlayer];
    if (mmplayer.player.rate > 0.0) {
        
        
        UIImage *normal = [UIImage imageNamed:@"nowplaying.png"];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.bounds = CGRectMake( 0, 0, normal.size.width, normal.size.height);    
        [button setImage:normal forState:UIControlStateNormal];
        [button addTarget:self action:@selector(showMusic) forControlEvents:UIControlEventTouchUpInside];    
        UIBarButtonItem *MusicButton = [[UIBarButtonItem alloc] initWithCustomView:button];
        
        self.navigationItem.rightBarButtonItem = MusicButton;
        [MusicButton release];
    }else{
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    [self.PlayListKeysArray release];
    
    if(self.libData == nil) [self LoadingPlayList];
    
//    self.libData = [LibraryData sharedLibrary];

    self.PlayListKeysArray = [[NSMutableArray alloc] initWithObjects:@"Add Playlist...", nil];   
    [self.PlayListKeysArray addObjectsFromArray:[self.libData.PlaylistDB allKeys]];        
    
    

//    NSLog(@"LibraryData = %@",    [self.libData.PlaylistDB allKeys]);
    //[self LoadPlaylist];
    

}

- (void)LoadingPlayList{
    
    
    NSLog(@"Update file info");
    
    self.navigationController.view.userInteractionEnabled = false;
    self.view.userInteractionEnabled = false;
    self.tabBarController.view.userInteractionEnabled = false;
    
    loadingView = [LoadingView loadingViewInView:self.navigationController.view 
                                   withTitle:@"Reading ..."];
    
    [loadingView performSelector:@selector(removeView)
                  withObject:nil
                  afterDelay:300.0];
    
    [NSThread detachNewThreadSelector:@selector(ThreadProcess) 
                             toTarget:self 
                           withObject:nil]; 

}


- (void)ThreadProcess{
    NSAutoreleasePool *autoreleasepool = [[NSAutoreleasePool alloc] init];
    
    //이곳에 처리할 코드를 넣는다.
    

    self.libData = [LibraryData sharedLibrary];
    [loadingView removeView];
    [self.PlayListKeysArray addObjectsFromArray:[self.libData.PlaylistDB allKeys]];        

    [self.tableView reloadData];
    
    self.navigationController.view.userInteractionEnabled = TRUE;
    self.view.userInteractionEnabled = TRUE;
    self.tabBarController.view.userInteractionEnabled = TRUE;
    
    [autoreleasepool release];
    NSLog(@"Thread Done");
    [NSThread exit];
    

    
}



- (void)showMusic{
    MyMusicPlayer *imp = [MyMusicPlayer sharedMusicPlayer];
    imp.hidesBottomBarWhenPushed = TRUE;
    [self.navigationController pushViewController:imp animated:YES];
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.tableView reloadData];
    
    
    // remote control regist
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self canBecomeFirstResponder];

}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    
    
    // save for testing
    [self.libData SavingFileInfo_plst];
    
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSLog(@"count = %d",[self.PlayListKeysArray count]);
    // Return the number of rows in the section.
    return [self.PlayListKeysArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    static NSString *CellIdentifier = @"Cell";
    
    int row = indexPath.row;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    if(row != 0) cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    else cell.accessoryType = UITableViewCellAccessoryNone;

//    NSLog(@"cell = %@", [ArrayPlayList objectAtIndex:row]);
    cell.textLabel.text = [self.PlayListKeysArray objectAtIndex:row];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    int row = indexPath.row;
    if(row == 0 ){
        [self alertMakePlaylist];
        
    }else{
        
        // Row Selection name
        NSString *key = [self.PlayListKeysArray objectAtIndex:row];
        

        self.DetailView = [[LibraryDetailView alloc] initWithKey:key];
        
//        self.DetailView.PlaylistKey = key;
//        self.DetailView.PlaylistArray = [DicPlayListDB objectForKey:key];
           
        [self.navigationController pushViewController:self.DetailView animated:YES];
        [self.DetailView release];
        
        NSLog(@"detailvoew load ");
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];


}

- (void) alertMakePlaylist{
    
    UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"New Playlist" message:@"\n\n" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];

    
    UITextField *myTextField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 55.0, 260.0, 30.0)];
    [myTextField setBackgroundColor:[UIColor whiteColor]];
    [myAlertView addSubview:myTextField];
    
    myTextField.borderStyle = UITextBorderStyleBezel;
    myTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    myTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    myTextField.font = [UIFont systemFontOfSize:18];
    [myTextField becomeFirstResponder];
    
    
    myAlertView.tag = 1000;
    [myAlertView show];
    [myAlertView release];
    [myTextField release];
    
    // set focus
    
    
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if(alertView.tag == 1000 && buttonIndex == 1){
        // array 에 추가 
        UITextField *TextField = [alertView.subviews objectAtIndex:5];
        
        // text null check
        if([TextField.text length] == 0) return;
        
        // exists check
        if([self.PlayListKeysArray containsObject:TextField.text] == TRUE) {
            
            UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Fail" message:@"Cause : Already exists name" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];

            myAlertView.tag = 8000;
            [myAlertView show];
            [myAlertView release];
            return;   
        }
            
        NSLog(@"condition passed");
        [self.PlayListKeysArray addObject:TextField.text];        
        
        // dic 에 추가 
        [self.libData.PlaylistDB setObject:[[NSArray alloc] init] forKey:TextField.text];
        [self.tableView reloadData];
        
        //SQL make
        [self.libData makeSQLPlaylists:TextField.text];
        [self.libData SavingFileInfo_plst];

        NSLog(@"Make PlayList");
    }
    
}

- (void) removePlayListArray:(NSString *)key{
    
    // clear
    [self.libData removePlayListArray:key];
    
}

- (void) removePlayListDictionary:(NSString *)key{

    // delete
    [self.libData removePlayListArray:key];
    
    [self.PlayListKeysArray removeObject:key];

    
}
@end

