///**********************************************************************************************************************************
///  GCStyleInspector.m
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

#import "GCSStyleInspector.h"

#import "GCSGradientWell.h"
#import "GCSDashEditor.h"
#import "GCSDashEditView.h"
#import "GCSBasicDialogController.h"
#import "WTSGradientControl.h"
#import "DrawDemoSwift-Swift.h"

#import <CoreImage/CIFilter.h>
#import <DKDrawKit/NSShadow+Scaling.h>

@implementation GCSStyleInspector
#pragma mark As a GCStyleInspector

- (void)setStyle:(DKStyle *)style
{
	if (style != mStyle) {
		if (mStyle)
			[[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:mStyle];

		mStyle = style;

		// listen for style change notifications so we can track changes made by undo, etc

		if (mStyle) {
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(styleChanged:) name:kDKStyleDidChangeNotification object:mStyle];
		}
		[self updateUIForStyle];
	}
}

- (DKStyle *)style
{
	return mStyle;
}

- (void)updateUIForStyle
{
	// set up the UI to match the style attached

	//	LogEvent_(kInfoEvent, @"selected style = %@", mStyle );

	mSelectedRendererRef = nil;

	[mOutlineView reloadData];

	if (mStyle != nil) {
		[mOutlineView expandItem:[self style] expandChildren:YES];
		[mOutlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];

		[mStyleLockCheckbox setEnabled:YES];
		mStyleSharedCheckbox.state = [self style].styleSharable;
		mStyleLockCheckbox.state = [self style].locked;
		mStyleClientCountText.integerValue = [self style].countOfClients;

		if ([self style].name)
			mStyleNameTextField.stringValue = [self style].name;
		else
			mStyleNameTextField.stringValue = @"";

		if (!mStyle.locked) {
			[mAddRendererPopUpButton setEnabled:YES];
			[mRemoveRendererButton setEnabled:YES];
			[mStyleNameTextField setEnabled:YES];
			[mStyleSharedCheckbox setEnabled:YES];
			//[mActionsPopUpButton setEnabled:YES];
		} else {
			[mAddRendererPopUpButton setEnabled:NO];
			[mRemoveRendererButton setEnabled:NO];
			[mStyleNameTextField setEnabled:NO];
			[mStyleSharedCheckbox setEnabled:NO];
			//[mActionsPopUpButton setEnabled:NO];
		}

		// if the style isn't in the registry, disable the lock checkbox

		BOOL registered = [self style].styleRegistered;

		//[mStyleLockCheckbox setEnabled:registered];
		mStyleRegisteredIndicatorText.hidden = !registered;
		mStyleAddToLibraryButton.enabled = !registered;
		mStyleRemoveFromLibraryButton.enabled = registered;
		[mStyleCloneButton setEnabled:YES];
		[self updateStylePreview];
	} else {
		[mOutlineView deselectAll:self];
		[mAddRendererPopUpButton setEnabled:NO];
		[mRemoveRendererButton setEnabled:NO];
		mStyleNameTextField.stringValue = @"";
		[mStyleNameTextField setEnabled:NO];
		[mStyleSharedCheckbox setEnabled:NO];
		[mStyleRegisteredIndicatorText setHidden:YES];
		[mStyleAddToLibraryButton setEnabled:NO];
		[mStyleRemoveFromLibraryButton setEnabled:NO];
		[mStyleCloneButton setEnabled:NO];
		[mStyleLockCheckbox setEnabled:NO];
		[mStylePreviewImageWell setImage:nil];
	}
}

- (void)updateStylePreview
{
	NSSize is = NSMakeSize(128, 128);

	NSImage *img = [[[self style] styleSwatchWithSize:is type:kDKStyleSwatchAutomatic] copy];
	mStylePreviewImageWell.image = img;
}

- (void)styleChanged:(NSNotification *)note
{
	//	LogEvent_(kInfoEvent, @"style changed notification: %@", note );

	if (note.object == [self style]) // && !mIsChangingGradient
	{
		if (mSelectedRendererRef == nil)
			[self updateUIForStyle];
		else
			[self selectTabPaneForObject:mSelectedRendererRef];

		[mOutlineView reloadData];
		[self updateStylePreview];
	}
}

- (void)styleAttached:(NSNotification *)note
{
	// a style is being changed in some object - if the style being detached is our current style,
	// then update the UI to show the new one being attached, otherwise just ignore it. This allows this
	// UI to keep up with undo, style pasting, drag modifications and so on

	id theOldStyle = note.userInfo[kDKDrawableOldStyleKey];

	if (theOldStyle == [self style])
		[self setStyle:note.userInfo[kDKDrawableNewStyleKey]];
}

- (void)styleRegistered:(NSNotification *)note
{
#pragma unused(note)
	//[self populateMenuWithLibraryStyles:[mStyleLibraryPopUpButton menu]];

	[self populatePopUpButtonWithLibraryStyles:mStyleLibraryPopUpButton];
}

#pragma mark -
- (void)selectTabPaneForObject:(DKRasterizer *)obj
{
	// given an item in the outline view, this selects the appropriate tab view and sets its widget contents
	// to match the object

	if (mSelectedRendererRef != obj) {
		// reset the font manager's action, in case an earlier label editor changed it:

		[NSFontManager sharedFontManager].action = @selector(changeFont:);
	}

	mSelectedRendererRef = obj;

	int tab = -1;

	if ([obj isKindOfClass:[DKStroke class]])
		tab = kDKInspectorStrokeTab;
	else if ([obj isKindOfClass:[DKFill class]])
		tab = kDKInspectorFillTab;
	else if ([obj isKindOfClass:[DKCIFilterRastGroup class]])
		tab = kDKInspectorFilterTab;
	else if ([obj isKindOfClass:[DKQuartzBlendRastGroup class]])
		tab = kDKInspectorBlendModeTab;
	else if ([obj isKindOfClass:[DKRastGroup class]])
		tab = kDKInspectorStylePreviewTab;
	else if ([obj isKindOfClass:[DKImageAdornment class]])
		tab = kDKInspectorImageTab;
	else if ([obj isKindOfClass:[DKHatching class]])
		tab = kDKInspectorHatchTab;
	else if ([obj isKindOfClass:[DKTextAdornment class]])
		tab = kDKInspectorLabelTab;
	else if ([obj isKindOfClass:[DKPathDecorator class]] || [obj isKindOfClass:[DKFillPattern class]])
		tab = kDKInspectorPathDecorTab;

	//	LogEvent_(kInfoEvent, @"tab selected = %d", tab );

	if (tab != -1) {
		// synch tab's contents with selected renderer attributes

		switch (tab) {
			case kDKInspectorStrokeTab:
				[self updateSettingsForStroke:(DKStroke *)mSelectedRendererRef];
				break;

			case kDKInspectorFillTab:
				[self updateSettingsForFill:(DKFill *)mSelectedRendererRef];
				break;

			case kDKInspectorHatchTab:
				[self updateSettingsForHatch:(DKHatching *)mSelectedRendererRef];
				break;

			case kDKInspectorImageTab:
				[self updateSettingsForImage:(DKImageAdornment *)mSelectedRendererRef];
				break;

			case kDKInspectorFilterTab:
				[self updateSettingsForCoreImageEffect:(DKCIFilterRastGroup *)mSelectedRendererRef];
				break;

			case kDKInspectorLabelTab:
				[self updateSettingsForTextLabel:(DKTextAdornment *)mSelectedRendererRef];
				break;

			case kDKInspectorPathDecorTab:
				[self updateSettingsForPathDecorator:(DKPathDecorator *)mSelectedRendererRef];
				break;

			case kDKInspectorBlendModeTab:
				[self updateSettingsForBlendEffect:(DKQuartzBlendRastGroup *)mSelectedRendererRef];
				break;

			case kDKInspectorStylePreviewTab:
				[self updateStylePreview];
				break;

			default:
				break;
		}

		[mTabView selectTabViewItemAtIndex:tab];
	} else
		[mTabView selectTabViewItemAtIndex:kDKInspectorNoItemsTab];
}

