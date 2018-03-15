//
//  GCSColourPickerView.swift
//  DrawDemoSwift
//
//  Created by C.W. Betts on 12/23/17.
//  Copyright © 2017 DrawKit. All rights reserved.
//

import Cocoa
import DKDrawKit.GCInfoFloater
import DKDrawKit.DKAdditions.NSColor

private var COLS: Int {
	return 16
}

private var ROWS: Int {
	return 16
}


final class GCSColourPickerView: NSView {
	@objc(DKSColourPickerMode)
	enum Mode: Int {
		case swatches = 0
		case spectrum = 1
	}
	
	@objc var colorForUndefinedSelection: NSColor = NSColor.gray {
		didSet {
			// set brightness to the colour's brightness
			if let newBright = colorForUndefinedSelection.usingColorSpaceName(.calibratedRGB)?.brightnessComponent {
				brightness = newBright
			}
		}
	}
	let infoWin: GCInfoFloater = {
		let newFloat = GCInfoFloater()
		newFloat.windowOffset = .zero
		return newFloat
	}()
	@objc var mode: Mode = .spectrum {
		didSet {
			if mode != oldValue {
				needsDisplay = true
			}
		}
	}
	
	private var mBright: CGFloat = 1
	@objc var brightness: CGFloat {
		get {
			return mBright
		}
		set {
			var nv = newValue
			nv = min(nv, 1)
			nv = max(nv, 0)
			
			if nv != mBright {
				mBright = nv
				needsDisplay = true
				
				if mode == .spectrum {
					sendToTarget()
				}
			}
		}
	}
	private var sel: NSPoint = NSPoint(x: -1, y: -1)
	@objc weak var target: AnyObject?
	@objc var action: Selector?
	@objc var showsInfo = true
	
	// MARK: -
	
	func drawSwatches(_ rect: NSRect) {
		let br = self.bounds
		let swx = Int(br.size.width / CGFloat(COLS))
		let swy = Int(br.size.height / CGFloat(ROWS))
		
		var swr = NSRect(x: 1, y: 1, width: swx - 1, height: swy - 1)
		
		for i in 0 ..< ROWS {
			for j in 0 ..< COLS {
				if swr.intersects(rect) {
					colorForSwatch(x: j, y: i)?.drawSwatch(in: swr)
					
					if j == Int(sel.x), i == Int(sel.y) {
						NSColor.black.set()
						swr.frame(withWidth: 2.0)
					}
				}
				swr.origin.x += CGFloat(swx)
			}
			swr.origin.x -= CGFloat(swx * COLS)
			swr.origin.y += CGFloat(swy);

		}
	}
	
	func drawSpectrum(_ rect: NSRect) {
		let specImage = #imageLiteral(resourceName: "NSColorWheelImage")
		
		// clip to a circle fitting bounds
		NSBezierPath(ovalIn: self.bounds.insetBy(dx: 5, dy: 5)).addClip()
		
		// composite image + brightness to view
		if brightness < 1.0 {
			NSColor.black.set()
			rect.fill()
		}
		
		NSGraphicsContext.current?.imageInterpolation = .high
		specImage.draw(in: rect, from: rect, operation: .copy, fraction: brightness, respectFlipped: true, hints: nil)
		
		// draw the current colour location
		let mr = rectForSpectrumPoint(sel)
		NSColor.contrastingColor(color).set()
		NSBezierPath.defaultLineWidth = 1
		NSBezierPath(ovalIn: mr.insetBy(dx: 0.5, dy: 0.5)).stroke()
	}
	
	// MARK: -
	
	@objc var color: NSColor {
		if mode == .swatches {
			if sel.x < 0 || sel.x > CGFloat(COLS - 1) || sel.y < 0 || sel.y > CGFloat(ROWS - 1) {
				return colorForUndefinedSelection
			} else {
				return colorForSwatch(x: Int(sel.x), y: Int(sel.y)) ?? .white
			}
		} else {
			return colorForSpectrumPoint(sel)
		}
	}
	
	/// Given a point `p`, this figures out the colour in the colourwheel at that point
	func colorForSpectrumPoint(_ p: NSPoint) -> NSColor {
		let br = self.bounds.insetBy(dx: 4, dy: 4)
		let cp = NSPoint(x: br.midX, y: br.midY)
		let mr = br.size.width / 2.0
		
		let radius = hypot(p.x - cp.x, p.y - cp.y)
		var angle = atan2(p.y - cp.y, p.x - cp.x)
		
		if angle < 0 {
			angle += 2 * .pi
		}
		
		// is the point within the colour wheel?
		if radius > mr {
			return colorForUndefinedSelection
		}
		
		// convert to hue, saturation and brightness
		
		let hue = 1.0 - (angle / (2 * .pi));
		let sat = radius / mr;
		
		return NSColor(calibratedHue: hue, saturation: sat, brightness: brightness, alpha: 1)
	}
	
