//
//  GKFadeNavigationController.m
//  
//
//  Created by GK on 15.06.25..
//
//

#import "GKFadeNavigationController.h"

#define kGKDefaultVisibility YES
#define IS_OS_OLDER_THAN_IOS_8 [[[UIDevice currentDevice] systemVersion] floatValue] <= 8.f

@interface GKFadeNavigationController () <UINavigationControllerDelegate>

@property (nonatomic, strong) UIVisualEffectView *visualEffectView;

@property (nonatomic) GKFadeNavigationControllerNavigationBarVisibility navigationBarVisibility;
@property (nonatomic, strong) UIColor *originalTintColor;

@end


@implementation GKFadeNavigationController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Base values
    self.originalTintColor = [self.navigationBar tintColor];
    self.delegate = self;

    [self setupCustomNavigationBar];
    self.navigationBarVisibility = GKFadeNavigationControllerNavigationBarVisibilityVisible;
    
    [self updateNavigationBarVisibilityForController:self.topViewController animated:NO];
}

- (void)viewDidLayoutSubviews {
    CGFloat navigationBarHeight = CGRectGetHeight(self.navigationBar.frame);
    CGFloat statusBarHeight = [self statusBarHeight];
    
    self.visualEffectView.frame = CGRectMake(0, -statusBarHeight, self.view.frame.size.width, navigationBarHeight+statusBarHeight);
}

#pragma mark - Accessors

- (void)setNavigationBarVisibility:(GKFadeNavigationControllerNavigationBarVisibility)navigationBarVisibility {
    [self setNavigationBarVisibility:navigationBarVisibility animated:NO];
}

- (NSString *)stringForNavigationBarVisibility:(GKFadeNavigationControllerNavigationBarVisibility)visibility {
    switch (visibility) {
        case GKFadeNavigationControllerNavigationBarVisibilitySystem:
            return @"system";
        case GKFadeNavigationControllerNavigationBarVisibilityVisible:
            return @"visible";
        case GKFadeNavigationControllerNavigationBarVisibilityHidden:
            return @"hidden";
        default:
            return @"unknown";
    }
}

- (void)setNavigationBarVisibility:(GKFadeNavigationControllerNavigationBarVisibility)navigationBarVisibility animated:(BOOL)animated {
    
    if (_navigationBarVisibility == navigationBarVisibility) {
//         NSLog(@"Changing navigaiton bar is not required");
        return;
    }
    
//    NSLog(@"setNavigationBarVisibility: from %@ to %@ animated: %@", [self stringForNavigationBarVisibility:_navigationBarVisibility], [self stringForNavigationBarVisibility:navigationBarVisibility], animated ? @"YES" : @"NO");

    if (_navigationBarVisibility == GKFadeNavigationControllerNavigationBarVisibilitySystem) {
        // We have system navigation bar
        
        if (navigationBarVisibility == GKFadeNavigationControllerNavigationBarVisibilityVisible) {
            
            // We have a system navigation bar and we transition to visible
            [self setupCustomNavigationBar];
            
        } else if (navigationBarVisibility == GKFadeNavigationControllerNavigationBarVisibilityHidden) {
            
            // We have a system navigation bar and we transition to hidden
            [self setupCustomNavigationBar];
            [self showCustomNavigationBar:NO withFadeAnimation:animated];
        }
        
    } else if (_navigationBarVisibility == GKFadeNavigationControllerNavigationBarVisibilityHidden) {
        // We have a custom navigation bar

        if (navigationBarVisibility == GKFadeNavigationControllerNavigationBarVisibilitySystem) {
            
            // We have a custom, hidden navigation bar, we animate back then transition to custom
            [self showCustomNavigationBar:YES withFadeAnimation:animated];
            [self setupSystemNavigationBar];
            
        } else if (navigationBarVisibility == GKFadeNavigationControllerNavigationBarVisibilityVisible) {
            
            // We have a custom, hidden navigation bar, we animate it back
            [self showCustomNavigationBar:YES withFadeAnimation:animated];
            
        }
    } else if (_navigationBarVisibility == GKFadeNavigationControllerNavigationBarVisibilityVisible) {
        
        if (navigationBarVisibility == GKFadeNavigationControllerNavigationBarVisibilitySystem) {
            
            // We have a visible custom navigation bar, we just have to replace it
            [self setupSystemNavigationBar];
            
        } else if (navigationBarVisibility == GKFadeNavigationControllerNavigationBarVisibilityHidden) {
            
            // We have a visible custom navigation bar which we need to hide
            [self showCustomNavigationBar:NO withFadeAnimation:animated];
        }

    }
    
    if (navigationBarVisibility == GKFadeNavigationControllerNavigationBarVisibilityUndefined) {
        NSLog(@"Error: This should not happen: somebody tried to transition from System/Hidden/Visible state to Undefined");
    }
    
    _navigationBarVisibility = navigationBarVisibility;
}

