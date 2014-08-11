#import <MapKit/MapKit.h>
#import <Google-Maps-iOS-SDK/GoogleMaps/GMSMapView.h>
#import <Google-Maps-iOS-Utils-QuadTree/GClusterManager.h>
#import "EXViewController.h"
#import "ClipView.h"
#import "GMSCameraPosition.h"
#import "DummyAnnotations.h"
#import "NonHierarchicalDistanceBasedAlgorithm.h"
#import "GClusterManager.h"
#import "GDefaultClusterRenderer.h"

@implementation EXViewController

const int MAX_ZOOM_LEVEL = 18;
const int MIN_ZOOM_LEVEL = 16;

typedef enum {
    UP, DOWN
} direction;

- (void)viewDidLoad {
    self.clipView.scrollView = self.scrollView;
    self.cardRevealed = NO;

    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.clipsToBounds = NO;
    self.scrollView.canCancelContentTouches = NO;
    [self.scrollView setDelegate:self];

    UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(cardPanned:)];
    [recognizer setDelegate:self];
    [self.scrollView addGestureRecognizer:recognizer];

    [self buildCards];
    [self adjustCardSizes];

    [self.mapView setMinZoom:MIN_ZOOM_LEVEL maxZoom:MAX_ZOOM_LEVEL];
    [self.mapView setIndoorEnabled:NO];
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;

    [self.locationManager startUpdatingLocation];

    self.clusterManager = [[GClusterManager alloc] init];
    [self.clusterManager setMapView:self.mapView];
    [self.clusterManager setClusterAlgorithm:[[NonHierarchicalDistanceBasedAlgorithm alloc] init]];
    [self.clusterManager setClusterRenderer:[[GDefaultClusterRenderer alloc] initWithGoogleMap:self.mapView]];

    [self.mapView setDelegate:self.clusterManager];
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    if (!self.hasFoundInitialLocation) {
        self.hasFoundInitialLocation = YES;
        [self.mapView setCamera:[GMSCameraPosition cameraWithLatitude:newLocation.coordinate.latitude
                                                            longitude:newLocation.coordinate.longitude
                                                                 zoom:MIN_ZOOM_LEVEL]];
        [[DummyAnnotations new] addAnnotations:self.clusterManager around:newLocation.coordinate];
        [[self clusterManager] cluster];
    }
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {

}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    MKCoordinateRegion region;
    region.center = mapView.userLocation.coordinate;
    region.span = MKCoordinateSpanMake(0.001, 0.001);

    region = [mapView regionThatFits:region];
    [mapView setRegion:region animated:NO];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self hideCard:NO];
}

- (void)cardPanned:(UIPanGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {self.swiping = NO;}
    CGPoint v = [gesture velocityInView:self.scrollView];
    const int THRESHOLD = 150;
    if (v.y <= -THRESHOLD && !self.swiping && !self.cardRevealed) {
        self.swiping = YES;
        [gesture cancelsTouchesInView];
        [self revealCard];
    }
    else if (v.y >= THRESHOLD && !self.swiping && self.cardRevealed) {
        self.swiping = YES;
        [gesture cancelsTouchesInView];
        [self hideCard:YES];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)revealCard {
    self.cardRevealed = YES;
    [self moveCard:UP animate:YES];
}

- (void)hideCard:(BOOL)animate {
    if (self.cardRevealed) {
        self.cardRevealed = NO;
        [self moveCard:DOWN animate:animate];
    }
}

- (void)moveCard:(direction)direction animate:(BOOL)animate {
    int page = (int) (self.scrollView.contentOffset.x / self.scrollView.frame.size.width);
    int yTranslation = direction == UP ? -100 : 100;
    UIView *card = self.cardViews[page];
    if (animate) {
        [UIView animateWithDuration:0.15 delay:0.1 options:UIViewAnimationOptionCurveEaseIn animations:^{
            card.center = CGPointMake(card.center.x, card.center.y + yTranslation);
        }                completion:^(BOOL finished) {
        }];
    }
    else {
        card.center = CGPointMake(card.center.x, card.center.y + yTranslation);
    }
}

- (void)buildCards {
    const int CARD_COUNT = 5;
    self.cardViews = [@[] mutableCopy];
    for (int i = 0; i < CARD_COUNT; i++) {
        UIStoryboard *cardBoard = [UIStoryboard storyboardWithName:@"StockCard" bundle:nil];
        UITableViewController *controller = [cardBoard instantiateViewControllerWithIdentifier:@"stockCards"];
        [self.cardViews addObject:controller.tableView];
        [self.scrollView addSubview:controller.tableView];
    }
}

- (void)adjustCardSizes {
    float rowHeight = [self cardRowHeight];
    UITableView *exampleView = (self.cardViews)[0];
    int rows = [[exampleView dataSource] tableView:exampleView numberOfRowsInSection:0];

    float scrollViewWidth = self.scrollView.frame.size.width;
    int spaceWidth = 5;
    float cardWidth = scrollViewWidth - 2 * spaceWidth;
    int subViewIndex = 0;
    for (UIView *view in self.cardViews) {
        view.frame = CGRectMake(scrollViewWidth * subViewIndex + spaceWidth,
                self.scrollView.frame.size.height - rowHeight, cardWidth, rowHeight * rows);
        subViewIndex++;
    }

    self.scrollView.contentSize = CGSizeMake([self getScreenWidth] * self.cardViews.count, rowHeight);
}

- (CGFloat)cardRowHeight {
    UITableView *exampleView = (self.cardViews)[0];
    return [[exampleView delegate] tableView:exampleView heightForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self adjustCardSizes];
}

- (CGFloat)getScreenWidth {
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    CGRect bounds = [UIScreen mainScreen].bounds;
    return UIInterfaceOrientationIsPortrait(interfaceOrientation) ? CGRectGetWidth(bounds) : CGRectGetHeight(bounds);
}

@end