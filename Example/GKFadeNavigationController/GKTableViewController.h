//
//  GKTableViewController.h
//  
//
//  Created by GK on 15.06.24..
//
//

#import <UIKit/UIKit.h>
#import <GKFadeNavigationController/GKFadeNavigationController.h>

@interface GKTableViewController : UITableViewController <UIScrollViewDelegate, GKFadeNavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageBottomConstraint;

@end
