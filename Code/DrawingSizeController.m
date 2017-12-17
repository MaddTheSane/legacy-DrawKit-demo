#import "DrawingSizeController.h"

#import <DKDrawKit/DKDrawing.h>
#import <DKDrawKit/DKGridLayer.h>
#import <DKDrawKit/LogEvent.h>

#pragma mark Static Vars
static const CGFloat sUnitFactors[] = {1.0, 12.0, 72.0, 2.8346456692913, 28.346456692913, 2834.6456692913, 28346.456692913, 1.0};
static NSString *sUnitNames[] = {@"Pixels", @"Picas", @"Inches", @"Millimetres", @"Centimetres", @"Metres", @"Kilometres", nil};

@implementation DrawingSizeController
#pragma mark As a DrawingSizeController

- (NSArray *)unitNames
{
	NSMutableArray *arr = [NSMutableArray array];
	NSString *name;
	NSInteger i = 0;

	while (1) {
		name = sUnitNames[i++];

		if (name)
			[arr addObject:name];
		else
			break;
	}

	return arr;
}

- (void)prepareDialogWithDrawing:(DKDrawing *)drawing
{
	// set up the dialog elements with the current drawing settings

	NSSize size = drawing.drawingSize;

	mWidthTextField.floatValue = size.width / mUnitConversionFactor;
	mHeightTextField.floatValue = size.height / mUnitConversionFactor;

	mTopMarginTextField.floatValue = drawing.topMargin / mUnitConversionFactor;
	mLeftMarginTextField.floatValue = drawing.leftMargin / mUnitConversionFactor;
	mRightMarginTextField.floatValue = drawing.rightMargin / mUnitConversionFactor;
	mBottomMarginTextField.floatValue = drawing.bottomMargin / mUnitConversionFactor;

	mConversionFactorTextField.floatValue = mUnitConversionFactor;
	mConversionFactorSpinControl.floatValue = mUnitConversionFactor;
	mPaperColourWell.color = drawing.paperColour;

	DKGridLayer *grid = drawing.gridLayer;

	if (grid) {
		mGridSpanTextField.floatValue = grid.spanDistance / mUnitConversionFactor;
		mGridDivsTextField.integerValue = grid.divisions;
		mGridDivsSpinControl.integerValue = grid.divisions;
		mGridMajorsTextField.integerValue = grid.majors;
		mGridMajorsSpinControl.integerValue = grid.majors;
		mGridThemeColourWell.color = grid.spanColour;
		mGridPrintCheckbox.intValue = grid.shouldDrawToPrinter;
		mGridAbbrevUnitsText.stringValue = drawing.abbreviatedDrawingUnits;
		mGridRulerStepsTextField.integerValue = grid.rulerSteps;
		mGridRulerStepsSpinControl.integerValue = grid.rulerSteps;

		mGridPreviewCheckbox.intValue = mLivePreview;
	}
}

- (void)setupComboBoxWithCurrentUnits:(NSString *)units
{
#pragma unused(units)
	// populate the combobox with default units
	[mUnitsComboBox setHasVerticalScroller:NO];
	[mUnitsComboBox addItemsWithObjectValues:[self unitNames]];
	mUnitsComboBox.numberOfVisibleItems = [self unitNames].count;
}

