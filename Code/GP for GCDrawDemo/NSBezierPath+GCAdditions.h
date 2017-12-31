//
//  NSBezierPath+GCAdditions.h
//  GCDrawKit
//
//  Created by graham on 12/04/2007.
//  Copyright 2007 Apptree.net. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSBezierPath (GCAdditions)

/** Makes a target cross and circle in the given rect.
 */
+ (NSBezierPath *)bezierPathWithTargetInRect:(NSRect)rect;
/** Returns a rect with rounded ends (half circles).
 
 If \c rect is square this returns a circle. The rounded ends are applied
 to the shorter sides.
 */
+ (NSBezierPath *)bezierPathWithRoundEndedRectInRect:(NSRect)rect;
/** return a roundRect with given corner radius. Note: this code based on Uli Kusterer's NSBezierpathRoundRects class with
 grateful thanks.
 */
+ (NSBezierPath *)roundRectInRect:(NSRect)rect andCornerRadius:(CGFloat)radius;
/** Returns a target centred in rect, but with a round-rect shaped centre region which extends to the
 left or right according to \c off (-1 to left, +1 to right, 0 = normal target).
 */
+ (NSBezierPath *)bezierPathWithOffsetTargetInRect:(NSRect)rect offset:(NSInteger)off;

/** Returns a complex path consisting of a ring with a square angled tab on the outer edge. The centre line
 of the ring lies at <code>radius</code>, centred at the origin. The path is equally distributed either side of
 the radius by half the width. The tab size sets the width and height of the tab.
 */
+ (NSBezierPath *)bezierPathWithIrisRingWithRadius:(CGFloat)radius width:(CGFloat)width tabSize:(NSSize)tabsize;
/** Returns a complex path consisting of a ring with a square angled tab on the outer edge. The centre line
 of the ring lies at <code>radius</code>, centred at the origin. The path is equally distributed either side of
 the radius by half the width. The angle sets the tab orientation in radians and the tab size sets
 the width and height of the tab.
 */
+ (NSBezierPath *)bezierPathWithIrisRingWithRadius:(CGFloat)radius width:(CGFloat)width tabAngle:(CGFloat)angle tabSize:(NSSize)tabsize;

/** Returns a path representing just the tab area of the above path. Allows this area to be filled/stroked
 separately if desired.
 */
+ (NSBezierPath *)bezierPathWithIrisTabWithRadius:(CGFloat)radius width:(CGFloat)width tabSize:(NSSize)tabsize;
+ (NSBezierPath *)bezierPathWithIrisTabWithRadius:(CGFloat)radius width:(CGFloat)width tabAngle:(CGFloat)angle tabSize:(NSSize)tabsize;

@end

NS_ASSUME_NONNULL_END
