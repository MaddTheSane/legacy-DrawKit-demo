//
//  GCGradientPasteboard.h
//  GradientTest
//
//  Created by Jason Jobe on 4/5/07.
//  Released under the Creative Commons license 2006 Datalore, LLC.
//
//
//  This work is licensed under the Creative Commons Attribution-ShareAlike 2.5 License.
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/2.5/ or send a letter to
//  Creative Commons, 543 Howard Street, 5th Floor, San Francisco, California, 94105, USA.
//
//***********************************************************************************************

#import <DKDrawKit/DKGradient.h>

//! Pasteboard Support
@interface DKGradient (GCGradientPasteboard)

//! An NSArray containing the pasteboard types that DKGradient can read.
@property (class, readonly, copy) NSArray<NSPasteboardType> *readablePasteboardTypes;
/** @brief an NSArray containing the pasteboard types that DKGradient can write.
 @discussion in fact this only declares one type - the native type. When writing to a pasteboard using
 \c writeType:toPasteboard: each additional type is added as a type on demand. Normally you will
 decalre the writeable type so that the pasteboard is initially cleared.
 */
@property (class, readonly, copy) NSArray<NSPasteboardType> *writablePasteboardTypes;

// Pasteboard Support

+ (BOOL)canInitalizeFromPasteboard:(NSPasteboard *)pboard;
@property (class) NSSize pasteboardImageSize;
+ (DKGradient *)gradientWithPasteboard:(NSPasteboard *)pboard;
+ (DKGradient *)gradientWithPlist:(NSDictionary *)plist;

- (BOOL)writeToPasteboard:(NSPasteboard *)pboard;
- (BOOL)writeType:(NSPasteboardType)type toPasteboard:(NSPasteboard *)pboard;

@property (readonly, copy) NSData *pdf;
@property (readonly, copy) NSData *eps;

// File interface

+ (DKGradient *)gradientWithContentsOfFile:(NSString *)path;
- (BOOL)writeToFile:(NSString *)path atomically:(BOOL)flag;
@property (readonly, copy) NSData *fileRepresentation;
@property (readonly, strong) NSFileWrapper *fileWrapperRepresentation;
@property (readonly, copy) NSDictionary *plistRepresentation;

- (BOOL)writeFileToPasteboard:(NSPasteboard *)pboard;

@end

// Gradient Library Keys
extern NSString * const GCGradientInfoKey;
extern NSString * const GCGradientsKey;

// Pasteboard and file types
extern NSPasteboardType const GPGradientPasteboardType NS_SWIFT_NAME(gpGradient);
extern NSPasteboardType const GPGradientLibPasteboardType;
extern NSString * const GradientFileExtension;
