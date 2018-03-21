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

NS_ASSUME_NONNULL_BEGIN

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

/** @brief checks if the pastebaord contains data we can use to create a gradient.
 @param pboard The pasteboard to check.
 @return \c YES if can initialize, \c NO otherwise.
 */
+ (BOOL)canInitalizeFromPasteboard:(NSPasteboard *)pboard;
@property (class) NSSize pasteboardImageSize;

/** @brief Returns a gradient created from pasteboard data, if valid.
 @param pboard The pasteboard to read.
 @return A gradient object, or \c nil if there was no suitable data on the pasteboard.
 */
+ (nullable DKGradient *)gradientWithPasteboard:(NSPasteboard *)pboard;

/** @brief Returns a gradient created from plist data, if valid.
 @param plist A dictionary with plist representation of the gradient object.
 @return A gradient object, or \c nil if the plist was invalid.
 */
+ (nullable DKGradient *)gradientWithPlist:(NSDictionary *)plist;

/** @brief Writes the gradient to the pasteboard.
 
 Also writes a TIFF image version for export.
 @param pboard The pasteboard to write to.
 @return \c YES if the data was written OK, \c NO otherwise.
 */
- (BOOL)writeToPasteboard:(NSPasteboard *)pboard;

/** @brief Places data of the requested type on the given pasteboard.
 @param type The data type to write.
 @param pboard The pasteboard to write it to.
 @return \c YES if the type could be written, \c NO otherwise.
 */
- (BOOL)writeType:(NSPasteboardType)type toPasteboard:(NSPasteboard *)pboard;

/** @brief Return gradient as PDF data.
 */
@property (readonly, copy, nullable) NSData *pdf;

/** @brief Return gradient as EPS data.
 */
@property (readonly, copy, nullable) NSData *eps;

// File interface

/** @brief create a gradient object from a gradient file
 @param path The path to the file.
 @return The gradient object, or \c nil if the file could not be read.
 */
+ (DKGradient *)gradientWithContentsOfFile:(NSString *)path;

/** @brief Write the gradient object to a gradient file.
 @param path The path to the file.
 @param flag \c YES to write via a safe save, \c NO to write directly.
 @return \c YES if the file was written succesfully, \c NO otherwise.
 */
- (BOOL)writeToFile:(NSString *)path atomically:(BOOL)flag;

/** @brief Write the gradient object to a gradient file.
 @param path The file URL to save to.
 @param writeOptionsMask The options to pass to NSFileWrapper.
 @return \c YES if the file was written succesfully, \c NO otherwise.
 */
- (BOOL)writeToURL:(NSURL *)path options:(NSFileWrapperWritingOptions)writeOptionsMask error:(NSError * __autoreleasing *)errorPtr;

/** @brief File representation of the gradient.
 @return A data object containing the file representation of the gradient.
 */
@property (readonly, copy) NSData *fileRepresentation;

/** @brief file wrapper representation of the gradient.
 
 a file wrapper object containing the file representation of the gradient
 */
@property (readonly, strong) NSFileWrapper *fileWrapperRepresentation;
@property (readonly, copy) NSDictionary *plistRepresentation;

/** @brief Writes the gradient file representation to the pasteboard.
 @param pboard The pasteboard to write to.
 */
- (BOOL)writeFileToPasteboard:(NSPasteboard *)pboard;

@end

// Gradient Library Keys
extern NSString * const GCGradientInfoKey;
extern NSString * const GCGradientsKey;

// Pasteboard and file types
extern NSPasteboardType const GPGradientPasteboardType NS_SWIFT_NAME(gpGradient);
extern NSPasteboardType const GPGradientLibPasteboardType NS_SWIFT_NAME(gpGradientLib);
extern NSString * const GradientFileExtension;
extern NSString *const GPGradientFileUTI;

NS_ASSUME_NONNULL_END
