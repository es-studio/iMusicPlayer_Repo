//
//  DirCell.h
//  App1
//
//  Created by Han Eunsung on 11. 10. 9..
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DirCell : UITableViewCell {
    UIImageView *CellImage;
    UILabel     *Label;
}

@property (nonatomic, retain) IBOutlet UIImageView *CellImage;

@property (nonatomic, retain) IBOutlet UILabel *Label;


@end
