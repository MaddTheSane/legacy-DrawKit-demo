//
//  GCSToolPalette.swift
//  DrawDemoSwift
//
//  Created by C.W. Betts on 12/18/17.
//  Copyright © 2017 DrawKit. All rights reserved.
//

import Cocoa
import DKDrawKit.DKDrawkitInspectorBase
import DKDrawKit.DKStyle

class GCSToolPalette: DKDrawkitInspectorBase {
	@IBOutlet weak var toolMatrix: NSMatrix!
	@IBOutlet weak var stylePopUpButton: NSPopUpButton!
	@IBOutlet weak var stylePreviewView: NSImageView!
	
	@IBAction func toolButtonMatrixAction(_ sender: NSMatrix?) {
		if let cell = sender?.selectedCell() {
			LogEvent(.infoEvent, "cell = \(cell), title = \(cell.title)")
			
			// forward the choice to the first responder - if it implements selectDrawingTool: it will switch tools based
			// on the sender of the message's title matching the registered name of the tool.

			//[NSApp sendAction:@selector(selectDrawingToolByName:) to:nil from:cell];
			
			// another way is to call the -set method on the tool itself:

			let tool = cell.representedObject as? DKDrawingTool
			tool?.set()
		}
	}
	
	@IBAction func libraryItemAction(_ sender: Any?) {
		// sets the style of the selected tool's prototype to the chosen style. Subsequent drawing with that tool
		// will use the given style.
		guard let key = ((sender as AnyObject?)?.representedObject as AnyObject?)?.uniqueKey,
			let ss = DKStyleRegistry.styleForKeyAdding(toRecentlyUsed: key) else {
				return
		}
		DKObjectCreationTool.styleForCreatedObjects = ss
		guard let toolname = toolMatrix.selectedCell()?.title,
			let tool = DKToolRegistry.shared.drawingTool(withName: DKToolName(toolname)) else {
				return
		}
		selectTool(withName: tool.registeredName)
	}
	
	@IBAction func toolDoubleClick(_ sender: Any?) {
		// double-clicking a tool turns OFF "auto return to selection". It is turned back on again
		// by manually selecting the selection tool. See DKToolController for details
		
		//	LogEvent_(kInfoEvent, @"dbl-clik tool: %@", sender );

		if let toolname = (sender as AnyObject?)?.selectedCell()?.title {
			if toolname == "Zoom" {
				// return to 100% zoom
				NSApp.sendAction(#selector(GCZoomView.zoomToActualSize(_:)), to: nil, from: sender)
			} else {
				NSApp.sendAction(#selector(DKToolController.toggleAutoRevertAction(_:)), to: nil, from: sender)
			}
		}
	}

	open func selectTool(withName name: DKToolName) {
		var row = 0
		var col = 0
		var style = DKObjectCreationTool.styleForCreatedObjects
		
		toolMatrix.getNumberOfRows(&row, columns: &col)
		
		for rr in 0 ..< row {
			for cc in 0 ..< col {
				let cell = toolMatrix.cell(atRow: rr, column: cc)
				if cell?.title == name.rawValue {
					toolMatrix.selectCell(atRow: rr, column: cc)
					
					// set the preview image to the tool prototype's style, if any
					
					let tool = DKToolRegistry.shared.drawingTool(withName: name)
					
					if let tool = tool as? DKObjectCreationTool {
						if style == nil {
							style = (tool.prototype as? DKDrawableObject)?.style
						}
					}
					
					updateStylePreview(with: style)
					return
				}
			}
		}
		
		toolMatrix.selectCell(atRow: 0, column: 0)
		updateStylePreview(with: style)
	}
	
	@objc open func toolChangedNotification(_ note: Notification) {
		let tc = note.object as? DKToolController
		var tn = tc?.drawingTool.registeredName
		
		LogEvent(.reactiveEvent, "tool did change to \(tn?.rawValue ?? "(nil)")");
		
		if tn == nil {
			tn = DKToolName.standardSelectionToolName
		}
		
		selectTool(withName: tn!)
	}
	
	open func populatePopUpButton(withLibraryStyles button: NSPopUpButton) {
		let styleMenu = DKStyleRegistry.managedStylesMenu(withItemTarget: self, itemAction: #selector(GCSToolPalette.libraryItemAction(_:)))
		button.menu = styleMenu
		button.title = "Style"
	}
	
	open func updateStylePreview(with style: DKStyle?) {
		if let style = style,
			let swatch = style.styleSwatch(with: NSSize(width: 112, height: 112), type: .automatic).copy() as? NSImage {
			stylePreviewView.image = swatch
		}
	}
	
	@objc open func styleRegistryChanged(_ note: Notification) {
		populatePopUpButton(withLibraryStyles: stylePopUpButton)
	}
	
	// MARK: - As an DKDrawkitInspectorBase
	
	override func documentDidChange(_ note: Notification!) {
		if let firstRE = (note.object as AnyObject?)?.firstResponder, let firstR = firstRE,
			let tool2 = (firstR as AnyObject?)?.drawingTool, let tool = tool2 {
			var tn = tool.registeredName
			
			LogEvent(.reactiveEvent, "tool will change to '\(tn?.rawValue ?? "(nil)")'");

			if tn == nil {
				tn = DKToolName.standardSelectionToolName
			}
			
			selectTool(withName: tn!)
		}
	}
	
	// MARK: - As an NSWindowController
	
	override func windowDidLoad() {
		super.windowDidLoad()
		if let panel = self.window as? NSPanel {
			panel.isFloatingPanel = true
			panel.becomesKeyOnlyIfNeeded = true
		}
		
		NotificationCenter.default.addObserver(self, selector: #selector(GCSToolPalette.toolChangedNotification(_:)), name: .dkDidChangeTool, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(GCSToolPalette.styleRegistryChanged(_:)), name: .dkStyleRegistryDidFlagPossibleUIChange, object: nil)
		
		// set up button cells with the respective images - the cell title is used to look up the image resource

		for cell in toolMatrix.cells {
			if let icon = NSImage(named: NSImage.Name(rawValue: cell.title)) {
				cell.image = icon
			}
			
			if cell.title.count == 0 {
				cell.isEnabled = false
			} else {
				let tool = DKToolRegistry.shared.drawingTool(withName: DKToolName(rawValue: cell.title))
				cell.representedObject = tool
				toolMatrix.setToolTip(cell.title, for: cell)
			}
		}
		
		populatePopUpButton(withLibraryStyles: stylePopUpButton)
		toolMatrix.doubleAction = #selector(GCSToolPalette.toolDoubleClick(_:))
		
		// position the palette on the left of the main screen

		var panelFrame = window!.frame
		let screenFrame = NSScreen.screens.first!.visibleFrame
		
		panelFrame.origin.x = screenFrame.minX + 34
		panelFrame.origin.y = screenFrame.height - 20 - panelFrame.height
		window?.setFrameOrigin(panelFrame.origin)
	}
	
	override func validateMenuItem(_ item: NSMenuItem) -> Bool {
		let action = item.action
		
		if action == #selector(GCSToolPalette.libraryItemAction(_:)) {
			item.state = DKObjectCreationTool.styleForCreatedObjects === (item.representedObject as AnyObject?) ? .on : .off
		}
		
		return true
	}
}
