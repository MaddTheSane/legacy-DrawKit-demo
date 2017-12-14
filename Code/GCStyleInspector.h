///**********************************************************************************************************************************
///  GCStyleInspector.h
///  GCDrawKit
///
///  Created by graham on 13/05/2007.
///  Released under the Creative Commons license 2007 Apptree.net.
///
///
///  This work is licensed under the Creative Commons Attribution-ShareAlike 2.5 License.
///  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/2.5/ or send a letter to
///  Creative Commons, 543 Howard Street, 5th Floor, San Francisco, California, 94105, USA.
///
///**********************************************************************************************************************************

#import <Cocoa/Cocoa.h>
#import <DKDrawKit/DKDrawkit.h>
#import "GCDashEditor.h"

@class GCDashEditor;
@class GCOutlineView;
@class GCBasicDialogController;
@class WTGradientControl;

@interface GCStyleInspector : DKDrawkitInspectorBase <NSOutlineViewDelegate, NSOutlineViewDataSource, GCDashEditorDelegate, GCDashEditViewDelegate> {
	IBOutlet GCOutlineView *mOutlineView;
	IBOutlet NSTabView *mTabView;
	IBOutlet NSPopUpButton *mAddRendererPopUpButton;
	IBOutlet NSButton *mRemoveRendererButton;
	IBOutlet NSPopUpButton *mActionsPopUpButton;

	IBOutlet GCDashEditor *mDashEditController;
	IBOutlet GCBasicDialogController *mScriptEditController;

	IBOutlet NSButton *mStyleCloneButton;
	IBOutlet NSPopUpButton *mStyleLibraryPopUpButton;
	IBOutlet NSButton *mStyleLockCheckbox;
	IBOutlet NSTextField *mStyleNameTextField;
	IBOutlet NSImageView *mStylePreviewImageWell;
	IBOutlet NSTextField *mStyleRegisteredIndicatorText;
	IBOutlet NSButton *mStyleAddToLibraryButton;
	IBOutlet NSButton *mStyleRemoveFromLibraryButton;
	IBOutlet NSButton *mStyleSharedCheckbox;
	IBOutlet NSTextField *mStyleClientCountText;

	IBOutlet NSView *mStrokeControlsTabView;
	IBOutlet NSColorWell *mStrokeColourWell;
	IBOutlet NSSlider *mStrokeSlider;
	IBOutlet NSTextField *mStrokeTextField;
	IBOutlet NSButton *mStrokeShadowCheckbox;
	IBOutlet id mStrokeShadowGroup;
	IBOutlet NSColorWell *mStrokeShadowColourWell;
	IBOutlet NSSlider *mStrokeShadowAngle;
	IBOutlet NSSlider *mStrokeShadowBlur;
	IBOutlet NSSlider *mStrokeShadowDistance;
	IBOutlet NSPopUpButton *mStrokeDashPopUpButton;
	IBOutlet NSPopUpButton *mStrokeArrowDimensionOptions;
	IBOutlet NSPopUpButton *mStrokeArrowStartPopUpButton;
	IBOutlet NSPopUpButton *mStrokeArrowEndPopUpButton;
	IBOutlet NSImageView *mStrokeArrowPreviewImageWell;
	IBOutlet NSSlider *mStrokeZZLength;
	IBOutlet NSSlider *mStrokeZZAmp;
	IBOutlet NSSlider *mStrokeZZSpread;
	IBOutlet NSSegmentedControl *mStrokeLineJoinSelector;
	IBOutlet NSSegmentedControl *mStrokeLineCapSelector;
	IBOutlet NSSlider *mStrokeRoughnessSlider;

	IBOutlet NSView *mFillControlsTabView;
	IBOutlet WTGradientControl *mFillGradientControlBar;
	IBOutlet NSButton *mFillGradientAddButton;
	IBOutlet NSButton *mFillGradientRemoveButton;
	IBOutlet NSSlider *mFillGradientAngleSlider;
	IBOutlet NSTextField *mFillGradientAngleTextField;
	IBOutlet NSStepper *mFillGradientAngleLittleArrows;
	IBOutlet NSButton *mFillGradientRelativeToObject;
	IBOutlet NSColorWell *mFillColourWell;
	IBOutlet NSButton *mFillShadowCheckbox;
	IBOutlet id mFillShadowGroup;
	IBOutlet NSColorWell *mFillShadowColourWell;
	IBOutlet NSSlider *mFillShadowAngle;
	IBOutlet NSSlider *mFillShadowBlur;
	IBOutlet NSSlider *mFillShadowDistance;
	IBOutlet NSImageView *mFillPatternImagePreview;
	IBOutlet NSSlider *mFillZZLength;
	IBOutlet NSSlider *mFillZZAmp;
	IBOutlet NSSlider *mFillZZSpread;

