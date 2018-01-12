//
//  GCSLayersPaletteController.swift
//  DrawDemoSwift
//
//  Created by C.W. Betts on 1/10/18.
//  Copyright © 2018 DrawKit. All rights reserved.
//

import Cocoa
import DKDrawKit
import DKDrawKit.DKDrawing
import DKDrawKit.DKObjectDrawingLayer
import DKDrawKit.DKViewController
import DKDrawKit.DKDrawingView
import DKDrawKit.LogEvent
import DKDrawKit.DKDrawkitInspectorBase

private let selectionColourInterfaceIdentifier = NSUserInterfaceItemIdentifier("selectionColour")

class GCSLayersPaletteController : DKDrawkitInspectorBase, GCSColourCellHack {
	@IBOutlet weak var layersTable: NSTableView!
	@IBOutlet weak var autoActivateCheckbox: NSButton!
	private var temporaryColour: NSColor?
	private var temporaryColourRow: Int = 0

	@objc var drawing: DKDrawing? {
		get {
			return currentDrawing
		}
		set {
			LogEvent(.reactiveEvent, "layers palette setting drawing = \(newValue?.description ?? "<nil>")")
			
			layersTable.reloadData()
			if let drawing = newValue {
				let row = drawing.index(of: drawing.activeLayer!)
				
				LogEvent(.reactiveEvent, "index of active layer = \(row)")

				layersTable.selectRowIndexes(IndexSet(integer: row), byExtendingSelection: true)
				layersTable.scrollRowToVisible(row)
			}
		}
	}
	
	@IBAction func addLayerButtonAction(_ sender: Any?) {
		let layer = DKObjectDrawingLayer()!
		drawing?.addLayer(layer, andActivateIt: true)
		
		let action = "\(NSLocalizedString("Add Layer", comment: "")) “\(layer.layerName)”"
		
		(drawing?.undoManager as AnyObject?)?.setActionName(action)
	}
	
	@IBAction func removeLayerButtonAction(_ sender: Any?) {
		guard let active = drawing?.activeLayer else {
			NSSound.beep()
			return
		}
		
		let action = "\(NSLocalizedString("Delete Layer", comment: "")) “\(active.layerName)”"
		drawing?.removeLayer(active, andActivate: nil)
		
		(drawing?.undoManager as AnyObject?)?.setActionName(action)
	}
	
	@IBAction func autoActivationAction(_ sender: Any?) {
		if let vc = currentMainViewController {
			vc.activatesLayersAutomatically = ((sender as AnyObject?)?.integerValue ?? 0) != 0
		}
	}

	// MARK: -
	@objc private func drawingDidReorderLayersNotification(_ note: Notification) {
		let drawing = self.drawing
		_=drawing	// Call me paranoid, but I don't want this code to be optimized out.
		self.drawing = drawing
	}

	func setTemporaryColour(_ aColour: NSColor?, for tView: NSTableView, row: Int) {
		// this is a bit of a hack to make the selection colour cells in the table update live as the menu is tracked, but without
		// updating the actual selection colour, which can be very expensive if there are many selected objects. This is called
		// to set the temporary colour and the objectValue... method will return this for the given row if set.
		
		//NSLog(@"setting temp colour: %@, row = %d", [aColour stringValue], row);

		temporaryColour = aColour;
		temporaryColourRow = row;
	}

	// MARK: - As a DKDrawkitInspectorBase
	override func redisplayContent(forSelection selection: [DKDrawableObject]?) {
		self.drawing = self.currentDrawing
	}
	
