//
//  GCGradientPasteboard.m
//  GradientTest
//
//  Created by Jason Jobe on 4/5/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "GCSGradientPasteboard.h"

#import "NSFolderManagerAdditions.h"
#import "WTPlistKeyValueCoding.h"
#import <DKDrawKit/LogEvent.h>

#pragma mark Contants (Non-localized)
// Pasteboard and file types
NSString *const GPGradientPasteboardType = @"GPGradientPasteboardType";
NSString *const GPGradientLibPasteboardType = @"GPGradientLibPasteboardType";
NSString *const GradientFileExtension = @"gradient";

NSString *GCGradientInfoKey = @"info";
NSString *GCGradientsKey = @"gradients";

#pragma mark Static Vars
static NSSize sGradientPasteboardImageSize = {256.0, 256.0};

@implementation DKGradient (GCSGradientPasteboard)
#pragma mark As a DKGradient
+ (NSArray *)readablePasteboardTypes
{
	static NSArray *types = nil;

	if (types == nil) {
		types = @[GPGradientPasteboardType,
				  NSFileContentsPboardType,
				  (NSString*)kUTTypeFileURL];
	}

	return types;
}

+ (NSArray *)writablePasteboardTypes
{
	static NSArray *types = nil;
	if (types == nil) {
		types = @[ GPGradientPasteboardType ];
	}

	return types;
}

#pragma mark -
///*********************************************************************************************************************
///
/// method:			canInitalizeFromPasteboard:
/// scope:			public class method
/// overrides:
/// description:	checksif the pastebaord containsdata we can use to create a gradient
///
/// parameters:		<pboard> the pasteboard to check
/// result:			YES if can initialize, NO otherwise
///
/// notes:
///
///********************************************************************************************************************

+ (BOOL)canInitalizeFromPasteboard:(NSPasteboard *)pboard
{
	NSString *bestType = [pboard availableTypeFromArray:[self readablePasteboardTypes]];
	return (bestType != nil);
}

///*********************************************************************************************************************
///
/// method:			setPasteboardImageSize:
/// scope:			public class method
/// overrides:
/// description:	sets the preferred size for the image versions of the gradient copied to the pasteboard
///
/// parameters:		<pbiSize> the preferred size
/// result:			none
///
/// notes:
///
///********************************************************************************************************************

+ (void)setPasteboardImageSize:(NSSize)pbiSize
{
	sGradientPasteboardImageSize = pbiSize;
}

+ (NSSize)pasteboardImageSize
{
	return sGradientPasteboardImageSize;
}

///*********************************************************************************************************************
///
/// method:			gradientWithPasteboard:
/// scope:			public class method
/// overrides:
/// description:	returns a gradient created from pasteboard data if valid
///
/// parameters:		<pboard> the pasteboard to read
/// result:			a gradient object, or nil if there was no suitable data on the pasteboard
///
/// notes:
///
///********************************************************************************************************************

+ (DKGradient *)gradientWithPasteboard:(NSPasteboard *)pboard
{
	NSString *bestType = [pboard availableTypeFromArray:[self readablePasteboardTypes]];

	//	LogEvent_(kReactiveEvent, @"gradient from pb, best type = %@", bestType );
	//	LogEvent_(kReactiveEvent, @"pb types = %@", [pboard types]);

	if ([GPGradientPasteboardType isEqualToString:bestType]) {
		NSData *data = [pboard dataForType:GPGradientPasteboardType];
		return [NSKeyedUnarchiver unarchiveObjectWithData:data];
	} else if ([(NSString*)kUTTypeFileURL isEqualToString:bestType]) {
		NSArray *files = [pboard propertyListForType:(NSString*)kUTTypeFileURL];
		// Can't handle more than one.
		if (files.count != 1)
			return nil;

		NSURL *filePath = files[0];
		if ([filePath.pathExtension isEqualToString:GradientFileExtension]) {
			NSDictionary *dict = [NSDictionary dictionaryWithContentsOfURL:filePath];
			id val = [dict unarchiveFromPropertyListFormat];
			return val;
		}
	}
	return nil;
}

///*********************************************************************************************************************
///
/// method:			gradientWithPlist:
/// scope:			public class method
/// overrides:
/// description:	returns a gradient created from plist data if valid
///
/// parameters:		<plist> a dictionary with plist representation of the gradient object
/// result:			a gradient object, or nil if the plist was invalid
///
/// notes:
///
///********************************************************************************************************************

