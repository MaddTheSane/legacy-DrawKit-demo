//
//  GCSWindowMenu.swift
//  DrawDemoSwift
//
//  Created by C.W. Betts on 1/15/18.
//  Copyright © 2018 DrawKit. All rights reserved.
//

import Cocoa
import DKDrawKit.LogEvent

private var kDKDefaultWindowMenuSize: NSRect {
	return NSRect(x: 0, y: 0, width: 100, height: 28)
}

class GCSWindowMenu : NSWindow {
	/// Pops up a custom popup menu, tracks it, then hides it again with a fadeout.
	/// - parameter menu: The custom popup window to display.
	/// - parameter event: The event to start the display with (usually from a mouse down).
	/// - parameter view: The view doing the popping up.
	///
	/// The menu is positioned with its top, left point just to the left of, and slightly below, the
	/// point given in the event.
	class func popUpWindowMenu(_ menu: GCSWindowMenu?, with event: NSEvent, for view: NSView) {
		var loc = event.locationInWindow
		loc.x -= 10
		loc.y -= 5
		
		popUpWindowMenu(menu, at: loc, with: event, for: view)
	}
	
	/// Pops up a custom popup menu, tracks it, then hides it again with a fadeout.
	/// - parameter menu: The custom popup window to display.
	/// - parameter event: The event to start the display with (usually from a mouse down).
	/// - parameter view: The view doing the popping up.
	/// - parameter loc: The location within the view at which to display the menu (top, left of menu).
	///
	/// Pop up a window menu, and track it until the mouse goes up. Implements standard menu behaviour
	/// but uses a completely custom view. If `menu` is `nil`, creates a default window. `loc` is the point in window
	/// coordinates that `view` belongs to.
	class func popUpWindowMenu(_ menu: GCSWindowMenu?, at loc: NSPoint, with event: NSEvent, for view: NSView) {
		let menu1 = menu ?? GCSWindowMenu()
		
		let loc2 = view.window!.convertToScreen(NSRect(origin: loc, size: CGSize(width: 1, height: 1))).origin
		menu1.setFrameTopLeftPoint(loc2)
		
		// show the "menu"
		menu1.orderFront(self)
		
		// track the menu (keeps control in its own event loop):
		menu1.track(with: event)
		
		// all done, tear down
		
		let shift = NSApp.currentEvent?.modifierFlags.contains(.shift) ?? false

		menu1.fade(withTimeInterval: shift ? 1.5 : 0.15)
		
		LogEvent(.reactiveEvent, "pop-up complete")
	}
	
	// MARK: -
	
	/// Makes a window menu that can be popped up using the above methods.
	///
	/// This initializer just makes an empy window with the default size. It's up to you to add some useful
	/// content before displaying it
	convenience init() {
		self.init(contentRect: .zero, styleMask: [], backing: .buffered, defer: true)
		
		// note - because windows are all sent a -close message at quit time, set it
		// not to be released at that time, otherwise the release from the autorelease pool
		// will cause a crash due to the stale reference
		
		self.isReleasedWhenClosed = false // **** important!! ****
	}

	/// Makes a window menu that can be popped up using the above methods.
	/// - parameter view: the view to display within the menu.
	/// - returns: A new poppable window menu containing the given view.
	///
	/// The window is sized to fit the frame of the view you pass.
	convenience init(contentView view: NSView) {
		self.init()
		setMainView(view, sizeToFit: true)
	}
	
	// MARK: -