	/// Given a colour, returns the point in the spectrum wheel where it will be found.
	@objc(pointForSpectrumColor:)
	func pointFor(spectrumColor colour: NSColor) -> NSPoint {
		let rgb = colour.usingColorSpaceName(NSColorSpaceName.calibratedRGB)!
		
		let hue = rgb.hueComponent
		let sat = rgb.saturationComponent
		
		let br = self.bounds.insetBy(dx: 4, dy: 4)
		let cp = NSPoint(x: br.midX, y: br.midY)
		let mr = br.size.width / 2
		
		let angle = (1.0 - hue) * 2 * .pi
		let p = NSPoint(x: cp.x + (cos(angle) * sat * mr), y: cp.y + (sin(angle) * sat * mr))
		
		return p
	}
	
	@objc
	func rectForSpectrumPoint(_ sp: NSPoint) -> NSRect {
		return NSRect(origin: sp, size: .zero).insetBy(dx: -4, dy: -4)
	}
	
	@objc(pointIsInColourwheel:)
	func pointIsInColourWheel(_ p: NSPoint) -> Bool {
		let br = self.bounds.insetBy(dx: 4, dy: 4)
		let cp = NSPoint(x: br.midX, y: br.midY)
		let mr = br.size.width / 2.0
		
		let radius = hypot(p.x - cp.x, p.y - cp.y)
		return radius <= mr
	}
	
	@objc(colorForSwatchX:y:)
	func colorForSwatch(x: Int, y: Int) -> NSColor? {
		let indx = y * COLS + x
		let cList = NSColorList(named: NSColorList.Name(rawValue: "Web Safe Colors"))!
		
		let keys = cList.allKeys
		
		let i = keys.count == 0 ? 0 : indx % keys.count
		
		return cList.color(withKey: keys[i])
	}

	// MARK: -
	
	/// returns x and y coordinates of the swatch containing `p`.
	@objc(swatchAtPoint:)
	func swatch(at p: NSPoint) -> NSPoint {
		let br = self.bounds
		let sp: NSPoint
		if br.contains(p) {
			sp = NSPoint(x: floor(p.x * CGFloat(COLS) / br.size.width), y: CGFloat(p.y * CGFloat(ROWS) / br.size.height))
		} else {
			sp = NSPoint(x: -1, y: -1)
		}
		
		return sp
	}
	
	func rectForSwatch(_ sp: NSPoint) -> NSRect {
		if mode == .swatches {
			let br = self.bounds
			let swx = floor(br.size.width / CGFloat(COLS))
			let swy = floor(br.size.height / CGFloat(ROWS))

			let swr = NSRect(x: 1, y: 1, width: swx, height: swy)
			
			return swr.offsetBy(dx: sp.x * swx, dy: sp.y * swy)
		} else {
			return rectForSpectrumPoint(sp)
		}
	}
	
	func updateInfo(at p: NSPoint) {
		if p != NSPoint(x: -1, y: -1) {
			infoWin.positionNearPoint(p, in: self)
		}
		
		let cf = color.hexString
		infoWin.setStringValue(cf)
	}
	
	// MARK: -
	@objc func sendToTarget() {
		if let sel = action {
			NSApp.sendAction(sel, to: target, from: self)
		}
	}
	
	// MARK: - As an NSView
	override func draw(_ dirtyRect: NSRect) {
		if mode == .swatches {
			drawSwatches(dirtyRect)
		} else {
			drawSpectrum(dirtyRect)
		}
	}
	
	override func flagsChanged(with event: NSEvent) {
		if event.modifierFlags.contains(.option) {
			mode = .swatches
		} else {
			mode = .spectrum
		}
	}
	
	override var isFlipped: Bool {
		return true
	}
	
	override func mouseDown(with event: NSEvent) {
		if showsInfo {
			let wn = window!.windowNumber
			
			infoWin.order(.above, relativeTo: wn)
			updateInfo(at: .zero)
		}
		
		mouseDragged(with: event)
	}
	
	override func mouseDragged(with event: NSEvent) {
		let p = convert(event.locationInWindow, from: nil)
		let s: NSPoint
		if mode == .swatches {
			s = swatch(at: p)
		} else {
			s = p
		}
		
		if sel != s {
			setNeedsDisplay(rectForSwatch(sel))
			sel = s
			setNeedsDisplay(rectForSwatch(sel))
			sendToTarget()
			
			// in colourwheel mode, if sel is outside the wheel, set it to the undefined colour position
			if mode == .spectrum, !pointIsInColourWheel(p) {
				sel = pointFor(spectrumColor: colorForUndefinedSelection)
				brightness = colorForUndefinedSelection.brightnessComponent
				setNeedsDisplay(rectForSwatch(sel))
			}
		}
		
		// update info window
		if showsInfo {
			updateInfo(at: NSPoint(x: -1, y: -1))
		}
	}
	
	override func mouseUp(with event: NSEvent) {
		infoWin.orderOut(self)
	}

	override func viewDidMoveToWindow() {
		super.viewDidMoveToWindow()
		if window == nil {
			infoWin.orderOut(nil)
		}
	}
	
	// MARK: - As an NSResponder
	
	override func scrollWheel(with event: NSEvent) {
		if mode == .spectrum {
			let deltay = event.deltaY / 150
			brightness -= deltay
			updateInfo(at: NSPoint(x: -1, y: -1))
		}
	}
}
