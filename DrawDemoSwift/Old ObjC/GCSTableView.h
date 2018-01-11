/* GCTableView */

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@protocol GCSColourCellHack <NSObject>

- (void)setTemporaryColour:(nullable NSColor *)aColour forTableView:(NSTableView *)tView row:(NSInteger)row;

@end

NS_ASSUME_NONNULL_END
