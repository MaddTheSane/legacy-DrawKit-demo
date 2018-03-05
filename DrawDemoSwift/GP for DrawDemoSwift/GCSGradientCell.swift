//
//  GCSGradientCell.swift
//  DrawDemoSwift
//
//  Created by C.W. Betts on 12/19/17.
//  Copyright © 2017 DrawKit. All rights reserved.
//

import Cocoa
import DKDrawKit.DKGradientExtensions


// MARK: Contants (Non-localized)
// private IDs locate mini controls within the cell

private let kLinearAngleControlID = "kLinearAngleControlID";
private let kRadialStartControlID = "kRadialStartControlID";
private let kRadialEndControlID = "kRadialEndControlID";
private let kSweepCentreControlID = "kSweepCentreControlID";
private let kSweepSegmentsControlID = "kSweepSegmentsControlID";
private let kSweepAngleControlID = "kSweepAngleControlID";

// clusters:

private let kLinearControlsClusterID = "kLinearControlsClusterID";
private let kRadialControlsClusterID = "kRadialControlsClusterID";
private let kSweepControlsClusterID = "kSweepControlsClusterID";

// MARK: Static Vars
private var sMFlags: UInt = 0

final class GCSGradientCell: DKSGradientCell, GCMiniControlDelegate {
	/// internal "partcodes" for where a mouse hit occurred
	enum HitPart: Int {
		case none = 0
		case miniControl = 5
		case proxyIcon = 7
		case other = 999
	}
	var controlBoundsRect = NSRect.zero
	var miniControls: GCMiniControlCluster?
	var updatingControls = false
	private var hitPart = HitPart.none

	// MARK: As a GCGradientCell
	
	/// the mini controls are stored in a series of hierarchical clusters. The top level is basically just used as a
	/// container for the lower level clusters. Each subcluster contains a group of mini controls, one for each of the
	/// gradient modes/types.
	func setupMiniControls() {
		guard let mMiniControls = GCMiniControlCluster(bounds: .zero, in: nil) else {
			fatalError()
		}
		miniControls = mMiniControls
		mMiniControls.delegate = self
		mMiniControls.forceVisible(false)
	
		var mcc: GCMiniControlCluster?
		var mini: GCMiniControl?
		
		// first contains circular slider for linear gradient angle
		mcc = GCMiniControlCluster(bounds: .zero, in: mMiniControls)
		mcc?.identifier = kLinearControlsClusterID
		
		mini = GCMiniCircularSlider(bounds: .zero, in: mcc)
		mini?.identifier = kLinearAngleControlID
		
		// second has twin radial controls

		mcc = GCMiniControlCluster(bounds: .zero, in: mMiniControls)
		mcc?.identifier = kRadialControlsClusterID
		
		// allow shift key to move both minicontrols together:

		mcc?.setLinkControlPart(kDKRadial2HitIris, modifierKeyMask: .shift)
		
		mini = GCMiniRadialControl2(bounds: .zero, in: mcc)
		mini?.identifier = kRadialEndControlID
		
		mini = GCMiniRadialControl2(bounds: .zero, in: mcc)
		mini?.identifier = kRadialStartControlID

		// third has circular slider + single radial control + straight slider
		// n.b. order is important as controls overlap. hit testing is done in reverse order to
		// that here, which is the drawing order.

		mcc = GCMiniControlCluster(bounds: .zero, in: mMiniControls)
		mcc?.identifier = kSweepControlsClusterID
		
		mini = GCMiniCircularSlider(bounds: .zero, in: mcc)
		mini?.identifier = kSweepAngleControlID
		
		mini = GCMiniSlider(bounds: .zero, in: mcc)
		mini?.identifier = kSweepSegmentsControlID
		mini?.setInfoWindowMode(.miniControlInfoWindowCentred)
		mini?.setInfoWindowFormat("0")
		
		mini = GCMiniRadialControls(bounds: .zero, in: mcc)
		mini?.identifier = kSweepCentreControlID
	}
	
