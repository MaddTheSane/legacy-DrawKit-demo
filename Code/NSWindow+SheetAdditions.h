#import <Cocoa/Cocoa.h>

/**
 provides a more logical way to start sheets than using NSApplication directly by invoking the method on the sheet or the parent window
 itself. These are very minimal wrappers around the NSApplicaiton method.
 */
@interface NSWindow (SheetAdditions)

- (void)beginSheet:(NSWindow *)sheet modalDelegate:(id)modalDelegate didEndSelector:(SEL)didEndSelector contextInfo:(void *)contextInfo DEPRECATED_ATTRIBUTE;
- (void)beginSheetModalForWindow:(NSWindow *)docWindow modalDelegate:(id)modalDelegate didEndSelector:(SEL)didEndSelector contextInfo:(void *)contextInfo DEPRECATED_ATTRIBUTE;

@end