- (void)addAndSelectNewRenderer:(DKRasterizer *)obj
{
	// given a renderer object, this adds it to the end of the currently selected group and selects it.

	NSAssert(obj != nil, @"trying to insert a nil renderer");

	// need to determine which group is currently selected in the outline view to give the item a parent

	DKRastGroup *parent;
	id sel = [mOutlineView itemAtRow:mOutlineView.selectedRow];

	if (sel == nil)
		parent = [self style];
	else {
		if ([sel isKindOfClass:[DKRastGroup class]])
			parent = sel;
		else
			parent = (DKRastGroup *)[sel container];
	}

	mSelectedRendererRef = nil;

	[[self style] notifyClientsBeforeChange];
	[parent addRenderer:obj];
	[[self style] notifyClientsAfterChange];

	[mOutlineView reloadData];

	NSInteger row = [mOutlineView rowForItem:obj];

	if (row != NSNotFound)
		[mOutlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
}

#pragma mark -
- (void)updateSettingsForStroke:(DKStroke *)stroke
{
	// set UI widgets to match stroke's attributes

	mStrokeColourWell.color = stroke.colour;
	mStrokeSlider.doubleValue = stroke.width;
	mStrokeTextField.doubleValue = stroke.width;
	mStrokeShadowCheckbox.intValue = stroke.shadow != nil;

	// set dash menu to match current dash:

	DKStrokeDash *dash = stroke.dash;

	if (dash == nil)
		[mStrokeDashPopUpButton selectItemWithTag:-1]; // None
	else {
		NSInteger i = [mStrokeDashPopUpButton indexOfItemWithRepresentedObject:dash];

		if (i != -1)
			[mStrokeDashPopUpButton selectItemAtIndex:i];
		else
			[mStrokeDashPopUpButton selectItemWithTag:-3]; // Other...
	}

	// set shadow controls (TO DO)

	// set cap/join selector (segmented control)

	mStrokeLineCapSelector.selectedSegment = stroke.lineCapStyle;
	mStrokeLineJoinSelector.selectedSegment = stroke.lineJoinStyle;

	// show/hide auxiliary controls for subclasses

	if ([stroke isKindOfClass:[DKArrowStroke class]]) {
		DKArrowStroke *as = (DKArrowStroke *)stroke;

		[mStrokeControlsTabView setSubviewsWithTag:kDKArrowStrokeParameterItemsTag hidden:NO];
		[mStrokeArrowStartPopUpButton selectItemWithTag:as.arrowHeadAtStart];
		[mStrokeArrowEndPopUpButton selectItemWithTag:as.arrowHeadAtEnd];
		[mStrokeArrowDimensionOptions selectItemWithTag:as.dimensioningLineOptions];

		NSSize previewSize = mStrokeArrowPreviewImageWell.bounds.size;
		NSImage *preview = [as arrowSwatchImageWithSize:previewSize strokeWidth:MIN(8.0, [as width])];
		mStrokeArrowPreviewImageWell.image = preview;
	} else if ([stroke isKindOfClass:[DKRoughStroke class]]) {
		[mStrokeControlsTabView setSubviewsWithTag:kDKRoughStrokeParameterItemsTag hidden:NO];
		[mStrokeControlsTabView setSubviewsWithTag:kDKArrowStrokeParameterItemsTag hidden:YES];
		mStrokeRoughnessSlider.floatValue = ((DKRoughStroke *)stroke).roughness;
	} else {
		[mStrokeControlsTabView setSubviewsWithTag:kDKArrowStrokeParameterItemsTag hidden:YES];
		[mStrokeControlsTabView setSubviewsWithTag:kDKRoughStrokeParameterItemsTag hidden:YES];
	}

	if ([stroke isKindOfClass:[DKZigZagStroke class]]) {
		DKZigZagStroke *zz = (DKZigZagStroke *)stroke;

		mStrokeZZLength.floatValue = zz.wavelength;
		mStrokeZZAmp.floatValue = zz.amplitude;
		mStrokeZZSpread.floatValue = zz.spread;
		[mStrokeControlsTabView setSubviewsWithTag:kDKZigZagParameterItemsTag hidden:NO];
	} else {
		[mStrokeControlsTabView setSubviewsWithTag:kDKZigZagParameterItemsTag hidden:YES];
	}
}

- (void)updateSettingsForFill:(DKFill *)fill
{
	// which tab of the fill type view to display

	int tab = kDKInspectorFillTypeSolid;

	if (fill.gradient != nil)
		tab = kDKInspectorFillTypeGradient;

	NSShadow *fs = fill.shadow;

	mFillShadowCheckbox.intValue = fs != nil;
	mFillColourWell.color = fill.colour;
	[mFillControlsTabView setSubviewsWithTag:kDKShadowParameterItemsTag enabled:fs != nil];

	if (fs != nil) {
		mShadowColourWell.color = fs.shadowColor;
		mShadowBlurRadiusSlider.floatValue = fs.shadowBlurRadius;
		mShadowDistanceSlider.floatValue = fs.distance;
		mShadowAngleSlider.floatValue = fs.angleInDegrees;
	}

	DKGradient *gradient = fill.gradient;

	if (!mIsChangingGradient)
		[mFillGradientControlBar setGradient:gradient];
	mFillGradientRemoveButton.enabled = (gradient != nil);
	mFillGradientAddButton.enabled = (gradient == nil);

	CGFloat angle = gradient.angleInDegrees;

	mFillGradientAngleSlider.floatValue = angle;
	mFillGradientAngleTextField.floatValue = angle;
	mFillGradientAngleLittleArrows.floatValue = angle;

	mFillGradientRelativeToObject.intValue = fill.tracksObjectAngle;

	if ([fill isKindOfClass:[DKZigZagFill class]]) {
		DKZigZagFill *zz = (DKZigZagFill *)fill;

		mFillZZLength.floatValue = zz.wavelength;
		mFillZZAmp.floatValue = zz.amplitude;
		mFillZZSpread.floatValue = zz.spread;
		[mFillControlsTabView setSubviewsWithTag:kDKZigZagParameterItemsTag hidden:NO];
	} else {
		[mFillControlsTabView setSubviewsWithTag:kDKZigZagParameterItemsTag hidden:YES];
	}
}

- (void)updateSettingsForHatch:(DKHatching *)hatch
{
	mHatchColourWell.color = hatch.colour;
	mHatchSpacingSlider.floatValue = hatch.spacing;
	mHatchSpacingTextField.floatValue = hatch.spacing;
	mHatchLineWidthSlider.floatValue = hatch.width;
	mHatchLineWidthTextField.floatValue = hatch.width;
	mHatchAngleSlider.floatValue = hatch.angleInDegrees;
	mHatchAngleTextField.floatValue = hatch.angleInDegrees;
	mHatchLeadInSlider.floatValue = hatch.leadIn;
	mHatchLeadInTextField.floatValue = hatch.leadIn;
	mHatchLineCapButton.selectedSegment = hatch.lineCapStyle;
	mHatchRelativeAngleCheckbox.intValue = hatch.angleIsRelativeToObject;

	// set dash menu to match current dash:

	DKStrokeDash *dash = hatch.dash;

	if (dash == nil)
		[mHatchDashPopUpButton selectItemWithTag:-1];
	else {
		NSInteger i = [mHatchDashPopUpButton indexOfItemWithRepresentedObject:dash];

		if (i != -1)
			[mHatchDashPopUpButton selectItemAtIndex:i];
		else
			[mHatchDashPopUpButton selectItemWithTag:-3];
	}
}

- (void)updateSettingsForImage:(DKImageAdornment *)ir
{
	mImageWell.image = ir.image;
	mImageOpacitySlider.floatValue = ir.opacity;
	mImageScaleSlider.floatValue = ir.scale;
	mImageAngleSlider.floatValue = ir.angleInDegrees;
	mImageClipToPathCheckbox.intValue = ir.clipping;
	mImageIdentifierTextField.stringValue = ir.imageIdentifier;
	[mImageFittingPopUpMenu selectItemWithTag:ir.fittingOption];

	// if fitting option is fit to bounds, or fit proportionally, disable scale slider

	if (ir.fittingOption == kDKClipToBounds)
		[mImageScaleSlider setEnabled:YES];
	else
		[mImageScaleSlider setEnabled:NO];
}

- (void)updateSettingsForCoreImageEffect:(DKCIFilterRastGroup *)effg
{
	mCIFilterClipToPathCheckbox.intValue = effg.clipping;

	// check and select the menu item corresponding to the current filter

	[mCIFilterPopUpMenu selectItemAtIndex:[mCIFilterPopUpMenu.menu indexOfItemWithRepresentedObject:effg.filter]];
}

- (void)updateSettingsForTextLabel:(DKTextAdornment *)tlr
{
	mTextLabelTextField.stringValue = [tlr string] ? [tlr string] : @"";
	[mTextLayoutPopUpButton selectItemWithTag:tlr.layoutMode];
	[mTextAlignmentPopUpButton selectItemWithTag:tlr.alignment];
	mTextWrapLinesCheckbox.intValue = tlr.wrapsLines;
	mTextClipToPathCheckbox.intValue = tlr.clipping;
	mTextRelativeAngleCheckbox.intValue = tlr.appliesObjectAngle;
	mTextAngleSlider.floatValue = tlr.angleInDegrees;
	[mTextLabelPlacementPopUpButton selectItemWithTag:tlr.verticalAlignment];
	mFlowedTextInsetSlider.floatValue = tlr.flowedTextPathInset;

	if (tlr.colour != nil)
		mTextColourWell.color = tlr.colour;
	else
		mTextColourWell.color = [NSColor blackColor];

	// disable items not relevant to path text if that mode is set

	BOOL enable = (tlr.layoutMode != kDKTextLayoutAlongPath && tlr.layoutMode != kDKTextLayoutAlongReversedPath);

	mTextClipToPathCheckbox.enabled = enable;
	mTextRelativeAngleCheckbox.enabled = enable;
	mFlowedTextInsetSlider.enabled = enable;
	mTextAngleSlider.enabled = enable;
	mTextWrapLinesCheckbox.enabled = enable;

	// synchronise the Font Panel to the renderer's settings and set its action to apply to it

	[NSFontManager sharedFontManager].action = @selector(temporaryPrivateChangeFontAction:);
	[[NSFontManager sharedFontManager] setSelectedFont:tlr.font isMultiple:NO];
	[[NSFontManager sharedFontManager] setSelectedAttributes:tlr.textAttributes isMultiple:NO];
}

- (void)updateSettingsForPathDecorator:(DKPathDecorator *)pd
{
	mPDIntervalSlider.floatValue = pd.interval;
	mPDScaleSlider.floatValue = pd.scale;
	mPDNormalToPathCheckbox.intValue = pd.normalToPath;
	mPDLeaderSlider.floatValue = pd.leaderDistance;
	mPDPreviewImage.image = pd.image;
	mPDRampProportionSlider.floatValue = pd.leadInAndOutLengthProportion;

	// if really a fill pattern, deal with the alt offset control

	if ([pd isKindOfClass:[DKFillPattern class]]) {
		mPDPatAltOffsetSlider.floatValue = ((DKFillPattern *)pd).patternAlternateOffset.height;
		mPDAngleSlider.floatValue = [(DKFillPattern *)pd angleInDegrees];
		mPDRelativeAngleCheckbox.intValue = [(DKFillPattern *)pd angleIsRelativeToObject];
		mMotifAngleSlider.floatValue = ((DKFillPattern *)pd).motifAngleInDegrees;
		mMotifRelativeAngleCheckbox.intValue = ((DKFillPattern *)pd).motifAngleIsRelativeToPattern;

		[mPDControlsTabView setSubviewsWithTag:kDKPathDecoratorParameterItemsTag hidden:YES];
		[mPDControlsTabView setSubviewsWithTag:kDKPatternFillParameterItemsTag hidden:NO];
	} else {
		[mPDControlsTabView setSubviewsWithTag:kDKPathDecoratorParameterItemsTag hidden:NO];
		[mPDControlsTabView setSubviewsWithTag:kDKPatternFillParameterItemsTag hidden:YES];
	}
}

- (void)updateSettingsForBlendEffect:(DKQuartzBlendRastGroup *)brg
{
	[mBlendModePopUpButton selectItemWithTag:brg.blendMode];
	mBlendGroupAlphaSlider.floatValue = brg.alpha;
	mBlendGroupImagePreview.image = brg.maskImage;
}

#pragma mark -
- (void)populatePopUpButtonWithLibraryStyles:(NSPopUpButton *)button
{
	NSMenu *styleMenu = [DKStyleRegistry managedStylesMenuWithItemTarget:self itemAction:@selector(libraryItemAction:)];
	button.menu = styleMenu;
	[button setTitle:@"Style Library"];
}

- (void)populateMenuWithDashes:(NSMenu *)menu
{
	NSArray *dashes = [DKStrokeDash registeredDashes];
	NSEnumerator *iter = [dashes objectEnumerator];
	DKStrokeDash *dash;
	NSMenuItem *item;
	int k = 1;

	while ((dash = [iter nextObject]) != nil) {
		item = [menu insertItemWithTitle:@"" action:NULL keyEquivalent:@"" atIndex:k++];

		[item setEnabled:YES];
		//[item setTarget:self];
		item.representedObject = dash;
		item.image = [dash standardDashSwatchImage];
	}
}

- (void)populateMenuWithCoreImageFilters:(NSMenu *)menu
{
	//NSArray*		categories = [NSArray arrayWithObjects:kCICategoryDistortionEffect, kCICategoryStylize, kCICategoryBlur, kCICategorySharpen, nil];
	NSEnumerator *iter = [[CIFilter filterNamesInCategory:kCICategoryStillImage] objectEnumerator];
	NSString *filter;
	NSMenuItem *item;

	[menu removeAllItems];

	while ((filter = [iter nextObject]) != nil) {
		item = [menu addItemWithTitle:[CIFilter localizedNameForFilterName:filter] action:NULL keyEquivalent:@""];
		item.representedObject = filter;
	}
}

#pragma mark -
- (void)openDashEditor
{
	mSavedDash = [(id)mSelectedRendererRef dash]; // in case the editor is doing live preview

	DKStrokeDash *dash = [[(id)mSelectedRendererRef dash] copy];
	mDashEditController.dash = dash;

	// as long as the current renderer supports these methods, the dash editor will work:

	mDashEditController.lineWidth = [(id)mSelectedRendererRef width];
	mDashEditController.lineCapStyle = [(id)mSelectedRendererRef lineCapStyle];
	mDashEditController.lineJoinStyle = [(id)mSelectedRendererRef lineJoinStyle];
	mDashEditController.lineColour = [(id)mSelectedRendererRef colour];

	[mDashEditController openDashEditorInParentWindow:self.window modalDelegate:self];
}

#pragma mark -
- (IBAction)strokeColourAction:(id)sender
{
	((DKStroke *)mSelectedRendererRef).colour = [sender color];
}

- (IBAction)strokeWidthAction:(id)sender
{
	((DKStroke *)mSelectedRendererRef).width = [sender floatValue];
}

- (IBAction)strokeShadowCheckboxAction:(id)sender
{
	((DKStroke *)mSelectedRendererRef).shadow = [sender intValue] ? [DKStyle defaultShadow] : nil;
}

- (IBAction)strokeDashMenuAction:(id)sender
{
	NSInteger tag = [sender selectedItem].tag;

	if (tag == -1)
		[(DKStroke *)mSelectedRendererRef setDash:nil];
	else if (tag == -2)
		[(DKStroke *)mSelectedRendererRef setAutoDash];
	else if (tag == -3) {
		// "Other..." item
		[self openDashEditor];
	} else {
		// menu's attributed object is the dash itself

		DKStrokeDash *dash = [sender selectedItem].representedObject;
		((DKStroke *)mSelectedRendererRef).dash = dash;
	}
}

- (IBAction)strokePathScaleAction:(id)sender
{
	[(DKStroke *)mSelectedRendererRef scaleWidthBy:[sender floatValue]];
}

- (IBAction)strokeArrowStartMenuAction:(id)sender
{
	DKArrowHeadKind kind = (DKArrowHeadKind)[sender selectedItem].tag;
	((DKArrowStroke *)mSelectedRendererRef).arrowHeadAtStart = kind;
}

- (IBAction)strokeArrowEndMenuAction:(id)sender
{
	DKArrowHeadKind kind = (DKArrowHeadKind)[sender selectedItem].tag;
	((DKArrowStroke *)mSelectedRendererRef).arrowHeadAtEnd = kind;
}

- (IBAction)strokeArrowShowDimensionAction:(id)sender
{
	((DKArrowStroke *)mSelectedRendererRef).dimensioningLineOptions = [sender selectedItem].tag;
}

- (IBAction)strokeTrimLengthAction:(id)sender
{
	((DKStroke *)mSelectedRendererRef).trimLength = [sender floatValue];
}

- (IBAction)strokeZigZagLengthAction:(id)sender
{
	((DKZigZagStroke *)mSelectedRendererRef).wavelength = [sender floatValue];
}

- (IBAction)strokeZigZagAmplitudeAction:(id)sender
{
	((DKZigZagStroke *)mSelectedRendererRef).amplitude = [sender floatValue];
}

- (IBAction)strokeZigZagSpreadAction:(id)sender
{
	((DKZigZagStroke *)mSelectedRendererRef).spread = [sender floatValue];
}

- (IBAction)strokeLineJoinStyleAction:(id)sender
{
	[(id)mSelectedRendererRef setLineJoinStyle:[sender selectedSegment]];
}

- (IBAction)strokeLineCapStyleAction:(id)sender
{
	[(id)mSelectedRendererRef setLineCapStyle:[sender selectedSegment]];
}

- (IBAction)strokeRoughnessAction:(id)sender
{
	[(id)mSelectedRendererRef setRoughness:[sender floatValue]];
}

#pragma mark -
- (IBAction)fillColourAction:(id)sender
{
	((DKFill *)mSelectedRendererRef).colour = [sender color];
}

- (IBAction)fillShadowCheckboxAction:(id)sender
{
	((DKFill *)mSelectedRendererRef).shadow = [sender intValue] ? [DKStyle defaultShadow] : nil;
}

- (IBAction)fillGradientAction:(id)sender
{
	//	LogEvent_(kInfoEvent, @"gradient change from %@", sender );

	mIsChangingGradient = YES;

	// copy needed to force KVO to flag the change of gradient in the fill

	DKGradient *grad = [[sender gradient] copy];

	((DKFill *)mSelectedRendererRef).gradient = grad;

	mIsChangingGradient = NO;
}

- (IBAction)fillRemoveGradientAction:(id)sender
{
#pragma unused(sender)
	//	LogEvent_(kInfoEvent, @"removing gradient from fill");

	[(DKFill *)mSelectedRendererRef setGradient:nil];
}

- (IBAction)fillAddGradientAction:(id)sender
{
#pragma unused(sender)
	//[(DKFill*) mSelectedRendererRef setColour:[NSColor clearColor]];

	[mFillGradientControlBar setGradient:[DKGradient defaultGradient]];
	[self fillGradientAction:mFillGradientControlBar];
	//[(DKFill*) mSelectedRendererRef setGradient:[mFillGradientControlBar gradient]];
}

- (IBAction)fillGradientAngleAction:(id)sender
{
	DKGradient *gradient = ((DKFill *)mSelectedRendererRef).gradient;
	gradient.angleInDegrees = [sender floatValue];
}

- (IBAction)fillGradientRelativeToObjectAction:(id)sender
{
	((DKFill *)mSelectedRendererRef).tracksObjectAngle = [sender intValue];
}

- (IBAction)fillPatternPasteImageAction:(id)sender
{
#pragma unused(sender)
	NSPasteboard *pb = [NSPasteboard generalPasteboard];

	if ([NSImage canInitWithPasteboard:pb]) {
		NSImage *image = [[NSImage alloc] initWithPasteboard:pb];
		((DKFill *)mSelectedRendererRef).colour = [NSColor colorWithPatternImage:image];
		mFillPatternImagePreview.image = image;

		LogEvent_(kInfoEvent, @"color space name: %@", ((DKFill *)mSelectedRendererRef).colour.colorSpaceName);
	}
}

- (IBAction)fillZigZagLengthAction:(id)sender
{
	((DKZigZagFill *)mSelectedRendererRef).wavelength = [sender floatValue];
}

- (IBAction)fillZigZagAmplitudeAction:(id)sender
{
	((DKZigZagFill *)mSelectedRendererRef).amplitude = [sender floatValue];
}

- (IBAction)fillZigZagSpreadAction:(id)sender
{
	((DKZigZagFill *)mSelectedRendererRef).spread = [sender floatValue];
}

#pragma mark -
- (IBAction)scriptButtonAction:(id)sender
{
#pragma unused(sender)
	// open the script editing dialog

	[mScriptEditController runAsSheetInParentWindow:self.window modalDelegate:self];
}

- (IBAction)libraryMenuAction:(id)sender
{
	NSInteger tag = [sender tag]; //[[sender selectedItem] tag];

	if (tag == -1) {
		// add to library using the name in the field

		[DKStyleRegistry registerStyle:[self style]];

		// update the library menu

		//[self populateMenuWithLibraryStyles:[mStyleLibraryPopUpButton menu]];
		[self updateUIForStyle];
	} else if (tag == -4) {
		// remove from library, if indeed the style really is part of it (more likely a copy, so this won't do anything)

		[DKStyleRegistry unregisterStyle:[self style]];
		[self populatePopUpButtonWithLibraryStyles:mStyleLibraryPopUpButton];
		[self updateUIForStyle];
	} else if (tag == -2) {
		// save library
	} else if (tag == -3) {
		// load library
	}
}

- (IBAction)libraryItemAction:(id)sender
{
	//	LogEvent_(kInfoEvent, @"library style = %@", [sender representedObject]);

	// set the style for the objects in the selection to the menu item style

	NSArray *selection = [self selectedObjectForCurrentTarget];

	if (selection) {
		// so that the item gets added to "recently used", request the style from the registry using this method:

		NSString *key = [[sender representedObject] uniqueKey];
		DKStyle *ss = [DKStyleRegistry styleForKeyAddingToRecentlyUsed:key];

		[selection makeObjectsPerformSelector:@selector(setStyle:) withObject:ss];
		[self redisplayContentForSelection:selection];

		[[self currentDocument].undoManager setActionName:NSLocalizedString(@"Apply Style", @"")];
	}
}

- (IBAction)sharedStyleCheckboxAction:(id)sender
{
	if (![self style].locked)
		[self style].styleSharable = [sender intValue];
}

- (IBAction)styleNameAction:(id)sender
{
	if (![self style].locked) {
		[self style].name = [sender stringValue];

		// if the style is registered, update the library menu

		if ([self style].styleRegistered)
			[self populatePopUpButtonWithLibraryStyles:mStyleLibraryPopUpButton];

		[[self currentDocument].undoManager setActionName:NSLocalizedString(@"Change Style Name", @"")];
	}
}

- (IBAction)cloneStyleAction:(id)sender
{
#pragma unused(sender)
	// makes a copy (mutable) of the current style and applies it to the objects in the selection. This gives us a useful
	// starting point for making a new style

	DKStyle *clone = [[self style] mutableCopy];

	// give it a new name:
	// if it has text attributes, give it a name based on the font, otherwise, blank.

	[clone setName:nil];

	if (clone.hasTextAttributes) {
		NSFont *font = clone.textAttributes[NSFontAttributeName];

		if (font != nil)
			clone.name = [DKStyle styleNameForFont:font];
	}

	// attach it to the selected objects and update

	NSArray *selection = [self selectedObjectForCurrentTarget];

	if (selection) {
		[selection makeObjectsPerformSelector:@selector(setStyle:) withObject:clone];
		[self redisplayContentForSelection:selection];
	}

	[[self currentDocument].undoManager setActionName:NSLocalizedString(@"Clone Style", @"")];
}

- (IBAction)unlockStyleAction:(id)sender
{
	// unlocks a locked style for editing. If the style is registered, posts a stern warning

	if ([self style].styleRegistered && [sender intValue] == 0) {
		// warn user what could happen

		NSAlert *alert = [NSAlert alertWithMessageText:@"Caution: Registered Style"
										 defaultButton:@"Cancel"
									   alternateButton:@"Unlock Anyway"
										   otherButton:nil
							 informativeTextWithFormat:@"Editing a registered style can have unforseen consequences as such styles may become permanently changed. Are you sure you want to unlock the style '%@' for editing?",
													   [self style].name];

		NSModalResponse result = [alert runModal];

		if (result == NSAlertAlternateReturn)
			[[self style] setLocked:NO];
	} else
		[self style].locked = [sender intValue];

	[self updateUIForStyle];

	if ([self style].styleRegistered && [sender intValue] == 1)
		[self populatePopUpButtonWithLibraryStyles:mStyleLibraryPopUpButton];

	[[self currentDocument].undoManager setActionName:NSLocalizedString([[self style] locked] ? @"Lock Style" : @"Unlock Style", @"")];
}

#pragma mark -
- (IBAction)addRendererElementAction:(id)sender
{
	NSInteger tag = [sender selectedItem].tag;

	// tag maps to the type of renderer to add

	DKRasterizer *rend;

	switch (tag) {
		case kDKAddStrokeRendererTag:
			rend = [[DKStroke alloc] init];
			break;

		case kDKAddZigZagStrokeRendererTag:
			rend = [[DKZigZagStroke alloc] init];
			break;

		case kDKAddFillRendererTag:
			rend = [[DKFill alloc] init];
			break;

		case kDKAddZigZagFillRendererTag:
			rend = [[DKZigZagFill alloc] init];
			break;

		case kDKAddGroupRendererTag:
			rend = [[DKRastGroup alloc] init];
			break;

		case kDKAddCoreEffectRendererTag:
			rend = [[DKCIFilterRastGroup alloc] init];
			break;

		case kDKAddImageRendererTag:
			rend = [[DKImageAdornment alloc] init];
			break;

		case kDKAddHatchRendererTag:
			rend = [[DKHatching alloc] init];
			break;

		case kDKAddLabelRendererTag:
			rend = [[DKTextAdornment alloc] init];
			break;

		case kDKAddArrowStrokeRendererTag:
			rend = [[DKArrowStroke alloc] init];
			[(DKArrowStroke *)rend setWidth:MAX(1.0, [[self style] maxStrokeWidth])];
			break;

		case kDKAddPathDecoratorRendererTag:
			rend = [[DKPathDecorator alloc] init];
			break;

		case kDKAddPatternFillRendererTag:
			rend = [[DKFillPattern alloc] init];
			break;

		case kDKAddBlendEffectRendererTag:
			rend = [[DKQuartzBlendRastGroup alloc] init];
			break;

		case kDKAddRoughStrokeRendererTag:
			rend = [[DKRoughStroke alloc] init];
			break;

		default:
			return; // TO DO
	}

	NSAssert(rend != nil, @"renderer was nil - can't continue");

	[self addAndSelectNewRenderer:rend];

	[[self currentDocument].undoManager setActionName:NSLocalizedString(@"Add Style Component", @"")];
}

- (IBAction)removeRendererElementAction:(id)sender
{
#pragma unused(sender)
	DKRastGroup *parent;
	id sel = [mOutlineView itemAtRow:mOutlineView.selectedRow];

	if (sel == nil || sel == [self style])
		return;

	parent = (DKRastGroup *)[sel container];

	//	LogEvent_(kInfoEvent, @"deleting renderer %@ from parent %@", sel, parent );

	mSelectedRendererRef = nil;

	[[self style] notifyClientsBeforeChange];
	[parent removeRenderer:sel];
	[[self style] notifyClientsAfterChange];

	[mOutlineView reloadData];

	NSInteger row = [mOutlineView rowForItem:parent];

	if (row != NSNotFound)
		[mOutlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];

	[[self currentDocument].undoManager setActionName:NSLocalizedString(@"Delete Style Component", @"")];
}

- (IBAction)duplicateRendererElementAction:(id)sender
{
#pragma unused(sender)
	// duplicates the selected renderer within its current parent group. If the root style is selected,
	// does nothing
	id sel = [mOutlineView itemAtRow:mOutlineView.selectedRow];

	if (sel == nil || sel == [self style]) {
		NSBeep();
		return;
	}

	id newItem = [sel copy];

	[self addAndSelectNewRenderer:newItem];
	[[self currentDocument].undoManager setActionName:NSLocalizedString(@"Duplicate Style Component", @"")];
}

- (IBAction)copyRendererElementAction:(id)sender
{
#pragma unused(sender)
	// ensure the copy is of a component and not the whole thing

	id sel = [mOutlineView itemAtRow:mOutlineView.selectedRow];

	if (sel == nil || sel == [self style]) {
		NSBeep();
		return;
	}

	[sel copyToPasteboard:[NSPasteboard generalPasteboard]];
}

- (IBAction)pasteRendererElementAction:(id)sender
{
#pragma unused(sender)
	DKRasterizer *rend = [DKRasterizer rasterizerFromPasteboard:[NSPasteboard generalPasteboard]];

	if (rend != nil) {
		[self addAndSelectNewRenderer:rend];
		[[self currentDocument].undoManager setActionName:NSLocalizedString(@"Paste Style Component", @"")];
	} else
		NSBeep();
}

- (IBAction)removeTextAttributesAction:(id)sender
{
#pragma unused(sender)

	if (![self style].locked && [self style].hasTextAttributes) {
		[[self style] removeTextAttributes];
		[[self currentDocument].undoManager setActionName:NSLocalizedString(@"Remove Text Attributes", @"")];
	}
}

#pragma mark -
- (IBAction)imageFileButtonAction:(id)sender
{
#pragma unused(sender)
	NSOpenPanel *op = [NSOpenPanel openPanel];

	[op setAllowsMultipleSelection:NO];
	[op setCanChooseDirectories:NO];
	op.allowedFileTypes = NSImage.imageTypes;
	NSInteger result = [op runModal];

	if (result == NSModalResponseOK) {
		NSImage *image = [[NSImage alloc] initByReferencingFile:op.URL.path];

		if ([mSelectedRendererRef respondsToSelector:@selector(setImage:)])
			((DKImageAdornment *)mSelectedRendererRef).image = image;
		else if ([mSelectedRendererRef isKindOfClass:[DKFill class]]) {
			((DKFill *)mSelectedRendererRef).colour = [NSColor colorWithPatternImage:image];
			mFillPatternImagePreview.image = image;
		}
	}
}

- (IBAction)imageWellAction:(id)sender
{
#pragma unused(sender)
}

- (IBAction)imageIdentifierAction:(id)sender
{
	((DKImageAdornment *)mSelectedRendererRef).imageIdentifier = [sender stringValue];
}

- (IBAction)imageOpacityAction:(id)sender
{
	((DKImageAdornment *)mSelectedRendererRef).opacity = [sender floatValue];
}

- (IBAction)imageScaleAction:(id)sender
{
	((DKImageAdornment *)mSelectedRendererRef).scale = [sender floatValue];
}

- (IBAction)imageAngleAction:(id)sender
{
	((DKImageAdornment *)mSelectedRendererRef).angleInDegrees = [sender floatValue];
}

- (IBAction)imageFittingMenuAction:(id)sender
{
	NSInteger option = [sender selectedItem].tag;
	((DKImageAdornment *)mSelectedRendererRef).fittingOption = option;
}

- (IBAction)imageClipToPathAction:(id)sender
{
	((DKImageAdornment *)mSelectedRendererRef).clipping = [sender intValue];
}

#pragma mark -
- (IBAction)hatchColourWellAction:(id)sender
{
	((DKHatching *)mSelectedRendererRef).colour = [sender color];
}

- (IBAction)hatchSpacingAction:(id)sender
{
	((DKHatching *)mSelectedRendererRef).spacing = [sender floatValue];
}

- (IBAction)hatchLineWidthAction:(id)sender
{
	((DKHatching *)mSelectedRendererRef).width = [sender floatValue];
}

- (IBAction)hatchAngleAction:(id)sender
{
	((DKHatching *)mSelectedRendererRef).angleInDegrees = [sender floatValue];
}

- (IBAction)hatchRelativeAngleAction:(id)sender
{
	((DKHatching *)mSelectedRendererRef).angleIsRelativeToObject = [sender intValue];
}

- (IBAction)hatchDashMenuAction:(id)sender
{
	NSInteger tag = [sender selectedItem].tag;

	if (tag == -1)
		[(DKHatching *)mSelectedRendererRef setDash:nil];
	else if (tag == -2)
		[(DKHatching *)mSelectedRendererRef setAutoDash];
	else if (tag == -3) {
		// "Other..." item

		[self openDashEditor];
	} else {
		// menu's attributed object is the dash itself

		DKStrokeDash *dash = [sender selectedItem].representedObject;
		((DKHatching *)mSelectedRendererRef).dash = dash;
	}
}

- (IBAction)hatchLeadInAction:(id)sender
{
	((DKHatching *)mSelectedRendererRef).leadIn = [sender floatValue];
}

#pragma mark -
- (IBAction)filterMenuAction:(id)sender
{
	LogEvent_(kInfoEvent, @"filter menu, choice = %@", [sender selectedItem].title);

	((DKCIFilterRastGroup *)mSelectedRendererRef).filter = [sender selectedItem].representedObject;
}

- (IBAction)filterClipToPathAction:(id)sender
{
	((DKCIFilterRastGroup *)mSelectedRendererRef).clipping = [sender intValue];
}

#pragma mark -
- (IBAction)textLabelAction:(id)sender
{
	id ss = [sender stringValue];
	[(DKTextAdornment *)mSelectedRendererRef setLabel:ss];
}

- (IBAction)textLayoutAction:(id)sender
{
	((DKTextAdornment *)mSelectedRendererRef).layoutMode = [sender selectedItem].tag;
}

- (IBAction)textAlignmentMenuAction:(id)sender
{
	((DKTextAdornment *)mSelectedRendererRef).alignment = [sender selectedItem].tag;
}

- (IBAction)textPlacementMenuAction:(id)sender
{
	((DKTextAdornment *)mSelectedRendererRef).verticalAlignment = [sender selectedItem].tag;
}

- (IBAction)textWrapLinesAction:(id)sender
{
	((DKTextAdornment *)mSelectedRendererRef).wrapsLines = [sender intValue];
}

- (IBAction)textClipToPathAction:(id)sender
{
	((DKTextAdornment *)mSelectedRendererRef).clipping = [sender intValue];
}

- (IBAction)textRelativeAngleAction:(id)sender
{
	((DKTextAdornment *)mSelectedRendererRef).appliesObjectAngle = [sender intValue];
}

- (IBAction)textAngleAction:(id)sender
{
	((DKTextAdornment *)mSelectedRendererRef).angleInDegrees = [sender floatValue];
}

- (IBAction)textFontButtonAction:(id)sender
{
	// set the font panel's action to our private redirection action when the Font button is clicked. This gets
	// restored to the standard action whenever the focus is removed from this pane.

	[[NSFontManager sharedFontManager] orderFrontFontPanel:sender];
}

- (IBAction)textColourAction:(id)sender
{
	((DKTextAdornment *)mSelectedRendererRef).colour = [sender color];
}

- (IBAction)textChangeFontAction:(id)sender
{
	if ([mSelectedRendererRef isKindOfClass:[DKTextAdornment class]]) {
		LogEvent_(kInfoEvent, @"got font change");

		NSFont *newFont = [sender convertFont:((DKTextAdornment *)mSelectedRendererRef).font];
		((DKTextAdornment *)mSelectedRendererRef).font = newFont;
	}
}

- (IBAction)textFlowInsetAction:(id)sender
{
	((DKTextAdornment *)mSelectedRendererRef).flowedTextPathInset = [sender floatValue];
}

- (void)changeTextAttributes:(id)sender
{
	if ([mSelectedRendererRef isKindOfClass:[DKTextAdornment class]]) {
		LogEvent_(kInfoEvent, @"got attributes change");

		NSDictionary *attrs = [sender convertAttributes:((DKTextAdornment *)mSelectedRendererRef).textAttributes];
		((DKTextAdornment *)mSelectedRendererRef).textAttributes = attrs;
	}
}

#pragma mark -
- (IBAction)pathDecoratorIntervalAction:(id)sender
{
	((DKPathDecorator *)mSelectedRendererRef).interval = [sender floatValue];
}

- (IBAction)pathDecoratorScaleAction:(id)sender
{
	((DKPathDecorator *)mSelectedRendererRef).scale = [sender floatValue];
}

- (IBAction)pathDecoratorPasteObjectAction:(id)sender
{
#pragma unused(sender)
	// allow PDF data to be pasted as an image

	NSPasteboard *pb = [NSPasteboard generalPasteboard];

	if ([NSImage canInitWithPasteboard:pb]) {
		NSImage *image = [[NSImage alloc] initWithPasteboard:pb];
		((DKPathDecorator *)mSelectedRendererRef).image = image;
	}
}

- (IBAction)pathDecoratorPathNormalAction:(id)sender
{
	((DKPathDecorator *)mSelectedRendererRef).normalToPath = [sender intValue];
}

- (IBAction)pathDecoratorLeaderDistanceAction:(id)sender
{
	((DKPathDecorator *)mSelectedRendererRef).leaderDistance = [sender floatValue];
}

- (IBAction)pathDecoratorAltPatternAction:(id)sender
{
	((DKFillPattern *)mSelectedRendererRef).patternAlternateOffset = NSMakeSize(0, [sender floatValue]);
}

- (IBAction)pathDecoratorRampProportionAction:(id)sender
{
	((DKPathDecorator *)mSelectedRendererRef).leadInAndOutLengthProportion = [sender floatValue];
}

- (IBAction)pathDecoratorAngleAction:(id)sender
{
	[(DKFillPattern *)mSelectedRendererRef setAngleInDegrees:[sender floatValue]];
}

- (IBAction)pathDecoratorRelativeAngleAction:(id)sender
{
	[(DKFillPattern *)mSelectedRendererRef setAngleIsRelativeToObject:[sender intValue]];
}

- (IBAction)pathDecoratorMotifAngleAction:(id)sender
{
	((DKFillPattern *)mSelectedRendererRef).motifAngleInDegrees = [sender floatValue];
}

- (IBAction)pathDecoratorMotifRelativeAngleAction:(id)sender
{
	((DKFillPattern *)mSelectedRendererRef).motifAngleIsRelativeToPattern = [sender intValue];
}

#pragma mark -
- (IBAction)blendModeAction:(id)sender
{
	NSInteger tag = [sender selectedItem].tag;
	((DKQuartzBlendRastGroup *)mSelectedRendererRef).blendMode = (CGBlendMode)tag;
}

- (IBAction)blendGroupAlphaAction:(id)sender
{
	((DKQuartzBlendRastGroup *)mSelectedRendererRef).alpha = [sender floatValue];
}

- (IBAction)blendGroupImagePasteAction:(id)sender
{
#pragma unused(sender)
	NSPasteboard *pb = [NSPasteboard generalPasteboard];

	if ([NSImage canInitWithPasteboard:pb]) {
		NSImage *image = [[NSImage alloc] initWithPasteboard:pb];
		((DKQuartzBlendRastGroup *)mSelectedRendererRef).maskImage = image;
	}
}

#pragma mark -

// shadow actions make copies because shadow properties are not directly under KVO, but
// -setShadow: is, so the actions are still undoable.

- (IBAction)shadowAngleAction:(id)sender
{
	NSShadow *shad = [((DKFill *)mSelectedRendererRef).shadow copy];
	shad.angleInDegrees = [sender floatValue];
	((DKFill *)mSelectedRendererRef).shadow = shad;
}

- (IBAction)shadowDistanceAction:(id)sender
{
	NSShadow *shad = [((DKFill *)mSelectedRendererRef).shadow copy];
	shad.distance = [sender floatValue];
	((DKFill *)mSelectedRendererRef).shadow = shad;
}

- (IBAction)shadowBlurRadiusAction:(id)sender
{
	NSShadow *shad = [((DKFill *)mSelectedRendererRef).shadow copy];
	shad.shadowBlurRadius = [sender floatValue];
	((DKFill *)mSelectedRendererRef).shadow = shad;
}

- (IBAction)shadowColourAction:(id)sender
{
	NSShadow *shad = [((DKFill *)mSelectedRendererRef).shadow copy];
	shad.shadowColor = [sender color];
	((DKFill *)mSelectedRendererRef).shadow = shad;
}

#pragma mark -
#pragma mark modal sheet callback - called by selector, otherwise private

- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
#pragma unused(sheet)
	//	LogEvent_(kReactiveEvent, @"sheet ended, return code = %d", returnCode);

	if ((__bridge id)contextInfo == mDashEditController) {
		if (returnCode == NSModalResponseOK)
			[(id)mSelectedRendererRef setDash:mDashEditController.dash];
		else
			[(id)mSelectedRendererRef setDash:mSavedDash];

		mSavedDash = nil;
	}
}

