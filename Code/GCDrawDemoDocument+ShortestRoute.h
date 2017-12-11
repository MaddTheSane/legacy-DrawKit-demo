//
//  GCDrawDemoDocument+ShortestRoute.h
//  GCDrawKit
//
//  Created by graham on 30/07/2008.
//  Copyright 2008 Apptree.net. All rights reserved.
//

#import "GCDrawDemoDocument.h"
#import <DKDrawKit/DKRouteFinder.h>


@class DKDrawablePath;



@interface GCDrawDemoDocument (ShortestRoute) <DKRouteFinderProgressDelegate>


- (IBAction)		computeShortestRoute:(id) sender;

- (DKDrawablePath*)	pathWithPoints:(NSArray*) points;
- (NSArray*)		objectsInArray:(NSArray*) objects sortedByXOrY:(BOOL) xory;

@end




