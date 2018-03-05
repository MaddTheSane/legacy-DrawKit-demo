//
//  WTSGradientControl.swift
//  DrawDemoSwift
//
//  Created by C.W. Betts on 1/12/18.
//  Copyright © 2018 DrawKit. All rights reserved.
//

import Cocoa
import DKDrawKit.DKGradient
import DKDrawKit.DKGradient.UISupport
import DKDrawKit.GCInfoFloater
import DKDrawKit.LogEvent

final class WTSGradientControl: GCSGradientWell {
	/// State constants used to specify highlighting for stops.
	enum State: Int {
		case normal = 0
		case pressed
		case selected
		case inactive
		case highlightedForMenu
	}
	
	var dragStop: DKColorStop?
	var deletionCandidateRef: DKColorStop?
	var infoWin = GCInfoFloater()
	
	var unsortedStops = [DKColorStop]()
	var sbArray: [NSRect]?

	private var stopInsertHint = NSPoint.zero
	private var stopWasDragged = false
	private var mouseDownInStop = false
	private var showsInfo = true
	
	@objc func colorWellActivation(_ note: Notification) {
		// when any well activates, deselect any stop

		selectedStop = nil
	}

	private func draw(_ stop: DKColorStop, in rect: NSRect, state st: State) {
		let inset = max(2, floor(rect.size.height / 8))
		let inner = centerScanRect(rect.insetBy(dx: inset, dy: inset))
		
		let rect2 = centerScanRect(rect)
		
		switch st {
		case .inactive, .normal:
			DKGradient.aquaNormal.fill(rect2)
			
		case .pressed:
			DKGradient.aquaPressed.fill(rect2)
			
		case .selected:
			DKGradient.aquaSelected.fill(rect2)
			
		default:
			break
		}
		
		stop.color.drawSwatch(in: inner)
		
		if st == .inactive {
			NSColor.lightGray.set()
		} else {
			NSColor.darkGray.set()
		}
		
		rect2.frame(withWidth: 1.0)
		inner.frame(withWidth: 1.0)
	}
	
	@objc func externalStopChange(_ note: Notification) {
		if (note.object as AnyObject?) === gradient {
			//	LogEvent_(kUserEvent, @"external change to stops");
			
			//invalidate()
			if let colorStops = gradient?.colorStops {
				unsortedStops = colorStops
			} else {
				unsortedStops.removeAll()
			}
			needsDisplay = true
		}
	}
	
	@IBAction func interpolation(_ sender: AnyObject?) {
		if let tag = sender?.tag, let interp = DKGradientInterpolation(rawValue: tag) {
			gradient?.gradientInterpolation = interp
		}
		syncGradientToControlSettings()
		needsDisplay = true
	}
	
	func relativeX(with pt: NSPoint) -> CGFloat {
		let bounds = interior
		var gPos = (pt.x - bounds.origin.x) / bounds.size.width
		
		gPos = min(1, gPos)
		return max(0, gPos)
	}
	
	// MARK: -

	override var gradient: DKGradient? {
		didSet {
			if gradient !== oldValue {
				selectedStop = nil
				dragStop = nil
				
				// copy initial set of stops to the unsorted stops array

				if let aGradient = gradient {
					unsortedStops = aGradient.colorStops
				} else {
					unsortedStops.removeAll()
				}
			} else {
				needsDisplay = true
			}
			invalidate()
		}
	}
	
	// MARK: -

	func removeColorStop(at point: NSPoint) {
		if let stop = self.stop(at: point) {
			unsortedStops.remove(at: unsortedStops.index(of: stop)!)
			invalidate()
			gradient?.removeColorStop(stop)
			syncGradientToControlSettings()
			needsDisplay = true
		}
	}
	
	func addColorStop(_ color1: NSColor?, at point: NSPoint) -> DKColorStop? {
		var stop = self.stop(at: point)
		if let stop = stop {
			if let color = color1 {
				stop.color = color
			}
			syncGradientToControlSettings()
		} else {
			let gPos = relativeX(with: point)
			
			needsDisplay = true
			let color = color1 ?? gradient!.color(atValue: gPos)
			
			stop = gradient?.add(color, at: gPos)
			//[mUnsortedStops addObject:stop];
			invalidate()
			syncGradientToControlSettings()
		}
		return stop
	}
	