	func setControlledAttribute(from ctrl: GCMiniControl) {
		let ident = ctrl.identifier!
		
		switch ident {
		case kLinearAngleControlID, kSweepAngleControlID:
			gradient?.angle = ctrl.value
			
		case kSweepSegmentsControlID:
			var seg = Int(floor(ctrl.value * 50))
			
			if seg < 4 {
				seg = 0
			}
			
			//[[self gradient] setNumberOfAngularSegments:seg];

		case kRadialStartControlID, kSweepCentreControlID:
			let rc = ctrl as! GCMiniRadialControls
			
			LogEvent(.stateEvent, "setting starting radius: \(rc.radius)")

			if let grad = gradient {
				let p = grad.mapPoint(rc.centre, from: controlBoundsRect)
				grad.radialStartingPoint = p
				grad.radialStartingRadius = rc.radius / controlBoundsRect.size.width
			}
			
		case kRadialEndControlID:
			let rc = ctrl as! GCMiniRadialControls
			
			LogEvent(.stateEvent, "setting ending radius: \(rc.radius)")

			if let grad = gradient {
				let p = grad.mapPoint(rc.centre, from: controlBoundsRect)
				grad.radialEndingPoint = p
				grad.radialEndingRadius = rc.radius / controlBoundsRect.size.width
			}
			
		default:
			break
		}
	}
	
	// MARK: -
	
	/// sets up the mini controls' bounds from the cellFrame. Each one is individually calculated as appropriate. Note
	/// that some types, notably the circular slider, position themselves centrally in their bounds so this method need
	/// not bother with that.
	func setMiniControlBounds(cellFrame cellframe: NSRect, for mode: GCSGradientWell.Mode) {
		let cframe = cellframe.insetBy(dx: 20, dy: 20)
		miniControls?.view = self.controlView
		
		// linear:

		switch mode {
		case .angle:
			setMiniControlBounds(cframe, identifier: kLinearAngleControlID)
			
		case .radial:
			// radial controls likewise just need the entire frame:

			setMiniControlBounds(cellframe, identifier: kRadialStartControlID)
			setMiniControlBounds(cellframe, identifier: kRadialStartControlID)

		case .sweep:
			// sweep controls:

			setMiniControlBounds(cframe, identifier: kSweepAngleControlID)
			setMiniControlBounds(cellframe, identifier: kSweepCentreControlID)

			// only the segment slider has a complex bounds calc:

			var sr = cframe.insetBy(dx: 40, dy: 50)
			sr.size.height = 12
			sr.origin.y = cframe.origin.y + (cframe.size.height * 0.63)
			
			setMiniControlBounds(sr, identifier: kSweepSegmentsControlID)
			
		default:
			break
		}
	}
	
	/// Sets the mini control with `key` identifier to have the bounds `br`
	func setMiniControlBounds(_ br: NSRect, identifier key: String) {
		if let mc = miniControls?.control(forKey: key) {
			mc.bounds = br
		}
	}
	
	/// given the mode which is set by the owning GCGradientWell, this draws the controls in the appropriate cluster.
	func drawMiniControls(for mode: GCSGradientWell.Mode) {
		controlCluster(for: mode)?.draw()
	}
	
	func controlCluster(for mode: GCSGradientWell.Mode) -> GCMiniControlCluster? {
		switch mode {
		case .angle:
			return miniControls?.control(forKey: kLinearControlsClusterID) as? GCMiniControlCluster
			
		case .radial:
			return miniControls?.control(forKey: kRadialControlsClusterID) as? GCMiniControlCluster

		case .sweep:
			return miniControls?.control(forKey: kSweepControlsClusterID) as? GCMiniControlCluster

		default:
			return nil
		}
	}
	
	func miniControl(forIdentifier key: String) -> GCMiniControl? {
		return miniControls?.control(forKey: key)
	}
	
