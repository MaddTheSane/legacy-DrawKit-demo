/* GCDrawKitAppDelegate */

#import <Cocoa/Cocoa.h>

@class GCSStyleInspector;
@class GCSToolPalette;
@class GCSObjectInspector;
@class GCSLayersPaletteController;
@class GCSStyleManagerDialog;
@class GCSDrawDemoPrefsController;

@interface GCSDrawKitAppDelegate : NSObject <NSApplicationDelegate> {
	GCSStyleInspector *mStyleInspector;
	GCSToolPalette *mToolPalette;
	GCSObjectInspector *mObjectInspector;
	GCSLayersPaletteController *mLayersController;
	GCSStyleManagerDialog *mStyleManager;
	GCSDrawDemoPrefsController *mPrefsController;
	IBOutlet NSMenu *mUserToolMenu;
}

- (IBAction)showStyleInspector:(id)sender;
- (IBAction)showToolPalette:(id)sender;
- (IBAction)showObjectInspector:(id)sender;
- (IBAction)showLayersPalette:(id)sender;
- (IBAction)showStyleManagerDialog:(id)sender;
- (IBAction)openPreferences:(id)sender;

- (IBAction)temporaryPrivateChangeFontAction:(id)sender;

- (void)openStyleInspector;
- (void)drawingToolRegistrationNote:(NSNotification *)note;

- (void)openToolPalette;
- (void)openObjectInspector;

@end
