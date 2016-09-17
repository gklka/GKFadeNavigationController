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

@interface GKTableViewController ()

@property (nonatomic) GKFadeNavigationControllerNavigationBarVisibility navigaionBarVisibility;

@end

@implementation GKTableViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        self.navigaionBarVisibility = GKFadeNavigationControllerNavigationBarVisibilityHidden;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view sendSubviewToBack:self.headerView];
    
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

- (void)setNavigaionBarVisibility:(GKFadeNavigationControllerNavigationBarVisibility)navigaionBarVisibility {
    BOOL changed = NO;
    if (_navigaionBarVisibility != navigaionBarVisibility) {
        changed = YES;
    }
    
    _navigaionBarVisibility = navigaionBarVisibility;
    
    // Play the change
    if (changed) {
        GKFadeNavigationController *navigationController = (GKFadeNavigationController *)self.navigationController;
        [navigationController setNeedsNavigationBarVisibilityUpdateAnimated:YES];
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
        self.navigaionBarVisibility = GKFadeNavigationControllerNavigationBarVisibilityVisible;
    } else {
        self.navigaionBarVisibility = GKFadeNavigationControllerNavigationBarVisibilityHidden;
    }
}

#pragma mark <GKFadeNavigationControllerDelegate>

- (GKFadeNavigationControllerNavigationBarVisibility)preferredNavigationBarVisibility {
    return self.navigaionBarVisibility;
}

@end
