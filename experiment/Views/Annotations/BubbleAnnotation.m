#import "BubbleAnnotation.h"
#import "TextDrawer.h"
#import "MyMarker.h"
#import "SpotData.h"

@implementation BubbleAnnotation

- (instancetype)initWithAnnotation:(MyMarker *)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setImage:[self buildImage]];
    }

    return self;
}

- (NSString *)getShortName {
    MyMarker *marker = self.annotation;
    SpotData *data = marker.data[0];
    return data.shortName;
}

- (UIImage *)buildImage {
    const int FONT_SIZE = 14;
    CGSize textFrame = [TextDrawer sizeOfText:[self getShortName] fontSize:FONT_SIZE];

    int triangleWidth = 10;
    int triangleHeight = 12;

    CGRect roundedRectangleRect = [self roundedRectangleRectFor:textFrame bottomHeight:triangleHeight];
    [self drawRoundedRect:roundedRectangleRect];
    [self drawBottomTriangle:roundedRectangleRect withWidth:triangleWidth withHeight:triangleHeight];

    [TextDrawer writeText:[self getShortName] fontSize:FONT_SIZE inRect:roundedRectangleRect];

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (CGRect)roundedRectangleRectFor:(CGSize)size bottomHeight:(int)bottomHeight {
    int rectangleHeight = (int) (size.height * 1.5);
    int rectangleWidth = (int) (size.width + 12);
    CGRect rect = CGRectMake(0, 0, rectangleWidth, rectangleHeight + bottomHeight);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    return CGRectMake(0, 0, rectangleWidth, rectangleHeight);
}

- (void)drawRoundedRect:(CGRect)roundedRectangleRect {
    CGRect insetRoundedRectangleRect = CGRectInset(roundedRectangleRect, 1, 1);

    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:insetRoundedRectangleRect byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(5, 5)];
    [[self currentColor] setFill];
    [path fill];

    CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 3);
    [[UIColor whiteColor] setStroke];
    [path stroke];
}

- (void)drawBottomTriangle:(CGRect)fromRect withWidth:(int)width withHeight:(int)height {
    UIBezierPath *path = [UIBezierPath bezierPath];

    int leftX = (int) (fromRect.size.width / 2.0 - width / 2.0);
    int rightX = (int) (fromRect.size.width / 2.0 + width / 2.0);
    [path moveToPoint:CGPointMake(leftX, fromRect.size.height - 2)];
    [path addLineToPoint:CGPointMake((leftX + rightX) / 2, fromRect.size.height + height)];
    [path addLineToPoint:CGPointMake(rightX, fromRect.size.height - 2)];
    [[UIColor whiteColor] setStroke];
    [path stroke];
    [path closePath];
    [[self currentColor] setFill];
    [path fill];
}

- (UIColor *)currentColor {
    if ([self isSelected]) {
        return [UIColor blueColor];
    }
    else {
        return [UIColor colorWithRed:18.0f / 255.0f green:204.0f / 255.0f blue:64.0f / 255.0f alpha:1.0];
    }
}

@end