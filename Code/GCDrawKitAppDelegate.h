/* GCDrawKitAppDelegate */

#import <Cocoa/Cocoa.h>

@class GCStyleInspector;
@class GCToolPalette;
@class GCObjectInspector;
@class GCLayersPaletteController;
@class GCStyleManagerDialog;
@class GCDrawDemoPrefsController;

@interface GCDrawKitAppDelegate : NSObject <NSApplicationDelegate>
{
	GCStyleInspector *mStyleInspector;
	GCToolPalette *mToolPalette;
	GCObjectInspector *mObjectInspector;
	GCLayersPaletteController *mLayersController;
	GCStyleManagerDialog *mStyleManager;
	GCDrawDemoPrefsController *mPrefsController;
	IBOutlet NSMenu*	mUserToolMenu;
}


- (IBAction)		showStyleInspector:(id) sender;
- (IBAction)		showToolPalette:(id) sender;
- (IBAction)		showObjectInspector:(id) sender;
- (IBAction)		showLayersPalette:(id) sender;
- (IBAction)		showStyleManagerDialog:(id) sender;
- (IBAction)		openPreferences:(id) sender;

- (IBAction)		temporaryPrivateChangeFontAction:(id) sender;

- (void)			openStyleInspector;
- (void)			drawingToolRegistrationNote:(NSNotification*) note;

- (void)			openToolPalette;
- (void)			openObjectInspector;

@end
