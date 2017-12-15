///**********************************************************************************************************************************
///  GCToolPalette.h
///  GCDrawKit
///
///  Created by graham on 11/06/2007.
///  Released under the Creative Commons license 2007 Apptree.net.
///
///
///  This work is licensed under the Creative Commons Attribution-ShareAlike 2.5 License.
///  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/2.5/ or send a letter to
///  Creative Commons, 543 Howard Street, 5th Floor, San Francisco, California, 94105, USA.
///
///**********************************************************************************************************************************

#import <DKDrawKit/DKDrawkitInspectorBase.h>
#import <DKDrawKit/DKStyle.h>

@interface GCSToolPalette : DKDrawkitInspectorBase {
	IBOutlet NSMatrix *mToolMatrix;
	IBOutlet NSPopUpButton *mStylePopUpButton;
	IBOutlet NSImageView *mStylePreviewView;
}

- (IBAction)toolButtonMatrixAction:(id)sender;
- (IBAction)libraryItemAction:(id)sender;
- (IBAction)toolDoubleClick:(id)sender;

- (void)selectToolWithName:(NSString *)name;
- (void)toolChangedNotification:(NSNotification *)note;
- (void)populatePopUpButtonWithLibraryStyles:(NSPopUpButton *)button;
- (void)updateStylePreviewWithStyle:(DKStyle *)style;
- (void)styleRegistryChanged:(NSNotification *)note;

@end