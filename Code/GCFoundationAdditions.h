///**********************************************************************************************************************************
///  GCStyleInspector.h
///  GCDrawKit
///
///  Created by graham on 13/05/2007.
///  Released under the Creative Commons license 2007 Apptree.net.
///
///
///  This work is licensed under the Creative Commons Attribution-ShareAlike 2.5 License.
///  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/2.5/ or send a letter to
///  Creative Commons, 543 Howard Street, 5th Floor, San Francisco, California, 94105, USA.
///
///**********************************************************************************************************************************

#import <Cocoa/Cocoa.h>

@interface NSImage (ImageResources)

+ (NSImage *)imageNamed:(NSImageName)name fromBundleForClass:(Class)aClass;

@end

extern NSPasteboardType const kDKTableRowInternalDragPasteboardType NS_SWIFT_NAME(dkTableRowInternalDrag);

// utility categories that help manage the user interface

@interface NSMenu (GCAdditions)

- (void)disableItemsWithTag:(NSInteger)tag;
- (void)uncheckAllItems;

@end

@interface NSView (TagEnablingAdditions)

/** Recursively checks the tags of all subviews below this, and sets any that match \c tag to the hidden state \c hide
 */
- (void)setSubviewsWithTag:(NSInteger)tag hidden:(BOOL)hide;
/** recursively checks the tags of all subviews below this, and sets any that match \c tag to the enabled state \c enable
 provided that the object actually implements \c setEnabled: (i.e. it's a control).
 */
- (void)setSubviewsWithTag:(NSInteger)tag enabled:(BOOL)enable;

@end
