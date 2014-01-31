//
//  PlaylistTable.m
//  App1
//
//  Created by Han Eunsung on 11. 10. 11..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PlaylistTable.h"
#import "PlaylistTableCell.h"
#import <QuartzCore/QuartzCore.h>

#import "MyMusicPlayer.h"
#import "Id3db.h"


@implementation PlaylistTable

@synthesize mplayer;
@synthesize here;
@synthesize cc;


#pragma mark - View lifecycle


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    
    self.view.backgroundColor = [UIColor clearColor];
    self.tableView.separatorColor = [UIColor darkGrayColor];
    

//    
//    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:item] options:nil];
//    
//    int duration = asset.duration.value / asset.duration.timescale;
//    
//    cell.TimeLabel.text = [NSString stringWithFormat:@"%02d:%02d", duration / 60, duration % 60];
//    
//    duration = 0;
//    [asset release];

}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    return [mplayer.playlist count];

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PlaylistCell";
    int row = [indexPath row];    
    
    PlaylistTableCell *cell = (PlaylistTableCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
//    PlaylistTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
         cell = (PlaylistTableCell *)[[[NSBundle mainBundle] loadNibNamed:@"PlaylistTableCell" owner:self options:nil] lastObject];

    }    
    
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    if(row == 0) cell.BarImage4.hidden = FALSE;
    if(row == mplayer.index) cell.HereImage.hidden = FALSE;    
    
    cc = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:0.3].CGColor ;    
    
    cell.BarImage3.layer.borderColor      = cc;
    cell.BarImage4.layer.borderColor      = cc;
    cell.backgroundView.layer.borderColor = cc;

    cell.BarImage3.layer.borderWidth      = 1;
    cell.BarImage4.layer.borderWidth      = 1;
    cell.backgroundView.layer.borderWidth = 0;
    
    Id3db *id3item = [mplayer.playlist objectAtIndex:row];
    

    cell.TitleLabel.text = id3item.title;
    cell.TimeLabel.text = [NSString stringWithFormat:@"%02d:%02d", (int)id3item.duration / 60, (int)id3item.duration % 60];
    cell.NumLabel.text = [NSString stringWithFormat:@"%d.", row+1];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    [mplayer PlayAtIndex:[indexPath row]];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
//    NSLog(@"Will begin dragging");
    [mplayer CancelAutoScroll];
}


@end