+ (DKGradient *)gradientWithPlist:(NSDictionary *)plist
{
	return [plist unarchiveFromPropertyListFormat];
}

#pragma mark -
///*********************************************************************************************************************
///
/// method:			writeToPasteboard:
/// scope:			public instance method
/// overrides:
/// description:	writes the gradient to the pasteboard
///
/// parameters:		<pboard> the pasteboard to write to
/// result:			YES if the data was written OK, NO otherwise
///
/// notes:			also writes a TIFF image version for export
///
///********************************************************************************************************************

- (BOOL)writeToPasteboard:(NSPasteboard *)pboard
{
	[pboard declareTypes:@[GPGradientPasteboardType] owner:self];
	[self writeType:GPGradientPasteboardType toPasteboard:pboard];
	[self writeType:NSPasteboardTypePDF toPasteboard:pboard];
	//[self writeType:@"com.adobe.encapsulated-postscript" toPasteboard:pboard];
	[self writeType:NSPasteboardTypeTIFF toPasteboard:pboard];
	return YES;
}

///*********************************************************************************************************************
///
/// method:			writeType:toPasteboard:
/// scope:			public instance method
/// overrides:
/// description:	places data of the requested type on the given pasteboard
///
/// parameters:		<type> the data type to write
///					<pboard> the pasteboard to write it to
/// result:			YES if the type could be written, NO otherwise
///
/// notes:
///
///********************************************************************************************************************

- (BOOL)writeType:(NSString *)type toPasteboard:(NSPasteboard *)pboard
{
	BOOL result = NO;

	// GPC: always add the requested type - thus we don't need to have separate type and write methods. However,
	// caller must declare *something* to clear pb first

	//	LogEvent_(kReactiveEvent, @"writing type = %@", type);

	[pboard addTypes:@[type] owner:self];

	if ([GPGradientPasteboardType isEqualToString:type]) {
		NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
		result = [pboard setData:data forType:GPGradientPasteboardType];
	} else if ([NSPasteboardTypeTIFF isEqualToString:type]) {
		NSImage *image = [self swatchImageWithSize:sGradientPasteboardImageSize withBorder:NO];
		result = [pboard setData:image.TIFFRepresentation forType:NSPasteboardTypeTIFF];
	} else if ([NSPasteboardTypePDF isEqualToString:type]) {
		NSData *pdf = [self pdf];
		result = [pboard setData:pdf forType:NSPasteboardTypePDF];
	} else if ([@"com.adobe.encapsulated-postscript" isEqualToString:type]) {
		NSData *eps = [self eps];
		result = [pboard setData:eps forType:@"com.adobe.encapsulated-postscript"];
	} else if ([NSFilesPromisePboardType isEqualToString:type]) {
		result = [pboard setPropertyList:@[GradientFileExtension]
								 forType:NSFilesPromisePboardType];
	} else if ([(NSString*)kUTTypeFileURL isEqualToString:type]) {
		// we do not have a file already in existence, so we wish to handle this
		// type lazily to delay file creation until actually requested
		result = YES;
	} else if ([NSFileContentsPboardType isEqualToString:type]) {
		result = [pboard writeFileWrapper:[self fileWrapperRepresentation]];
	}

	return result;
}

#pragma mark -
- (NSData *)pdf
{
	// return gradient as PDF data

	NSRect fr;

	fr.origin = NSZeroPoint;
	fr.size = sGradientPasteboardImageSize;

	//GCGradientView*		gv = [[GCGradientView alloc] initWithFrame:fr];
	//[gv setGradient:self];

	//NSData* pdf = [gv dataWithPDFInsideRect:fr];

	//[gv release];

	return nil; //pdf;
}

- (NSData *)eps
{
	// return gradient as EPS data

	NSRect fr;

	fr.origin = NSZeroPoint;
	fr.size = sGradientPasteboardImageSize;

	//GCGradientView*		gv = [[GCGradientView alloc] initWithFrame:fr];
	//[gv setGradient:self];

	//NSData* eps = [gv dataWithEPSInsideRect:fr];

	//[gv release];

	return nil; //eps;
}

#pragma mark -
///*********************************************************************************************************************
///
/// method:			gradientWithContentsOfFile:
/// scope:			public class method
/// overrides:
/// description:	create a gradient object from a gradient file
///
/// parameters:		<path> the path to the file
/// result:			the gradient object, or nil if the file could not be read
///
/// notes:
///
///********************************************************************************************************************

