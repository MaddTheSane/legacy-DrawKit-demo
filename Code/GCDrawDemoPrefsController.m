#import "GCDrawDemoPrefsController.h"
#import "GCDrawDemoDocument.h"
#import <DKDrawKit/DKObjectDrawingLayer.h>
#import <DKDrawKit/DKBSPObjectStorage.h>

@implementation GCDrawDemoPrefsController

- (IBAction)qualityThrottlingAction:(id)sender
{
	[GCDrawDemoDocument setDefaultQualityModulation:[sender intValue]];
}

- (IBAction)undoableSelectionAction:(id)sender
{
	[DKObjectDrawingLayer setDefaultSelectionChangesAreUndoable:[sender intValue]];
}

- (IBAction)setStorageTypeAction:(id)sender
{
	if ([sender intValue] == 0)
		[DKObjectOwnerLayer setStorageClass:[DKLinearObjectStorage class]];
	else
		[DKObjectOwnerLayer setStorageClass:[DKBSPObjectStorage class]];

	[[NSUserDefaults standardUserDefaults] setObject:NSStringFromClass([DKObjectOwnerLayer storageClass]) forKey:@"DKObjectStorageClass"];
}

- (void)awakeFromNib
{
	mQualityThrottlingCheckbox.intValue = [GCDrawDemoDocument defaultQualityModulation];
	mUndoSelectionsCheckbox.intValue = [DKObjectDrawingLayer defaultSelectionChangesAreUndoable];
	mStorageTypeCheckbox.intValue = 0;
}

@end
