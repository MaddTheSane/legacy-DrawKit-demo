//
//  GCDrawDemoDocument.h
//  GCDrawDemo
//
//  Created by Jason Jobe on 2/18/07.
//  Copyright __MyCompanyName__ 2007 . All rights reserved.
//

#import <DKDrawKit/DKDrawingDocument.h>
#import "GCPolarDuplicateController.h"
#import "GCLinearDuplicateController.h"
#import "GCExportOptionsController.h"

@class GCBasicDialogController;
@class GCExportOptionsController;
@class DrawingSizeController;

@interface GCDrawDemoDocument : DKDrawingDocument <PolarDuplicationDelegate, ExportControllerDelegate, LinearDuplicationDelegate>
{
	IBOutlet GCBasicDialogController *mToolNamePanelController;
	IBOutlet GCPolarDuplicateController *mPolarDuplicateController;
	IBOutlet GCLinearDuplicateController *mLinearDuplicateController;
	IBOutlet GCExportOptionsController *mExportController;
	DrawingSizeController *mDrawingSizeController;
}

@property (class) BOOL defaultQualityModulation;


- (NSString*)			askUserForToolName;

- (IBAction)			makeToolFromSelectedShape:(id) sender;

- (IBAction)			polarDuplicate:(id) sender;
- (IBAction)			linearDuplicate:(id) sender;
- (IBAction)			openDrawingSizePanel:(id) sender;
- (IBAction)			exportAction:(id) sender;

@end



extern NSString*		kDKTableRowInternalDragPasteboardType;
