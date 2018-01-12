//
//  AppDelegate.swift
//  DrawDemoSwift
//
//  Created by C.W. Betts on 12/14/17.
//  Copyright © 2017 DrawKit. All rights reserved.
//

import Cocoa
import DKDrawKit.LogEvent

let defaultQualityModulationFlag = "GCDrawDemo_defaultQualityModulationFlag"

@NSApplicationMain
final class AppDelegate: NSObject, NSApplicationDelegate {
	@IBOutlet weak var userToolMenu: NSMenu!
	private var styleInspector: GCSStyleInspector?
	private var toolPalette: GCSToolPalette?
	private var objectInspector: GCSObjectInspector?
	private var layersController: GCSLayersPaletteController?
	private var styleManager: GCSStyleManagerDialog?
	private var prefsController: GCSDrawDemoPrefsController?

	@IBAction func showStyleInspector(_ sender: Any?) {
		if let styleVis = styleInspector?.window?.isVisible, styleVis {
			styleInspector?.window?.orderOut(self)
		} else {
			openStyleInspector()
		}
	}
	
	@IBAction func showToolPalette(_ sender: Any?) {
		if let styleVis = toolPalette?.window?.isVisible, styleVis {
			toolPalette?.window?.orderOut(self)
		} else {
			openToolPalette()
		}
	}

	@IBAction func showObjectInspector(_ sender: Any?) {
		if let styleVis = objectInspector?.window?.isVisible, styleVis {
			objectInspector?.window?.orderOut(self)
		} else {
			openObjectInspector()
		}
	}

	@IBAction func showLayersPalette(_ sender: Any?) {
		if layersController == nil {
			layersController = GCSLayersPaletteController(windowNibName: NSNib.Name(rawValue: "LayersPalette"))
		}
		
		layersController!.showWindow(self)
	}

	@IBAction func showStyleManagerDialog(_ sender: Any?) {
		if styleManager == nil {
			styleManager = GCSStyleManagerDialog(windowNibName: NSNib.Name(rawValue: "StyleManager"))
		}
		
		styleManager!.showWindow(self)
	}

	@IBAction func openPreferences(_ sender: Any?) {
		if prefsController == nil {
			prefsController = GCSDrawDemoPrefsController(windowNibName: NSNib.Name(rawValue: "Preferences"))
		}
		
		prefsController!.showWindow(self)
	}

	// MARK: -
	
	@IBAction func temporaryPrivateChangeFontAction(_ sender: Any?) {
		// this works around a lack of a setTarget: method in NSFontManger prior to 10.5 - it traps the changeFont
		// message from the Font Manager on behalf of the style inspector and redirects it there. This is the recommended
		// approach for 10.4 as advised by an Apple engineer - it has the advantage of not requiring the ugly hack that
		// was in DK previously, which has been removed.
		
		// note that the onus is on the style inspector to set this action and reset it correctly when appropriate.

		styleInspector?.textChangeFontAction(sender as! NSFontManager)
	}

	@IBAction func changeAttributes(_ sender: Any?) {
		styleInspector?.changeTextAttributes(sender as! NSFontManager)
	}

	func openStyleInspector() {
		if styleInspector == nil {
			styleInspector = GCSStyleInspector(windowNibName: NSNib.Name(rawValue: "StyleInspector"))
		}
		
		styleInspector!.showWindow(self)
	}
	
	@objc(drawingToolRegistrationNote:)
	func drawingToolRegistration(note: Notification) {
		// a new tool was registered. Add it to the tool menu if it's not known already.
		let names = DKToolRegistry.shared.toolNames
		
		guard let menu = userToolMenu, menu.numberOfItems > 0 else {
			return
		}
		
		menu.removeAllItems()
		
		for name in names {
			let tool = DKToolRegistry.shared.drawingTool(withName: name)
			let item = menu.addItem(withTitle: name.rawValue, action: #selector(DKToolController.selectDrawingToolByName(_:)), keyEquivalent: "")
			item.target = nil
			
			//if( tool && [tool respondsToSelector:@selector(image)])
			//	[item setImage:[tool image]];
			_=tool
		}
	}
	
	func openToolPalette() {
		if toolPalette == nil {
			toolPalette = GCSToolPalette(windowNibName: NSNib.Name(rawValue: "ToolPalette"))
		}
		
		toolPalette!.showWindow(self)
	}

	func openObjectInspector() {
		if objectInspector == nil {
			objectInspector = GCSObjectInspector(windowNibName: NSNib.Name(rawValue: "ObjectInspector"))
		}
		
		objectInspector?.showWindow(self)
	}
	
	func applicationDidFinishLaunching(_ aNotification: Notification) {
		if (getenv("NSZombieEnabled") != nil) || (getenv("NSAutoreleaseFreedObjectCheckEnabled") != nil) {
			NSLog("NSZombieEnabled/NSAutoreleaseFreedObjectCheckEnabled enabled!")
		}
		
		NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.drawingToolRegistration(note:)), name: .dkDrawingToolWasRegistered, object: nil)
		NSColorPanel.shared.showsAlpha = true
		
		showStyleInspector(self)
		showToolPalette(self)
		showLayersPalette(self)

		LogEvent(.infoEvent, "app finished launching")
	}
	
	func applicationWillFinishLaunching(_ aNotification: Notification) {
		let qm = UserDefaults.standard.bool(forKey: defaultQualityModulationFlag)
		DrawDemoDocument.defaultQualityModulation = qm
	}
	
	func applicationWillTerminate(_ aNotification: Notification) {
		LogEvent(.infoEvent, "app quitting...")
		
		UserDefaults.standard.set(DrawDemoDocument.defaultQualityModulation, forKey: defaultQualityModulationFlag)
	}
	
	@IBAction func showAboutBox(_ sender: Any?) {
		if let isOptionKeyDown = NSApp.currentEvent?.modifierFlags.contains(.option), isOptionKeyDown {
			LoggingController.shared.showLoggingWindow()
		} else {
			NSApp.orderFrontStandardAboutPanel(sender)
		}
	}
}