+ (DKGradient *)gradientWithContentsOfFile:(NSString *)path
{
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
	return [dict unarchiveFromPropertyListFormat];
}

///*********************************************************************************************************************
///
/// method:			writeToFile:atomically:
/// scope:			public instance method
/// overrides:
/// description:	write the gradient object to a gradient file
///
/// parameters:		<path> the path to the file
///					<flag> YES to write via a safe save, NO to write directly
/// result:			YES if the file was written succesfully, NO otherwise
///
/// notes:
///
///********************************************************************************************************************

- (BOOL)writeToFile:(NSString *)path atomically:(BOOL)flag
{
	return [[self fileWrapperRepresentation] writeToFile:path atomically:flag updateFilenames:YES];
}

///*********************************************************************************************************************
///
/// method:			fileRepresentation
/// scope:			public instance method
/// overrides:
/// description:	file representation of the gradient
///
/// parameters:		none
/// result:			a data object containing the file representation of the gradient
///
/// notes:
///
///********************************************************************************************************************

- (NSData *)fileRepresentation
{
	return [NSPropertyListSerialization dataWithPropertyList:[self plistRepresentation]
													  format:NSPropertyListXMLFormat_v1_0
													 options:0
													   error:nil];
}

///*********************************************************************************************************************
///
/// method:			fileWrapperRepresentation
/// scope:			public instance method
/// overrides:
/// description:	file wrapper representation of the gradient
///
/// parameters:		none
/// result:			a file wrapper object containing the file representation of the gradient
///
/// notes:
///
///********************************************************************************************************************

- (NSFileWrapper *)fileWrapperRepresentation
{
	NSFileWrapper *wrap = [[NSFileWrapper alloc] initRegularFileWithContents:[self fileRepresentation]];
	wrap.preferredFilename = @"untitled gradient.gradient";

	NSDictionary *attributes = @{NSFileExtensionHidden: @YES,
								 NSFileType: NSFileTypeRegular,
								 NSFilePosixPermissions: @420UL/* <--- 0644 octal (-wrr) -> 420 decimal*/};

	wrap.fileAttributes = attributes;

	return wrap;
}

- (NSDictionary *)plistRepresentation
{
	return [NSDictionary archiveToPropertyListForRootObject:self];
}

#pragma mark -

///*********************************************************************************************************************
///
/// method:			writeFileToPasteboard:
/// scope:			public instance method
/// overrides:
/// description:	writes the gradient file representation to the pasteboard
///
/// parameters:		<pboard> the pasteboard to write to
/// result:			none
///
/// notes:
///
///********************************************************************************************************************

- (BOOL)writeFileToPasteboard:(NSPasteboard *)pboard
{
	[pboard declareTypes:[DKGradient writablePasteboardTypes] owner:self];
	[self writeType:NSFileContentsPboardType toPasteboard:pboard]; // <-- very important that this is first
	[self writeType:GPGradientPasteboardType toPasteboard:pboard];
	[self writeType:NSPasteboardTypePDF toPasteboard:pboard];
	[self writeType:NSFilesPromisePboardType toPasteboard:pboard]; // <--- may create temporary or real file if requested
	//[self writeType:(NSString*)kUTTypeFileURL toPasteboard:pboard];		// <--- may create temporary file if requested

	//	LogEvent_(kReactiveEvent, @"pboard types written = %@", [pboard types]);
	return YES;
}

#pragma mark -
#pragma mark As an NSPasteboard delegate
- (void)pasteboard:(NSPasteboard *)pboard provideDataForType:(NSString *)type
{
	if ([(NSString*)kUTTypeFileURL isEqualToString:type]) {
		//	LogEvent_(kReactiveEvent, @"creating temporary file for filenames pasteboard");

		NSFileManager *fm = [NSFileManager defaultManager];
		NSString *path = [fm writeContents:[self fileRepresentation] toUniqueTemporaryFile:@"untitled gradient.gradient"];

		if (path)
			[pboard setPropertyList:@[[NSURL fileURLWithPath:path]] forType:(NSString*)kUTTypeFileURL];
	} else if ([NSFileContentsPboardType isEqualToString:type]) {
		[pboard writeFileWrapper:[self fileWrapperRepresentation]];
	}
}

@end
