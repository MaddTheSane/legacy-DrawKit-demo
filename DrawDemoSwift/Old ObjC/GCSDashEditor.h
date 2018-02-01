///**********************************************************************************************************************************
///  GCDashEditor.h
///  GCDrawKit
///
///  Created by graham on 18/05/2007.
///  Released under the Creative Commons license 2007 Apptree.net.
///
///
///  This work is licensed under the Creative Commons Attribution-ShareAlike 2.5 License.
///  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/2.5/ or send a letter to
///  Creative Commons, 543 Howard Street, 5th Floor, San Francisco, California, 94105, USA.
///
///**********************************************************************************************************************************

#import <Cocoa/Cocoa.h>
#import "GCSBasicDialogController.h"

@protocol GCSDashEditorDelegate <GCSBasicDialogDelegate>
@optional
- (void)dashDidChange:(nullable id)sender;

@end
