/* GCStyleManagerDialog */

#import <Cocoa/Cocoa.h>
#import <DKDrawKit/DKStyle.h>
#import <DKDrawKit/DKStyleRegistry.h>
#import "GCSTableView.h"
#import "GCSBasicDialogController.h"

@class DKStyle;

@interface GCSStyleManagerDialog : NSWindowController <NSTableViewDataSource, NSTableViewDelegate, DKStyleRegistryDelegate, GCSBasicDialogDelegate> {
	IBOutlet NSButton *mAddCategoryButton;
	IBOutlet NSButton *mDeleteCategoryButton;
	IBOutlet GCSTableView *mStyleCategoryList;
	IBOutlet NSMatrix *mStyleIconMatrix;
	IBOutlet NSTextField *mStyleNameTextField;
	IBOutlet NSImageView *mPreviewImageWell;
	IBOutlet NSTabView *mStyleListTabView;
	IBOutlet NSTableView *mStyleBrowserList;
	IBOutlet NSButton *mDeleteStyleButton;
	IBOutlet GCSBasicDialogController *mKeyChangeDialogController;

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

- (void)alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;

@end
