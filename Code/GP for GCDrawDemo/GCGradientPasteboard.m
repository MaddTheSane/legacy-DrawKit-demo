//
//  GCGradientPasteboard.m
//  GradientTest
//
//  Created by Jason Jobe on 4/5/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "GCGradientPasteboard.h"

#import "NSFolderManagerAdditions.h"
#import "WTPlistKeyValueCoding.h"
#import "GCGradientView.h"
#import <DKDrawKit/LogEvent.h>

#pragma mark Contants (Non-localized)
// Pasteboard and file types
NSString *const GPGradientPasteboardType = @"GPGradientPasteboardType";
NSString *const GPGradientLibPasteboardType = @"GPGradientLibPasteboardType";
NSString *const GradientFileExtension = @"gradient";
NSString *const GPGradientFileUTI = @"net.apptree.gcdrawdemo.gradients";

NSString * const GCGradientInfoKey = @"info";
NSString * const GCGradientsKey = @"gradients";

#pragma mark Static Vars
static NSSize sGradientPasteboardImageSize = {256.0, 256.0};

@implementation DKGradient (GCGradientPasteboard)
#pragma mark As a DKGradient
+ (NSArray *)readablePasteboardTypes
{
	static NSArray *types = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		types = @[GPGradientFileUTI,
				  GPGradientPasteboardType,
				  NSFileContentsPboardType,
				  (NSString*)kUTTypeFileURL];
	});

	return types;
}

+ (NSArray *)writablePasteboardTypes
{
	static NSArray *types = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		types = @[ GPGradientFileUTI, GPGradientPasteboardType ];
	});

	return types;
}

#pragma mark -

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

+ (DKGradient *)gradientWithPasteboard:(NSPasteboard *)pboard
{
	NSString *bestType = [pboard availableTypeFromArray:[self readablePasteboardTypes]];

	//	LogEvent_(kReactiveEvent, @"gradient from pb, best type = %@", bestType );
	//	LogEvent_(kReactiveEvent, @"pb types = %@", [pboard types]);

	if ([GPGradientPasteboardType isEqualToString:bestType]) {
		NSData *data = [pboard dataForType:GPGradientPasteboardType];
		return [NSKeyedUnarchiver unarchiveObjectWithData:data];
	} else if ([GPGradientFileUTI isEqualToString:bestType]) {
		NSData *data = [pboard dataForType:GPGradientFileUTI];
		NSDictionary *plist = [NSPropertyListSerialization propertyListWithData:data options:0 format:NULL error:NULL];
		id val = [plist unarchiveFromPropertyListFormat];
		if ([val isKindOfClass:[DKGradient class]]) {
			return val;
		}
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
			if ([val isKindOfClass:[DKGradient class]]) {
				return val;
			}
			return [NSKeyedUnarchiver unarchiveObjectWithFile:[filePath path]];
		}
	}
	return nil;
}

+ (DKGradient *)gradientWithPlist:(NSDictionary *)plist
{
	return [plist unarchiveFromPropertyListFormat];
}

#pragma mark -

- (BOOL)writeToPasteboard:(NSPasteboard *)pboard
{
	[pboard declareTypes:@[GPGradientPasteboardType, GPGradientFileUTI] owner:self];
	[self writeType:GPGradientFileUTI toPasteboard:pboard];
	[self writeType:GPGradientPasteboardType toPasteboard:pboard];
	[self writeType:NSPasteboardTypePDF toPasteboard:pboard];
	//[self writeType:@"com.adobe.encapsulated-postscript" toPasteboard:pboard];
	[self writeType:NSPasteboardTypeTIFF toPasteboard:pboard];
	return YES;
}

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
	} else if ([GPGradientFileUTI isEqualToString:type]) {
		NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
		result = [pboard setData:data forType:GPGradientFileUTI];
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
	NSRect fr;

	fr.origin = NSZeroPoint;
	fr.size = sGradientPasteboardImageSize;

	GCGradientView* gv = [[GCGradientView alloc] initWithFrame:fr];
	[gv setGradient:self];

	NSData* pdf = [gv dataWithPDFInsideRect:fr];

	return pdf;
}

- (NSData *)eps
{
	NSRect fr;

	fr.origin = NSZeroPoint;
	fr.size = sGradientPasteboardImageSize;

	GCGradientView* gv = [[GCGradientView alloc] initWithFrame:fr];
	[gv setGradient:self];

	NSData* eps = [gv dataWithEPSInsideRect:fr];

	return eps;
}

#pragma mark -

+ (DKGradient *)gradientWithContentsOfFile:(NSString *)path
{
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
	id tmp = [dict unarchiveFromPropertyListFormat];
	
	if ([tmp isKindOfClass:[DKGradient class]]) {
		return tmp;
	}
	return [NSKeyedUnarchiver unarchiveObjectWithFile:path];
}

- (BOOL)writeToFile:(NSString *)path atomically:(BOOL)flag
{
	return [self writeToURL:[NSURL fileURLWithPath:path] options:NSFileWrapperWritingWithNameUpdating | (flag ? NSFileWrapperWritingAtomic : 0) error:NULL];
}

- (BOOL)writeToURL:(NSURL *)path options:(NSFileWrapperWritingOptions)writeOptionsMask error:(NSError * _Nullable __autoreleasing * _Nullable)errorPtr
{
	return [[self fileWrapperRepresentation] writeToURL:path options:writeOptionsMask originalContentsURL:nil error:errorPtr];
}

- (NSData *)fileRepresentation
{
	return [NSPropertyListSerialization dataWithPropertyList:[self plistRepresentation]
													  format:NSPropertyListXMLFormat_v1_0
													 options:0
													   error:nil];
}

- (NSFileWrapper *)fileWrapperRepresentation
{
	NSFileWrapper *wrap = [[NSFileWrapper alloc] initRegularFileWithContents:[self fileRepresentation]];
	wrap.preferredFilename = [@"untitled gradient" stringByAppendingPathExtension:GradientFileExtension];

	NSDictionary *attributes = @{NSFileExtensionHidden: @YES,
								 NSFileType: NSFileTypeRegular,
								 NSFilePosixPermissions: @420/* <--- 0644 octal (-wrr) -> 420 decimal*/};

	wrap.fileAttributes = attributes;

	return wrap;
}

- (NSDictionary *)plistRepresentation
{
	return [NSDictionary archiveToPropertyListForRootObject:self];
}

#pragma mark -

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
		NSString *path = [fm writeContents:[self fileRepresentation] toUniqueTemporaryFile:[@"untitled gradient" stringByAppendingPathExtension:GradientFileExtension]];

		if (path)
			[pboard setPropertyList:@[[NSURL fileURLWithPath:path]] forType:(NSString*)kUTTypeFileURL];
	} else if ([NSFileContentsPboardType isEqualToString:type]) {
		[pboard writeFileWrapper:[self fileWrapperRepresentation]];
	}
}

@end
