/* GCObjectInspector */

#import <Cocoa/Cocoa.h>
#import <DKDrawKit/DKDrawkitInspectorBase.h>


@class DKDrawableObject;
@class DKShapeGroup;


@interface GCObjectInspector : DKDrawkitInspectorBase <NSTableViewDataSource, NSTableViewDelegate>
{
    IBOutlet NSTextField *mGenInfoAngleField;
    IBOutlet NSTextField *mGenInfoHeightField;
    IBOutlet NSTextField *mGenInfoLocationXField;
    IBOutlet NSTextField *mGenInfoLocationYField;
    IBOutlet NSTextField *mGenInfoStyleNameField;
    IBOutlet NSTextField *mGenInfoTypeField;
    IBOutlet NSTextField *mGenInfoWidthField;
	IBOutlet NSMatrix *mGenInfoCoordinateRadioButtons;
	
	IBOutlet NSTextField *mMultiInfoItemCountField;
	IBOutlet NSTextField *mGroupInfoItemCountField;
    IBOutlet NSTabView *mMainTabView;
    IBOutlet NSPopUpButton *mMetaAddItemButton;
    IBOutlet NSButton *mMetaRemoveItemButton;
    IBOutlet NSTableView *mMetaTableView;
    IBOutlet NSTabView *mObjectTabView;
	
	IBOutlet NSImageView *mLockIconImageWell;
	
	DKDrawableObject*	mSel;
	BOOL				mConvertCoordinates;
}


- (void)			updateTabAtIndex:(NSInteger) tab withSelection:(NSArray*) sel;
- (void)			updateGroupTabWithObject:(DKShapeGroup*) group;
- (void)			updateSingleItemTabWithObject:(DKDrawableObject*) obj;

- (void)			objectChanged:(NSNotification*) note;
- (void)			styleChanged:(NSNotification*) note;

- (IBAction)		addMetaItemAction:(id)sender;
- (IBAction)		removeMetaItemAction:(id)sender;
- (IBAction)		ungroupButtonAction:(id)sender;

- (IBAction)		changeCoordinatesAction:(id) sender;

- (IBAction)		changeLocationAction:(id) sender;
- (IBAction)		changeSizeAction:(id) sender;
- (IBAction)		changeAngleAction:(id) sender;

@end



enum
{
	kDKObjectInspectorTabNoItems		= 0,
	kDKObjectInspectorTabMultipleItems	= 1,
	kDKObjectInspectorTabSingleItem		= 2,
	kDKObjectInspectorTabGroupItem		= 3
};


enum
{
	kDKMetaDataItemTypeString			= 0,
	kDKMetaDataItemTypeInteger			= 1,
	kDKMetaDataItemTypeFloat			= 2
};