	IBOutlet NSImageView *mImageWell;
	IBOutlet NSTextField *mImageIdentifierTextField;
	IBOutlet NSSlider *mImageOpacitySlider;
	IBOutlet NSSlider *mImageScaleSlider;
	IBOutlet NSSlider *mImageAngleSlider;
	IBOutlet NSButton *mImageClipToPathCheckbox;
	IBOutlet NSPopUpButton *mImageFittingPopUpMenu;

	IBOutlet NSPopUpButton *mCIFilterPopUpMenu;
	IBOutlet NSButton *mCIFilterClipToPathCheckbox;

	IBOutlet NSTextField *mTextLabelTextField;
	IBOutlet NSTextField *mTextIdentifierTextField;
	IBOutlet NSPopUpButton *mTextLayoutPopUpButton;
	IBOutlet NSPopUpButton *mTextAlignmentPopUpButton;
	IBOutlet NSPopUpButton *mTextLabelPlacementPopUpButton;
	IBOutlet NSButton *mTextWrapLinesCheckbox;
	IBOutlet NSButton *mTextClipToPathCheckbox;
	IBOutlet NSButton *mTextRelativeAngleCheckbox;
	IBOutlet NSSlider *mTextAngleSlider;
	IBOutlet NSColorWell *mTextColourWell;
	IBOutlet NSSlider *mFlowedTextInsetSlider;

	IBOutlet NSColorWell *mHatchColourWell;
	IBOutlet NSSlider *mHatchSpacingSlider;
	IBOutlet NSTextField *mHatchSpacingTextField;
	IBOutlet NSSlider *mHatchLineWidthSlider;
	IBOutlet NSTextField *mHatchLineWidthTextField;
	IBOutlet NSSlider *mHatchAngleSlider;
	IBOutlet NSTextField *mHatchAngleTextField;
	IBOutlet NSSlider *mHatchLeadInSlider;
	IBOutlet NSTextField *mHatchLeadInTextField;
	IBOutlet NSPopUpButton *mHatchDashPopUpButton;
	IBOutlet NSButton *mHatchRelativeAngleCheckbox;
	IBOutlet NSSegmentedControl *mHatchLineCapButton;

	IBOutlet NSView *mPDControlsTabView;
	IBOutlet NSSlider *mPDIntervalSlider;
	IBOutlet NSSlider *mPDScaleSlider;
	IBOutlet NSButton *mPDNormalToPathCheckbox;
	IBOutlet NSSlider *mPDLeaderSlider;
	IBOutlet NSImageView *mPDPreviewImage;
	IBOutlet NSSlider *mPDPatAltOffsetSlider;
	IBOutlet NSSlider *mPDRampProportionSlider;
	IBOutlet NSSlider *mPDAngleSlider;
	IBOutlet NSButton *mPDRelativeAngleCheckbox;
	IBOutlet NSSlider *mMotifAngleSlider;
	IBOutlet NSButton *mMotifRelativeAngleCheckbox;

	IBOutlet NSPopUpButton *mBlendModePopUpButton;
	IBOutlet NSSlider *mBlendGroupAlphaSlider;
	IBOutlet NSImageView *mBlendGroupImagePreview;

	IBOutlet NSSlider *mShadowAngleSlider;
	IBOutlet NSSlider *mShadowDistanceSlider;
	IBOutlet NSColorWell *mShadowColourWell;
	IBOutlet NSSlider *mShadowBlurRadiusSlider;

	DKStyle *mStyle;
	DKRasterizer *mSelectedRendererRef;
	BOOL mIsChangingGradient;
	DKRasterizer *mDragItem;
	DKStrokeDash *mSavedDash;
}

// general state management:

@property (copy) DKStyle *style;
- (void)updateUIForStyle;
- (void)updateStylePreview;

// responding to notifications:

- (void)styleChanged:(NSNotification *)note;
- (void)styleAttached:(NSNotification *)note;
- (void)styleRegistered:(NSNotification *)note;

// selecting which tab view is shown for the selected rasterizer:

- (void)selectTabPaneForObject:(DKRasterizer *)obj;
- (void)addAndSelectNewRenderer:(DKRasterizer *)obj;

// refreshing the UI for different selected rasterizers as the selection changes:

- (void)updateSettingsForStroke:(DKStroke *)stroke;
- (void)updateSettingsForFill:(DKFill *)fill;
- (void)updateSettingsForHatch:(DKHatching *)hatch;
- (void)updateSettingsForImage:(DKImageAdornment *)ir;
- (void)updateSettingsForCoreImageEffect:(DKCIFilterRastGroup *)effg;
- (void)updateSettingsForTextLabel:(DKTextAdornment *)tlr;
- (void)updateSettingsForPathDecorator:(DKPathDecorator *)pd;
- (void)updateSettingsForBlendEffect:(DKQuartzBlendRastGroup *)brg;