	/// sets the minicontrol values in `mode` cluster to match the current gradient
	func updateMiniControls(for mode: GCSGradientWell.Mode) {
		updatingControls = true
		
		switch mode {
		case .angle:
			if let gradAngle = gradient?.angle {
				miniControl(forIdentifier: kLinearAngleControlID)?.value = gradAngle
			}
			
		case .radial:
			LogEvent(.stateEvent, "setting up radial controls")
			guard var rc = miniControls?.control(forKey: kRadialStartControlID) as? GCMiniRadialControl2,
			let gradient = self.gradient else {
				break
			}
			
			rc.setRingRadiusScale(0.85)
			rc.centre = gradient.mapPoint(gradient.radialStartingPoint, to: controlBoundsRect)
			rc.radius = gradient.radialStartingRadius * controlBoundsRect.size.width
			rc.tabColor = gradient.color(atValue: 0)
			
			rc = miniControls!.control(forKey: kRadialEndControlID) as! GCMiniRadialControl2
			
			rc.centre = gradient.mapPoint(gradient.radialEndingPoint, to: controlBoundsRect)
			rc.radius = gradient.radialEndingRadius * controlBoundsRect.size.width
			rc.tabColor = gradient.color(atValue: 1)
			
		case .sweep:
			// sweep controls:

			guard let rc = miniControls?.control(forKey: kSweepCentreControlID) as? GCMiniRadialControls,
			let gradient = self.gradient else {
				break
			}
			rc.centre = gradient.mapPoint(gradient.radialStartingPoint, to: controlBoundsRect)
			
			let seg = 100 //[[self gradient] numberOfAngularSegments];
			var v = CGFloat(seg) / 50.0
			
			if seg < 4 {
				v = 0
			}
			
			miniControl(forIdentifier: kSweepSegmentsControlID)?.value = v
			miniControl(forIdentifier: kSweepAngleControlID)?.value = gradient.angle
			
		default:
			break
		}
		
		updatingControls = false
	}
	
	// MARK: -
	func proxyIconRect(inCellFrame rect:NSRect) -> NSRect {
		let br = rect.insetBy(dx: 8, dy: 9)
		let ficon = NSImage(named: NSImage.Name(rawValue: "fileiconsmall"))
		var ir = NSRect()

		if let ficon = ficon {
			ir.size = ficon.size
		}
		ir.origin.x = br.maxX - ir.size.width
		ir.origin.y = br.maxY - ir.size.height
		
		return ir
	}
	
	// MARK: -
	@objc func setControlVisible(_ vis: Bool) {
		miniControls?.visible = vis
		controlView?.needsDisplay = true
	}
	
	// MARK: - As an DKSGradientCell

	override func drawInterior(withFrame cellFrame: NSRect, in controlView: NSView) {
		if gradient != nil {
			super.drawInterior(withFrame: cellFrame, in: controlView)
			
			controlBoundsRect = cellFrame
			
			if let control = self.controlView as? GCSGradientWell {
				control.setupTrackingRect()
			
				//[self setMiniControlBoundsWithCellFrame:cellFrame forMode:[control controlMode]]
				updateMiniControls(for: control.controlMode)
				
				NSBezierPath.clip(cellFrame.insetBy(dx: 8, dy: 8))
				drawMiniControls(for: control.controlMode)
				
				// if proxy icon flag set, draw it

				if control.displaysProxyIcon,
					let ficon = NSImage(named: NSImage.Name(rawValue: "fileiconsmall")) {
					ficon.draw(in: proxyIconRect(inCellFrame: cellFrame), from: .zero, operation: .sourceAtop, fraction: 0.8)
				}
			}
		}
	}
	
	// MARK: - As an NSCell
	
	override func continueTracking(last lastPoint: NSPoint, current currentPoint: NSPoint, in controlView: NSView) -> Bool {
		if let cv = controlView as? GCSGradientWell,
			hitPart == .miniControl {
			let cmode = cv.controlMode
			let cc = controlCluster(for: cmode)
			
			return cc?.mouseDragged(at: currentPoint, inPart: GCControlHitTest(0), modifierFlags: NSEvent.ModifierFlags(rawValue: UInt(mouseDownFlags))) ?? false
		}
		return false
	}
	
	override var mouseDownFlags: Int {
		return Int(sMFlags)
	}
	
