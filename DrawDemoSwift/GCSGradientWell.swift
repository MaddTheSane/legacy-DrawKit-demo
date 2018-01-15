//
//  GCSGradientWell.swift
//  DrawDemoSwift
//
//  Created by C.W. Betts on 1/12/18.
//  Copyright © 2018 DrawKit. All rights reserved.
//

import Cocoa
import DKDrawKit.DKGradient
import DKDrawKit.DKGradient.Extensions
import DKDrawKit.LogEvent

class GCSGradientWell: NSControl, NSDraggingSource {
	//@objc(DKSGradientWellMode)
	enum Mode: Int {
		case display = 0
		case angle = 1
		case radial = 2
		case sweep = 3
	}
	
	static var activeWell: GCSGradientWell? {
		willSet(well) {
			if well !== activeWell {
				activeWell?.wellWillResignActive()
			}
		}
		didSet(well) {
			if well !== activeWell {
				activeWell?.wellDidBecomeActive()
			}
		}
	}
	
	class func clearAllActiveWells() {
		activeWell = nil
	}
	
	private var trackingTag: NSView.TrackingRectTag = 0
	private var isSendingAction = false
	
	// MARK: -

	var gradient: DKGradient? {
		get {
			return (cell as? GCSGradientCell)?.gradient
		}
		set {
			if gradient !== newValue {
				(cell as? GCSGradientCell)?.gradient = newValue
				needsDisplay = true
				//[self syncGradientToControlSettings];
			}
		}
	}
	// MARK: -
	
	func syncGradientToControlSettings() {
		//LogEvent_(kReactiveEvent, @"synching target/action, target = %@, action = %@", [self target], NSStringFromSelector([self action]));
		if !isSendingAction {
			isSendingAction = true
			needsDisplay = true
			sendAction(action, to: target)
			isSendingAction = false
		}
	}
	
