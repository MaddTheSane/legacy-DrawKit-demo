//
//  NSBezierPath+GCAdditions.h
//  GCDrawKit
//
//  Created by graham on 12/04/2007.
//  Copyright 2007 Apptree.net. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSBezierPath (GCAdditions)

+ (NSBezierPath*)	bezierPathWithTargetInRect:(NSRect) rect;
+ (NSBezierPath*)	bezierPathWithRoundEndedRectInRect:(NSRect) rect;
+ (NSBezierPath*)	roundRectInRect:(NSRect) rect andCornerRadius:(CGFloat) radius;
+ (NSBezierPath*)   bezierPathWithOffsetTargetInRect:(NSRect) rect offset:(NSInteger) off;


+ (NSBezierPath*)   bezierPathWithIrisRingWithRadius:(CGFloat) radius width:(CGFloat) width tabSize:(NSSize) tabsize;
+ (NSBezierPath*)   bezierPathWithIrisRingWithRadius:(CGFloat) radius width:(CGFloat) width tabAngle:(CGFloat) angle tabSize:(NSSize) tabsize;

+ (NSBezierPath*)   bezierPathWithIrisTabWithRadius:(CGFloat) radius width:(CGFloat) width tabSize:(NSSize) tabsize;
+ (NSBezierPath*)   bezierPathWithIrisTabWithRadius:(CGFloat) radius width:(CGFloat) width tabAngle:(CGFloat) angle tabSize:(NSSize) tabsize;

@end
