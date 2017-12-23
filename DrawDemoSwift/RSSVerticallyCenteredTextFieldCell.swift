//
//  RSSVerticallyCenteredTextFieldCell.swift
//  DrawDemoSwift
//
//  Created by C.W. Betts on 12/23/17.
//  Copyright © 2017 DrawKit. All rights reserved.
//

import Cocoa

class RSSVerticallyCenteredTextFieldCell: NSTextFieldCell {
	private var isEditingOrSelecting = false
	//	BOOL mIsEditingOrSelecting;

	override func drawingRect(forBounds rect: NSRect) -> NSRect {
		// Get the parent's idea of where we should draw
		var newRect = super.drawingRect(forBounds: rect)
		
		// When the text field is being
		// edited or selected, we have to turn off the magic because it screws up
		// the configuration of the field editor.  We sneak around this by
		// intercepting selectWithFrame and editWithFrame and sneaking a
		// reduced, centered rect in at the last minute.
		if !isEditingOrSelecting {
			let textSize = cellSize(forBounds: rect)
			
			// Center that in the proposed rect
			let heightDelta = newRect.size.height - textSize.height;
			if heightDelta > 0 {
				newRect.size.height -= heightDelta;
				newRect.origin.y += (heightDelta / 2);
			}
		}
		
		return newRect
	}
	
	override func select(withFrame rect: NSRect, in controlView: NSView, editor textObj: NSText, delegate: Any?, start selStart: Int, length selLength: Int) {
		let aRect = drawingRect(forBounds: rect)
		isEditingOrSelecting = true
		super.select(withFrame: aRect, in: controlView, editor: textObj, delegate: delegate, start: selStart, length: selLength)
		isEditingOrSelecting = false
	}
	
	override func edit(withFrame rect: NSRect, in controlView: NSView, editor textObj: NSText, delegate: Any?, event: NSEvent?) {
		let aRect = drawingRect(forBounds: rect)
		isEditingOrSelecting = true
		super.edit(withFrame: aRect, in: controlView, editor: textObj, delegate: delegate, event: event)
		isEditingOrSelecting = false
	}
}