	/// Track the mouse in the menu.
	/// - parameter event: The initial starting event (will usually be a mouse down).
	///
	/// Tracking calls the main view's usual mouseDown/dragged/up methods, and tries to do so as compatibly
	/// as possible with the usual view behaviours.
	func track(with event: NSEvent) {
		// tracks the "menu" by keeping control until a mouse up (or down, if menu 'clicked' into being)
		LogEvent(.reactiveEvent, "starting tracking; initial event = \(event)");

		//[NSEvent startPeriodicEventsAfterDelay:1.0 withPeriod:0.1];

		let startTime = event.timestamp
		
		//[self setAcceptsMouseMovedEvents:YES];
		mainView?.mouseDown(with: transmogrify(event)!)
		
		var theEvent: NSEvent? = nil
		var keepOn = true
		var invertedTracking = false

		var mask: NSEvent.EventTypeMask = [.leftMouseUp, .leftMouseDragged,
										   .rightMouseUp, .rightMouseDragged,
										   .appKitDefined, .flagsChanged,
										   .scrollWheel]
		
		while keepOn {
			theEvent = transmogrify(nextEvent(matching: mask))
			
			guard let theEvent1 = theEvent else {
				continue
			}
			
			switch theEvent1.type {
				
			case .rightMouseDragged, .leftMouseDragged:
				mainView?.mouseDragged(with: theEvent1)
				
			case .rightMouseUp, .leftMouseUp:
				// if this is within a very short time of the mousedown, leave the menu up but track it
				// using mouse moved and mouse down to end.
				if theEvent1.timestamp - startTime < 0.25 {
					invertedTracking = true
					mask.insert([.leftMouseDown, .rightMouseDown])
				} else {
					mainView?.mouseUp(with: theEvent1)
					keepOn = false
				}
				
			case .rightMouseDown, .leftMouseDown:
				if !mainView!.frame.contains(theEvent1.locationInWindow) {
					keepOn = false
				} else {
					mainView?.mouseDown(with: theEvent1)
				}
				
			case .periodic:
				break
				
			case .flagsChanged:
				mainView?.flagsChanged(with: theEvent1)
				
			case .appKitDefined:
				//	LogEvent_(kReactiveEvent, @"appkit event: %@", theEvent);
				if theEvent1.subtype == NSEvent.EventSubtype.applicationDeactivated {
					keepOn = false
				}
				
			case .scrollWheel:
				mainView?.scrollWheel(with: theEvent1)
				
			default:
				/* Ignore any other kind of event. */
				break
			}
			
		}

		//[self setAcceptsMouseMovedEvents:NO];
		discardEvents(matching: .any, before: theEvent)

		//[NSEvent stopPeriodicEvents];
		LogEvent(.reactiveEvent, "ending tracking...")
	}
	
	// MARK: -

	/// Sets the pop-up window's content to the given view, and optionally sizes the window to fit.
	/// - parameter aView: Any view already created to be displayed in the menu.
	/// - parameter stf: If `true`, window is sized to the view's frame. If `false`, the window size is not changed.
	func setMainView(_ aView: NSView, sizeToFit stf: Bool) {
		mainView = aView
		
		// add as a subview which retains it as well

		contentView?.addSubview(aView)
		
		// if stf, position the view at top, left corner of the window and
		// make the window the size of the view

		if stf {
			var fr = aView.frame
			
			fr.origin = .zero
			aView.setFrameOrigin(.zero)
			self.setFrame(fr, display: true)
		}

		mainView?.needsDisplay = true
	}
	
	private(set) weak var mainView: NSView?
	
	// MARK: -

	// private stuff:

	/// Fades the window out.
	/// - parameter t: The total time to take to perform the fade out (0.15 is recommended as being close to a standard menu).
	///
	/// This is called by the main popup method as needed.
	private func fade(withTimeInterval t: TimeInterval) {
		// fades the window to invisible over <t> seconds. Used when the menu is closed.
		// retain ourselves so that the timer can run long after the window's owner has said goodbye.
		
		if isVisible {
			NSAnimationContext.runAnimationGroup({ (aniCtx) in
				aniCtx.duration = t
				self.animator().alphaValue = 0
			}, completionHandler: {
				self.orderOut(self)
			})
		}
	}
	
	/// convert the event to the local window if necessary.
	/// - parameter event: an event
	/// - returns: The same event, or a modified version.
	///
	/// Ensures that events received while tracking are always targetted at the right window.
	private func transmogrify(_ event: NSEvent?) -> NSEvent? {
		if let event = event, event.window !== self, event.isMouseEventType {
			let glob = event.window!.convertToScreen(NSRect(origin: event.locationInWindow, size: CGSize(width: 1, height: 1))).origin
			let glob2 = self.convertFromScreen(NSRect(origin: glob, size: CGSize(width: 1, height: 1))).origin
			
			return NSEvent.mouseEvent(with: event.type, location: glob2, modifierFlags: event.modifierFlags, timestamp: event.timestamp, windowNumber: self.windowNumber, context: NSGraphicsContext.current, eventNumber: event.eventNumber, clickCount: event.clickCount, pressure: event.pressure)
		} else {
			return event
		}
	}

	// MARK: - As an NSWindow
	
	override var canBecomeMain: Bool {
		return true
	}
	
	override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {
		super.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)
		
		level = .popUpMenu
		hasShadow = true
		alphaValue = 0.95
		isReleasedWhenClosed = true
		setFrame(kDKDefaultWindowMenuSize, display: false)
	}
}

extension NSEvent {
	/// Checks event to see if it's a mouse event.
	/// Is `true` if the event is a mouse event of any kind.
	fileprivate var isMouseEventType: Bool {
		get {
			let t = self.type
			
			return (t == .leftMouseDown ||
				t == .leftMouseUp ||
				t == .rightMouseDown ||
				t == .rightMouseUp ||
				t == .leftMouseDragged ||
				t == .rightMouseDragged ||
				t == .otherMouseDown ||
				t == .otherMouseUp ||
				t == .otherMouseDragged)
		}
	}
}
