//
//  GCExportOptionsController.h
//  GCDrawKit
//
//  Created by graham on 11/07/2008.
//  Copyright 2008 Apptree.net. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol GCSExportControllerDelegate;

typedef NS_ENUM(NSInteger, GCSExportFileTypes) {
	// to unify the file types for export, the following is used to indicate export to PDF
	GCSExportFileTypePDF = -1,

	GCSExportFileTypeJPEG = NSBitmapImageFileTypeJPEG,
	GCSExportFileTypePNG = NSBitmapImageFileTypePNG,
	GCSExportFileTypeTIFF = NSBitmapImageFileTypeTIFF,
};

@interface GCSExportOptionsController : NSObject {
	IBOutlet __strong NSView *mExportAccessoryView;
	IBOutlet NSPopUpButton *mExportFormatPopUpButton;
	IBOutlet NSPopUpButton *mExportResolutionPopUpButton;
	IBOutlet NSButton *mExportIncludeGridCheckbox;
	IBOutlet NSTabView *mExportOptionsTabView;
	IBOutlet NSSlider *mJPEGQualitySlider;
	IBOutlet NSButton *mJPEGProgressiveCheckbox;
	IBOutlet NSButton *mPNGInterlaceCheckbox;
	IBOutlet NSPopUpButton *mTIFFCompressionTypePopUpButton;
	IBOutlet NSButton *mTIFFAlphaCheckbox;

	NSSavePanel *mSavePanel;
	__weak id<GCSExportControllerDelegate> mDelegate;
	NSMutableDictionary *mOptionsDict;
	GCSExportFileTypes mFileType;
}

- (void)beginExportDialogWithParentWindow:(NSWindow *)parent delegate:(id<GCSExportControllerDelegate>)delegate;

- (IBAction)formatPopUpAction:(id)sender;
- (IBAction)resolutionPopUpAction:(id)sender;
- (IBAction)formatIncludeGridAction:(id)sender;
- (IBAction)jpegQualityAction:(id)sender;
- (IBAction)jpegProgressiveAction:(id)sender;
- (IBAction)tiffCompressionAction:(id)sender;
- (IBAction)tiffAlphaAction:(id)sender;
- (IBAction)pngInterlaceAction:(id)sender;

- (void)displayOptionsForFileType:(GCSExportFileTypes)type;
- (void)exportPanelDidEnd:(NSSavePanel *)sp returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;

@end

// delegate protocol:

@protocol GCSExportControllerDelegate <NSObject>

- (void)performExportType:(GCSExportFileTypes)fileType withOptions:(NSDictionary<NSString *, id> *)options NS_SWIFT_NAME(performExport(type:withOptions:));

@end

static const GCSExportFileTypes NSPDFFileType API_DEPRECATED_WITH_REPLACEMENT("GCExportFileTypePDF", macosx(10.0, 10.6)) = GCSExportFileTypePDF;

// additional keys for option properties not used by Cocoa

extern NSString *kGCIncludeGridInExportedFile; // BOOL property
extern NSString *kGCExportedFileURL;		   // NSURL property