#pragma mark -
- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
#pragma unused(sheet, contextInfo)
	DKGridLayer *grid = mDrawing.gridLayer;

	if (returnCode == NSOKButton) {
		// apply the settings to the drawing.

		NSSize dwgSize;
		CGFloat t, l, b, r;

		dwgSize.width = mWidthTextField.floatValue * mUnitConversionFactor;
		dwgSize.height = mHeightTextField.floatValue * mUnitConversionFactor;

		t = mTopMarginTextField.floatValue * mUnitConversionFactor;
		l = mLeftMarginTextField.floatValue * mUnitConversionFactor;
		b = mBottomMarginTextField.floatValue * mUnitConversionFactor;
		r = mRightMarginTextField.floatValue * mUnitConversionFactor;

		mDrawing.drawingSize = dwgSize;
		[mDrawing setMarginsLeft:l top:t right:b bottom:r];
		[mDrawing setDrawingUnits:mUnitsComboBox.stringValue unitToPointsConversionFactor:mUnitConversionFactor];
		mDrawing.paperColour = mPaperColourWell.color;

		if (grid) {
			CGFloat span;
			NSInteger divs, majs;

			span = mGridSpanTextField.floatValue * mUnitConversionFactor;
			divs = mGridDivsTextField.integerValue;
			majs = mGridMajorsTextField.integerValue;

			[grid setDistanceForUnitSpan:span
							drawingUnits:mUnitsComboBox.stringValue
									span:1.0
							   divisions:divs
								  majors:majs
							  rulerSteps:mGridRulerStepsTextField.integerValue];

			if (mTweakMarginsCheckbox.integerValue == 1)
				[grid tweakDrawingMargins];

			[grid setGridThemeColour:mGridThemeColourWell.color];
		}

		[mDrawing setNeedsDisplay:YES];
	} else if (returnCode == NSCancelButton) {
		// restore saved grid settings

		if (grid) {
			[grid setDistanceForUnitSpan:mSavedSpan
							drawingUnits:mSavedUnits
									span:1.0
							   divisions:mSavedDivs
								  majors:mSavedMajors
							  rulerSteps:2];

			[grid setGridThemeColour:mSavedGridColour];
		}

		mDrawing.paperColour = mSavedPaperColour;
	}
}

- (void)beginDrawingSizeDialog:(NSWindow *)parent withDrawing:(DKDrawing *)drawing
{
	mDrawing = drawing;
	mUnitConversionFactor = mSavedCF = [drawing unitToPointsConversionFactor];

	// save off the current grid settings in case we cancel:

	mSavedPaperColour = drawing.paperColour;

	DKGridLayer *grid = mDrawing.gridLayer;

	if (grid) {
		mSavedSpan = grid.spanDistance;
		mSavedDivs = grid.divisions;
		mSavedMajors = grid.majors;
		mSavedGridColour = grid.spanColour;
		mSavedUnits = drawing.drawingUnits;
	}

	[self window];
	mUnitsComboBox.stringValue = drawing.drawingUnits;
	mConversionFactorLabelText.stringValue = [NSString stringWithFormat:@"1 %@ occupies", drawing.drawingUnits];
	[self prepareDialogWithDrawing:drawing];

	[NSApp beginSheet:self.window
		modalForWindow:parent
		 modalDelegate:self
		didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:)
		   contextInfo:@"drawing_size"];
}

#pragma mark -
- (IBAction)cancelAction:(id)sender
{
#pragma unused(sender)
	[self.window orderOut:self];
	[NSApp endSheet:self.window returnCode:NSCancelButton];
}

- (IBAction)gridDivsAction:(id)sender
{
	DKGridLayer *grid = mDrawing.gridLayer;

	if (mLivePreview && grid) {
		CGFloat span;
		NSInteger majs;

		span = grid.spanDistance / mUnitConversionFactor;
		majs = grid.majors;

		[grid setDistanceForUnitSpan:mUnitConversionFactor
						drawingUnits:mDrawing.drawingUnits
								span:span
						   divisions:[sender intValue]
							  majors:majs
						  rulerSteps:mGridRulerStepsTextField.intValue];
	}

	if (sender == mGridDivsSpinControl)
		mGridDivsTextField.integerValue = [sender integerValue];
	else
		mGridDivsSpinControl.integerValue = [sender integerValue];
}

- (IBAction)gridMajorsAction:(id)sender
{
	DKGridLayer *grid = mDrawing.gridLayer;

	if (mLivePreview && grid) {
		CGFloat span;
		NSInteger divs;

		span = grid.spanDistance / mUnitConversionFactor;
		divs = grid.divisions;

		[grid setDistanceForUnitSpan:mUnitConversionFactor
						drawingUnits:mDrawing.drawingUnits
								span:span
						   divisions:divs
							  majors:[sender intValue]
						  rulerSteps:mGridRulerStepsTextField.integerValue];
	}
	if (sender == mGridMajorsSpinControl)
		mGridMajorsTextField.integerValue = [sender integerValue];
	else
		mGridMajorsSpinControl.integerValue = [sender integerValue];
}

