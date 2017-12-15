//
//  GCExportOptionsController.m
//  GCDrawKit
//
//  Created by graham on 11/07/2008.
//  Copyright 2008 Apptree.net. All rights reserved.
//

#import "GCSExportOptionsController.h"
#import <DKDrawKit/DKDrawing+Export.h>
#import <DKDrawKit/LogEvent.h>

NSString *kGCIncludeGridInExportedFile = @"kGCIncludeGridInExportedFile";
NSString *kGCExportedFileURL = @"kGCExportedFileURL";

@implementation GCSExportOptionsController

- (void)beginExportDialogWithParentWindow:(NSWindow *)parent delegate:(id<GCSExportControllerDelegate>)delegate
{
	// allows export of the drawing as PDF, etc.

	mDelegate = delegate;

	if (mOptionsDict == nil) {
		mOptionsDict = [[NSMutableDictionary alloc] init];
		mOptionsDict[NSImageCompressionFactor] = @0.67f;
		mOptionsDict[kDKExportPropertiesResolution] = @72;
	}

	NSSavePanel *sp = [NSSavePanel savePanel];

	sp.accessoryView = mExportAccessoryView;
	mSavePanel = sp;
	mFileType = GCSExportFileTypePDF;
	[self displayOptionsForFileType:mFileType];

	[sp setPrompt:NSLocalizedString(@"Export", @"")];
	[sp setMessage:NSLocalizedString(@"Export The Drawing", @"")];
	[sp setCanSelectHiddenExtension:YES];
	sp.nameFieldStringValue = [(id)delegate displayName];

	[sp beginSheetModalForWindow:parent
			   completionHandler:^(NSModalResponse result) {
				   [self exportPanelDidEnd:sp returnCode:result contextInfo:NULL];
			   }];
}

- (IBAction)formatPopUpAction:(id)sender
{
	NSInteger tag = [sender selectedItem].tag;

	mFileType = tag;

	[self displayOptionsForFileType:tag];
}

- (IBAction)resolutionPopUpAction:(id)sender
{
	NSInteger tag = [sender selectedItem].tag;
	mOptionsDict[kDKExportPropertiesResolution] = @(tag);
}

- (IBAction)formatIncludeGridAction:(id)sender
{
	mOptionsDict[kGCIncludeGridInExportedFile] = [NSNumber numberWithBool:([sender intValue] != 0)];
}

- (IBAction)jpegQualityAction:(id)sender
{
	mOptionsDict[NSImageCompressionFactor] = @([sender floatValue]);
}

- (IBAction)jpegProgressiveAction:(id)sender
{
	mOptionsDict[NSImageProgressive] = [NSNumber numberWithBool:([sender intValue] != 0)];
}

- (IBAction)tiffCompressionAction:(id)sender
{
	NSInteger tag = [sender selectedItem].tag;

	mOptionsDict[NSImageCompressionMethod] = @(tag);
}

- (IBAction)tiffAlphaAction:(id)sender
{
	mOptionsDict[kDKExportedImageHasAlpha] = [NSNumber numberWithBool:([sender intValue] != 0)];
}

- (IBAction)pngInterlaceAction:(id)sender
{
	mOptionsDict[NSImageInterlaced] = [NSNumber numberWithBool:([sender intValue] != 0)];
}

- (void)displayOptionsForFileType:(GCSExportFileTypes)type
{
	[mExportFormatPopUpButton selectItemWithTag:type];

	if (type == GCSExportFileTypePDF)
		[mExportResolutionPopUpButton setEnabled:NO];
	else
		[mExportResolutionPopUpButton setEnabled:YES];

	// set controls in options to match current dict state

	mJPEGQualitySlider.floatValue = [mOptionsDict[NSImageCompressionFactor] floatValue];
	mJPEGProgressiveCheckbox.intValue = [mOptionsDict[NSImageProgressive] intValue];
	mPNGInterlaceCheckbox.intValue = [mOptionsDict[NSImageInterlaced] intValue];
	[mTIFFCompressionTypePopUpButton selectItemWithTag:[mOptionsDict[NSImageCompressionMethod] intValue]];
	mTIFFAlphaCheckbox.intValue = [mOptionsDict[kDKExportedImageHasAlpha] intValue];
	[mExportResolutionPopUpButton selectItemWithTag:[mOptionsDict[kDKExportPropertiesResolution] intValue]];

	NSString *rft;

	switch (type) {
		default:
		case GCSExportFileTypePDF:
			[mExportOptionsTabView selectTabViewItemAtIndex:0];
			rft = (NSString *)kUTTypePDF;
			break;

		case NSJPEGFileType:
			[mExportOptionsTabView selectTabViewItemAtIndex:1];
			rft = (NSString *)kUTTypeJPEG;
			break;

		case NSPNGFileType:
			[mExportOptionsTabView selectTabViewItemAtIndex:2];
			rft = (NSString *)kUTTypePNG;
			break;

		case NSTIFFFileType:
			[mExportOptionsTabView selectTabViewItemAtIndex:3];
			rft = (NSString *)kUTTypeTIFF;
			break;
	}
	mSavePanel.allowedFileTypes = @[ rft ];
}

- (void)exportPanelDidEnd:(NSSavePanel *)sp returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
#pragma unused(contextInfo)

	if (returnCode == NSOKButton) {
		if (mDelegate && [mDelegate respondsToSelector:@selector(performExportType:withOptions:)]) {
			// call the delegate to perform the export with the data we've obtained from the user.

			mOptionsDict[kGCExportedFileURL] = sp.URL;

			LogEvent_(kFileEvent, @"export controller completed (OK), type = %ld, dict = %@", (long)mFileType, mOptionsDict);

			[mDelegate performExportType:mFileType withOptions:mOptionsDict];
		}
	}
}

@end
