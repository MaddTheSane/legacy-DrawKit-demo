/* GCLayersPaletteController */

#import <DKDrawKit/DKDrawkitInspectorBase.h>
#import <DKDrawKit/DKDrawing.h>
#import "GCSTableView.h"

@interface GCSLayersPaletteController : DKDrawkitInspectorBase <NSTableViewDataSource, NSTableViewDelegate, GCSColourCellHack> {
	IBOutlet NSTableView *mLayersTable;
	IBOutlet NSButton *mAutoActivateCheckbox;
	NSColor *mTemporaryColour;
	NSInteger mTemporaryColourRow;
}

@property (strong) DKDrawing *drawing;

- (IBAction)addLayerButtonAction:(id)sender;
- (IBAction)removeLayerButtonAction:(id)sender;
- (IBAction)autoActivationAction:(id)sender;

- (void)setTemporaryColour:(NSColor *)aColour forTableView:(NSTableView *)tView row:(NSInteger)row;
@end

extern NSPasteboardType kDKTableRowInternalDragPasteboardType;