	func color(at point: NSPoint) -> NSColor? {
		let gPos = relativeX(with: point)
		return gradient?.color(atValue: gPos)
	}
	
	// MARK: -
	
	func swatchBox(atPosition position: CGFloat) -> NSRect {
		let bounds = interior
		var box = NSRect()
		
		box.size.height = bounds.size.height // / 2;
		box.size.width = 17 //box.size.height * 0.5;
		
		box.origin.x = bounds.origin.x + (bounds.size.width * position - (box.size.width / 2))
		box.origin.y = bounds.minY //(box.size.height / 2);
		
		return box
	}
	
	var allSwatchBoxes: [NSRect] {
		if let sbarray = sbArray {
			return sbarray
		} else {
			var sbarr = [NSRect]()
			
			for stop in unsortedStops {
				let r = swatchBox(atPosition: stop.position)
				sbarr.append(r)
			}
			
			let swr = swatchBox(atPosition: 0)
			
			for i in 0 ..< sbarr.count {
				var r = sbarr[i]
				var hits = IndexSet()
				
				hits.insert(i)
				
				for (k, rn) in sbarr.enumerated() {
					guard i != k else {
						continue
					}
					
					if r.intersects(rn) {
						// collision, make note of its index
						hits.insert(k)
						r = rn
					}
				}
				
				// if any hits, need to adjust all indicated rects
				if hits.count > 1 {
					let height = swr.size.height / CGFloat(hits.count)
					var yorigin = swr.origin.y
					
					for j in hits {
						r = sbarr[j]
						
						r.size.height = height
						r.origin.y = yorigin
						
						yorigin += height
						
						sbarr[j] = r
					}

				}
			}
			
			sbArray = sbarr
			return sbarr
		}
	}
	
	func invalidate() {
		//	LogEvent_(kReactiveEvent, @"invalidating stops rects");

		sbArray = nil
	}
	
	/// returns the actual rect used for the given stop, taking into account overlaps, etc.
	func swatchRect(for stop: DKColorStop) -> NSRect {
		
		if let indx = unsortedStops.index(of: stop) {
			return allSwatchBoxes[indx]
		} else {
			return .zero
		}
	}
	
	// MARK: -
	
	func drawStops(in rect: NSRect) {
		let boxes = allSwatchBoxes
		
		for (element, sw) in zip(unsortedStops, boxes) {
			if element !== deletionCandidateRef {
				let state: State
				
				if element === selectedStop || element == dragStop {
					if mouseDownInStop {
						state = .pressed
					} else {
						state = .selected
					}
				} else {
					state = .normal
				}
				draw(element, in: sw, state: state)
			}
		}
	}
	
	func stop(at point: NSPoint) -> DKColorStop? {
		
		for (j, r) in allSwatchBoxes.enumerated() {
			if r.contains(point) {
				return unsortedStops[j]
			}
		}
		
		return nil
	}
	
