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
@property (nonatomic, strong) UIView *fakeNavigationBarBackground;

@property (nonatomic) GKFadeNavigationControllerNavigationBarVisibility navigationBarVisibility;
@property (nonatomic, strong) UIColor *originalTintColor;

@end


@implementation GKFadeNavigationController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.window.backgroundColor = [UIColor redColor];
    
    // Base values
    self.originalTintColor = [self.navigationBar tintColor];
    self.delegate = self;

    [self setupCustomNavigationBar];
    self.navigationBarVisibility = GKFadeNavigationControllerNavigationBarVisibilityVisible;
    
    [self updateNavigationBarVisibilityForController:self.topViewController animated:NO];
}

#pragma mark - Accessors

- (void)setNavigationBarVisibility:(GKFadeNavigationControllerNavigationBarVisibility)navigationBarVisibility animated:(BOOL)animated
{
    if (_navigationBarVisibility == navigationBarVisibility) {
        // NSLog(@"Changing navigaiton bar is not required");
        return;
    }
    
    if (_navigationBarVisibility == GKFadeNavigationControllerNavigationBarVisibilitySystem) {
        // We have system navigation bar
        
        if (navigationBarVisibility == GKFadeNavigationControllerNavigationBarVisibilityVisible) {
            
            // We have a system navigation bar and we transition to visible
            [self setupCustomNavigationBar];
            
        } else if (navigationBarVisibility == GKFadeNavigationControllerNavigationBarVisibilityHidden) {
            
            // We have a system navigation bar and we transition to hidden
            [self setupCustomNavigationBar];
            [self showCustomNavigaitonBar:NO withFadeAnimation:animated];
        }
        
    } else if (_navigationBarVisibility == GKFadeNavigationControllerNavigationBarVisibilityHidden) {
        // We have a custom navigation bar

        if (navigationBarVisibility == GKFadeNavigationControllerNavigationBarVisibilitySystem) {
            
            // We have a custom, hidden navigation bar, we animate back then transition to custom
            [self showCustomNavigaitonBar:YES withFadeAnimation:animated];
            [self setupSystemNavigationBar];
            
        } else if (navigationBarVisibility == GKFadeNavigationControllerNavigationBarVisibilityVisible) {
            
            // We have a custom, hidden navigation bar, we animate it back
            [self showCustomNavigaitonBar:YES withFadeAnimation:animated];
            
        }
    } else if (_navigationBarVisibility == GKFadeNavigationControllerNavigationBarVisibilityVisible) {
        
        if (navigationBarVisibility == GKFadeNavigationControllerNavigationBarVisibilitySystem) {
            
            // We have a visible custom navigation bar, we just have to replace it
            [self setupSystemNavigationBar];
            
        } else if (navigationBarVisibility == GKFadeNavigationControllerNavigationBarVisibilityHidden) {
            
            // We have a visible custom navigation bar which we need to hide
            [self showCustomNavigaitonBar:NO withFadeAnimation:animated];
        }

    }
    
    if (navigationBarVisibility == GKFadeNavigationControllerNavigationBarVisibilityUndefined) {
        NSLog(@"Error: This should not happen: somebody tried to transition from System/Hidden/Visible state to Undefined");
    }
    
    _navigationBarVisibility = navigationBarVisibility;
}

// For iOS 7
- (UIView *)fakeNavigationBarBackground
{
    if (!_fakeNavigationBarBackground) {
        _fakeNavigationBarBackground = [[UIView alloc] initWithFrame:self.navigationBar.frame];
        _fakeNavigationBarBackground.frame = CGRectMake(0, -20.f, self.view.frame.size.width, 64.f);
        _fakeNavigationBarBackground.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _fakeNavigationBarBackground.userInteractionEnabled = NO;
        _fakeNavigationBarBackground.backgroundColor = [UIColor colorWithWhite:1.f alpha:0.9f];

        // Shadow line
        UIView *shadowView = [[UIView alloc] initWithFrame:CGRectMake(0, 63.5f, self.view.frame.size.width, 0.5f)];
        shadowView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2f];
        shadowView.autoresizingMask = UIViewAutoresizingFlexibleWidth;

        [_fakeNavigationBarBackground addSubview:shadowView];
    }
    
    return _fakeNavigationBarBackground;
}

// For iOS 8+
- (UIVisualEffectView *)visualEffectView
{
    if (!_visualEffectView) {
        // Create a the fake navigation bar background
        UIVisualEffect *blurEffect;
        blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
        
        _visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        _visualEffectView.frame = CGRectMake(0, -20.f, self.view.frame.size.width, 64.f);
        _visualEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _visualEffectView.userInteractionEnabled = NO;
        
        // Shadow line
        UIView *shadowView = [[UIView alloc] initWithFrame:CGRectMake(0, 63.5f, self.view.frame.size.width, 0.5f)];
        shadowView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2f];
        shadowView.autoresizingMask = UIViewAutoresizingFlexibleWidth;

        [self.visualEffectView addSubview:shadowView];
    }
    
    return _visualEffectView;
}

