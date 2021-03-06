#import "GCObjectInspector.h"

#import <DKDrawKit/DKDrawKit.h>

@implementation GCObjectInspector
#pragma mark As a GCObjectInspector
- (void)updateTabAtIndex:(DKObjectInspectorTab)tab withSelection:(NSArray *)sel
{
	mSel = nil;

	switch (tab) {
		case kDKObjectInspectorTabNoItems:
			break;

		case kDKObjectInspectorTabMultipleItems:
			mMultiInfoItemCountField.integerValue = sel.count;
			break;

		case kDKObjectInspectorTabGroupItem:
			[self updateGroupTabWithObject:sel.lastObject];
			break;

		case kDKObjectInspectorTabSingleItem:
			mSel = sel.lastObject;
			[self updateSingleItemTabWithObject:mSel];
			break;
		default:
			break;
	}
}

- (void)updateGroupTabWithObject:(DKShapeGroup *)group
{
	mGroupInfoItemCountField.integerValue = [group groupObjects].count;
}

- (void)updateSingleItemTabWithObject:(DKDrawableObject *)obj
{
	CGFloat cFactor = 1.0;
	NSPoint loc = obj.location;

	if (mConvertCoordinates) {
		cFactor = 1.0 / [obj.drawing unitToPointsConversionFactor];
		loc = [obj.drawing.gridLayer gridLocationForPoint:loc];
	}

	if ([obj isKindOfClass:[DKDrawablePath class]] || obj.locked) {
		[mGenInfoAngleField setEnabled:NO];
		[mGenInfoWidthField setEnabled:NO];
		[mGenInfoHeightField setEnabled:NO];
	} else {
		[mGenInfoAngleField setEnabled:YES];
		[mGenInfoWidthField setEnabled:YES];
		[mGenInfoHeightField setEnabled:YES];
	}

	mGenInfoAngleField.floatValue = obj.angleInDegrees;
	mGenInfoWidthField.floatValue = obj.size.width * cFactor;
	mGenInfoHeightField.floatValue = obj.size.height * cFactor;

	mGenInfoLocationXField.floatValue = loc.x;
	mGenInfoLocationYField.floatValue = loc.y;
	mGenInfoTypeField.stringValue = NSStringFromClass([obj class]);

	if (obj.locked) {
		[mGenInfoLocationXField setEnabled:NO];
		[mGenInfoLocationYField setEnabled:NO];
		mLockIconImageWell.image = [NSImage imageNamed:NSImageNameLockLockedTemplate];
		[mMetaTableView setEnabled:NO];
		[mMetaAddItemButton setEnabled:NO];
		[mMetaRemoveItemButton setEnabled:NO];
	} else {
		[mGenInfoLocationXField setEnabled:YES];
		[mGenInfoLocationYField setEnabled:YES];
		mLockIconImageWell.image = [NSImage imageNamed:NSImageNameLockUnlockedTemplate];
		[mMetaTableView setEnabled:YES];
		[mMetaAddItemButton setEnabled:YES];
		[mMetaRemoveItemButton setEnabled:YES];
	}

	if ([obj isKindOfClass:[DKShapeGroup class]])
		mGroupInfoItemCountField.integerValue = [(DKShapeGroup *)obj groupObjects].count;
	else
		mGroupInfoItemCountField.stringValue = @"n/a";

	DKStyle *style = obj.style;

	if (style != nil) {
		NSString *cs = style.name;

		if (cs != nil)
			mGenInfoStyleNameField.stringValue = cs;
		else
			mGenInfoStyleNameField.stringValue = @"(unnamed)";
	} else
		mGenInfoStyleNameField.stringValue = @"none";

	// refresh the metadata table

	[mMetaTableView reloadData];
}

- (void)objectChanged:(NSNotification *)note
{
	if (note.object == mSel)
		[self updateSingleItemTabWithObject:mSel];
}

- (void)styleChanged:(NSNotification *)note
{
	if (note.object == mSel.style)
		[self updateSingleItemTabWithObject:mSel];
}

#pragma mark -
- (IBAction)addMetaItemAction:(id)sender
{
	static NSInteger keySeed = 1;

	NSInteger tag = [sender selectedItem].tag;

	NSString *key = [NSString stringWithFormat:@"** change me %ld **", (long)(keySeed++)];

	switch (tag) {
		case kDKMetaDataItemTypeString:
			[mSel setString:@"" forKey:key];
			break;

		case kDKMetaDataItemTypeInteger:
			[mSel setIntValue:0 forKey:key];
			break;

		case kDKMetaDataItemTypeFloat:
			[mSel setFloatValue:0.0 forKey:key];
			break;
		default:
			break;
	}

	[mMetaTableView reloadData];
}