#pragma mark -
#pragma mark As a DKDrawkitInspectorBase
- (void)redisplayContentForSelection:(NSArray *)selection
{
	// inherited from inspector base - is passed current selection array whenever a change in selection state occurs
	//	LogEvent_(kInfoEvent, @"selection: %@", selection );

	if (selection != nil) {
		if (selection.count > 1) {
			// multiple selection - if all the selected objects share the same style, we should proceeed as for
			// a single selection. Otherwise just switch to th emulti-selection tab.

			NSArray *styles = [selection valueForKey:@"style"];

			// are the styles all the same?

			NSEnumerator *iter = [styles objectEnumerator];
			DKStyle *aStyle;
			DKStyle *prevStyle = nil;
			BOOL same = YES;

			while ((aStyle = [iter nextObject])) {
				if (aStyle != prevStyle && prevStyle != nil) {
					same = NO;
					break;
				}

				prevStyle = aStyle;
			}

			if (same) {
				[self setStyle:prevStyle];
				[mTabView selectTabViewItemAtIndex:kDKInspectorStylePreviewTab];
				mStyleClientCountText.integerValue = [self style].countOfClients;
			} else {
				[self setStyle:nil];
				[mTabView selectTabViewItemAtIndex:kDKInspectorMultipleItemsTab];
			}
		} else if (selection.count == 1) {
			// single selection

			[self setStyle:((DKDrawableObject *)selection[0]).style];
			[mTabView selectTabViewItemAtIndex:kDKInspectorStylePreviewTab];
			mStyleClientCountText.integerValue = [self style].countOfClients;
		} else {
			// no selection

			[self setStyle:nil];
			[mTabView selectTabViewItemAtIndex:kDKInspectorNoItemsTab];
		}
	} else {
		[self setStyle:nil]; // no selection
		[mTabView selectTabViewItemAtIndex:kDKInspectorNoItemsTab];
	}
}