	func initiateGradientDrag(with theEvent: NSEvent) {
		if #available(OSX 10.13, *) {
			gradient?.writeFile(to: NSPasteboard(name: .drag))
		} else {
			gradient?.writeFile(to: NSPasteboard(name: .dragPboard))
		}
		//[self dragStandardSwatchGradient:self.gradient slideBack:YES event:theEvent]
	}
	
	
	// MARK: -
	
	var controlMode: Mode = .display {
		didSet {
			if controlMode != oldValue {
				needsDisplay = true
			}
		}
	}
	
	// MARK: -

	@objc var displaysProxyIcon = false

	// MARK: -
	
	func setupTrackingRect() {
		//	LogEvent_(kStateEvent, @"setting tracking rect");
		if cell is GCSGradientCell {
			if trackingTag != 0 {
				removeTrackingRect(trackingTag)
			}
			
			let loc = convert(window?.mouseLocationOutsideOfEventStream ?? .zero, from: nil)
			let inside = hitTest(loc) === self
			
			if inside {
				window?.makeFirstResponder(self)
			}
			
			//NSRect fr = [self frame];
			//fr.origin = NSZeroPoint;

			trackingTag = addTrackingRect(visibleRect, owner: self, userData: nil, assumeInside: inside)
		}

	}
	
	// MARK: -
	
	var forceSquare = false
	
	// MARK: -
	
	var canBecomeActiveWell = true
	
	@objc(activeWell) var isActiveWell: Bool {
		@objc(isActiveWell) get {
			return GCSGradientWell.activeWell === self
		}
	}
	
	func wellDidBecomeActive() {
		needsDisplay = true
		// copy its gradient to the GP, if it has one
		if let gradient = self.gradient {
			let copyGrad = gradient.copy() as! DKGradient
			_=copyGrad
		} else {
			// should we do this?
			
			//[self setGradient:[[GCGradientPanel sharedGradientPanel] gradient]];
		}
		
		//[[GCGradientPanel sharedGradientPanel] show:self];
	}
	
	func wellWillResignActive() {
		// set our own gradient to a copy so as to fully detach it from the GP
		if let gradient = self.gradient {
			let copyGrad = gradient.copy() as! DKGradient
			self.gradient = copyGrad
		}
		
		needsDisplay = true
	}
	
	/// if already the active well, turn off all active wells, otherwise make it the active well
	func toggleActiveWell() {
		if isActiveWell {
			GCSGradientWell.clearAllActiveWells()
		} else {
			GCSGradientWell.activeWell = self
		}
	}
	
	// MARK: -

	@IBAction func cut(_ sender: Any?) {
		copy(sender)
		gradient = nil
	}
	
	@IBAction func copy(_ sender: Any?) {
		gradient?.write(to: NSPasteboard.general)
	}

	@IBAction func copyImage(_ sender: Any?) {
		let pboard = NSPasteboard.general
		if let grad = gradient {
			pboard.declareTypes([.pdf], owner: grad)
			grad.writeType(.pdf, to: pboard)
			grad.writeType(.tiff, to: pboard)
		}
	}
	
	@IBAction func copyBorderedImage(_ sender: Any?) {
		let pboard = NSPasteboard.general
		if let grad = gradient {
			pboard.declareTypes([.tiff], owner: grad)
			let image = grad.swatchImage(with: NSSize(width: 128, height: 128), withBorder: true)
			pboard.setData(image.tiffRepresentation, forType: .tiff)
		}
	}
	
	@IBAction func paste(_ sender: Any?) {
		gradient = DKGradient(pasteboard: NSPasteboard.general)
		
		if isActiveWell {
			// update GP with dropped gradient too
			
			//DKGradient *copyGrad = [self.gradient copy];
			//[[GCGradientPanel sharedGradientPanel] setGradient:copyGrad];
			//(void)copyGrad;
		}
	}
	
	@IBAction func delete(_ sender: Any?) {
		gradient = nil
		
		let cf = self.bounds
		var globalLoc = NSPoint(x: cf.midX, y: cf.midY)
		
		globalLoc = convert(globalLoc, to: nil)
		globalLoc = window!.convertToScreen(NSRect(origin: globalLoc, size: NSSize(width: 1, height: 1))).origin
		
		NSAnimationEffect.disappearingItemDefault.show(centeredAt: globalLoc, size: .zero)
	}
	
	@IBAction func resetRadial(_ sender: Any?) {
		if controlMode == .radial {
			gradient?.radialStartingPoint = NSPoint(x: 0.5, y: 0.5)
			gradient?.radialEndingPoint = NSPoint(x: 0.5, y: 0.5)
			gradient?.radialStartingRadius = 0
			gradient?.radialEndingRadius = 0.5
		} else if controlMode == .sweep {
			gradient?.radialStartingPoint = NSPoint(x: 0.5, y: 0.5)
		}
		syncGradientToControlSettings()
		needsDisplay = true
	}

	// MARK: - As an NSControl
	
	override class var cellClass: AnyClass? {
		get {
			return DKSGradientCell.self
		}
		set {
			// Do nothing
		}
	}
	
	// MARK: - As an NSView
	
	override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
		return true
	}
	
	override var isFlipped: Bool {
		return true
	}
	
	override func menu(for event: NSEvent) -> NSMenu? {
		let contextualMenu = NSMenu(title: "GradientWell")
		let allowsClear = canBecomeActiveWell && !(cell is GCSGradientCell)
		var item: NSMenuItem
		
		// add "Copy" and "Paste" command

		if allowsClear {
			item = contextualMenu.addItem(withTitle: NSLocalizedString("Cut", comment: ""), action: #selector(GCSGradientWell.cut(_:)), keyEquivalent: "")
			item.target = self
		}
		item = contextualMenu.addItem(withTitle: NSLocalizedString("Copy Gradient", comment: ""), action: #selector(GCSGradientWell.copy(_:)), keyEquivalent: "")
		item.target = self
		item = contextualMenu.addItem(withTitle: NSLocalizedString("Paste Gradient", comment: ""), action: #selector(GCSGradientWell.paste(_:)), keyEquivalent: "")
		item.target = self
		if allowsClear {
			item = contextualMenu.addItem(withTitle: NSLocalizedString("Delete", comment: ""), action: #selector(GCSGradientWell.delete(_:)), keyEquivalent: "")
			item.target = self
			contextualMenu.addItem(.separator())
		}
		
		item = contextualMenu.addItem(withTitle: NSLocalizedString("Copy Image", comment: ""), action: #selector(GCSGradientWell.copyImage(_:)), keyEquivalent: "")
		item.target = self
		
		item = contextualMenu.addItem(withTitle: NSLocalizedString("Copy Bordered Image", comment: ""), action: #selector(GCSGradientWell.copyBorderedImage(_:)), keyEquivalent: "")
		item.target = self
		item.isAlternate = true
		item.keyEquivalentModifierMask = .option
		
		if controlMode == .radial || controlMode == .sweep {
			contextualMenu.addItem(.separator())
			item = contextualMenu.addItem(withTitle: NSLocalizedString("Reset Radial Gradient", comment: ""), action: #selector(GCSGradientWell.resetRadial(_:)), keyEquivalent: "")
			item.target = self
		}
		
		return contextualMenu
	}

	override func resetCursorRects() {
		super.resetCursorRects()
		setupTrackingRect()
	}
	
	override var frame: NSRect {
		set {
			var newFrame = newValue
			if forceSquare, let superv = superview {
			// if forced to be square, the frame size will be set to be the maximum size
			// that will fit squarely in the superview. (the other dimension is centred).
			// !!!---this assumes that the superview is set up to do the right thing---!!!
				let ss = superv.frame.size
				
				var smaller = min(ss.width, ss.height)
				smaller -= 20
				newFrame.size.width = smaller
				newFrame.size.height = smaller
				
				smaller /= 2.0
				
				if frame.size.width < ss.width {
					newFrame.origin.x = (ss.width / 2.0) - smaller
				}
				
				if frame.size.height < ss.height {
					newFrame.origin.y = (ss.height / 2.0) - smaller
				}

			}
			super.frame = newFrame
			setupTrackingRect()
			superview?.needsDisplay = true
		}
		get {
			return super.frame
		}
	}
	
	override func viewDidMoveToWindow() {
		if window != nil {
			setupTrackingRect()
		}
		super.viewDidMoveToWindow()
	}
	
	// MARK: - As an NSResponder

	override func mouseEntered(with event: NSEvent) {
		//	LogEvent_(kReactiveEvent,  @"mouse went in..." );
		
		//[super mouseEntered:event];
		(cell as? GCSGradientCell)?.setControlVisible(true)
	}
	
	override func mouseExited(with event: NSEvent) {
		//	LogEvent_(kReactiveEvent,  @"...mouse went out" );
		
		(cell as? GCSGradientCell)?.setControlVisible(false)
		//[super mouseExited:event];
	}
	
	// MARK: - As an NSObject

	deinit {
		removeTrackingRect(trackingTag)
	}
	
	// MARK: - As part of NSDraggingDestination Protocol

	override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
		let sourceDragMask = sender.draggingSourceOperationMask()
		let pboard = sender.draggingPasteboard()
		
		if DKGradient.canInitalize(from: pboard) || pboard.types!.contains(.color) {
			if sourceDragMask.contains(.generic) {
				return .generic
			}
		}
		
		return []
	}
	
	func draggingSession(_ session: NSDraggingSession, sourceOperationMaskFor context: NSDraggingContext) -> NSDragOperation {
		
		return .generic
	}
	
	override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
		let pboard = sender.draggingPasteboard()

		if (sender.draggingSource() as AnyObject?) !== self {
			if DKGradient.canInitalize(from: pboard) {
				if let gradient = DKGradient(pasteboard: pboard) {
					self.gradient = gradient
				}
			} else if pboard.types!.contains(.color) {
				if let colour = NSColor(from: pboard), let grad = gradient?.colorizing(with: colour) {
					//	LogEvent_(kReactiveEvent, @"received colour drag, colourizing. %@", grad);

					gradient = grad
				}
			}
		}
		
		if let cell2 = cell as? GCSGradientCell {
			cell2.setControlVisible(true)
		} else if isActiveWell {
			// update GP with dropped gradient too
			
			//DKGradient *copyGrad = [self.gradient copy];
			//[[GCGradientPanel sharedGradientPanel] setGradient:copyGrad];
		}
		return true
	}
	
	// MARK: - As part of NSDraggingInfo Protocol
	override func namesOfPromisedFilesDropped(atDestination dropDestination: URL) -> [String]? {
		let fm = FileManager.default
		let path = fm.writeContents(gradient?.fileRepresentation, toUniqueFile: "untitled gradient.gradient", inDirectory: dropDestination.path)
		
		if let path = path {
			return [(path as NSString).lastPathComponent]
		} else {
			return nil
		}
	}
	
	// MARK: - As part of NSMenuValidation Protocol
	override func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
		var enable = gradient != nil
		let act = menuItem.action
		
		if act == #selector(GCSGradientWell.paste(_:)) {
			enable = NSPasteboard.general.availableType(from: [.gpGradient]) != nil
		}
		
		return enable
	}
	
	// MARK: - As part of NSNibAwaking Protocol
	override func awakeFromNib() {
		super.awakeFromNib()
		var newPBs = DKGradient.readablePasteboardTypes
		newPBs.append(.color)
		registerForDraggedTypes(newPBs)
	}
}