	weak var selectedStop: DKColorStop? {
		willSet {
			if let mSelectedStopRef = selectedStop {
				setNeedsDisplay(swatchRect(for: mSelectedStopRef))
			}
		}
		didSet {
			if let mSelectedStopRef = selectedStop {
				// order here is important: deactivate external well before setting panel's colour:

				GCSpecialColorWell.deactivateCurrentWell()
				
				NSColorPanel.shared.color = mSelectedStopRef.color
				NSColorPanel.shared.setTarget(self)
				NSColorPanel.shared.setAction(#selector(NSObject.changeColor(_:)))
				
				setNeedsDisplay(swatchRect(for: mSelectedStopRef))
			}
		}
	}

	func setColorOfSelectedStop(_ color: NSColor) {
		if let selectedStop = selectedStop {
			selectedStop.color = color
			syncGradientToControlSettings()
			needsDisplay = true
		}
	}
	
	// MARK: -
	
	func updateInfo(withPosition pos: CGFloat) {
		guard showsPositionInfo else {
			return
		}
		let sr = swatchBox(atPosition: pos)
		let ip = NSPoint(x: sr.minX, y: sr.minY)
		
		infoWin.setFloatValue(Float(pos * 100))
		infoWin.positionNearPoint(ip, in: self)
	}
	
	var showsPositionInfo = false
	
	// MARK: -
	
	func setCursorInSafeLocation(_ p: NSPoint) -> Bool {
		let safeZone = self.bounds.insetBy(dx: -32, dy: -7)
		
		if safeZone.contains(p) || gradient!.countOfColorStops < 3 {
			NSCursor.arrow.set()
			return true
		} else {
			if let dragStop = dragStop {
				makeCursor(forDeleting: dragStop).set()
			}
			return false
		}
	}

	// MARK: -
	
	func dragImage(for stop: DKColorStop) -> NSImage {
		var sr = swatchBox(atPosition: 0)
		sr.origin = .zero
		
		let img = NSImage(size: sr.size)
		
		img.lockFocus()
		draw(stop, in: sr, state: .normal)
		img.unlockFocus()
		
		return img
	}
	
	/// This is something of a hack, though an inspired one ;-). wish to show the stop under the cursor
	/// when it's going to be deleted, but using a drag image doesn't fit the current logic design. So instead we
	/// just create a custom cursor on the fly by compositing the stop image with the 'poof' cursor.
	func makeCursor(forDeleting stop: DKColorStop) -> NSCursor {
		struct S {
			static var curs: NSCursor?
			static var stop: DKColorStop?
		}
		
		if S.curs == nil || S.stop !== stop {
			let poofImage = NSCursor.disappearingItem.image
			let stopImg = dragImage(for: stop)
			var hotspot = NSCursor.disappearingItem.hotSpot

			// compute size of composited image. stopImg will be centred under the hotspot
			var a = NSRect(origin: .zero, size: poofImage.size)
			var b = NSRect(origin: CGPoint(x: hotspot.x - (stopImg.size.width / 2.0), y: hotspot.y - (stopImg.size.height / 2.0)), size: stopImg.size)
			
			//	LogEvent_(kInfoEvent,  @"rect B = {%f, %f - %f, %f}", b.origin.x, b.origin.y, b.size.width, b.size.height );
			
			var c = a.union(b)
			b.origin.x -= c.origin.x;
			b.origin.y -= c.origin.y;
			a.origin.x -= c.origin.x;
			a.origin.y -= c.origin.y;
			c.origin = NSZeroPoint;
			hotspot.x = b.origin.x + (b.size.width / 2.0);
			hotspot.y = b.origin.y + (b.size.height / 2.0);
			
			//	LogEvent_(kInfoEvent,  @"rect C = {%f, %f - %f, %f}", c.origin.x, c.origin.y, c.size.width, c.size.height );
			
			let newImage = NSImage(size: c.size)
			
			newImage.lockFocusFlipped(true)
			stopImg.draw(in: b, from: .zero, operation: .copy, fraction: 0.5, respectFlipped: true, hints: nil)
			poofImage.draw(in: a, from: .zero, operation: .sourceOver, fraction: 1, respectFlipped: true, hints: nil)
			/*
			[[NSColor redColor] set];
			NSFrameRect( b );
			NSFrameRect( a );
			NSFrameRect( c );
			a = NSInsetRect( NSMakeRect( hotspot.x, hotspot.y, 0, 0 ), -2, -2 );
			NSFrameRect( a );
			*/
			newImage.unlockFocus()
			
			S.curs = NSCursor(image: newImage, hotSpot: hotspot)
			S.stop = stop
		}
		
		return S.curs!
	}

	// MARK: -
	
	/// keeps control in its own event loop until the mouse is released. It handles the dragging of the stops and swatch
	/// drag. This is more appropriate for a control than implementing mouseDown/dragged/up because any clients that
	/// implement Undo don't want individual changes seen as separate undos.
	private func trackMouse(with event2: NSEvent) {
		// Note - this is called from mouseDown, so do not call it again.
		var loop = true
		let mask: NSEvent.EventTypeMask = [.leftMouseUp, .leftMouseDragged]
		var event = event2
		
		while loop {
			guard let event3 = window?.nextEvent(matching: mask) else {
				continue
			}
			event = event3
			
			switch event.type {
			case .leftMouseUp:
				mouseUp(with: event)
				loop = false
				
			case .leftMouseDragged:
				mouseDragged(with: event)
				
			default:
				break
			}
		}
	}
	
	// MARK: -
	
	@IBAction override func changeColor(_ sender: Any?) {
		//	LogEvent_(kStateEvent, @"changing colour...");

		if let clr: NSColor = (sender as AnyObject?)?.color {
			setColorOfSelectedStop(clr)
			
			if (sender as AnyObject?) !== NSColorPanel.shared {
				NSColorPanel.shared.color = clr
			}
		}
	}
	
	@IBAction func newStop(_ sender: Any?) {
		var p = stopInsertHint
		
		if p == .zero {
			p.x = bounds.midX
			p.y = bounds.midY
		}
		selectedStop = addColorStop(nil, at: p)
	}
	
	@IBAction func blendMode(_ sender: AnyObject?) {
		if let tag = sender?.tag, let blend = DKGradientBlending(rawValue: tag) {
			gradient?.gradientBlending = blend
		}
		syncGradientToControlSettings()
		needsDisplay = true
	}
	
	@IBAction func flip(_ sender: Any?) {
		gradient?.reverseColorStops()
		syncGradientToControlSettings()
		needsDisplay = true
		invalidate()
	}
	
	@IBAction func gradientType(_ sender: AnyObject?) {
		if let tag = sender?.tag,
			let type = DKGradientType(rawValue: tag),
			type != gradient?.gradientType {
			gradient?.gradientType = type
			syncGradientToControlSettings()
			needsDisplay = true
		}
	}

	// MARK: -
	
	var interior: NSRect {
		return bounds.insetBy(dx: 11, dy: 2)
	}
	
	// MARK: - As an NSView
	
	override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
		return true
	}
	
