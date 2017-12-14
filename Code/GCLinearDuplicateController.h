//
//  GCLinearDuplicateController.h
//  GCDrawKit
//
//  Created by graham on 01/04/2008.
//  Copyright 2008 Apptree.net. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol LinearDuplicationDelegate;

@interface GCLinearDuplicateController : NSWindowController {
	IBOutlet NSTextField *mNumberOfCopiesTextField;
	IBOutlet NSTextField *mXOffsetTextField;
	IBOutlet NSTextField *mYOffsetTextField;
	IBOutlet NSButton *mOKButton;

	id<LinearDuplicationDelegate> mDelegateRef;
}

- (IBAction)numberOfCopiesAction:(id)sender;
- (IBAction)xyOffsetAction:(id)sender;
- (IBAction)okAction:(id)sender;
- (IBAction)cancelAction:(id)sender;

- (void)beginLinearDuplicationDialog:(NSWindow *)parentWindow linearDelegate:(id<LinearDuplicationDelegate>)delegate;
- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;

- (void)conditionallyEnableOKButton;

@end

@protocol LinearDuplicationDelegate <NSObject>

- (void)doLinearDuplicateCopies:(NSInteger)copies offset:(NSSize)offset;
@property (readonly) NSInteger countOfItemsInSelection;

@end
