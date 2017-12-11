//
//  GCDrawDemoDocument.h
//  GCDrawDemo
//
//  Created by Jason Jobe on 2/18/07.
//  Copyright __MyCompanyName__ 2007 . All rights reserved.
//

#import <DKDrawKit/DKDrawingDocument.h>
#import "GCPolarDuplicateController.h"
#import "GCExportOptionsController.h"

@interface GCDrawDemoDocument : DKDrawingDocument <PolarDuplicationDelegate, ExportControllerDelegate>
{
	IBOutlet	id		mToolNamePanelController;
	IBOutlet	id		mPolarDuplicateController;
	IBOutlet	id		mLinearDuplicateController;
	IBOutlet	id		mExportController;
	id					mDrawingSizeController;
}

+ (void)				setDefaultQualityModulation:(BOOL) dqm;
+ (BOOL)				defaultQualityModulation;
@property (class) BOOL defaultQualityModulation;


- (NSString*)			askUserForToolName;

- (IBAction)			makeToolFromSelectedShape:(id) sender;

- (IBAction)			polarDuplicate:(id) sender;
- (IBAction)			linearDuplicate:(id) sender;
- (IBAction)			openDrawingSizePanel:(id) sender;
- (IBAction)			exportAction:(id) sender;

@end



extern NSString*		kDKTableRowInternalDragPasteboardType;
