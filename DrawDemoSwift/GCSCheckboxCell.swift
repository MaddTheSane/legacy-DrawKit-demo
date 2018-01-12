//
//  GCSCheckboxCell.swift
//  DrawDemoSwift
//
//  Created by C.W. Betts on 12/23/17.
//  Copyright © 2017 DrawKit. All rights reserved.
//

import Cocoa

final class GCSCheckboxCell: NSButtonCell {
	override func trackMouse(with event: NSEvent, in cellFrame: NSRect, of controlView: NSView, untilMouseUp flag: Bool) -> Bool {
		isHighlighted = true
		controlView.setNeedsDisplay(cellFrame)
		
		// keep control until mouse up
		
		var loop = true;
		let mask: NSEvent.EventTypeMask = [.leftMouseUp, .leftMouseDragged]

		var wasIn = true
		var isIn = false
		
		while loop {
			guard let newEvt = controlView.window?.nextEvent(matching: mask) else {
				continue
			}
			
			switch newEvt.type {
			case .leftMouseDragged:
				let p = controlView.convert(newEvt.locationInWindow, from: nil)
				isIn = NSPointInRect(p, cellFrame);

				if (isIn != wasIn) {
					self.isHighlighted = isIn;
					controlView.setNeedsDisplay(cellFrame)
					wasIn = isIn;
				}

			case .leftMouseUp:
				loop = false
				
			default:
				break
			}
		}
		
		isHighlighted = false
		
		// if the mouse was in the cell when it was released, flip the checkbox state
		if wasIn {
			self.intValue = self.intValue == 0 ? 1 : 0
		}
		
		controlView.setNeedsDisplay(cellFrame)

		LogEvent(.reactiveEvent, "tracking in checkbox ended");

		return wasIn
	}
	
	@objc func charValue() -> Int8 {
		return Int8(self.intValue & 0x7f)
	}
}
