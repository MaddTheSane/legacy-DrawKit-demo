/* DrawingSizeController */

#import <Cocoa/Cocoa.h>
#import <DKDrawKit/DKDrawing.h>

@interface GCSDrawingSizeController : NSWindowController {
	IBOutlet NSTextField *mBottomMarginTextField;
	IBOutlet NSTextField *mGridDivsTextField;
	IBOutlet NSTextField *mGridMajorsTextField;
	IBOutlet NSButton *mGridPreviewCheckbox;
	IBOutlet NSTextField *mGridSpanTextField;
	IBOutlet NSColorWell *mGridThemeColourWell;
	IBOutlet NSTextField *mHeightTextField;
	IBOutlet NSTextField *mLeftMarginTextField;
	IBOutlet NSTextField *mRightMarginTextField;
	IBOutlet NSTextField *mTopMarginTextField;
	IBOutlet NSButton *mTweakMarginsCheckbox;
	IBOutlet NSComboBox *mUnitsComboBox;
	IBOutlet NSTextField *mWidthTextField;
	IBOutlet NSBox *mGridControlsBox;
	IBOutlet NSStepper *mGridDivsSpinControl;
	IBOutlet NSStepper *mGridMajorsSpinControl;
	IBOutlet NSTextField *mGridAbbrevUnitsText;
	IBOutlet NSButton *mGridPrintCheckbox;
	IBOutlet NSTextField *mGridRulerStepsTextField;
	IBOutlet NSStepper *mGridRulerStepsSpinControl;
	IBOutlet NSTextField *mConversionFactorTextField;
	IBOutlet NSStepper *mConversionFactorSpinControl;
	IBOutlet NSTextField *mConversionFactorLabelText;
	IBOutlet NSColorWell *mPaperColourWell;

	DKDrawing *mDrawing;
	BOOL mLivePreview;
	CGFloat mUnitConversionFactor;
	CGFloat mSavedSpan;
	CGFloat mSavedCF;
	NSInteger mSavedDivs;
	NSInteger mSavedMajors;
	NSString *mSavedUnits;
	NSColor *mSavedGridColour;
	NSColor *mSavedPaperColour;
}

- (void)beginDrawingSizeDialog:(NSWindow *)parent withDrawing:(DKDrawing *)drawing;

- (IBAction)cancelAction:(id)sender;
- (IBAction)gridDivsAction:(id)sender;
- (IBAction)gridMajorsAction:(id)sender;
- (IBAction)gridSpanAction:(id)sender;
- (IBAction)gridRulerStepsAction:(id)sender;
- (IBAction)gridThemeColourAction:(id)sender;
- (IBAction)gridPrintAction:(id)sender;
- (IBAction)livePreviewAction:(id)sender;
- (IBAction)okAction:(id)sender;
- (IBAction)unitsComboBoxAction:(id)sender;
- (IBAction)conversionFactorAction:(id)sender;
- (IBAction)paperColourAction:(id)sender;

@end
