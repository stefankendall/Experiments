#import <MapKit/MapKit.h>
#import <Google-Maps-iOS-Utils-QuadTree/GQuadItem.h>
#import "MyClusterRenderer.h"
#import "MyMarker.h"
#import "Spot.h"

@implementation MyClusterRenderer

- (instancetype)initWithMapView:(MKMapView *)mapView {
    self = [super init];
    if (self) {
        self.mapView = mapView;
        self.markerCache = [[NSMutableArray alloc] init];
    }

    return self;
}

- (void)clustersChanged:(NSSet *)clusters atMaxZoom:(BOOL)atMaxZoom {
    for (id <GCluster> cluster in clusters) {
        if ([cluster count] > 1) {
            id maxPriorityItem = [[[cluster getItems] objectEnumerator] allObjects][0];
            for (id item in [cluster getItems]) {
                Spot *spot = [self spotFromUnknown:item];
                if (spot.priority > [self spotFromUnknown:maxPriorityItem].priority) {
                    maxPriorityItem = item;
                }
            }

            for (id item in [cluster getItems]) {
                [self addItem:item isBubble:maxPriorityItem == item || atMaxZoom];
            }
        }
        else {
            id unknownItem = [[cluster getItems] allObjects][0];
            [self addItem:unknownItem isBubble:YES];
        }
    }
}

- (void)addItem:(id)item isBubble:(BOOL)bubble {
    Spot *spot = [self spotFromUnknown:item];

    MyMarker *existingMarker = [self existingMarkerAtPosition:spot.position];
    BOOL bubbleTypeChanged = existingMarker != nil && existingMarker.isBubble != bubble;
    if (bubbleTypeChanged || existingMarker == nil) {
        [self.mapView removeAnnotation:existingMarker];
        [self.markerCache removeObject:existingMarker];
        MyMarker *marker = [[MyMarker alloc] initWithSpot:spot isBubble:bubble];
        [self addMarker:marker atPosition:spot.position];
    }
}

- (MyMarker *)existingMarkerAtPosition:(CLLocationCoordinate2D)coordinate {
    for (MyMarker *marker in self.markerCache) {
        if (marker.coordinate.latitude == coordinate.latitude && marker.coordinate.longitude == coordinate.longitude) {
            return marker;
        }
    }
    return nil;
}

- (Spot *)spotFromUnknown:(id)item {
    Spot *spot;
    if ([item isKindOfClass:Spot.class]) {
        spot = item;
    }
    else {
        GQuadItem *quadItem = item;
        spot = [quadItem.getItems allObjects][0];
    }
    return spot;
}

- (void)addMarker:(MyMarker *)marker atPosition:(CLLocationCoordinate2D)position {
    [marker setCoordinate:position];
    [self.markerCache addObject:marker];
    [self.mapView addAnnotation:marker];
}

- (id <MKAnnotation>)markerForSpot:(Spot *)spot {
    for( MyMarker *marker in self.markerCache ){
        if( marker.spot == spot ){
            return marker;
        }
    }
    return nil;
}

- (void)removeMarker:(NSObject <MKAnnotation> *)annotation {
    [self.mapView removeAnnotation:annotation];
    [self.markerCache removeObject:annotation];
}

@end