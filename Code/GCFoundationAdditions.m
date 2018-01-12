///**********************************************************************************************************************************
///  GCStyleInspector.m
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

#import "GCFoundationAdditions.h"
#import <DKDrawKit/LogEvent.h>
#import <DKDrawKit/NSShadow+Scaling.h>

#pragma mark Contants (Non-localized)
NSString *const kDKTableRowInternalDragPasteboardType = @"kDKTableRowInternalDragPasteboardType";

#pragma mark -
@implementation NSImage (ImageResources)

+ (NSImage *)imageNamed:(NSString *)name fromBundleForClass:(Class) class
{
	NSImage *image = [[NSBundle bundleForClass:class] imageForResource:name];
	if (image == nil)
		LogEvent_(kWheneverEvent, @"ERROR: Unable to locate image resource '%@'", name);
	return image;
}

@end

#pragma mark -
@implementation NSMenu(GCAdditions)

- (void)disableItemsWithTag : (NSInteger)tag
{
	NSInteger i, m = self.numberOfItems;
	NSMenuItem *item;

	for (i = 0; i < m; ++i) {
		item = [self itemAtIndex:i];

		if (item.tag == tag)
			[item setEnabled:NO];
	}
}

- (void)uncheckAllItems
{
	NSInteger i, m = self.numberOfItems;

	for (i = 0; i < m; ++i)
		[self itemAtIndex:i].state = NSOffState;
}

@end

#pragma mark -

@implementation NSView (TagEnablingAdditions)

- (void)setSubviewsWithTag:(NSInteger)tag hidden:(BOOL)hide
{
	if (self.tag == tag) {
		self.hidden = hide;
	} else {
		for (NSView *sub in self.subviews) {
			[sub setSubviewsWithTag:tag hidden:hide];
		}
	}
}

- (void)setSubviewsWithTag:(NSInteger)tag enabled:(BOOL)enable
{
	if (self.tag == tag && [self respondsToSelector:@selector(setEnabled:)]) {
		[(id)self setEnabled:enable];
	} else {
		for (NSView *sub in self.subviews) {
			[sub setSubviewsWithTag:tag enabled:enable];
		}
	}
}

@end
