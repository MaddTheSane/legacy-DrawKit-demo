///**********************************************************************************************************************************
///  GCBasicDialogController.h
///  GCDrawKit
///
///  Created by graham on 03/11/2006.
///  Released under the Creative Commons license 2006 Apptree.net.
///
///
///  This work is licensed under the Creative Commons Attribution-ShareAlike 2.5 License.
///  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/2.5/ or send a letter to
///  Creative Commons, 543 Howard Street, 5th Floor, San Francisco, California, 94105, USA.
///
///**********************************************************************************************************************************

#import <Cocoa/Cocoa.h>


@protocol GCBasicDialogDelegate;

/**
 
 Basic controller handles dialogs with OK, Cancel and one primary item.
 
 When running as a sheet, modal delegate should implement:
 
 - (void)		sheetDidEnd:(NSWindow*) sheet returnCode:(NSInteger) returnCode  contextInfo:(void*) contextInfo;
 
 */
@interface GCBasicDialogController : NSWindowController {
	IBOutlet NSButton *mOK;
	IBOutlet NSButton *mCancel;
	IBOutlet NSTextField *mPrimaryItem;

	BOOL mRunningAsSheet;
}

- (NSModalResponse)runModal;
- (void)runAsSheetInParentWindow:(NSWindow *)parent modalDelegate:(id<GCBasicDialogDelegate>)delegate;

@property (readonly, strong) id primaryItem;

- (IBAction)ok:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)primaryItemAction:(id)sender;

@end

@protocol GCBasicDialogDelegate <NSObject>
- (void)sheetDidEnd:(NSWindow*)sheet returnCode:(NSModalResponse)returnCode contextInfo:(void*)contextInfo;

@end
