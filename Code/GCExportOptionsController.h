//
//  GCExportOptionsController.h
//  GCDrawKit
//
//  Created by graham on 11/07/2008.
//  Copyright 2008 Apptree.net. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol ExportControllerDelegate;

typedef NS_ENUM(NSInteger, GCExportFileTypes) {
	// to unify the file types for export, the following is used to indicate export to PDF
	GCExportFileTypePDF = -1,

	GCExportFileTypeJPEG = NSJPEGFileType,
	GCExportFileTypePNG = NSPNGFileType,
	GCExportFileTypeTIFF = NSTIFFFileType,
};

@interface GCExportOptionsController : NSObject {
	IBOutlet NSView *mExportAccessoryView;
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
	id<ExportControllerDelegate> mDelegate;
	NSMutableDictionary *mOptionsDict;
	GCExportFileTypes mFileType;
}

- (void)beginExportDialogWithParentWindow:(NSWindow *)parent delegate:(id<ExportControllerDelegate>)delegate;

- (IBAction)formatPopUpAction:(id)sender;
- (IBAction)resolutionPopUpAction:(id)sender;
- (IBAction)formatIncludeGridAction:(id)sender;
- (IBAction)jpegQualityAction:(id)sender;
- (IBAction)jpegProgressiveAction:(id)sender;
- (IBAction)tiffCompressionAction:(id)sender;
- (IBAction)tiffAlphaAction:(id)sender;
- (IBAction)pngInterlaceAction:(id)sender;

- (void)displayOptionsForFileType:(GCExportFileTypes)type;
- (void)exportPanelDidEnd:(NSSavePanel *)sp returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;

@end

// delegate protocol:

@protocol ExportControllerDelegate <NSObject>

- (void)performExportType:(GCExportFileTypes)fileType withOptions:(NSDictionary<NSString *, id> *)options;

@end

static const GCExportFileTypes NSPDFFileType API_DEPRECATED_WITH_REPLACEMENT("GCExportFileTypePDF", macosx(10.0, 10.6)) = GCExportFileTypePDF;

// additional keys for option properties not used by Cocoa

extern NSString *kGCIncludeGridInExportedFile; // BOOL property
extern NSString *kGCExportedFileURL;		   // NSURL property