// setting up various menu listings:

- (void)populatePopUpButtonWithLibraryStyles:(NSPopUpButton *)button;
- (void)populateMenuWithDashes:(NSMenu *)menu;
- (void)populateMenuWithCoreImageFilters:(NSMenu *)menu;

// opening the subsidiary sheet for editing dashes:

- (void)openDashEditor;

// actions from stroke widgets:

- (IBAction)strokeColourAction:(id)sender;
- (IBAction)strokeWidthAction:(id)sender;
- (IBAction)strokeShadowCheckboxAction:(id)sender;
- (IBAction)strokeDashMenuAction:(id)sender;
- (IBAction)strokePathScaleAction:(id)sender;
- (IBAction)strokeArrowStartMenuAction:(id)sender;
- (IBAction)strokeArrowEndMenuAction:(id)sender;
- (IBAction)strokeArrowShowDimensionAction:(id)sender;
- (IBAction)strokeTrimLengthAction:(id)sender;
- (IBAction)strokeZigZagLengthAction:(id)sender;
- (IBAction)strokeZigZagAmplitudeAction:(id)sender;
- (IBAction)strokeZigZagSpreadAction:(id)sender;
- (IBAction)strokeLineJoinStyleAction:(id)sender;
- (IBAction)strokeLineCapStyleAction:(id)sender;
- (IBAction)strokeRoughnessAction:(id)sender;

// actions from fill widgets:

- (IBAction)fillColourAction:(id)sender;
- (IBAction)fillShadowCheckboxAction:(id)sender;
- (IBAction)fillGradientAction:(id)sender;
- (IBAction)fillRemoveGradientAction:(id)sender;
- (IBAction)fillAddGradientAction:(id)sender;
- (IBAction)fillGradientAngleAction:(id)sender;
- (IBAction)fillGradientRelativeToObjectAction:(id)sender;
- (IBAction)fillPatternPasteImageAction:(id)sender;
- (IBAction)fillZigZagLengthAction:(id)sender;
- (IBAction)fillZigZagAmplitudeAction:(id)sender;
- (IBAction)fillZigZagSpreadAction:(id)sender;

// actions from style registry widgets:

- (IBAction)scriptButtonAction:(id)sender;
- (IBAction)libraryMenuAction:(id)sender;
- (IBAction)libraryItemAction:(id)sender;
- (IBAction)sharedStyleCheckboxAction:(id)sender;
- (IBAction)styleNameAction:(id)sender;
- (IBAction)cloneStyleAction:(id)sender;
- (IBAction)unlockStyleAction:(id)sender;

// actions from general style widgets:

- (IBAction)addRendererElementAction:(id)sender;
- (IBAction)removeRendererElementAction:(id)sender;
- (IBAction)duplicateRendererElementAction:(id)sender;
- (IBAction)copyRendererElementAction:(id)sender;
- (IBAction)pasteRendererElementAction:(id)sender;
- (IBAction)removeTextAttributesAction:(id)sender;

// actions from image adornment widgets:

- (IBAction)imageFileButtonAction:(id)sender;
- (IBAction)imageWellAction:(id)sender;
- (IBAction)imageIdentifierAction:(id)sender;
- (IBAction)imageOpacityAction:(id)sender;
- (IBAction)imageScaleAction:(id)sender;
- (IBAction)imageAngleAction:(id)sender;
- (IBAction)imageFittingMenuAction:(id)sender;
- (IBAction)imageClipToPathAction:(id)sender;

// actions from hatch widgets:

- (IBAction)hatchColourWellAction:(id)sender;
- (IBAction)hatchSpacingAction:(id)sender;
- (IBAction)hatchLineWidthAction:(id)sender;
- (IBAction)hatchAngleAction:(id)sender;
- (IBAction)hatchRelativeAngleAction:(id)sender;
- (IBAction)hatchDashMenuAction:(id)sender;
- (IBAction)hatchLeadInAction:(id)sender;

// actions from CI Filter widgets:

- (IBAction)filterMenuAction:(id)sender;
- (IBAction)filterClipToPathAction:(id)sender;

// actions from text adornment widgets

- (IBAction)textLabelAction:(id)sender;
- (IBAction)textLayoutAction:(id)sender;
- (IBAction)textAlignmentMenuAction:(id)sender;
- (IBAction)textPlacementMenuAction:(id)sender;
- (IBAction)textWrapLinesAction:(id)sender;
- (IBAction)textClipToPathAction:(id)sender;
- (IBAction)textRelativeAngleAction:(id)sender;
- (IBAction)textAngleAction:(id)sender;
- (IBAction)textFontButtonAction:(id)sender;
- (IBAction)textColourAction:(id)sender;
- (IBAction)textChangeFontAction:(id)sender;
- (IBAction)textFlowInsetAction:(id)sender;

