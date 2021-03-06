#import "DotAnnotationView.h"
#import "SpotDataColors.h"
#import "MyMarker.h"
#import "Spot.h"

@implementation DotAnnotationView

- (instancetype)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        [self draw];
    }

    return self;
}


- (UIImage *)buildImage {
    int diameter = 17;
    float inset = 1;

    CGRect rect = CGRectMake(0, 0, diameter, diameter);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);

    CGContextRef ctx = UIGraphicsGetCurrentContext();

    CGRect circleRect = CGRectMake(0, 0, diameter, diameter);
    circleRect = CGRectInset(circleRect, inset * 3, inset * 3);

    [self drawCircle:ctx circleRect:circleRect];
    [self drawStroke:inset ctx:ctx circleRect:circleRect];

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}

- (void)drawStroke:(float)inset ctx:(CGContextRef)ctx circleRect:(CGRect)circleRect {
    [[UIColor whiteColor] setStroke];
    CGContextSetShadowWithColor(ctx, CGSizeMake(0, 1), 3.0, [UIColor blackColor].CGColor);
    CGContextStrokeEllipseInRect(ctx, circleRect);
}

- (void)drawCircle:(CGContextRef)ctx circleRect:(CGRect)circleRect {
    CGContextSetShadowWithColor(ctx, CGSizeMake(0, 1), 3.0, [UIColor grayColor].CGColor);
    MyMarker *marker = self.annotation;
    [[SpotDataColors colorFor:marker.spot.data[0]] setFill];
    CGContextFillEllipseInRect(ctx, circleRect);
}

- (void)draw {
    [self setImage:[self buildImage]];
}

@end