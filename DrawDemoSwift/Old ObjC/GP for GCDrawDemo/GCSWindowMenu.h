///**********************************************************************************************************************************
///  GCWindowMenu.h
///  GCDrawKitUI
///
///  Created by graham on 27/03/07.
///  Released under the Creative Commons license 2006 Apptree.net.
///
///
///  This work is licensed under the Creative Commons Attribution-ShareAlike 2.5 License.
///  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/2.5/ or send a letter to
///  Creative Commons, 543 Howard Street, 5th Floor, San Francisco, California, 94105, USA.
///
///**********************************************************************************************************************************

#import <Cocoa/Cocoa.h>

@interface GCSWindowMenu : NSWindow {
	__unsafe_unretained NSView *mMainViewRef;
}

+ (void)popUpWindowMenu:(GCSWindowMenu *)menu withEvent:(NSEvent *)event forView:(NSView *)view;
+ (void)popUpWindowMenu:(GCSWindowMenu *)menu atPoint:(NSPoint)loc withEvent:(NSEvent *)event forView:(NSView *)view;

+ (GCSWindowMenu *)windowMenu;
+ (GCSWindowMenu *)windowMenuWithContentView:(NSView *)view;

- (void)trackWithEvent:(NSEvent *)event;

- (void)setMainView:(NSView *)aView sizeToFit:(BOOL)stf;
@property (readonly, unsafe_unretained) NSView *mainView;

// private stuff:

- (void)fadeWithTimeInterval:(NSTimeInterval)t;
- (void)timerFadeCallback:(NSTimer *)timer;
- (NSEvent *)transmogrify:(NSEvent *)event;

@end

#define kDKDefaultWindowMenuSize (NSMakeRect(0, 0, 100, 28))

@interface NSEvent (GCAdditions)

@property (getter=isMouseEventType, readonly) BOOL mouseEventType;

@end
