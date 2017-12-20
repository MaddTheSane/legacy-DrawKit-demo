//
//  GCSOutlineView.swift
//  DrawDemoSwift
//
//  Created by C.W. Betts on 12/14/17.
//  Copyright © 2017 DrawKit. All rights reserved.
//

import Cocoa
import DKDrawKit.DKGradient
import DKDrawKit.DKGradient.UISupport

class GCSOutlineView: NSOutlineView {
	override func highlightSelection(inClipRect clipRect: NSRect) {
		super.highlightSelection(inClipRect: clipRect)
		
		let rows = self.rows(in: clipRect)
		if rows.contains(selectedRow) {
			let sr = rect(ofRow: selectedRow)
			/*
			DKGradient* aqua = [DKGradient sourceListSelectedGradient];
			[aqua fillRect:sr];
			
			[[NSColor blackColor] set];
			NSFrameRectWithWidth( NSInsetRect(sr, -1, 0 ), 1 );
			*/
			NSColor.selectedTextBackgroundColor.set()
			NSBezierPath.fill(sr)
		}
	}
	
	override var gridColor: NSColor {
		get {
			return NSColor(calibratedRed: 0.30, green: 0.60, blue: 0.92, alpha: 0.15)
		}
		set {
			//Do nothing
		}
	}
	
	@objc(_highlightColorForCell:)
	func _highlightColor(for: NSCell?) -> Any? {
		return nil
	}
	
	override func mouseDown(with event: NSEvent) {
		let p = convert(event.locationInWindow, from: nil)

		// which column and cell has been hit?

		let column = self.column(at: p)
		let row = self.row(at: p)
		let theColumn = tableColumns[column]
		let dataCell = theColumn.dataCell(forRow: row)
		// if the checkbox column, handle click in checkbox without selecting the row
		if let buttonCell = dataCell as? NSButtonCell {
			let cellFrame = frameOfCell(atColumn: column, row: row)
			
			// track the button - this keeps control until the mouse goes up. If the mouse was in on release,
			// it will have changed the button's state and returns YES.

			if buttonCell.trackMouse(with: event, in: cellFrame, of: self, untilMouseUp: true) {
				self.dataSource?.outlineView?(self, setObjectValue: buttonCell.objectValue, for: theColumn, byItem: item(atRow: row))
				updateCell(buttonCell)
			}
		} else {
			// for all other columns, work as normal
			super.mouseDown(with: event)
		}
	}
}
