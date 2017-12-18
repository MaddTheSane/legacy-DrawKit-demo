//
//  DrawDemoDocument+TimelineLayout.swift
//  DrawDemoSwift
//
//  Created by C.W. Betts on 12/17/17.
//  Copyright © 2017 DrawKit. All rights reserved.
//

import Foundation
import DKDrawKit.DKObjectDrawingLayer
import DKDrawKit.DKDrawablePath
import DKDrawKit.DKStyle
import DKDrawKit.DKObjectDrawingLayer
import DKDrawKit.DKDrawableObject_Metadata
import DKDrawKit.DKGridLayer
import DKDrawKit.DKDrawing
import DKDrawKit.DKDrawablePath
import DKDrawKit.DKStyle
import DKDrawKit.DKTextShape
import DKDrawKit.LogEvent

private var lowestEdge: CGFloat = -10000

extension DrawDemoDocument {
	
	/// this function is an experiment to illustrate the kinds of automatic functionality you can easily create using the
	/// drawkit. This makes the following assumptions:
	///
	/// 1. that there exists in the drawing (text) objects occupying a rectangular area containing metadata "year" and an integer value.
	/// 2. that the drawing scale/grid is set up such that a linear timeline of integral years is available horizontally
	///
	/// what it does is this: it first finds all such objects having metadata "year" key. Then it sorts them into chronological
	/// order by year. Then it assigns a position to them in the drawing where the horizontal position is set to the year (plus a
	/// small "leader" offet) and the vertical position is calculated to avoid colliding with any labels already laid down and
	/// in such a vertical order that the leader lines do not cross over.
	@objc(performTimelineLayoutWithLayer:showAsYouGo:)
	func performTimelineLayout(with layer: DKObjectDrawingLayer, showAsYouGo showIt: Bool) {
		// first locate the candidate objects:

		var tlObjects = [DKDrawableObject]()
		for obj in layer.availableObjects {
			// does this object have a metadata item "year"?

			if obj.hasMetadata(forKey: "year") {
				tlObjects.append(obj)
				
				// make a note of the lowest edge found among these objects - it will be used as the starting point for
				// applying the vertical location.

				let loc = obj.location
				lowestEdge = min(lowestEdge, loc.y)
			}
		}
		
		//	LogEvent_(kReactiveEvent, @"found %d eligible objects. Bottom edge = %f", [tlObjects count], lowestEdge);

		if tlObjects.count < 1 {
			return // nothing to do
		}
		
		// sort the objects into chronological order:
		tlObjects.sort { (a, b) -> Bool in
			let na = a.metadataObject(forKey: "year") as AnyObject
			let nb = b.metadataObject(forKey: "year") as AnyObject
			
			return na.compare(nb) == .orderedAscending
		}
		
		// next, remove all the existing leader lines (we recreate them as we lay out the labels). Note - this will not work when
		// reloading the drawing from a file, as the style object is not literally the same. TO DO: fix this.
		
		if let leaderLines = layer.objectsWith(self.leaderLineStyle), leaderLines.count > 0 {
			layer.removeObjects(in: leaderLines)
		}

		// we need the grid to locate objects in time and space
		
		let grid = drawing.gridLayer!

		// indx tracks the location of the next object ahead of the one we are laying out
		var indx = tlObjects.count
		
		let gridVIncrement = grid.divisionDistance;

		for obj in tlObjects.reversed() {
			var objRect = NSRect()
			// place the object's horizontal position based on the "year" value. To make this easier we also offset the
			// "loc" of the object relative to its top, left corner:

			obj.offset = NSSize(width: -0.5, height: -0.5)
			let year: Int = (obj.metadataObject(forKey: "year") as AnyObject).intValue
		
			// use the grid to figure the real position:
			
			var position = NSPoint(x: year, y: 0)
			position = grid.point(forGridLocation: position)

			// this is the candidate location (x will not change), but we shift it upwards vertically to avoid collision with any other
			// already laid objects. To allow a neat layout, we test in grid increments
			
			//[(GCTextShape*)obj sizeVerticallyToFitText];
			objRect.size = obj.size;

			// if the size is less than 4 grid units high, make it at least that high
			
			if objRect.size.height < (gridVIncrement * 4) {
				objRect.size.height = gridVIncrement * 4
				obj.size = objRect.size
			} else if objRect.size.height > (gridVIncrement * 4) {
				// make sure we are either exactly at 4 grid spaces, or 6 for 2-line labels
				
				let rem = fmod(objRect.size.height, gridVIncrement);
				
				objRect.size.height -= rem;
				
				if objRect.size.height > (gridVIncrement * 4) {
					objRect.size.height = gridVIncrement * 6
				}
				obj.size = objRect.size
			}
			
			position.y = lowestEdge - objRect.size.height;
			
			// position one grid square to the right:
			
			position.x += gridVIncrement;
			
			// allow a grid square's space around the label:
			
			objRect.size.height += gridVIncrement;
			objRect.size.width += gridVIncrement;
			objRect.origin = position;
			
			// reposition to avoid collision:

			var j = indx;
			
			while (j < tlObjects.count) {
				let colObj = tlObjects[j];
				
				var colObjRect = NSRect(origin: colObj.location, size: colObj.size)
				colObjRect.origin = colObj.location;
				colObjRect.size = colObj.size;
				
				// if this object is beyond the x range of our object, we can jump out now since there
				// is no more beyond j worth testing against
				
				if (colObjRect.origin.x > objRect.maxX) {
					break;
				}
				
				if (NSIntersectsRect(objRect, colObjRect)) {
					// they collide, so try incrementing the vertical position and starting again
					
					objRect.origin.y -= gridVIncrement;
					j = indx;
				} else {
					// they don't collide, so try the next in sequence.
					
					j += 1
				}
			}
			// the object is now positioned so that it doesn't collide, so place it here
			
			position.y = objRect.origin.y;
			obj.location = position;
			(obj as? DKTextShape)?.verticalAlignment = .textShapeVerticalAlignmentCentre
			
			//	LogEvent_(kReactiveEvent, @"laid object %@ at position {%.2f,%.2f}", obj, position.x, position.y );
			
			// now create a leader line which links this label with the timeline vertical datum
			var lp1 = NSPoint()
			var lp2 = NSPoint()
			lp1.x = position.x - gridVIncrement;
			lp1.y = lowestEdge + (gridVIncrement * 3);
			lp2.x = objRect.origin.x;
			objRect.size.height -= gridVIncrement;
			lp2.y = NSMidY(objRect);
			
			let leader = leaderLine(from: lp1, to: lp2)
			layer.addObject(toSelection: leader)
			layer.moveObject(toBottom: leader)
			
			if showIt {
				drawing.scroll(to: objRect)
				windowForSheet?.displayIfNeeded()
			}
			
			// one more to check against next time
			
			indx += 1

		}
	}
	