#pragma mark -
#pragma mark As an NSWindowController
- (void)windowDidLoad
{
	[(NSPanel *)self.window setFloatingPanel:YES];
	[(NSPanel *)self.window setBecomesKeyOnlyIfNeeded:YES];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(styleAttached:) name:kDKDrawableStyleWillBeDetachedNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(styleRegistered:) name:kDKStyleRegistryDidFlagPossibleUIChange object:nil];

	//[mFillGradientWell setCell:[[GCSGradientCell alloc] init]];
	//[mFillGradientWell setCanBecomeActiveWell:NO];
	[mFillGradientControlBar setCanBecomeActiveWell:NO];
	mFillGradientControlBar.target = self;
	mFillGradientControlBar.action = @selector(fillGradientAction:);

	mOutlineView.delegate = self;
	[mOutlineView registerForDraggedTypes:@[kDKTableRowInternalDragPasteboardType]];
	[mOutlineView setDraggingSourceOperationMask:NSDragOperationEvery forLocal:YES];
	[mOutlineView setVerticalMotionCanBeginDrag:YES];

	[mStyleLibraryPopUpButton.menu insertItemWithTitle:@"Style Library" action:NULL keyEquivalent:@"" atIndex:0];

	[self populatePopUpButtonWithLibraryStyles:mStyleLibraryPopUpButton];

	[self populateMenuWithDashes:mHatchDashPopUpButton.menu];
	[self populateMenuWithDashes:mStrokeDashPopUpButton.menu];
	[self populateMenuWithCoreImageFilters:mCIFilterPopUpMenu.menu];

	mAddRendererPopUpButton.font = [NSFont fontWithName:@"Lucida Grande" size:10];
	[mAddRendererPopUpButton.menu setAutoenablesItems:NO];
	[mAddRendererPopUpButton.menu uncheckAllItems];
	[mAddRendererPopUpButton.menu disableItemsWithTag:-99];

	mActionsPopUpButton.font = [NSFont fontWithName:@"Lucida Grande" size:10];
	[mActionsPopUpButton.menu uncheckAllItems];

	mStyle = nil;
	[self updateUIForStyle];

	NSRect panelFrame = self.window.frame;
	NSRect screenFrame = [NSScreen screens][0].visibleFrame;

	//	LogEvent_(kInfoEvent, @"screen frame = %@", NSStringFromRect( screenFrame ));

	panelFrame.origin.x = NSMaxX(screenFrame) - NSWidth(panelFrame) - 20;
	[self.window setFrameOrigin:panelFrame.origin];
}

