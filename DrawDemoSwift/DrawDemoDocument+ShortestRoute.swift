//
//  DrawDemoDocument+ShortestRoute.swift
//  DrawDemoSwift
//
//  Created by C.W. Betts on 12/17/17.
//  Copyright © 2017 DrawKit. All rights reserved.
//

import Cocoa
import DKDrawKit.DKRouteFinder
import DKDrawKit.DKDrawablePath
import DKDrawKit.DKDrawableObject
import DrawKitSwift

private var routePath: DKDrawablePath?
private var origRoutePath: DKDrawablePath?

extension DrawDemoDocument: DKRouteFinderProgressDelegate {
	/// locate the target layer - active layer of class
	@IBAction func computeShortestRoute(_ sender: Any?) {
		guard let layer = drawing.activeLayer(of: DKObjectOwnerLayer.self) else {
			return
		}
		
		layer.undoManager.disableUndoRegistration()
		
		if let routePath = routePath {
			layer.removeObject(routePath)
		}
		
		if let routePath = origRoutePath {
			layer.removeObject(routePath)
		}
		
		let objects = layer.objects
		
		DKRouteFinder.algorithm = .useNearestNeighbour
		var rf = DKRouteFinder(objects: objects, withValueForKey: "location")!
		
		rf.progressDelegate = self
		rf.sortedArray(from: objects)
		
		origRoutePath = routePath?.copy() as? DKDrawablePath
		if let origRoutePath = origRoutePath {
			layer.addObject(origRoutePath)
		}
		
		let p1 = rf.pathLength
		
		DKRouteFinder.algorithm = .useSimulatedAnnealing
		rf = DKRouteFinder(objects: objects, withValueForKey: "location")!
		
		rf.progressDelegate = self
		rf.sortedArray(from: objects)
		
		let p2 = rf.pathLength
		
		NSLog("path lengths: NN = \(p1); SA = \(p2); diff = \(p1 - p2)");
		
		layer.undoManager.enableUndoRegistration()
	}
	
	/// given an array of `NSPoint` values, construct a path object having those points.
	@objc(pathWithPoints:)
	func path(with points: [NSValue]) -> DKDrawablePath {
		return path(with: points.map({$0.pointValue}))
	}
	
	/// given an array of `NSPoint`s, construct a path object having those points.
	func path(with points: [NSPoint]) -> DKDrawablePath {
		var points2 = points
		let path = NSBezierPath()
		
		path.move(to: points2.removeFirst())
		
		for val in points2 {
			path.line(to: val)
		}
		
		return DKDrawablePath(bezierPath: path)
	}

	/// given an array of objects, sorts them by location `x` or `y`.
	@objc(objectsInArray:sortedByXOrY:)
	func objects(in array: [DKDrawableObject], sortedByX xory: Bool) -> [DKDrawableObject] {
		return array.sorted(by: { (a, b) -> Bool in
			let pa = a.location
			let pb = b.location
			
			let ppa: CGFloat
			let ppb: CGFloat
			
			if xory {
				ppa = pa.x
				ppb = pb.x
			} else {
				ppa = pa.y
				ppb = pb.y
			}

			return ppa > ppb
		})
	}
	
	func routeFinder(_ rf: DKRouteFinder, progressHasReached value: CGFloat) {
		guard value >= 1 else {
			return
		}
		
		autoreleasepool() {
			let points = rf.shortestRoute()
			let path = self.path(with: points)
			
			//NSLog(@"making path for value: %.4f (length %f)", value, [rf pathLength] );

			let lineColour: NSColor
			
			if rf.algorithm == .useSimulatedAnnealing {
				lineColour = NSColor.red
			} else {
				lineColour = NSColor.magenta
			}
			
			let routeStyle = DKStyle(fillColour: nil, strokeColour: lineColour, strokeWidth: 3)
			path.style = routeStyle
			
			let layer = drawing.activeLayer(of: DKObjectOwnerLayer.self)
			
			if let routePath = routePath {
				layer?.removeObject(routePath)
			}
			
			layer?.addObject(path)
			
			NSApp.mainWindow?.displayIfNeeded()
		}
	}
}
