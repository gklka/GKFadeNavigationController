//
//  GKTableViewController.m
//  
//
//  Created by GK on 15.06.24..
//
//

#import "GKTableViewController.h"

#define kGKHeaderHeight 150.f
#define kGKHeaderVisibleThreshold 44.f
#define kGKNavbarHeight 64.f

@interface GKTableViewController () <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageBottomConstraint;

@property (nonatomic) GKFadeNavigationControllerNavigationBarVisibility navigationBarVisibility;

@end


@implementation GKTableViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        self.navigationBarVisibility = GKFadeNavigationControllerNavigationBarVisibilityHidden;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBezierPath *topImageViewMaskingPath = [UIBezierPath bezierPath];
    [topImageViewMaskingPath moveToPoint:CGPointMake(0, -1000.f)];
    [topImageViewMaskingPath addLineToPoint:CGPointMake(1000.f, -1000.f)];
    [topImageViewMaskingPath addLineToPoint:CGPointMake(1000.f, self.tableView.tableHeaderView.frame.size.height)];
    [topImageViewMaskingPath addLineToPoint:CGPointMake(0, self.tableView.tableHeaderView.frame.size.height)];
    [topImageViewMaskingPath closePath];
    [topImageViewMaskingPath addClip];
    
    CAShapeLayer *mask = [CAShapeLayer layer];
    mask.path = topImageViewMaskingPath.CGPath;
    
    self.tableView.tableHeaderView.layer.mask = mask;
    
    GKFadeNavigationController *navigationController = (GKFadeNavigationController *)self.navigationController;
    [navigationController setNeedsNavigationBarVisibilityUpdateAnimated:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // Deselect row animated
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.navigationController setNeedsStatusBarAppearanceUpdate];
}

#pragma mark - Accessors

- (void)setNavigationBarVisibility:(GKFadeNavigationControllerNavigationBarVisibility)navigationBarVisibility {

    if (_navigationBarVisibility != navigationBarVisibility) {
        // Set the value
        _navigationBarVisibility = navigationBarVisibility;

        // Play the change
        GKFadeNavigationController *navigationController = (GKFadeNavigationController *)self.navigationController;
        if (navigationController.topViewController) {
            [navigationController setNeedsNavigationBarVisibilityUpdateAnimated:YES];
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text = [NSString stringWithFormat:@"Cell %@", @(indexPath.row)];
    
    return cell;
}

#pragma mark <UIScrollViewDelegate>

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat scrollOffsetY = kGKHeaderHeight-scrollView.contentOffset.y;

    // Stretch the header view if neccessary
    if (scrollOffsetY > kGKHeaderHeight) {
        self.imageTopConstraint.constant = kGKHeaderHeight-scrollOffsetY;
    } else {
        self.imageTopConstraint.constant = (kGKHeaderHeight-scrollOffsetY)/2.f;
        self.imageBottomConstraint.constant = -(kGKHeaderHeight-scrollOffsetY)/2.f;
    }

    // Show or hide the navigaiton bar
    if (scrollOffsetY-kGKNavbarHeight < kGKHeaderVisibleThreshold) {
        self.navigationBarVisibility = GKFadeNavigationControllerNavigationBarVisibilityVisible;
    } else {
        self.navigationBarVisibility = GKFadeNavigationControllerNavigationBarVisibilityHidden;
    }
}

#pragma mark <GKFadeNavigationControllerDelegate>

- (GKFadeNavigationControllerNavigationBarVisibility)preferredNavigationBarVisibility {
    return self.navigationBarVisibility;
}

@end
