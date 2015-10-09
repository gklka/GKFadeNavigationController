//
//  GKFadeNavigationController.h
//  
//
//  Created by GK on 15.06.25..
//
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, GKFadeNavigationControllerNavigationBarVisibility) {
    GKFadeNavigationControllerNavigationBarVisibilityUndefined = 0, // Initial value, don't set this
    GKFadeNavigationControllerNavigationBarVisibilitySystem = 1, // Use System navigation bar - Don't use this directly!
    GKFadeNavigationControllerNavigationBarVisibilityHidden = 2, // Use custom navigation bar and hide it
    GKFadeNavigationControllerNavigationBarVisibilityVisible = 3 // Use custom navigation bar and show it
};


@protocol GKFadeNavigationControllerDelegate <NSObject>

/**
 You should give back the correct enum value if the controller asks you
 */
- (GKFadeNavigationControllerNavigationBarVisibility)preferredNavigationBarVisibility;

@end


@interface GKFadeNavigationController : UINavigationController

/**
 You can ask GKFadeNavigationController to update it's navigation bar visibility using this function. Then the controller will ask its topViewController (in best scenario, a controller, which conforms to the GKFadeNavigationControllerDelegate protocol), then shows or hides the navigation bar based on what the -preferredNavigationBarVisibility returns in the controller.
 
 @param animated Play animation or make the changes instantly
 */
- (void)setNeedsNavigationBarVisibilityUpdateAnimated:(BOOL)animated;

@end