	override func draw(_ dirtyRect: NSRect) {
		let br = bounds
		let clip = interior.insetBy(dx: -8, dy: 0)
		
		NSColor.gray.set()
		br.frame(withWidth: 1)
		
		// draw a background pattern so we can "see" transparencies

		let pat = #imageLiteral(resourceName: "chequered")
		do {
			let pp = NSColor(patternImage: pat)
			pp.set()
			clip.fill()
		}
		
		// must make a copy of the gradient so that the angle and type can be ignored

		let gradCopy = self.gradient?.copy() as? DKGradient
		
		gradCopy?.gradientType = .linear
		gradCopy?.angle = 0
		let path = NSBezierPath(rect: clip)
		
		let start = NSPoint(x: clip.minX, y: clip.midY)
		let end = NSPoint(x: clip.maxX, y: clip.midY)
		
		gradCopy?.fill(path, startingAt: start, startRadius: 0, endingAt: end, endRadius: 0)

		// Draw the swatches
		drawStops(in: clip)
	}

	override init(frame frameRect: NSRect) {
		super.init(frame: frameRect)
		infoWin.setFormat("0.0%")
		gradient = DKGradient.default()
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		infoWin.setFormat("0.0%")
		gradient = DKGradient.default()
	}
	
	override var isFlipped: Bool {
		return true
	}
	
