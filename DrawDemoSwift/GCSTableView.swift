//
//  GCSTableView.swift
//  DrawDemoSwift
//
//  Created by C.W. Betts on 12/30/17.
//  Copyright © 2017 DrawKit. All rights reserved.
//

import Cocoa
import DKDrawKit.DKGradient.UISupport
import DKDrawKit.NSColor_DKAdditions

class GCSTableView: NSTableView {
	// MARK: As an NSTableView
	
	override func textDidEndEditing(_ notification: Notification) {
		// this overrides the standard behaviour so that ending text editing does not select a new cell for editing
		// Instead the delegate is called as normal but then the table is made 1stR.
		let thestring = ((notification.object as AnyObject?)?.string)!

		//NSLog(@"column = %d, string = %@", [self editedColumn], theString);
		
		let theColumn = tableColumns[editedColumn]
		dataSource?.tableView!(self, setObjectValue: thestring, for: theColumn, row: selectedRow)
		abortEditing()
		window?.makeFirstResponder(self)
	}
	
	override func highlightSelection(inClipRect clipRect: NSRect) {
		super.highlightSelection(inClipRect: clipRect)
		
		let rows = self.rows(in: clipRect)
		
		if rows.contains(selectedRow) {
			let sr = rect(ofRow: selectedRow)
			
			let aqua = DKGradient.sourceListSelected()!
			aqua.angleInDegrees = -90
			aqua.fill(sr)
			NSColor.black.set()
			sr.insetBy(dx: -1, dy: 0).frame(withWidth: 1)
		}
	}
	
	@objc(_highlightColorForCell:)
	func _highlightColor(for cell: NSCell?) -> Any? {
		return nil
	}
	
	override var gridColor: NSColor {
		get {
			return NSColor(calibratedRed: 0.30, green: 0.60, blue: 0.92, alpha: 0.15)
		}
		set {
			// Do nothing
		}
	}
	
	// MARK: - As an NSResponder
	override func mouseDown(with event: NSEvent) {
		let p = convert(event.locationInWindow, from: nil)
		
		// which column and cell has been hit?

		let column = self.column(at: p)
		let row = self.row(at: p)
		let theColumn = tableColumns[column]
		let dataCell = theColumn.dataCell(forRow: row)
		
		// if the checkbox column, handle click in checkbox without selecting the row

		let goodCell: NSCell? = {
			if let dcell = dataCell as? NSButtonCell {
				return dcell
			} else if let dcell = dataCell as? GCSColourCell {
				return dcell
			}
			return nil
		}()
		
		if let datCell = goodCell {
			// no way to get the button type for further testing, so we'll plough on blindly

			let cellFrame = frameOfCell(atColumn: column, row: row)
			
			// track the button - this keeps control until the mouse goes up. If the mouse was in on release,
			// it will have changed the button's state and returns YES.
			
			if datCell.trackMouse(with: event, in: cellFrame, of: self, untilMouseUp: true) {
				// call the data source to handle the checkbox state change as normal
				dataSource?.tableView?(self, setObjectValue: datCell.objectValue, for: theColumn, row: row)
				self.updateCell(datCell)
			}
		} else {
			super.mouseDown(with: event)
		}
	}
}

/// declare a custom NSCell class for drawing a colour in a table's column
class GCSColourCell : NSCell {
	// MARK: As a GCColourCell
	
	@objc @NSCopying var colorValue: NSColor? {
		didSet {
			(controlView as? NSControl)?.updateCellInside(self)
		}
	}
	
	var frame: NSRect = .zero
	
	override var state: NSControl.StateValue {
		didSet {
			isHighlighted = state == .on
		}
	}
	
	/// hack - call the table's dataSource to temporarily set a colour that will be returned to the table when we update here - this
	/// allows the cell to update live even though the cell is shared with all the other cells in the column.
	@IBAction func colourChangeFromPicker(_ sender: NSColorWell?) {
		if let cview = controlView as? NSTableView {
			let ds = (cview.dataSource as? NSTableViewDataSource & GCSColourCellHack)
			let rows = cview.rows(in: frame)
			
			ds?.setTemporaryColour(sender!.color, for: cview, row: rows.location)
			
			// force a reload of the row which will grab the temp colour and update the cell

			controlView?.setNeedsDisplay(frame)
		}
	}
	
	// MARK: - As an NSCell
	
	override func drawInterior(withFrame cellFrame: NSRect, in controlView: NSView) {
		if let colorValue = self.colorValue {
			if isHighlighted {
				NSColor.darkGray.set()
			} else {
				NSColor.white.set()
			}
			var r = cellFrame.insetBy(dx: 6, dy: 5)
			r.fill()
			
			r = cellFrame.insetBy(dx: 8, dy: 7)
			
			colorValue.set()
			r.fill()
			
			r = cellFrame.insetBy(dx: 6, dy: 5)
			NSColor.darkGray.set()
			r.frame(withWidth: 1)
			
			// draw the menu triangle image

			let img = #imageLiteral(resourceName: "menu_triangle")
			let mp = NSPoint(x: cellFrame.maxX - 18, y: cellFrame.maxY - 13)
			img.draw(at: mp, from: .zero, operation: .sourceAtop, fraction: 1)
		}
	}

	override var objectValue: Any? {
		get {
			return colorValue
		}
		set {
			if let obj = newValue as? NSColor {
				colorValue = obj
			} else {
				colorValue = nil
			}
		}
	}
	
	override func trackMouse(with event: NSEvent, in cellFrame: NSRect, of controlView: NSView, untilMouseUp flag: Bool) -> Bool {
		self.controlView = controlView
		frame = cellFrame
		
		state = .on
		controlView.setNeedsDisplay(cellFrame)
		
		// pop up the colour picker
		
		var loc = NSPoint.zero
		
		loc.x = cellFrame.minX + 6
		loc.y = cellFrame.maxY - 5
		
		loc = controlView.convert(loc, to: nil)
		
		let sr = NSRect(x: 0, y: 0, width: 161, height: 161)
		
		let picker = GCSColourPickerView(frame: sr)
		let popup = GCSWindowMenu(contentView: picker)
		
		picker.mode = .swatches
		picker.target = self
		picker.action = #selector(GCSColourCell.colourChangeFromPicker(_:))
		picker.colorForUndefinedSelection = colorValue!
		picker.showsInfo = false
		
		GCSWindowMenu.popUpWindowMenu(popup, at: loc, with: event, for: controlView)
		
		// keeps control until mouse up
		state = .off
		if let acv = controlView as? NSTableView,
			let ds = (acv.dataSource as? NSTableViewDataSource & GCSColourCellHack) {
			ds.setTemporaryColour(nil, for: acv, row: -1)
		}
		controlView.setNeedsDisplay(cellFrame)
		
		return true
	}
}
