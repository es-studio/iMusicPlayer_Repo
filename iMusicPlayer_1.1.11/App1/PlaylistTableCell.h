//
//  PlaylistTableCell.h
//  App1
//
//  Created by Han Eunsung on 11. 10. 12..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlaylistTableCell : UITableViewCell {
    UILabel *NumLabel;
    UIImageView *HereImage;
    UILabel *TitleLabel;
    UILabel *TimeLabel;
}

@property (nonatomic, retain) IBOutlet UILabel *NumLabel;
@property (nonatomic, retain) IBOutlet UIImageView *HereImage;
@property (nonatomic, retain) IBOutlet UIImageView *BarImage3;
@property (nonatomic, retain) IBOutlet UIImageView *BarImage4;
@property (nonatomic, retain) IBOutlet UILabel *TitleLabel;
@property (nonatomic, retain) IBOutlet UILabel *TimeLabel;

@end