	override func menu(for event: NSEvent) -> NSMenu? {
		var p = event.locationInWindow
		p = self.convert(p, from: nil)
		
		if let stop = self.stop(at: p) {
			// right-click in stop. pop up our custom menu
			
			//	LogEvent_(kReactiveEvent, @"popping up stop contextual menu");

			selectedStop = stop
			
			// figure out where to put the menu

			let sw = swatchRect(for: stop)
			var loc = NSPoint(x: sw.minX, y: sw.maxY)
			loc = convert(loc, to: nil)
			
			let sr = NSRect(x: 0, y: 0, width: 161, height: 161)
			let picker = GCSColourPickerView(frame: sr)
			let popup = GCSWindowMenu(contentView: picker)
			
			if event.modifierFlags.contains(.option) {
				picker.mode = .swatches
			} else {
				picker.mode = .spectrum
			}
			
			picker.target = self
			picker.action = #selector(NSObject.changeColor(_:))
			picker.colorForUndefinedSelection = stop.color
			picker.showsInfo = true
			
			GCSWindowMenu.popUpWindowMenu(popup, at: loc, with: event, for: self)

			return nil
		} else {
			let contextualMenu = super.menu(for: event)!
			
			var item = contextualMenu.insertItem(withTitle: NSLocalizedString("New Color Stop", comment: ""), action: #selector(WTSGradientControl.newStop(_:)), keyEquivalent: "", at: 0)
			item = contextualMenu.insertItem(withTitle: NSLocalizedString("Reverse Colors", comment: ""), action: #selector(WTSGradientControl.flip(_:)), keyEquivalent: "", at: 1)
			item.target = self
			contextualMenu.insertItem(.separator(), at: 2)
			
			// gradient types:

			contextualMenu.addItem(.separator())
			item = contextualMenu.addItem(withTitle: NSLocalizedString("Linear", comment: ""), action: #selector(WTSGradientControl.gradientType(_:)), keyEquivalent: "")
			item.target = self
			item.tag = DKGradientType.linear.rawValue
			item = contextualMenu.addItem(withTitle: NSLocalizedString("Radial", comment: ""), action: #selector(WTSGradientControl.gradientType(_:)), keyEquivalent: "")
			item.target = self
			item.tag = DKGradientType.radial.rawValue
			item = contextualMenu.addItem(withTitle: NSLocalizedString("Sweep", comment: ""), action: #selector(WTSGradientControl.gradientType(_:)), keyEquivalent: "")
			item.target = self
			item.tag = DKGradientType.sweptAngle.rawValue
			
			// blending modes:

			contextualMenu.addItem(.separator())
			item = contextualMenu.addItem(withTitle: NSLocalizedString("RGB Blending", comment: ""), action: #selector(WTSGradientControl.blendMode(_:)), keyEquivalent: "")
			item.target = self
			item.tag = DKGradientBlending.RGB.rawValue
			item = contextualMenu.addItem(withTitle: NSLocalizedString("HSV Blending", comment: ""), action: #selector(WTSGradientControl.blendMode(_:)), keyEquivalent: "")
			item.target = self
			item.tag = DKGradientBlending.HSB.rawValue
			
			// interpolations:

			contextualMenu.addItem(.separator())

			item = contextualMenu.addItem(withTitle: NSLocalizedString("Linear", comment: ""), action: #selector(WTSGradientControl.interpolation(_:)), keyEquivalent: "")
			item.target = self
			item.tag = DKGradientInterpolation.linear.rawValue
			item = contextualMenu.addItem(withTitle: NSLocalizedString("Quadratic", comment: ""), action: #selector(WTSGradientControl.interpolation(_:)), keyEquivalent: "")
			item.target = self
			item.tag = DKGradientInterpolation.quadratic.rawValue
			item = contextualMenu.addItem(withTitle: NSLocalizedString("Cubic", comment: ""), action: #selector(WTSGradientControl.interpolation(_:)), keyEquivalent: "")
			item.target = self
			item.tag = DKGradientInterpolation.cubic.rawValue
			item = contextualMenu.addItem(withTitle: NSLocalizedString("Sinusoid", comment: ""), action: #selector(WTSGradientControl.interpolation(_:)), keyEquivalent: "")
			item.target = self
			item.tag = DKGradientInterpolation.sinus.rawValue

			stopInsertHint = p
			
			return contextualMenu
		}
		
		//return nil
	}
	
	override var frame: NSRect {
		didSet {
			invalidate()
		}
	}
	
	// MARK: - As an NSFirstResponder
	
	override func mouseDown(with event: NSEvent) {
		var pt = event.locationInWindow
		pt = convert(pt, from: nil)
		
		dragStop = nil
		stopWasDragged = false
		
		if let stop = self.stop(at: pt) {
			dragStop = stop
			mouseDownInStop = true
			//mSelectedStopRef = nil;
			// prepare the info window to show the stop's position
			
			if showsInfo {
				updateInfo(withPosition: dragStop!.position)
				infoWin.orderFront(self)
			}
			setNeedsDisplay(swatchRect(for: stop))
		}
		
		trackMouse(with: event)
	}
	
	override func mouseDragged(with event: NSEvent) {
		if let dragStop = dragStop {
			var point = event.locationInWindow
			point = self.convert(point, from: nil)
			var gPos = relativeX(with: point)
			
			if !setCursorInSafeLocation(point) {
				deletionCandidateRef = dragStop
				infoWin.orderOut(self)
			} else {
				deletionCandidateRef = nil
				
				if showsInfo {
					infoWin.show()
				}
				
				// round gPos to "grid" clicks if desired
				if event.modifierFlags.contains(.shift) {
					gPos = round(gPos * 100) / 100
				}
				
				updateInfo(withPosition: gPos)
				dragStop.position = gPos
				invalidate()
				gradient?.sortColorStops()
				syncGradientToControlSettings()
				
				stopWasDragged = true
			}
			
			needsDisplay = true
		} else {
			initiateGradientDrag(with: event)
		}
	}
	
	override func mouseUp(with event: NSEvent) {
		var pt = event.locationInWindow
		pt = convert(pt, from: nil)
		mouseDownInStop = false
		
		infoWin.hide()
		if let mdragStopRef = dragStop {
			if selectedStop === mdragStopRef, !stopWasDragged {
				selectedStop = nil
			} else {
				selectedStop = mdragStopRef
				
				if !stopWasDragged {
					NSColorPanel.shared.orderFront(self)
				}
			}
			
			if !setCursorInSafeLocation(pt) {
				if mdragStopRef === selectedStop {
					selectedStop = nil
				}
				
				unsortedStops.remove(at: unsortedStops.index(of: mdragStopRef)!)
				gradient?.removeColorStop(mdragStopRef)
				syncGradientToControlSettings()
				NSAnimationEffect.disappearingItemDefault.show(centeredAt: NSEvent.mouseLocation, size: .zero)
				NSCursor.arrow.set()
				invalidate()
			}
		}
		dragStop = nil
		needsDisplay = true
	}
	
	// MARK: - As part of NSDraggingDestination  Protocol
	
	override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
		let sourceDragMask = sender.draggingSourceOperationMask()
		let pboard = sender.draggingPasteboard()
		
		if DKGradient.canInitalize(from: pboard) || (pboard.types?.contains(.color) ?? false) {
			if sourceDragMask.contains(.generic) {
				return .generic
			}
		}
		
		return []
	}
	
	override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
		dragStop = nil
		
		let pboard = sender.draggingPasteboard()
		
		if DKGradient.canInitalize(from: pboard), (sender.draggingSource() as AnyObject?) !== self {
			if let aGradient = DKGradient(pasteboard: pboard) {
				self.gradient = aGradient
			}
		} else if pboard.types?.contains(.color) ?? false {
			let color = NSColor(from: pboard)
			var pt = sender.draggingLocation()
			pt = convert(pt, from: nil)
			selectedStop = addColorStop(color, at: pt)
		}
		needsDisplay = true
		return true
	}

	// MARK: - As part of NSMenuValidation Protocol
	
	override func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
		let enable = super.validateMenuItem(menuItem)
		let act = menuItem.action
		
		if act == #selector(WTSGradientControl.blendMode(_:)) {
			menuItem.state = (menuItem.tag == gradient?.gradientBlending.rawValue) ? .on : .off
		} else if act == #selector(WTSGradientControl.interpolation(_:)) {
			menuItem.state = (menuItem.tag == gradient?.gradientInterpolation.rawValue) ? .on : .off
		} else if act == #selector(WTSGradientControl.gradientType(_:)) {
			menuItem.state = (menuItem.tag == gradient?.gradientType.rawValue) ? .on : .off
		}
		
		return enable
	}

	// MARK: - As part of NSNibAwaking  Protocol
	override func awakeFromNib() {
		super.awakeFromNib()
		NSColorPanel.shared.showsAlpha = true
		
		// register for dragged types handled by super.
		
		NotificationCenter.default.addObserver(self, selector: #selector(WTSGradientControl.colorWellActivation(_:)), name: .dkColorWellWillActivate, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(WTSGradientControl.externalStopChange(_:)), name: .dkNotificationGradientDidAddColorStop, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(WTSGradientControl.externalStopChange(_:)), name: .dkNotificationGradientDidRemoveColorStop, object: nil)
	}
}
