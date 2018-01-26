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

NS_ASSUME_NONNULL_BEGIN

@protocol GCSBasicDialogDelegate <NSObject>
- (void)sheetDidEnd:(NSWindow*)sheet returnCode:(NSModalResponse)returnCode contextInfo:(nullable void*)contextInfo;

@end

NS_ASSUME_NONNULL_END
