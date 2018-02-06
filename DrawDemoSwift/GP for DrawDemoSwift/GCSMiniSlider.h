//
//  GCMiniSlider.h
//  panel
//
//  Created by Graham on Thu Apr 12 2007.
//  Copyright (c) 2007 __MyCompanyName__. All rights reserved.
//

#import "GCSMiniControl.h"

@interface GCSMiniSlider : GCSMiniControl {
	NSImage *mKnobImage;
	BOOL mShowTicks;
}

@property (nonatomic) BOOL showTickMarks;

@property (readonly) NSRect knobRect;

@end

enum {
	kDKMiniSliderKnob = 2
}
;

#define kMiniSliderEndCapWidth 10
