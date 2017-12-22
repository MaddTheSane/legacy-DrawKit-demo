//
//  LogEventSwift.h
//  DrawDemo
//
//  Created by C.W. Betts on 12/14/17.
//  Copyright © 2017 DrawKit. All rights reserved.
//

#ifndef LogEventSwift_h
#define LogEventSwift_h

#import <Foundation/NSString.h>
#import <DKDrawKit/LogEvent.h>

NS_ASSUME_NONNULL_BEGIN
BOOL LogEventSwift(LCEventType eventType, NSString* format) NS_SWIFT_NAME(LogEvent(_:_:));
NS_ASSUME_NONNULL_END


#endif /* LogEventSwift_h */