- (IBAction)removeMetaItemAction:(id)sender
{
#pragma unused(sender)
	NSInteger sel = mMetaTableView.selectedRow;
	NSArray *keys = [[mSel userInfo].allKeys sortedArrayUsingSelector:@selector(compare:)];
	NSString *oldKey = keys[sel];

	[mSel removeMetadataForKey:oldKey];
	[mMetaTableView reloadData];
}

- (IBAction)ungroupButtonAction:(id)sender
{
#pragma unused(sender)
}

- (IBAction)changeCoordinatesAction:(id)sender
{
	mConvertCoordinates = [[sender selectedCell] tag] == 0;
	[self updateSingleItemTabWithObject:mSel];
}

- (IBAction)changeLocationAction:(id)sender
{
#pragma unused(sender)
	NSPoint loc = NSMakePoint(mGenInfoLocationXField.floatValue, mGenInfoLocationYField.floatValue);

	if (mConvertCoordinates)
		loc = [mSel.drawing.gridLayer pointForGridLocation:loc];

	mSel.location = loc;
	[mSel.drawing.undoManager setActionName:NSLocalizedString(@"Position Object", @"undo for position object")];
}

- (IBAction)changeSizeAction:(id)sender
{
#pragma unused(sender)
	NSSize size = NSMakeSize(mGenInfoWidthField.floatValue, mGenInfoHeightField.floatValue);
	CGFloat cFactor = 1.0;

	if (mConvertCoordinates) {
		cFactor = [mSel.drawing unitToPointsConversionFactor];
		size.width *= cFactor;
		size.height *= cFactor;
	}

	mSel.size = size;
	[mSel.drawing.undoManager setActionName:NSLocalizedString(@"Set Object Size", @"undo for size object")];
}

- (IBAction)changeAngleAction:(id)sender
{
#pragma unused(sender)

	CGFloat radians = ([sender doubleValue] * M_PI / 180.0);
	mSel.angle = radians;
	[mSel.drawing.undoManager setActionName:NSLocalizedString(@"Set Object Angle", @"undo for angle object")];
}

#pragma mark -
#pragma mark As a DKDrawkitInspectorBase
- (void)redisplayContentForSelection:(NSArray *)selection
{
	// this inspector really needs to work with the unfiltered selection, so fetch it:

	DKLayer *layer = [self currentActiveLayer];

	if ([layer isKindOfClass:[DKObjectDrawingLayer class]]) {
		selection = ((DKObjectDrawingLayer *)layer).selection.allObjects;
	}

	DKObjectInspectorTab tab;
	NSInteger oc = selection.count;

	if (oc == 0) {
		mSel = nil;
		tab = kDKObjectInspectorTabNoItems;
	} else if (oc > 1) {
		mSel = nil;
		tab = kDKObjectInspectorTabMultipleItems;
	} else {
		tab = kDKObjectInspectorTabSingleItem;
	}
	[mMetaTableView reloadData];
	[self updateTabAtIndex:tab withSelection:selection];
	[mMainTabView selectTabViewItemAtIndex:tab];
}

#pragma mark -
#pragma mark As an NSWindowController

- (void)windowDidLoad
{
	[(NSPanel *)self.window setFloatingPanel:YES];
	[(NSPanel *)self.window setBecomesKeyOnlyIfNeeded:YES];
	[mMainTabView selectTabViewItemAtIndex:kDKObjectInspectorTabNoItems];

	mConvertCoordinates = YES;

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(objectChanged:) name:kDKDrawableDidChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(styleChanged:) name:kDKStyleNameChangedNotification object:nil];
}

#pragma mark -
#pragma mark As part of NSTableDataSource Protocol

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
#pragma unused(aTableView)

	return [mSel metadataKeys].count;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
#pragma unused(aTableView)

	NSArray *keys = [[mSel metadataKeys] sortedArrayUsingSelector:@selector(compare:)];
	NSString *key = keys[rowIndex];

	if ([aTableColumn.identifier isEqualToString:@"key"])
		return key;
	else
		return [[mSel metadataItemForKey:key] value];
}

- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
#pragma unused(aTableView)

	NSArray *keys = [[mSel metadataKeys] sortedArrayUsingSelector:@selector(compare:)];
	NSString *oldKey = keys[rowIndex];

	if ([aTableColumn.identifier isEqualToString:@"key"]) {
		DKMetadataItem *item = [mSel metadataItemForKey:oldKey];

		[mSel removeMetadataForKey:oldKey];
		[mSel setMetadataItem:item forKey:anObject];
	} else
		[mSel setMetadataItemValue:anObject forKey:oldKey];
}

- (BOOL)tableView:(NSTableView *)aTableView shouldEditTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
#pragma unused(aTableView)
#pragma unused(aTableColumn)
#pragma unused(rowIndex)

	return !mSel.locked;
}

@end
