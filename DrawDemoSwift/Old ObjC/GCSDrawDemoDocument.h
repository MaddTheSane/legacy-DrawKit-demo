//
//  GCDrawDemoDocument.h
//  GCDrawDemo
//
//  Created by Jason Jobe on 2/18/07.
//  Copyright __MyCompanyName__ 2007 . All rights reserved.
//

#import <DKDrawKit/DKDrawingDocument.h>
#import "GCSPolarDuplicateController.h"
#import "GCSLinearDuplicateController.h"
#import "GCSExportOptionsController.h"

@class GCSBasicDialogController;
@class GCSExportOptionsController;
@class GCSDrawingSizeController;

@interface GCSDrawDemoDocument : DKDrawingDocument <GCSPolarDuplicationDelegate, GCSExportControllerDelegate, GCSLinearDuplicationDelegate> {
	IBOutlet GCSBasicDialogController *mToolNamePanelController;
	IBOutlet GCSPolarDuplicateController *mPolarDuplicateController;
	IBOutlet GCSLinearDuplicateController *mLinearDuplicateController;
	IBOutlet GCSExportOptionsController *mExportController;
	GCSDrawingSizeController *mDrawingSizeController;
}

@property (class) BOOL defaultQualityModulation;

- (NSString *)askUserForToolName;

- (IBAction)makeToolFromSelectedShape:(id)sender;

- (IBAction)polarDuplicate:(id)sender;
- (IBAction)linearDuplicate:(id)sender;
- (IBAction)openDrawingSizePanel:(id)sender;
- (IBAction)exportAction:(id)sender;

@end

extern NSPasteboardType kDKSTableRowInternalDragPasteboardType;
