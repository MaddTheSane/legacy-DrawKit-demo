//
//  LogEventSwift.m
//  DrawDemoSwift
//
//  Created by C.W. Betts on 12/14/17.
//  Copyright © 2017 DrawKit. All rights reserved.
//

#import "LogEventSwift.h"

BOOL LogEventSwift(LCEventType eventType, NSString* format)
{
#if defined(qUseLogEvent) && qUseLogEvent
	return LogEvent_(eventType, @"%@", format);
#else
#pragma unused(eventType, format)
	return NO;
#endif
}