	override func documentDidChange(_ note: Notification) {
		LogEvent(.reactiveEvent, "layers palette got document change, main = \(String(describing: note.object))")
		
		if note.name == NSWindow.didResignMainNotification {
			// delay here to ensure that the document/drawing has really gone for reloading the table
			perform(#selector(setter: GCSLayersPaletteController.drawing), with: nil, afterDelay: 0.2)
		} else {
			let drawing = self.drawing(forTargetWindow: (note.object as! NSWindow))
			
			self.drawing = drawing
			window?.title = "\((note.object as AnyObject?)?.title ?? "") - Layers"
			
			// see if the window contains a DKDrawingView and controller

			var view = (note.object as AnyObject?)?.firstResponder
			
			// if view is nil try initial first responder
			if view == nil {
				view = (note.object as AnyObject?)?.initialFirstResponder
			}
			
			if let view2 = view, let view3 = view2 as? DKDrawingView {
				let vc = view3.controller
				autoActivateCheckbox.state = (vc?.activatesLayersAutomatically ?? false) ? .on : .off
			}
		}
	}
	
	// MARK: - As an NSWindowController
	
	override func windowDidLoad() {
		super.windowDidLoad()
		(window as! NSPanel).isFloatingPanel = true
		(window as! NSPanel).becomesKeyOnlyIfNeeded = true
		
		layersTable.allowsEmptySelection = true
		
		// set the cell type of the colours column to GCColourCell

		let cc = GCSColourCell()
		layersTable.tableColumn(withIdentifier: selectionColourInterfaceIdentifier)?.dataCell = cc
		
		// subscribe to active layer notifications so the table can be kept in synch

		NotificationCenter.default.addObserver(self, selector: #selector(GCSLayersPaletteController.drawingDidReorderLayersNotification(_:)), name: .dkLayerGroupDidReorderLayers, object: self.drawing)
		NotificationCenter.default.addObserver(self, selector: #selector(GCSLayersPaletteController.drawingDidReorderLayersNotification(_:)), name: .dkLayerGroupDidAddLayer, object: self.drawing)
		NotificationCenter.default.addObserver(self, selector: #selector(GCSLayersPaletteController.drawingDidReorderLayersNotification(_:)), name: .dkLayerGroupDidRemoveLayer, object: self.drawing)
		NotificationCenter.default.addObserver(self, selector: #selector(DKDrawkitInspectorBase.layerDidChange(_:)), name: .dkLayerVisibleStateDidChange, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(DKDrawkitInspectorBase.layerDidChange(_:)), name: .dkLayerLockStateDidChange, object: nil)
		
		// position the palette at the right hand edge of the screen

		var panelFrame = window!.frame
		let screenFrame = NSScreen.screens[0].visibleFrame
		
		panelFrame.origin.x = screenFrame.maxX - panelFrame.width - 20
		window?.setFrameOrigin(panelFrame.origin)
		
		// select the active layer in the table

		if let drawing = self.drawing {
			let row: Int
			if let activeLayer = drawing.activeLayer {
				row = drawing.index(of: activeLayer)
			} else {
				row = NSNotFound
			}
			
			if row != NSNotFound {
				layersTable.selectRowIndexes(IndexSet(integer: row), byExtendingSelection: false)
			}
		}
		
		// allow row-drag reordering
		layersTable.registerForDraggedTypes([.dkTableRowInternalDrag])
		window?.title = "\(NSApp.mainWindow?.title ?? "hi") - Layers"

		// ready to go - set delegate. This isn't set in the nib to avoid the race condition that occurs due to the delegate getting a premature
		// selection change notification while awaking from nib that incorrectly switches the active layer to index #0.
		
		layersTable.delegate = self
	}
	
	override var windowNibName: NSNib.Name? {
		return NSNib.Name("LayersPalette")
	}
}

// MARK: -

extension GCSLayersPaletteController: NSTableViewDataSource, NSTableViewDelegate {
	
	// MARK: As an NSTableView delegate
	
	func tableViewSelectionDidChange(_ aNotification: Notification) {
		if (aNotification.object as AnyObject?) === layersTable {
			let row = layersTable.selectedRow
			
			LogEvent(.reactiveEvent, "layer selection changed to \(row)");
			
			if row != -1, let drawing = self.drawing {
				drawing.setActiveLayer(drawing.objectInLayers(at: row))
			}
		}
	}
	
	func tableView(_ tableView: NSTableView, willDisplayCell cell: Any, for tableColumn: NSTableColumn?, row: Int) {
		if tableColumn?.identifier.rawValue == "name" {
			var font = ((cell as? NSCell)?.font) ?? NSFont.systemFont(ofSize: NSFont.systemFontSize)
			let fontColor: NSColor
			if tableView.selectedRowIndexes.contains(row), tableView.editedRow != row {
				fontColor = NSColor.white
				//shadowColor = [NSColor colorWithDeviceRed:(127.0/255.0) green:(140.0/255.0) blue:(160.0/255.0) alpha:1.0];
				
				font = NSFontManager.shared.convert(font, toHaveTrait: .boldFontMask)
				(cell as? NSCell)?.font = font
			} else {
				fontColor = NSColor.black
				//shadowColor = nil;

				font = NSFontManager.shared.convert(font, toHaveTrait: .boldFontMask)
				(cell as? NSCell)?.font = font
			}
			(cell as? NSTextFieldCell)?.textColor = fontColor
			/*
			NSShadow *shad = [[NSShadow alloc] init];
			NSSize shadowOffset = { width: 1.0, height: -1.5};
			[shad setShadowOffset:shadowOffset];
			[shad setShadowColor:shadowColor];
			[shad set];
			*/
		}
	}
	
	// MARK: - As part of NSTableDataSource Protocol

	func numberOfRows(in tableView: NSTableView) -> Int {
		return drawing?.countOfLayers ?? 0
	}
	
	func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableView.DropOperation) -> Bool {
		let pboard = info.draggingPasteboard()
		if let rowData = pboard.data(forType: .dkTableRowInternalDrag),
			let rowIndexes = NSKeyedUnarchiver.unarchiveObject(with: rowData) as? IndexSet,
			let dragRow = rowIndexes.first,
			let drawing = drawing {
			let layer = drawing.objectInLayers(at: dragRow)
			
			drawing.moveLayer(layer, to: row)
			(drawing.undoManager as AnyObject?)?.setActionName(NSLocalizedString("Reorder Layers", comment: ""))
			return true
		}
		return false
	}
	
	func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
		let layer = drawing?.objectInLayers(at: row)
		var val = layer?.value(forKey: tableColumn?.identifier.rawValue ?? "")
		
		// hack - if a temporary colour is set for the requested row and column, return it instead of getting it from the drawing.
		// this permits the cutsom cells that display this colour in the table to update "live" without having to change the data model
		// which is potentially very expensive.
		if row == temporaryColourRow, let temporaryColor = temporaryColour, tableColumn?.identifier == selectionColourInterfaceIdentifier {
			val = temporaryColor
		}
		
		//NSLog(@"table value = %@", [val stringValue] );

		return val
	}
	
	func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
		let layer = drawing?.objectInLayers(at: row)
		layer?.setValue(object, forKey: tableColumn?.identifier.rawValue ?? "")
	}
	
	func tableView(_ aTableView: NSTableView, writeRowsWith indexes: IndexSet, to pb: NSPasteboard) -> Bool {
		let data = NSKeyedArchiver.archivedData(withRootObject: indexes)
		
		pb.declareTypes([.dkTableRowInternalDrag], owner: self)
		pb.setData(data, forType: .dkTableRowInternalDrag)
		return true
	}
	
	func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableView.DropOperation) -> NSDragOperation {
		return .every
	}
}
