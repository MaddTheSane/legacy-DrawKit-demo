//
//  DKSGradientCell.swift
//  DrawDemoSwift
//
//  Created by C.W. Betts on 12/14/17.
//  Copyright © 2017 DrawKit. All rights reserved.
//

import Cocoa
import DKDrawKit.DKGradient
import DKDrawKit.DKShapeFactory

private var kDKDefaultGradientCellInset: NSSize {
	return NSSize(width: 8.0, height: 8.0)
}

@objc protocol DKSGradientDragging: NSObjectProtocol {
	@objc(dragProxyIconAtPoint:fromControl:)
	func dragProxyIcon(at startPoint: NSPoint, from control: NSControl!)
	@objc(initiateGradientDragWithEvent:)
	func initiateGradientDrag(with event: NSEvent!)
}

class DKSGradientCell: NSImageCell {
	var enableCache = true
	@objc var inset = kDKDefaultGradientCellInset
	@objc var gradient: DKGradient? {
		willSet {
			if gradient !== newValue {
				enableCache = true
				NotificationCenter.default.removeObserver(self, name: nil, object: gradient)
			}
		}
		didSet {
			if oldValue !== gradient {
				gradient?.setUpKVOForObserver(self)
				
				NotificationCenter.default.addObserver(self, selector: #selector(DKSGradientCell.gradientDidChange(notification:)), name: .dkNotificationGradientDidAddColorStop, object: gradient)
				NotificationCenter.default.addObserver(self, selector: #selector(DKSGradientCell.gradientDidChange(notification:)), name: .dkNotificationGradientDidRemoveColorStop, object: gradient)
				NotificationCenter.default.addObserver(self, selector: #selector(DKSGradientCell.gradientWillChange(notification:)), name: .dkNotificationGradientWillAddColorStop, object: gradient)
				NotificationCenter.default.addObserver(self, selector: #selector(DKSGradientCell.gradientWillChange(notification:)), name: .dkNotificationGradientWillRemoveColorStop, object: gradient)
				
				invalidateCache()
			}
		}
	}

	// MARK: -
	@objc func invalidateCache() {
		LogEvent(.reactiveEvent, "invalidating cache")
		objectValue = nil
	}
	
	@discardableResult
	final func cachedImage(for size: NSSize) -> NSImage! {
		var img = self.image
		if img == nil {
			let img2 = makeCacheImage(with: size)
			img = img2
			objectValue = img2
		}
		
		return img
	}

	/// creates an image of the current gradient for rendering in this cell as a cache. Note that the swatch method
	/// of the gradient itself does not include the chequered background.
	final func makeCacheImage(with size: NSSize) -> NSImage {
		let swatchImage = NSImage(size: size)
		let box = NSRect(origin: .zero, size: size)
		
		swatchImage.lockFocusFlipped(true)
		gradient?.fill(box)
		swatchImage.unlockFocus()
		
		return swatchImage
	}
	
	// MARK: -
	@objc(gradientDidChange:)
	final func gradientDidChange(notification note: Notification) {
		invalidateCache()
		gradient?.setUpKVOForObserver(self)
	}
	
	@objc(gradientWillChange:)
	final func gradientWillChange(notification note: Notification) {
		gradient?.tearDownKVO(forObserver: self)
	}
	
	// MARK: - As an NSCell
	
	override func drawInterior(withFrame cellFrame: NSRect, in controlView: NSView) {
		if let gradient = self.gradient {
			do {
				let pat = #imageLiteral(resourceName: "chequered")
				let pp = NSColor(patternImage: pat)
				pp.set()
				cellFrame.insetBy(dx: inset.width, dy: inset.height).fill()
			}
			
			if enableCache {
				cachedImage(for: cellFrame.size)
				super.drawInterior(withFrame: cellFrame, in: controlView)
			} else {
				super.drawInterior(withFrame: cellFrame, in: controlView)
				gradient.fill(cellFrame.insetBy(dx: inset.width, dy: inset.height))
			}
		}
	}
	
	final override func draw(withFrame cellFrame: NSRect, in controlView: NSView) {
		super.draw(withFrame: cellFrame, in: controlView)
		
		if let cv = controlView as? GCSGradientWell {
			if cv.isActiveWell {
				let rr = DKShapeFactory.roundRect(in: cellFrame.insetBy(dx: 2, dy: 2), andCornerRadius: 5)
				
				rr.lineWidth = 3
				
				NSColor(for: NSColor.currentControlTint).set()
				rr.stroke()
			}
		}
	}
	
	override func trackMouse(with theEvent: NSEvent, in cellFrame: NSRect, of controlView: NSView, untilMouseUp flag: Bool) -> Bool {
		let p = controlView.convert(theEvent.locationInWindow, from: nil)
		
		if startTracking(at: p, in: controlView) {
			var event: NSEvent?
			var loop = true
			var currentPoint = NSPoint.zero
			var lastPoint = NSPoint.zero
			
			enableCache = false
			let mask: NSEvent.EventTypeMask = [.leftMouseUp, .leftMouseDragged]
			lastPoint = p
			
			while loop {
				guard let event1 = controlView.window!.nextEvent(matching: mask) else {
					continue
				}
				
				event = event1
				currentPoint = controlView.convert(event1.locationInWindow, from: nil)
				
				switch event1.type {
				case .leftMouseUp:
					stopTracking(last: lastPoint, current: currentPoint, in: controlView, mouseIsUp: true)
					loop = false
					
					// set active if allowed to become (default is YES)

					if let cv = self.controlView as? GCSGradientWell {
						cv.toggleActiveWell()
					}
					
				case .leftMouseDragged:
					loop = false
					stopTracking(last: lastPoint, current: currentPoint, in: controlView, mouseIsUp: false)
					(controlView as? DKSGradientDragging)?.initiateGradientDrag(with: theEvent)
				default:
					break
				}
				lastPoint = currentPoint
			}
			controlView.window!.discardEvents(matching: mask, before: event)
			enableCache = true
		}
		
		return true
	}
	
	// MARK: - As an NSObject
	
	override init() {
		super.init(imageCell: nil)
		
		isContinuous = true
		imageFrameStyle = .grayBezel
		imageScaling = .scaleAxesIndependently
	}
	
	required init(coder: NSCoder) {
		super.init(coder: coder)
		
		isContinuous = true
		imageFrameStyle = .grayBezel
		imageScaling = .scaleAxesIndependently
	}
	
	// MARK: - As part of NSKeyValueObserving Protocol
	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		invalidateCache()
	}
}
