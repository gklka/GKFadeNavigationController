//
//  GKFadeNavigationController.m
//  
//
//  Created by GK on 15.06.25..
//
//

#import "GKFadeNavigationController.h"

#define kGKDefaultVisibility YES

@interface GKFadeNavigationController ()

@property (nonatomic, strong) UIVisualEffectView *visualEffectView;
@property (nonatomic) GKFadeNavigationControllerNavigationBarVisibility navigationBarVisibility;
@property (nonatomic, strong) UIColor *originalTintColor;

- (void)showNavigaitonBar:(BOOL)show withFadeAnimation:(BOOL)animated;

@end

@implementation GKFadeNavigationController

#pragma mark Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Base values
    self.navigationBarVisibility = GKFadeNavigationControllerNavigationBarVisibilityHidden;
    self.originalTintColor = [self.navigationBar tintColor];

    // Hide the original navigation bar's background
    [self.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.translucent = YES;
    self.navigationBar.shadowImage = [UIImage new];

    // Create a the fake navigation bar background
    UIVisualEffect *blurEffect;
    blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
    
    self.visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    self.visualEffectView.frame = CGRectMake(0, -20.f, self.view.frame.size.width, 64.f);
    self.visualEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.visualEffectView.userInteractionEnabled = NO;
    
    // Shadow line
    UIView *shadowView = [[UIView alloc] initWithFrame:CGRectMake(0, 63.5f, self.view.frame.size.width, 0.5f)];
    shadowView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2f];
    shadowView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.visualEffectView addSubview:shadowView];
    
    // Add as subviews
    [self.navigationBar addSubview:self.visualEffectView];
    [self.navigationBar sendSubviewToBack:self.visualEffectView];
}

#pragma mark UI support

- (UIStatusBarStyle)preferredStatusBarStyle
{
    if (self.navigationBarVisibility == GKFadeNavigationControllerNavigationBarVisibilityVisible) {
        return UIStatusBarStyleDefault;
    } else {
        return UIStatusBarStyleLightContent;
    }
}

#pragma mark Navigation Controller overrides

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [super pushViewController:viewController animated:animated];
    [self setNeedsNavigationBarVisibilityUpdateAnimated:NO];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    UIViewController *viewController = [super popViewControllerAnimated:animated];
    [self setNeedsNavigationBarVisibilityUpdateAnimated:NO];
    return viewController;
}

#pragma mark Core functions

- (void)showNavigaitonBar:(BOOL)show withFadeAnimation:(BOOL)animated
{
    [UIView animateWithDuration:(animated ? 0.2 : 0) animations:^{
        if (show) {
            self.visualEffectView.alpha = 1;
            self.navigationBar.tintColor = [self originalTintColor];
            self.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor blackColor]};
        } else {
            self.visualEffectView.alpha = 0;
            self.navigationBar.tintColor = [UIColor whiteColor];
            self.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor clearColor]};
        }
    } completion:^(BOOL finished) {
        [self setNeedsStatusBarAppearanceUpdate];
        self.navigationBarVisibility = show ? GKFadeNavigationControllerNavigationBarVisibilityVisible : GKFadeNavigationControllerNavigationBarVisibilityHidden;
    }];
}

- (void)setNeedsNavigationBarVisibilityUpdateAnimated:(BOOL)animated
{
    if ([self.topViewController conformsToProtocol:@protocol(GKFadeNavigationControllerDelegate)]) {
        GKFadeNavigationControllerNavigationBarVisibility topControllerPrefersVisibility = (GKFadeNavigationControllerNavigationBarVisibility)[self.topViewController performSelector:@selector(preferredNavigationBarVisibility)];
        
        if (topControllerPrefersVisibility == GKFadeNavigationControllerNavigationBarVisibilityVisible) {
            [self showNavigaitonBar:YES withFadeAnimation:animated];
        } else if (topControllerPrefersVisibility == GKFadeNavigationControllerNavigationBarVisibilityHidden) {
            [self showNavigaitonBar:NO withFadeAnimation:animated];
        } else {
            [self showNavigaitonBar:kGKDefaultVisibility withFadeAnimation:NO];
        }
    } else {
        [self showNavigaitonBar:kGKDefaultVisibility withFadeAnimation:NO];
    }
}

@end