- (void)changeTextAttributes:(id)sender;

// actions from path decaorator widgets:

- (IBAction)pathDecoratorIntervalAction:(id)sender;
- (IBAction)pathDecoratorScaleAction:(id)sender;
- (IBAction)pathDecoratorPasteObjectAction:(id)sender;
- (IBAction)pathDecoratorPathNormalAction:(id)sender;
- (IBAction)pathDecoratorLeaderDistanceAction:(id)sender;
- (IBAction)pathDecoratorAltPatternAction:(id)sender;
- (IBAction)pathDecoratorRampProportionAction:(id)sender;
- (IBAction)pathDecoratorAngleAction:(id)sender;
- (IBAction)pathDecoratorRelativeAngleAction:(id)sender;
- (IBAction)pathDecoratorMotifAngleAction:(id)sender;
- (IBAction)pathDecoratorMotifRelativeAngleAction:(id)sender;

// actions from blend effect widgets:

- (IBAction)blendModeAction:(id)sender;
- (IBAction)blendGroupAlphaAction:(id)sender;
- (IBAction)blendGroupImagePasteAction:(id)sender;

// actions from shadow widgets:

- (IBAction)shadowAngleAction:(id)sender;
- (IBAction)shadowDistanceAction:(id)sender;
- (IBAction)shadowBlurRadiusAction:(id)sender;
- (IBAction)shadowColourAction:(id)sender;

@end

@interface NSImage (ImageResources)

+ (NSImage *)imageNamed:(NSImageName)name fromBundleForClass:(Class)aClass;

@end

//! tab indexes for main tab view
typedef NS_ENUM(NSInteger, DKInspectorTabs) {
	kDKInspectorStrokeTab = 0,
	kDKInspectorFillTab = 1,
	kDKInspectorMultipleItemsTab = 2,
	kDKInspectorNoItemsTab = 3,
	kDKInspectorStylePreviewTab = 4,
	kDKInspectorImageTab = 5,
	kDKInspectorFilterTab = 6,
	kDKInspectorLabelTab = 7,
	kDKInspectorHatchTab = 8,
	kDKInspectorPathDecorTab = 9,
	kDKInspectorBlendModeTab = 10
};

//! tab indexes for fill type tab view
typedef NS_ENUM(NSInteger, DKInspectorFillTypes) {
	kDKInspectorFillTypeSolid = 0,
	kDKInspectorFillTypeGradient = 1,
	kDKInspectorFillTypePattern = 2
};

//! tags in Add Renderer menu
typedef NS_ENUM(NSInteger, DKRendererTags) {
	kDKAddStrokeRendererTag = 0,
	kDKAddFillRendererTag = 1,
	kDKAddGroupRendererTag = 2,
	kDKAddImageRendererTag = 3,
	kDKAddCoreEffectRendererTag = 4,
	kDKAddLabelRendererTag = 5,
	kDKAddHatchRendererTag = 6,
	kDKAddArrowStrokeRendererTag = 7,
	kDKAddPathDecoratorRendererTag = 8,
	kDKAddPatternFillRendererTag = 9,
	kDKAddBlendEffectRendererTag = 10,
	kDKAddZigZagStrokeRendererTag = 11,
	kDKAddZigZagFillRendererTag = 12,
	kDKAddRoughStrokeRendererTag = 13
};

//! tags used to selectively hide or disable particular items in the UI (such as labels) without needing
//! an explicit outlet to them. The tags are deliberately set to arbitrary numbers that are unlikely to be accidentally set.
typedef NS_ENUM(NSInteger, DKParameterItemsTags) {
	kDKZigZagParameterItemsTag = 145,
	kDKPathDecoratorParameterItemsTag = 146,
	kDKPatternFillParameterItemsTag = 147,
	kDKArrowStrokeParameterItemsTag = 148,
	kDKShadowParameterItemsTag = 149,
	kDKRoughStrokeParameterItemsTag = 150
};

extern NSString *kDKTableRowInternalDragPasteboardType;

// utility categories that help manage the user interface

@interface NSMenu (GCAdditions)

- (void)disableItemsWithTag:(int)tag;
- (void)uncheckAllItems;

@end

@interface NSView (TagEnablingAdditions)

- (void)setSubviewsWithTag:(NSInteger)tag hidden:(BOOL)hide;
- (void)setSubviewsWithTag:(NSInteger)tag enabled:(BOOL)enable;

@end
