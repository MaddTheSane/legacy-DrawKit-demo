//
//  GCExportOptionsController.h
//  GCDrawKit
//
//  Created by graham on 11/07/2008.
//  Copyright 2008 Apptree.net. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@protocol GCSExportControllerDelegate;

typedef NS_ENUM(NSInteger, GCSExportFileTypes) {
	// to unify the file types for export, the following is used to indicate export to PDF
	GCSExportFileTypePDF = -1,

	GCSExportFileTypeJPEG = NSBitmapImageFileTypeJPEG,
	GCSExportFileTypePNG = NSBitmapImageFileTypePNG,
	GCSExportFileTypeTIFF = NSBitmapImageFileTypeTIFF,
};

// additional keys for option properties not used by Cocoa

extern NSBitmapImageRepPropertyKey kGCIncludeGridInExportedFile; // BOOL property
extern NSBitmapImageRepPropertyKey kGCExportedFileURL;		   // NSURL property

NS_ASSUME_NONNULL_END
