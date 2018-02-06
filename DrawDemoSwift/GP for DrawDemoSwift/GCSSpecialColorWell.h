///**********************************************************************************************************************************
///  GCSpecialColorWell.h
///  GCDrawKit
///
///  Created by graham on 01/05/2007.
///  Released under the Creative Commons license 2007 Apptree.net.
///
///
///  This work is licensed under the Creative Commons Attribution-ShareAlike 2.5 License.
///  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/2.5/ or send a letter to
///  Creative Commons, 543 Howard Street, 5th Floor, San Francisco, California, 94105, USA.
///
///**********************************************************************************************************************************

#import <Cocoa/Cocoa.h>

/** @brief This works exactly like an NSColorWell, and is intended to pose as that class.

 This works exactly like an NSColorWell, and is intended to pose as that class.

 The point is to get notified on all activates and deactivates so WTGradientControl can simulate
 its color well behaviour correctly.
 */
@interface GCSSpecialColorWell : NSColorWell

+ (void)deactivateCurrentWell;

@end

extern NSNotificationName kDKColorWellWillActivate;
extern NSNotificationName kDKColorWellDidActivate;
extern NSNotificationName kDKColorWellWillDeactivate;
extern NSNotificationName kDKColorWellDidDeactivate;


