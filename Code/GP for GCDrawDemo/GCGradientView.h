//
//  GCGradientView.h
//  panel
//
//  Created by Graham on Wed Apr 11 2007.
//  Copyright (c) 2007 __MyCompanyName__. All rights reserved.
//

#import <AppKit/AppKit.h>

@class DKGradient;

@interface GCGradientView : NSView {
	DKGradient *_gradient;
}

@property (nonatomic, retain) DKGradient *gradient;

@end

// ultra simple view class simply renders its gradient in the bounds.
// used (in part) to provide PDF/EPS export facility for gradients

// list view used to provide similar feature for exporting library images

@interface GCGradientListView : NSView {
	NSArray<DKGradient*> *_list;
	NSSize _cellSize;
	NSSize _cellSpacing;
}

@property (retain) NSArray<DKGradient *> *gradientList;
@property NSSize cellSize;

@end

#define kGCDefaultListViewCellSize (NSMakeSize(64, 64))
#define kGCDefaultListViewCellSpacing (NSMakeSize(2, 2))
