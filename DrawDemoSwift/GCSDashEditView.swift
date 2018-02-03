//
//  GCSDashEditView.swift
//  DrawDemoSwift
//
//  Created by C.W. Betts on 2/1/18.
//  Copyright © 2018 DrawKit. All rights reserved.
//

import Cocoa
import DKDrawKit.DKStrokeDash
import DKDrawKit.LogEvent
import DrawKitSwift

private var kDKStandardHandleRectSize: NSSize {
	return NSSize(width: 8, height: 8)
}

private var kDKDashEditInset: CGFloat {
	return 8
}

class GCSDashEditView : NSView {
	private var handles = [NSRect]()
	private let path: NSBezierPath = {
		let path2 = NSBezierPath()
		path2.lineWidth = 5
		return path2
	}()
	private var selected = -1
	private var phaseHandle = NSRect()
	
	var dash: DKStrokeDash? {
		didSet {
			needsDisplay = true
		}
	}
	
	
	var lineWidth: CGFloat {
		get {
			return path.lineWidth
		}
		set {
			path.lineWidth = newValue
			needsDisplay = true
		}
	}
	
	var lineCapStyle: NSBezierPath.LineCapStyle {
		get {
			return path.lineCapStyle
		}
		set {
			path.lineCapStyle = newValue
			needsDisplay = true
		}
	}
	
	var lineJoinStyle: NSBezierPath.LineJoinStyle {
		get {
			return path.lineJoinStyle
		}
		set {
			path.lineJoinStyle = newValue
			needsDisplay = true
		}
	}
	
	var lineColour: NSColor = NSColor.gray {
		didSet {
			needsDisplay = true
		}
	}
	
	
	weak var delegate: GCSDashEditViewDelegate?
	
	
	/// calculates where the handle rects are given the current dash
	func calcHandles() {
		var d = [CGFloat](repeating: 1, count: 8)
		var c = 0

		let scale = (dash?.scalesToLineWidth ?? false) ? path.lineWidth : 1.0;

		var hr = NSRect(origin: .zero, size: kDKStandardHandleRectSize)
		let br = bounds
		handles.removeAll(keepingCapacity: true)
		dash?.getPattern(&d, count: &c)
		
		let phase = (dash?.phase ?? 1) * scale
		
		hr.origin.x = kDKDashEditInset - (hr.size.width * 0.5) + phase
		
		for (i, di) in d[0..<c].enumerated() {
			hr.origin.x += di * scale
			hr.origin.y = 12 + (br.minY + br.maxY) / 4

			// if this collides with the previous rect, offset it downwards
			if i > 0 {
				var kr = hr
				let pr = handles[i - 1]
				kr.size.height += 100
				
				if hr.intersects(pr) {
					hr.origin.y = pr.maxY + 1
				}
			}
			
			handles.append(hr)
		}
		// add a handle for the phase
		
		hr.origin.y = max(2, scale) + ((br.minY + br.maxY) / 4.0)
		phaseHandle = NSMakeRect(kDKDashEditInset + phase, hr.origin.y, 5, 10)
	}
	
	
	func mouse(inHandle mp: NSPoint) -> Int {
		for (i, c) in handles.enumerated() {
			if c.contains(mp) {
				return i
			}
		}
		
		if phaseHandle.contains(mp) {
			return 99; // phase "part code"
		}
		
		return -1
	}
	
	func drawHandles() {
		let temp = NSBezierPath()
		let br = bounds
		var a = NSPoint()
		
		// draw the selected one highlighted
		if selected != -1, selected != 99 {
			temp.appendOval(in: handles[selected])
			NSColor.green.set()
			temp.fill()
			temp.removeAllPoints()
		}
		
		a.y = 3 + (br.minY + br.maxY) / 4
		
		for hr in handles {
			a.x = hr.origin.x + (hr.size.width * 0.5)
			let b = NSPoint(x: a.x, y: hr.origin.y)
			
			temp.move(to: a)
			temp.line(to: b)
			temp.appendOval(in: hr)
		}

		NSColor.darkGray.set()
		temp.stroke()
	}
	
	
	/// sets the dash element indexed by mSelected to the right size for the given mouse point
	func calcDash(for mp: NSPoint) {
		let scale = (dash?.scalesToLineWidth ?? false) ? path.lineWidth : 1.0;
		var phase = (dash?.phase ?? 0) * scale;
		var fixedAmount = kDKDashEditInset
		
		if selected == 99 {
			// dragging the phase

			phase = max(0, (mp.x - fixedAmount) / scale)
			dash?.phase = phase
		} else {
			var d = dash?.pattern ?? [CGFloat](repeating: 1, count: 8)
			fixedAmount += phase;
			// sanity check the value of selected:
			guard selected >= 0 && selected < d.count else {
				return
			}
			
			// compute the fixed amount to subtract from mp.x

			for di in d[0..<selected] {
				fixedAmount += (di * scale);

			}
			d[selected] = (mp.x - fixedAmount) / scale;

			if d[selected] < 0 {
				d[selected] = 0
			}
			
			dash?.pattern = d
		}
		
		// inform delegate
		delegate?.dashDidChange(self)
	}
	
	// MARK: - As an NSView
	override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
		return true
	}
	
	override func draw(_ dirtyRect: NSRect) {
		NSColor.white.set()
		dirtyRect.fill()
		
		NSColor.lightGray.set()
		bounds.frame(withWidth: 1)
		let br = bounds
		let a = NSPoint(x: br.minX + kDKDashEditInset, y: (br.minY + br.maxY) / 4)
		let b = NSPoint(x: br.maxX - kDKDashEditInset, y: (br.minY + br.maxY) / 4)
		
		path.removeAllPoints()
		path.move(to: a)
		path.line(to: b)
		
		dash?.apply(to: path)
		
		lineColour.set()
		path.stroke()
		
		calcHandles()
		drawHandles()
		
		// draw phase handle - right pointing triangle

		let path2 = NSBezierPath()
		path2.move(to: NSPoint(x: phaseHandle.minX, y: phaseHandle.minY))
		path2.line(to: NSPoint(x: phaseHandle.minX, y: phaseHandle.maxY))
		path2.line(to: NSPoint(x: phaseHandle.maxX, y: phaseHandle.midY))
		path2.close()
		
		NSColor.darkGray.set()
		path2.fill()
	}
	
	override var isFlipped: Bool {
		return true
	}
	
	// MARK: - As an NSResponder
	
	override func mouseDown(with event: NSEvent) {
		let mp = convert(event.locationInWindow, from: nil)
		selected = mouse(inHandle: mp)
		needsDisplay = true
		
		LogEvent(.reactiveEvent, "selected = \(selected)")
	}
	
	override func mouseDragged(with event: NSEvent) {
		if selected != -1 {
			let mp = convert(event.locationInWindow, from: nil)

			calcDash(for: mp)
			needsDisplay = true
		}
	}
	
	override func mouseUp(with event: NSEvent) {
		selected = -1
		needsDisplay = true
	}
}
