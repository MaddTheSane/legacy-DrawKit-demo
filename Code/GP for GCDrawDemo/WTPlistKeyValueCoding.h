//
//  WTPlistKeyValueCoding.h
//  GradientTest
//
//  Created by Jason Jobe on 4/3/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (WTPlistKeyValueCoding)

@property (class, readonly) BOOL supportsSimpleDictionaryKeyValueCoding;
@property (readonly) BOOL supportsSimpleDictionaryKeyValueCoding;

@end

@interface NSDictionary (WTPlistKeyValueCoding)

+ (nullable id)archiveToPropertyListForRootObject:(id)rob;
- (nullable id)unarchiveFromPropertyListFormat;
- (nullable id)archiveFromPropertyListFormat;

- (BOOL)decodeBoolForKey:(NSString *)key;
- (float)decodeFloatForKey:(NSString *)key;
- (double)decodeDoubleForKey:(NSString *)key;
- (int)decodeIntForKey:(NSString *)key;
- (NSInteger)decodeIntegerForKey:(NSString *)key;
- (nullable id)decodeObjectForKey:(NSString *)key;

@end

@interface NSMutableDictionary (WTPlistKeyValueCoding)

- (void)encodeBool:(BOOL)intv forKey:(NSString *)key;
- (void)encodeFloat:(float)intv forKey:(NSString *)key;
- (void)encodeDouble:(double)value forKey:(NSString *)key;
- (void)encodeInt:(int)intv forKey:(NSString *)key;
- (void)encodeInteger:(NSInteger)value forKey:(NSString *)key;
- (void)encodeObject:(id)intv forKey:(NSString *)key;
- (void)encodeConditionalObject:(nullable id)object forKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
