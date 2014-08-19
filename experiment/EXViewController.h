#import <UIKit/UIKit.h>
#import <CoreLocation/CLLocationManagerDelegate.h>

@class ClipView;
@class GClusterManager;
@class ShadeScrollView;
@class MKClusterManager;

@interface EXViewController : UIViewController <UIGestureRecognizerDelegate, UIScrollViewDelegate, CLLocationManagerDelegate> {
}
@property(weak, nonatomic) IBOutlet ClipView *clipView;
@property(weak, nonatomic) IBOutlet ShadeScrollView *scrollView;

@property(nonatomic, strong) NSMutableArray *cardViews;
@property(nonatomic, strong) CLLocationManager *locationManager;
@property(strong, nonatomic) IBOutlet MKMapView *mapView;
@property(nonatomic) BOOL hasFoundInitialLocation;
@property(nonatomic, strong) MKClusterManager *clusterManager;

@property(nonatomic, strong) NSMutableArray *viewControllers;
@end