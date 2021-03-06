#import "GCDrawKitAppDelegate.h"

#import "GCObjectInspector.h"
#import "GCLayersPaletteController.h"
#import "GCStyleInspector.h"
#import "GCStyleManagerDialog.h"
#import "GCToolPalette.h"
#import "GCDrawDemoPrefsController.h"
#import "GCDrawDemoDocument.h"

#import <DKDrawKit/DKDrawkit.h>

@implementation GCDrawKitAppDelegate
#pragma mark As a GCDrawKitAppDelegate
- (IBAction)showStyleInspector:(id)sender
{
#pragma unused(sender)
	if (mStyleInspector.window.visible)
		[mStyleInspector.window orderOut:self];
	else
		[self openStyleInspector];
}

- (IBAction)showToolPalette:(id)sender
{
#pragma unused(sender)
	if (mToolPalette.window.visible)
		[mToolPalette.window orderOut:self];
	else
		[self openToolPalette];
}

- (IBAction)showObjectInspector:(id)sender
{
#pragma unused(sender)
	if (mObjectInspector.window.visible)
		[mObjectInspector.window orderOut:self];
	else
		[self openObjectInspector];
}

- (IBAction)showLayersPalette:(id)sender
{
	if (mLayersController == nil)
		mLayersController = [[GCLayersPaletteController alloc] initWithWindowNibName:@"LayersPalette"];

	[mLayersController showWindow:sender];
}

- (IBAction)showStyleManagerDialog:(id)sender
{
	if (mStyleManager == nil)
		mStyleManager = [[GCStyleManagerDialog alloc] initWithWindowNibName:@"StyleManager"];

	[mStyleManager showWindow:sender];
}

- (IBAction)openPreferences:(id)sender
{
	if (mPrefsController == nil)
		mPrefsController = [[GCDrawDemoPrefsController alloc] initWithWindowNibName:@"Preferences"];

	[mPrefsController showWindow:sender];
}

#pragma mark -
- (IBAction)temporaryPrivateChangeFontAction:(id)sender
{
	// this works around a lack of a setTarget: method in NSFontManger prior to 10.5 - it traps the changeFont
	// message from the Font Manager on behalf of the style inspector and redirects it there. This is the recommended
	// approach for 10.4 as advised by an Apple engineer - it has the advantage of not requiring the ugly hack that
	// was in DK previously, which has been removed.

	// note that the onus is on the style inspector to set this action and reset it correctly when appropriate.

	[mStyleInspector textChangeFontAction:sender];
}

- (void)changeAttributes:(id)sender
{
	[mStyleInspector changeTextAttributes:sender];
}

#pragma mark -
- (void)openStyleInspector
{
	if (mStyleInspector == nil)
		mStyleInspector = [[GCStyleInspector alloc] initWithWindowNibName:@"StyleInspector"];

	[mStyleInspector showWindow:self];
}

- (void)drawingToolRegistrationNote:(NSNotification *)note
{
#pragma unused(note)
	// a new tool was registered. Add it to the tool menu if it's not known already.

	NSArray *names = [[DKToolRegistry sharedToolRegistry] toolNames];
	NSMenu *menu = mUserToolMenu;
	NSInteger m;
	NSMenuItem *item;
	DKDrawingTool *tool;

	m = menu.numberOfItems;

	if (menu == nil || m == 0)
		return;

	do {
		[menu removeItemAtIndex:--m];
	} while (m);

	for (NSString *name in names) {
		tool = [[DKToolRegistry sharedToolRegistry] drawingToolWithName:name];

		item = [menu addItemWithTitle:name action:@selector(selectDrawingToolByName:) keyEquivalent:@""];
		[item setTarget:nil];

		//if( tool && [tool respondsToSelector:@selector(image)])
		//	[item setImage:[tool image]];
	}
}

#pragma mark -
- (void)openToolPalette
{
	if (mToolPalette == nil)
		mToolPalette = [[GCToolPalette alloc] initWithWindowNibName:@"ToolPalette"];

	[mToolPalette showWindow:self];
}

- (void)openObjectInspector
{
	if (mObjectInspector == nil)
		mObjectInspector = [[GCObjectInspector alloc] initWithWindowNibName:@"ObjectInspector"];

	[mObjectInspector showWindow:self];
}

#pragma mark -
#pragma mark As an NSObject

#pragma mark -
#pragma mark As an NSApplication delegate
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
#pragma unused(aNotification)
	if (getenv("NSZombieEnabled") || getenv("NSAutoreleaseFreedObjectCheckEnabled")) {
		NSLog(@"NSZombieEnabled/NSAutoreleaseFreedObjectCheckEnabled enabled!");
	}

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(drawingToolRegistrationNote:) name:kDKDrawingToolWasRegisteredNotification object:nil];
	[[NSColorPanel sharedColorPanel] setShowsAlpha:YES];

	[self showStyleInspector:self];
	[self showToolPalette:self];
	[self showLayersPalette:self];

	LogEvent_(kInfoEvent, @"app finished launching");
}

- (void)applicationWillFinishLaunching:(NSNotification *)aNotification
{
#pragma unused(aNotification)

	BOOL qm = [[NSUserDefaults standardUserDefaults] boolForKey:@"GCDrawDemo_defaultQualityModulationFlag"];
	[GCDrawDemoDocument setDefaultQualityModulation:qm];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
#pragma unused(aNotification)

	LogEvent_(kInfoEvent, @"app quitting...");

	[[NSUserDefaults standardUserDefaults] setBool:[GCDrawDemoDocument defaultQualityModulation] forKey:@"GCDrawDemo_defaultQualityModulationFlag"];
}

- (IBAction)showAboutBox:(id)sender
{
	BOOL isOptionKeyDown = ((NSApp.currentEvent.modifierFlags & NSAlternateKeyMask) != 0);
	if (isOptionKeyDown) {
		[[LoggingController sharedLoggingController] showLoggingWindow];
	} else {
		[NSApp orderFrontStandardAboutPanel:sender];
	}
}

@end