- (UIVisualEffectView *)visualEffectView {
    if (!_visualEffectView) {
        // Create a the fake navigation bar background
        UIVisualEffect *blurEffect;
        if ([self isNavigationStyleBlack]) {
            blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        } else {
            blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
        }

        CGFloat navigationBarHeight = CGRectGetHeight(self.navigationBar.frame);
        CGFloat statusBarHeight = [self statusBarHeight];

        _visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        _visualEffectView.frame = CGRectMake(0, -statusBarHeight, self.view.frame.size.width, navigationBarHeight+statusBarHeight);
        _visualEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _visualEffectView.userInteractionEnabled = NO;
        
        // Shadow line
        UIView *shadowView = [[UIView alloc] initWithFrame:CGRectMake(0, navigationBarHeight+statusBarHeight-0.5, self.view.frame.size.width, 0.5f)];
        shadowView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2f];
        shadowView.autoresizingMask = UIViewAutoresizingFlexibleWidth;

        [_visualEffectView.contentView addSubview:shadowView];
    }
    
    return _visualEffectView;
}


/**
 Returns the current status bar height, this might be different that 20pt, depending on the device model, orientation and other
 factors like incomming call (in iPhone X Portrait the status bar height is 44pt). See http://stackoverflow.com/questions/12991935/how-to-programmatically-get-ios-status-bar-height/16598350#16598350

 @return The current status bar height
 */
- (CGFloat)statusBarHeight {
    CGSize statusBarSize = [[UIApplication sharedApplication] statusBarFrame].size;
    //Check for the MIN dimention is the easiest way to get the correct height for the current orientation
    return MIN(statusBarSize.width, statusBarSize.height);
}

#pragma mark - UI support

- (UIStatusBarStyle)preferredStatusBarStyle {
    if (self.navigationBarVisibility == GKFadeNavigationControllerNavigationBarVisibilityHidden) {
        return UIStatusBarStyleLightContent;
    } else {
        if ([self isNavigationStyleBlack]) {
            return UIStatusBarStyleLightContent;
        } else {
            return UIStatusBarStyleDefault;
        }
    }
}

#pragma mark - <UINavigationControllerDelegate>

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [self updateNavigationBarVisibilityForController:viewController animated:animated];

    // This code is responsible for adjusting the correct navigation bar style when the user starts a side swipe gesture, but does not finish it.
    id<UIViewControllerTransitionCoordinator> transitionCoordinator = navigationController.topViewController.transitionCoordinator;
    [transitionCoordinator notifyWhenInteractionEndsUsingBlock:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        
        if ([context isCancelled]) {
            UIViewController *sourceViewController = [context viewControllerForKey:UITransitionContextFromViewControllerKey];
            [self updateNavigationBarVisibilityForController:sourceViewController animated:NO];
        }
        
    }];
}

#pragma mark - Core functions

/**
 Add custom navigation bar background, and set the colors for a hideable navigation bar
 */
