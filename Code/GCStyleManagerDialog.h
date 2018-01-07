/* GCStyleManagerDialog */

#import <Cocoa/Cocoa.h>
#import <DKDrawKit/DKStyleRegistry.h>
#import "GCTableView.h"
#import "GCBasicDialogController.h"

@class DKStyleRegistry, DKStyle;
@class GCBasicDialogController;

@interface GCStyleManagerDialog : NSWindowController <NSTableViewDataSource, NSTableViewDelegate, DKStyleRegistryDelegate, GCBasicDialogDelegate> {
	IBOutlet NSButton *mAddCategoryButton;
	IBOutlet NSButton *mDeleteCategoryButton;
	IBOutlet GCTableView *mStyleCategoryList;
	IBOutlet NSMatrix *mStyleIconMatrix;
	IBOutlet NSTextField *mStyleNameTextField;
	IBOutlet NSImageView *mPreviewImageWell;
	IBOutlet NSTabView *mStyleListTabView;
	IBOutlet NSTableView *mStyleBrowserList;
	IBOutlet NSButton *mDeleteStyleButton;
	IBOutlet GCBasicDialogController *mKeyChangeDialogController;

	__unsafe_unretained DKStyle *mSelectedStyle;
	NSString *mSelectedCategory;
}
- (IBAction)addCategoryAction:(id)sender;
- (IBAction)deleteCategoryAction:(id)sender;
- (IBAction)styleIconMatrixAction:(id)sender;
- (IBAction)styleKeyChangeAction:(id)sender;
- (IBAction)styleDeleteAction:(id)sender;
- (IBAction)registryResetAction:(id)sender;
- (IBAction)saveStylesToFileAction:(id)sender;
- (IBAction)loadStylesFromFileAction:(id)sender;

@property (readonly, copy) DKStyleRegistry *styles;
- (void)populateMatrixWithStyleInCategory:(NSString *)cat;
- (void)updateUIForStyle:(DKStyle *)style;
- (void)updateUIForCategory:(NSString *)category;

- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(NSModalResponse)returnCode contextInfo:(void *)contextInfo;
- (void)alertDidEnd:(NSAlert *)alert returnCode:(NSModalResponse)returnCode contextInfo:(void *)contextInfo;

@end