#pragma mark - UI support

- (UIStatusBarStyle)preferredStatusBarStyle
{
    if (self.navigationBarVisibility == GKFadeNavigationControllerNavigationBarVisibilityHidden) {
        return UIStatusBarStyleLightContent;
    } else {
        return UIStatusBarStyleDefault;
    }
}

#pragma mark - <UINavigationControllerDelegate>

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
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
- (void)setupCustomNavigationBar
{
    // Hide the original navigation bar's background
    [self.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.translucent = YES;
    self.navigationBar.shadowImage = [UIImage new];

    if (IS_OS_OLDER_THAN_IOS_8) {
        // iOS 7
        [self.navigationBar addSubview:self.fakeNavigationBarBackground];
        [self.navigationBar sendSubviewToBack:self.fakeNavigationBarBackground];
        
    } else {
        // iOS 8+
        [self.navigationBar addSubview:self.visualEffectView];
        [self.navigationBar sendSubviewToBack:self.visualEffectView];
    }
}

/**
 Remove custom navigation bar background, and reset to the system default
 */
- (void)setupSystemNavigationBar
{
    if (IS_OS_OLDER_THAN_IOS_8) {
        // iOS 7
        [self.fakeNavigationBarBackground removeFromSuperview];
    } else {
        // iOS 8+
        [self.visualEffectView removeFromSuperview];
    }
    
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
- (void)updateNavigationBarVisibilityForController:(UIViewController *)viewController animated:(BOOL)animated
{
    GKFadeNavigationControllerNavigationBarVisibility visibility = GKFadeNavigationControllerNavigationBarVisibilityVisible;
    
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
- (void)showCustomNavigaitonBar:(BOOL)show withFadeAnimation:(BOOL)animated
{
    [UIView animateWithDuration:(animated ? 0.2 : 0) animations:^{
        if (show) {
            if (IS_OS_OLDER_THAN_IOS_8) {
                // iOS 7
                self.fakeNavigationBarBackground.alpha = 1;
            } else {
                // iOS 8+
                self.visualEffectView.alpha = 1;
            }
            self.navigationBar.tintColor = [self originalTintColor];
            self.navigationBar.titleTextAttributes = [[UINavigationBar appearance] titleTextAttributes];
        } else {
            if (IS_OS_OLDER_THAN_IOS_8) {
                // iOS 7
                self.fakeNavigationBarBackground.alpha = 0;
            } else {
                // iOS 8+
                self.visualEffectView.alpha = 0;
            }
            self.navigationBar.tintColor = [UIColor whiteColor];
            self.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor clearColor]};
        }
    } completion:^(BOOL finished) {
        self.navigationBarVisibility = show ? GKFadeNavigationControllerNavigationBarVisibilityVisible : GKFadeNavigationControllerNavigationBarVisibilityHidden;
        [self setNeedsStatusBarAppearanceUpdate];
    }];
}

#pragma mark Public

- (void)setNeedsNavigationBarVisibilityUpdateAnimated:(BOOL)animated
{
    if ([self.topViewController conformsToProtocol:@protocol(GKFadeNavigationControllerDelegate)]) {
        if ([self.topViewController respondsToSelector:@selector(preferredNavigationBarVisibility)]) {

            GKFadeNavigationControllerNavigationBarVisibility topControllerPrefersVisibility = (GKFadeNavigationControllerNavigationBarVisibility)[self.topViewController performSelector:@selector(preferredNavigationBarVisibility)];

            if (topControllerPrefersVisibility == GKFadeNavigationControllerNavigationBarVisibilityVisible) {
                [self showCustomNavigaitonBar:YES withFadeAnimation:animated];
            } else if (topControllerPrefersVisibility == GKFadeNavigationControllerNavigationBarVisibilityHidden) {
                [self showCustomNavigaitonBar:NO withFadeAnimation:animated];
            }

        } else {
            NSLog(@"GKFadeNavigationController error: setNeedsNavigationBarVisibilityUpdateAnimated is called but the current topmost view controller does not conform to GKFadeNavigationControllerDelegate protocol!");
            return;
        }
    } else {
        NSLog(@"GKFadeNavigationController error: setNeedsNavigationBarVisibilityUpdateAnimated is called but the current topmost view controller does not conform to GKFadeNavigationControllerDelegate protocol!");
    }
}

@end
