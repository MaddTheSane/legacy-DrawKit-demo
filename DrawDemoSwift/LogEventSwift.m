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
	return LogEvent_(eventType, @"%@", format);
}
