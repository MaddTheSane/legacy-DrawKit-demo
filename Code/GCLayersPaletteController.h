/* GCLayersPaletteController */

#import <DKDrawKit/DKDrawkitInspectorBase.h>


@class DKDrawing;



@interface GCLayersPaletteController : DKDrawkitInspectorBase <NSTableViewDataSource, NSTableViewDelegate>
{
    IBOutlet NSTableView *mLayersTable;
	IBOutlet id		mAutoActivateCheckbox;
	NSColor*		mTemporaryColour;
	NSInteger				mTemporaryColourRow;
}


- (void)			setDrawing:(DKDrawing*) drawing;
- (DKDrawing*)		drawing;

- (IBAction)		addLayerButtonAction:(id)sender;
- (IBAction)		removeLayerButtonAction:(id)sender;
- (IBAction)		autoActivationAction:(id) sender;

- (void)			setTemporaryColour:(NSColor*) aColour forTableView:(NSTableView*) tView row:(NSInteger) row;
@end


extern NSString*		kDKTableRowInternalDragPasteboardType;
