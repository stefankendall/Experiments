#import <MapKit/MapKit.h>
#import <Google-Maps-iOS-SDK/GoogleMaps/GMSMapView.h>
#import <Google-Maps-iOS-Utils-QuadTree/GClusterManager.h>
#import "EXViewController.h"
#import "ShadeView.h"
#import "DummyAnnotations.h"
#import "NonHierarchicalDistanceBasedAlgorithm.h"
#import "MyClusterRenderer.h"
#import "ShadeScrollView.h"

#include "MKMapView+ZoomLevel.h"
#import "MKClusterManager.h"

@implementation EXViewController

const int MAX_ZOOM_LEVEL = 21;

- (void)viewDidLoad {
    self.clipView.scrollView = self.scrollView;
    self.clipView.heightConstraint = self.shadeHeightConstraint;
    [self.scrollView buildCards];

    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;

    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager startUpdatingLocation];

    self.clusterManager = [[MKClusterManager alloc] initWithMapView:self.mapView
                                                          algorithm:[[NonHierarchicalDistanceBasedAlgorithm alloc] initWithMaxDistanceAtZoom:7000]
                                                           renderer:[[MyClusterRenderer alloc] initWithMapView:self.mapView]];

    [self.mapView setDelegate:self.clusterManager];

    [self.mapView setShowsUserLocation:YES];
    self.mapView.userTrackingMode = MKUserTrackingModeFollow;
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    if (!self.hasFoundInitialLocation) {
        self.hasFoundInitialLocation = YES;
        [self.mapView setCenterCoordinate:newLocation.coordinate zoomLevel:MAX_ZOOM_LEVEL animated:NO];
        self.clusterManager.initialLocationFound = YES;
        [[DummyAnnotations new] addAnnotations:self.clusterManager around:newLocation.coordinate];
        [[self clusterManager] cluster];
    }
}

@end