#pragma mark -
#pragma mark As an NSObject
- (instancetype)init
{
	self = [super init];
	if (self != nil) {
		NSAssert(mStyle == nil, @"Expected init to zero");
		NSAssert(mSelectedRendererRef == nil, @"Expected init to zero");
		NSAssert(!mIsChangingGradient, @"Expected init to zero");
		NSAssert(mDragItem == nil, @"Expected init to zero");
		NSAssert(mSavedDash == nil, @"Expected init to zero");
	}
	return self;
}

#pragma mark -
#pragma mark As a GCDashEditorDelegate delegate
- (void)dashDidChange:(id)sender
{
	// called if live preview is set - set the target's dash to the sender's

	[(id)mSelectedRendererRef setDash:[sender dash]];
}

#pragma mark -
#pragma mark As part of NSOutlineViewDataSource Protocol
- (BOOL)outlineView:(NSOutlineView *)olv acceptDrop:(id<NSDraggingInfo>)info item:(id)targetItem childIndex:(NSInteger)childIndex
{
#pragma unused(info)
	// the item being moved is already stored as mDragItem, so simply move it to the new place

	DKRastGroup *group;

	if (targetItem == nil)
		group = [self style];
	else
		group = targetItem;

	NSInteger srcIndex, row;

	srcIndex = [group.renderList indexOfObject:mDragItem];

	if (srcIndex != NSNotFound) {
		// moving within the same group it already belongs to

		[[self style] notifyClientsBeforeChange];
		[group moveRendererAtIndex:srcIndex toIndex:childIndex];
		[[self style] notifyClientsAfterChange];

		[olv reloadData];

		row = [olv rowForItem:mDragItem];

		if (row != NSNotFound) {
			[olv selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO]; // workaround over-optimisation bug in o/v
			[olv selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
		}

		[[self currentDocument].undoManager setActionName:NSLocalizedString(@"Reorder Style Component", @"")];

		return YES;
	} else if (group != mDragItem.container) {
		// moving to another group in the hierarchy

		[[self style] notifyClientsBeforeChange];
		[mDragItem.container removeRenderer:mDragItem];
		[group addRenderer:mDragItem];
		[group moveRendererAtIndex:group.countOfRenderList - 1 toIndex:childIndex];
		[[self style] notifyClientsAfterChange];

		[olv reloadData];
		row = [olv rowForItem:mDragItem];

		if (row != NSNotFound) {
			[olv selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO]; // workaround over-optimisation bug in o/v
			[olv selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
		}

		[[self currentDocument].undoManager setActionName:NSLocalizedString(@"Move Style Component To Group", @"")];

		return YES;
	} else
		return NO;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)childIndex ofItem:(id)item
{
#pragma unused(outlineView)
	return (item == nil) ? [self style] : [item rendererAtIndex:childIndex];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
#pragma unused(outlineView)
	if ([self style] == nil)
		return NO;
	else
		return (item == nil) ? YES : [item isKindOfClass:[DKRastGroup class]];
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
#pragma unused(outlineView)
	return (item == nil) ? 1 : [item countOfRenderList];
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
#pragma unused(outlineView)
	if ([tableColumn.identifier isEqualToString:@"class"])
		return (item == nil) ? NSStringFromClass([[self style] class]) : NSStringFromClass([item class]);
	else if ([tableColumn.identifier isEqualToString:@"enabled"])
		return [item valueForKey:@"enabled"];
	else
		return nil;
}

- (void)outlineView:(NSOutlineView *)outlineView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
#pragma unused(outlineView)
	if ([tableColumn.identifier isEqualToString:@"enabled"])
		[item setValue:object forKey:@"enabled"];
}

- (NSDragOperation)outlineView:(NSOutlineView *)olv validateDrop:(id<NSDraggingInfo>)info proposedItem:(id)item proposedChildIndex:(NSInteger)childIndex
{
#pragma unused(info)
	//	LogEvent_(kInfoEvent, @"proposing drop on %@, childIndex = %d", item, childIndex );

	if ([item isKindOfClass:[DKRastGroup class]]) {
		if (childIndex == NSOutlineViewDropOnItemIndex)
			[olv setDropItem:item dropChildIndex:0];
		else
			[olv setDropItem:item dropChildIndex:childIndex];

		return NSDragOperationGeneric;
	} else
		return NSDragOperationNone;
}

- (BOOL)outlineView:(NSOutlineView *)oView writeItems:(NSArray *)rows toPasteboard:(NSPasteboard *)pboard
{
#pragma unused(oView)
	//	LogEvent_(kInfoEvent, @"starting drag in outline view, array = %@", rows );

	mDragItem = rows[0];

	if (mDragItem == [self style])
		return NO;

	// just write dummy data to the pboard - it's all internal so we just keep a reference to the item being moved

	[pboard declareTypes:@[kDKTableRowInternalDragPasteboardType] owner:self];
	[pboard setData:[NSData data] forType:kDKTableRowInternalDragPasteboardType];

	return YES;
}

#pragma mark -
#pragma mark As an NSOutlineView delegate
- (void)outlineViewSelectionDidChange:(NSNotification *)notification
{
#pragma unused(notification)
	// select the appropriate tab for the selected item and set up its contents

	NSInteger row = mOutlineView.selectedRow;

	if (row != -1) {
		id item = [mOutlineView itemAtRow:row];

		if ([self style].locked)
			[self selectTabPaneForObject:[self style]];
		else
			[self selectTabPaneForObject:item];
	} else
		[self selectTabPaneForObject:nil];
}

- (NSString *)outlineView:(NSOutlineView *)ov toolTipForCell:(NSCell *)cell rect:(NSRectPointer)rect
			  tableColumn:(NSTableColumn *)tc
					 item:(id)item
			mouseLocation:(NSPoint)mouseLocation
{
#pragma unused(ov, cell, rect, tc, mouseLocation)
	return [item styleScript];
}

- (void)outlineView:(NSOutlineView *)outlineView willDisplayCell:(id)cell
	 forTableColumn:(NSTableColumn *)tableColumn
			   item:(id)item
{
#pragma unused(outlineView, item)
	if ([tableColumn.identifier isEqualToString:@"class"]) {
		if ([self style].locked)
			[cell setTextColor:[NSColor lightGrayColor]];
		else
			[cell setTextColor:[NSColor blackColor]];
	} else if ([tableColumn.identifier isEqualToString:@"enabled"]) {
		[cell setEnabled:![self style].locked];
	}
}

#pragma mark -
#pragma mark As part of the NSMenuValidation protocol

- (BOOL)validateMenuItem:(NSMenuItem *)item
{
	SEL action = item.action;
	BOOL enable = YES;
	id sel = [mOutlineView itemAtRow:mOutlineView.selectedRow];

	if (action == @selector(copyRendererElementAction:)) {
		// permitted for a valid selection even if style locked

		if (sel == nil || sel == [self style])
			enable = NO;
	} else if (action == @selector(duplicateRendererElementAction:) ||
			   action == @selector(removeRendererElementAction:)) {
		// permitted if the selection is not root or nil, and style unlocked

		if (sel == nil || sel == [self style] || [self style].locked)
			enable = NO;
	} else if (action == @selector(pasteRendererElementAction:)) {
		// permitted if the pasteboard contains a renderer & style unlocked

		NSString *pbType = [[NSPasteboard generalPasteboard] availableTypeFromArray:@[kDKRasterizerPasteboardType]];

		enable = (pbType != nil && ![self style].locked);
	} else if (action == @selector(libraryItemAction:)) {
		item.state = item.representedObject == mStyle ? NSOnState : NSOffState;
	} else if (action == @selector(removeTextAttributesAction:)) {
		enable = ![self style].locked && [self style].hasTextAttributes;
	}

	return enable;
}

@end

#pragma mark -
@implementation NSImage (ImageResources)

+ (NSImage *)imageNamed:(NSString *)name fromBundleForClass:(Class) class
{
	NSImage *image = [[NSBundle bundleForClass:class] imageForResource:name];
	if (image == nil)
		LogEvent_(kWheneverEvent, @"ERROR: Unable to locate image resource '%@'", name);
	return image;
}

	@end

#pragma mark -
	@implementation NSMenu(GCAdditions)

	- (void)disableItemsWithTag : (int)tag
{
	NSInteger i, m = self.numberOfItems;
	NSMenuItem *item;

	for (i = 0; i < m; ++i) {
		item = [self itemAtIndex:i];

		if (item.tag == tag)
			[item setEnabled:NO];
	}
}

- (void)uncheckAllItems
{
	NSInteger i, m = self.numberOfItems;

	for (i = 0; i < m; ++i)
		[self itemAtIndex:i].state = NSOffState;
}

@end

#pragma mark -

@implementation NSView (TagEnablingAdditions)

- (void)setSubviewsWithTag:(NSInteger)tag hidden:(BOOL)hide
{
	// recursively checks the tags of all subviews below this, and sets any that match <tag> to the hidden state <hide>

	if (self.tag == tag)
		self.hidden = hide;
	else {
		NSEnumerator *iter = [self.subviews objectEnumerator];
		NSView *sub;

		while ((sub = [iter nextObject]))
			[sub setSubviewsWithTag:tag hidden:hide];
	}
}

- (void)setSubviewsWithTag:(NSInteger)tag enabled:(BOOL)enable
{
	// recursively checks the tags of all subviews below this, and sets any that match <tag> to the enabled state <enable>
	// provided that the object actually implements setEnabled: (i.e. it's a control)

	if (self.tag == tag && [self respondsToSelector:@selector(setEnabled:)])
		[(id)self setEnabled:enable];
	else {
		NSEnumerator *iter = [self.subviews objectEnumerator];
		NSView *sub;

		while ((sub = [iter nextObject]))
			[sub setSubviewsWithTag:tag enabled:enable];
	}
}

@end
