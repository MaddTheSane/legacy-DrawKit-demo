//
//  GCExportOptionsController.m
//  GCDrawKit
//
//  Created by graham on 11/07/2008.
//  Copyright 2008 Apptree.net. All rights reserved.
//

#import "GCExportOptionsController.h"
#import <DKDrawKit/DKDrawing+Export.h>
#import <DKDrawKit/LogEvent.h>


NSString* kGCIncludeGridInExportedFile = @"kGCIncludeGridInExportedFile";
NSString* kGCExportedFileURL = @"kGCExportedFileURL";


@implementation GCExportOptionsController


- (void)beginExportDialogWithParentWindow:(NSWindow*)parent delegate:(id<ExportControllerDelegate>)delegate
{
	// allows export of the drawing as PDF, etc.
	
	mDelegate = delegate;
	
	if( mOptionsDict == nil )
	{
		mOptionsDict = [[NSMutableDictionary alloc] init];
		[mOptionsDict setObject:[NSNumber numberWithFloat:0.67] forKey:NSImageCompressionFactor];
		[mOptionsDict setObject:[NSNumber numberWithInt:72] forKey:kDKExportPropertiesResolution];
	}
	
	NSSavePanel*	sp = [NSSavePanel savePanel];
	
	[sp setAccessoryView:mExportAccessoryView];
	mSavePanel = sp;
	mFileType = GCExportFileTypePDF;
	[self displayOptionsForFileType:mFileType];
	
	[sp setPrompt:NSLocalizedString(@"Export", @"")];
	[sp setMessage:NSLocalizedString(@"Export The Drawing", @"")];
	[sp setCanSelectHiddenExtension:YES];
	
	[sp beginSheetForDirectory:nil
		file:[delegate displayName]
		modalForWindow:parent
		modalDelegate:self
		didEndSelector:@selector(exportPanelDidEnd:returnCode:contextInfo:)
		contextInfo:NULL];
}




- (IBAction)formatPopUpAction:(id) sender
{
	NSInteger tag = [[sender selectedItem] tag];
	
	mFileType = tag;
	
	[self displayOptionsForFileType:tag];
}


- (IBAction)	resolutionPopUpAction:(id) sender
{
	NSInteger tag = [[sender selectedItem] tag];
	[mOptionsDict setObject:@(tag) forKey:kDKExportPropertiesResolution];
}



- (IBAction)formatIncludeGridAction:(id) sender
{
	[mOptionsDict setObject:[NSNumber numberWithBool:[sender intValue]] forKey:kGCIncludeGridInExportedFile];
}



- (IBAction)jpegQualityAction:(id) sender
{
	[mOptionsDict setObject:[NSNumber numberWithFloat:[sender floatValue]] forKey:NSImageCompressionFactor];
}



- (IBAction)jpegProgressiveAction:(id) sender
{
	[mOptionsDict setObject:[NSNumber numberWithBool:[sender intValue]] forKey:NSImageProgressive];
}



- (IBAction)tiffCompressionAction:(id) sender
{
	NSInteger tag = [[sender selectedItem] tag];

	[mOptionsDict setObject:@(tag) forKey:NSImageCompressionMethod];
}


- (IBAction)	tiffAlphaAction:(id) sender
{
	[mOptionsDict setObject:[NSNumber numberWithBool:[sender intValue]] forKey:kDKExportedImageHasAlpha];
}



- (IBAction)	pngInterlaceAction:(id) sender
{
	[mOptionsDict setObject:[NSNumber numberWithBool:[sender intValue]] forKey:NSImageInterlaced];
}




- (void)displayOptionsForFileType:(GCExportFileTypes) type
{
	[mExportFormatPopUpButton selectItemWithTag:type];
	
	if( type == GCExportFileTypePDF )
		[mExportResolutionPopUpButton setEnabled:NO];
	else
		[mExportResolutionPopUpButton setEnabled:YES];
	
	// set controls in options to match current dict state
	
	[mJPEGQualitySlider setFloatValue:[[mOptionsDict objectForKey:NSImageCompressionFactor] floatValue]];
	[mJPEGProgressiveCheckbox setIntValue:[[mOptionsDict objectForKey:NSImageProgressive] intValue]];
	[mPNGInterlaceCheckbox setIntValue:[[mOptionsDict objectForKey:NSImageInterlaced] intValue]];
	[mTIFFCompressionTypePopUpButton selectItemWithTag:[[mOptionsDict objectForKey:NSImageCompressionMethod] intValue]];
	[mTIFFAlphaCheckbox setIntValue:[[mOptionsDict objectForKey:kDKExportedImageHasAlpha] intValue]];
	[mExportResolutionPopUpButton selectItemWithTag:[[mOptionsDict objectForKey:kDKExportPropertiesResolution] intValue]];
	
	NSString* rft;
	
	switch (type) {
		default:
		case GCExportFileTypePDF:
			[mExportOptionsTabView selectTabViewItemAtIndex:0];
			rft = (NSString*)kUTTypePDF;
			break;
		
		case NSJPEGFileType:
			[mExportOptionsTabView selectTabViewItemAtIndex:1];
			rft = (NSString*)kUTTypeJPEG;
			break;

		case NSPNGFileType:
			[mExportOptionsTabView selectTabViewItemAtIndex:2];
			rft = (NSString*)kUTTypePNG;
			break;

		case NSTIFFFileType:
			[mExportOptionsTabView selectTabViewItemAtIndex:3];
			rft = (NSString*)kUTTypeTIFF;
			break;
	}
	mSavePanel.allowedFileTypes = @[rft];
}


- (void)exportPanelDidEnd:(NSSavePanel*) sp returnCode:(NSInteger) returnCode contextInfo:(void*) contextInfo
{
	#pragma unused(contextInfo)
	
	if( returnCode == NSOKButton )
	{
		if( mDelegate && [mDelegate respondsToSelector:@selector(performExportType:withOptions:)])
		{
			// call the delegate to perform the export with the data we've obtained from the user.
			
			[mOptionsDict setObject:[sp URL] forKey:kGCExportedFileURL];
			
			LogEvent_( kFileEvent, @"export controller completed (OK), type = %d, dict = %@", mFileType, mOptionsDict );

			[mDelegate performExportType:mFileType withOptions:mOptionsDict];
		}
	}
}

@end