- (void)setupCustomNavigationBar {
    // Hide the original navigation bar's background
    [self.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.translucent = YES;
    self.navigationBar.shadowImage = [UIImage new];
    
    [self.navigationBar addSubview:self.visualEffectView];
    [self.navigationBar sendSubviewToBack:self.visualEffectView];
}

/**
 Remove custom navigation bar background, and reset to the system default
 */
- (void)setupSystemNavigationBar {
    [self.visualEffectView removeFromSuperview];
    
    // Revert to original values
    [self.navigationBar setBackgroundImage:[[UINavigationBar appearance] backgroundImageForBarMetrics:UIBarMetricsDefault] forBarMetrics:UIBarMetricsDefault];
    [self.navigationBar setTranslucent:YES];
    [self.navigationBar setShadowImage:[[UINavigationBar appearance] shadowImage]];
    [self.navigationBar setTitleTextAttributes:[[UINavigationBar appearance] titleTextAttributes]];
    [self.navigationBar setTintColor:self.originalTintColor];
}

/**
 Determines if the given view controller conforms to GKFadeNavigationControllerDelegate or not. If conforms, asks it about the desired navigation bar visibility (visible or hidden). If it does not conform, then falls back to system navigation controller.
 
 @param viewController The view controller which will be presented
 @param animated Present using animation or instantly
 */
- (void)updateNavigationBarVisibilityForController:(UIViewController *)viewController animated:(BOOL)animated {
    GKFadeNavigationControllerNavigationBarVisibility visibility = GKFadeNavigationControllerNavigationBarVisibilitySystem;
    
    if ([viewController conformsToProtocol:@protocol(GKFadeNavigationControllerDelegate)]) {
        if ([viewController respondsToSelector:@selector(preferredNavigationBarVisibility)]) {
            visibility = (GKFadeNavigationControllerNavigationBarVisibility)[viewController performSelector:@selector(preferredNavigationBarVisibility)];
        }
    }

    [self setNavigationBarVisibility:visibility animated:animated];
}

/**
 Show or hide the navigation custom navigation bar

 @param show If YES, the navigation bar will be shown. If no, it will be hidden.
 @param animated Animate the change or not
 */
- (void)showCustomNavigationBar:(BOOL)show withFadeAnimation:(BOOL)animated {
    [UIView animateWithDuration:(animated ? 0.2 : 0) animations:^{
        if (show) {
            self.visualEffectView.alpha = 1;
            self.navigationBar.tintColor = [self originalTintColor];
            [self.navigationBar setTitleVerticalPositionAdjustment:0 forBarMetrics:UIBarMetricsDefault];
            [self.navigationBar setTitleVerticalPositionAdjustment:0 forBarMetrics:UIBarMetricsDefaultPrompt];
            [self.navigationBar setTitleVerticalPositionAdjustment:0 forBarMetrics:UIBarMetricsCompact];
            [self.navigationBar setTitleVerticalPositionAdjustment:0 forBarMetrics:UIBarMetricsCompactPrompt];
        } else {
            self.visualEffectView.alpha = 0;
            self.navigationBar.tintColor = [UIColor whiteColor];
            [self.navigationBar setTitleVerticalPositionAdjustment:-500 forBarMetrics:UIBarMetricsDefault];
            [self.navigationBar setTitleVerticalPositionAdjustment:-500 forBarMetrics:UIBarMetricsDefaultPrompt];
            [self.navigationBar setTitleVerticalPositionAdjustment:-500 forBarMetrics:UIBarMetricsCompact];
            [self.navigationBar setTitleVerticalPositionAdjustment:-500 forBarMetrics:UIBarMetricsCompactPrompt];
        }
    } completion:^(BOOL finished) {
        [self setNeedsStatusBarAppearanceUpdate];
    }];
}

#pragma mark - Public

- (void)setNeedsNavigationBarVisibilityUpdateAnimated:(BOOL)animated {
    if (!self.topViewController) {
        NSLog(@"GKFadeNavigationController error: topViewController is not set");
        return;
    }
    
    if ([self.topViewController conformsToProtocol:@protocol(GKFadeNavigationControllerDelegate)]) {
        if ([self.topViewController respondsToSelector:@selector(preferredNavigationBarVisibility)]) {

            GKFadeNavigationControllerNavigationBarVisibility topControllerPrefersVisibility = (GKFadeNavigationControllerNavigationBarVisibility)[self.topViewController performSelector:@selector(preferredNavigationBarVisibility)];
            
            [self setNavigationBarVisibility:topControllerPrefersVisibility animated:animated];

        } else {
            NSLog(@"GKFadeNavigationController error: setNeedsNavigationBarVisibilityUpdateAnimated is called but %@ does not have -preferredNavigationBarVisibility method!", self.topViewController);
            return;
        }
    } else {
        NSLog(@"GKFadeNavigationController error: setNeedsNavigationBarVisibilityUpdateAnimated is called but %@ does not conform to GKFadeNavigationControllerDelegate protocol!", self.topViewController);
    }
}

#pragma mark - Helper

- (BOOL)isNavigationStyleBlack {
    if (self.navigationBar.barStyle == UIBarStyleBlackTranslucent ||
        self.navigationBar.barStyle == UIBarStyleBlack ||
        self.navigationBar.barStyle == UIBarStyleBlackOpaque) {
        return YES;
    } else {
        return NO;
    }
}

@end