- (IBAction)gridSpanAction:(id)sender
{
	DKGridLayer *grid = mDrawing.gridLayer;

	if (mLivePreview && grid) {
		NSInteger divs, majs;

		divs = grid.divisions;
		majs = grid.majors;

		[grid setDistanceForUnitSpan:mUnitConversionFactor
						drawingUnits:mDrawing.drawingUnits
								span:[sender doubleValue]
						   divisions:divs
							  majors:majs
						  rulerSteps:mGridRulerStepsTextField.integerValue];
	}
}

- (IBAction)gridRulerStepsAction:(id)sender
{
	DKGridLayer *grid = mDrawing.gridLayer;

	if (mLivePreview && grid)
		grid.rulerSteps = [sender integerValue];

	if (sender == mGridRulerStepsSpinControl)
		mGridRulerStepsTextField.integerValue = [sender integerValue];
	else
		mGridRulerStepsSpinControl.integerValue = [sender integerValue];
}

- (IBAction)gridThemeColourAction:(id)sender
{
	DKGridLayer *grid = mDrawing.gridLayer;

	if (mLivePreview && grid)
		[grid setGridThemeColour:[sender color]];
}

- (IBAction)gridPrintAction:(id)sender
{
	mDrawing.gridLayer.shouldDrawToPrinter = [sender intValue];
}

- (IBAction)livePreviewAction:(id)sender
{
	mLivePreview = [sender intValue];
}

- (IBAction)okAction:(id)sender
{
#pragma unused(sender)
	[self.window orderOut:self];
	[NSApp endSheet:self.window returnCode:NSOKButton];
}

- (IBAction)unitsComboBoxAction:(id)sender
{
	//	LogEvent_(kStateEvent, @"units changing to: %@", [sender stringValue]);

	NSInteger indx = [mUnitsComboBox indexOfItemWithObjectValue:[sender stringValue]];

	if (indx == NSNotFound) {
		mUnitConversionFactor = 1.0;
		//[mConversionFactorTextField setEnabled:YES];
		//[mConversionFactorSpinControl setEnabled:YES];
	} else {
		mUnitConversionFactor = sUnitFactors[indx];
		//[mConversionFactorTextField setEnabled:NO];
		//[mConversionFactorSpinControl setEnabled:NO];
	}

	mConversionFactorLabelText.stringValue = [NSString stringWithFormat:@"1 %@ occupies", [sender stringValue]];
	[mDrawing setDrawingUnits:[sender stringValue] unitToPointsConversionFactor:mUnitConversionFactor];

	if (mLivePreview)
		[mDrawing.gridLayer synchronizeRulers];

	[self prepareDialogWithDrawing:mDrawing];
}

- (IBAction)conversionFactorAction:(id)sender
{
	CGFloat oldUCF = mUnitConversionFactor;

	mUnitConversionFactor = [sender floatValue];

	if (sender == mConversionFactorSpinControl)
		mConversionFactorTextField.floatValue = [sender floatValue];
	else
		mConversionFactorSpinControl.floatValue = [sender floatValue];

	DKGridLayer *grid = mDrawing.gridLayer;

	if (mLivePreview && grid) {
		NSInteger divs, majs;
		CGFloat span;

		divs = grid.divisions;
		majs = grid.majors;
		span = grid.spanDistance / oldUCF;

		[grid setDistanceForUnitSpan:mUnitConversionFactor
						drawingUnits:mDrawing.drawingUnits
								span:span
						   divisions:divs
							  majors:majs
						  rulerSteps:mGridRulerStepsTextField.integerValue];
	}
}

- (IBAction)paperColourAction:(id)sender
{
	if (mLivePreview)
		mDrawing.paperColour = [sender color];
}

#pragma mark -
#pragma mark As an NSWindowController
- (void)windowDidLoad
{
	mLivePreview = YES;
	[self setupComboBoxWithCurrentUnits:mDrawing.drawingUnits];
	mUnitsComboBox.stringValue = mDrawing.drawingUnits;
	mConversionFactorLabelText.stringValue = [NSString stringWithFormat:@"1 %@ occupies", mDrawing.drawingUnits];
	[self prepareDialogWithDrawing:mDrawing];
}

@end