	override func startTracking(at startPoint: NSPoint, in controlView: NSView) -> Bool {
		LogEvent(.reactiveEvent, "cell starting tracking...");
		
		hitPart = .other
		
		guard let cv = controlView as? GCSGradientWell else {
			return true
		}
		// hit in proxy icon?

		if cv.displaysProxyIcon {
			let ir = proxyIconRect(inCellFrame: controlBoundsRect)
			
			if ir.contains(startPoint) {
				hitPart = .proxyIcon
				return true
			}
		}
		
		let cmode = cv.controlMode
		if let cc = controlCluster(for: cmode), cc.mouseDown(at: startPoint, inPart: 0, modifierFlags: NSEvent.ModifierFlags(rawValue: UInt(mouseDownFlags))) {
			hitPart = .miniControl // for any mini-control
		}
		return true
	}
	
	override func stopTracking(last lastPoint: NSPoint, current stopPoint: NSPoint, in controlView: NSView, mouseIsUp flag: Bool) {
		if let cv = controlView as? GCSGradientWell, hitPart == .miniControl {
			let cmode = cv.controlMode
			let cc = controlCluster(for: cmode)
			
			cc?.mouseUp(at: stopPoint, inPart: 0, modifierFlags: NSEvent.ModifierFlags(rawValue: UInt(mouseDownFlags)))
		}
	}
	
	override func trackMouse(with theEvent: NSEvent, in cellFrame: NSRect, of controlView: NSView, untilMouseUp flag: Bool) -> Bool {
		let p = controlView.convert(theEvent.locationInWindow, from: nil)
		sMFlags = theEvent.modifierFlags.rawValue
		miniControls?.flagsChanged(NSEvent.ModifierFlags(rawValue: sMFlags))
		
		if startTracking(at: p, in: controlView) {
			var event: NSEvent?
			var loop = true
			var currentPoint: NSPoint
			
			enableCache = false
			let mask: NSEvent.EventTypeMask = [.leftMouseUp, .leftMouseDragged, .flagsChanged]
			var lastPoint = p
			
			while loop {
				event = controlView.window?.nextEvent(matching: mask)
				guard let event2 = event else {
					continue
				}
				
				currentPoint = controlView.convert(event2.locationInWindow, from: nil)
				sMFlags = event2.modifierFlags.rawValue
				
				switch event2.type {
				case .leftMouseUp:
					stopTracking(last: lastPoint, current: currentPoint, in: controlView, mouseIsUp: true)
					loop = false
					
				case .leftMouseDragged:
					loop = continueTracking(last: lastPoint, current: currentPoint, in: controlView)

					if !loop {
						stopTracking(last: lastPoint, current: currentPoint, in: controlView, mouseIsUp: false)
						if hitPart == .other {
							miniControls?.visible = false
							(controlView as? DKSGradientDragging)?.initiateGradientDrag(with: theEvent)
						}
					}
					
				case .flagsChanged:
					miniControls?.flagsChanged(event2.modifierFlags)
					
				default:
					break
				}
				
				lastPoint = currentPoint
			}
			
			controlView.window?.discardEvents(matching: mask, before: event)
			hitPart = .none
			enableCache = true
			miniControls?.flagsChanged([])
		}
		
		LogEvent(.reactiveEvent, "cell ended tracking");
		
		return true
	}
	
	// MARK: - As an NSObject
	
	override init() {
		super.init()
		setupMiniControls()
	}
	
	required init(coder: NSCoder) {
		super.init(coder: coder)
		setupMiniControls()
	}
	
	
	// MARK: - As a GCMiniControl delegate
	
	/// delegate method called for a change in any mini-control value. route the result to the appropriate
	/// setting. Note - no need to call for redisplay, that has been done.
	func miniControl(_ mc: GCMiniControl!, didChangeValue newValue: Any!) {
		if !updatingControls {
			LogEvent(.infoEvent, "miniControl ‘\(mc.identifier)’ didChangeValue ‘\(newValue)’")
			
			setControlledAttribute(from: mc)

			if let control = self.controlView as? GCSGradientWell {
				control.syncGradientToControlSettings()
			}
		}
	}
	
	func miniControlWillUpdateInfoWindow(_ mc: GCMiniControl!, withValue val: CGFloat) -> CGFloat {
		if mc.identifier == kSweepSegmentsControlID {
			var seg = mc.value * 50
			if seg < 4 {
				seg = 0
			}
			
			return seg
		} else {
			return val
		}
	}
}