	/// Return an L-shaped path from `p1` to `p2`. The path extends vertically, then horizontally.
	func leaderLine(from p1: NSPoint, to p2: NSPoint) -> DKDrawablePath {
		let leader = DKDrawablePath(bezierPath: leaderLinePath(from: p1, to: p2))!
		
		leader.style = leaderLineStyle
		return leader
	}
	
	/// Return an L-shaped path from `p1` to `p2`. The path extends vertically, then horizontally.
	func leaderLinePath(from p1: NSPoint, to p2: NSPoint) -> NSBezierPath {
		let path = NSBezierPath()
		let pp = NSPoint(x: p1.x, y: p2.y)
		
		path.move(to: p1)
		path.line(to: pp)
		path.line(to: p2)
		
		return path
	}
	
	var leaderLineStyle: DKStyle {
		return DrawDemoDocument.leaderLineStyle
	}
	
	static var leaderLineStyle: DKStyle = {
		// set the style to something appropriate:
		let style = DKStyle(fillColour: nil, strokeColour: NSColor.gray, strokeWidth: 0.5)!
		style.isStyleSharable = true
		
		return style
	}()
	
	/// locate the active layer and do the timeline layout on it
	@IBAction func timelineAction(_ sender: Any?) {
		if let odl = drawing.activeLayer(of: DKObjectDrawingLayer.self) {
			performTimelineLayout(with: odl, showAsYouGo: true)
		}
	}
}
