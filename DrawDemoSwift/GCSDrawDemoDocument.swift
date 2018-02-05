//
//  GCSDrawDemoDocument.swift
//  DrawDemoSwift
//
//  Created by C.W. Betts on 12/14/17.
//  Copyright © 2017 DrawKit. All rights reserved.
//

import Cocoa
import DKDrawKit
import DKDrawKit.DKDrawing.Export
import DrawKitSwift

final class DrawDemoDocument: DKDrawingDocument, GCSPolarDuplicationDelegate, GCSExportControllerDelegate, GCSLinearDuplicationDelegate {
	
	@IBOutlet weak var toolNamePanelController: GCSBasicDialogController?
	@IBOutlet weak var polarDuplicateController: GCSPolarDuplicateController?
	@IBOutlet weak var linearDuplicateController: GCSLinearDuplicateController?
	@IBOutlet weak var exportController: GCSExportOptionsController?
	var drawingSizeController: GCSDrawingSizeController?

	static var defaultQualityModulation: Bool = false {
		didSet {
			// also push the setting out to all current documents

			for doc in NSDocumentController.shared.documents {
				if let doc2 = doc as? DKDrawingDocument {
					doc2.drawing.dynamicQualityModulationEnabled = defaultQualityModulation
				}
			}
		}
	}

	override class var autosavesInPlace: Bool {
		return true
	}
	
	func askUserForToolName() -> String? {
		// this method needs redoing for Leopard, but is not currently used anyway
		
		// displays the tool naming sheet, handles it, and returns the entered name (or nil, if the dialog was cancelled or no name entered)
		/*
		NSString* s = nil;
		
		int result = [mToolNamePanelController runModalWithParentWindow:[self windowForSheet]];
		
		if ( result == NSOKButton )
		s = [[mToolNamePanelController primaryItem] stringValue];
		
		return s;
		*/
		
		return nil
	}
	
	/// allows a single selected shape in the active layer to be turned into a named tool. If the selection is valid, this then asks the user
	/// for a name for the tool.
	@IBAction func makeToolFromSelectedShape(_ sender: Any?) {
		guard let layer = drawing.activeLayer(of: DKObjectDrawingLayer.self) else {
			return
		}
		
		if layer.isSingleObjectSelected, layer.selectionContainsObject(of: DKDrawableShape.self) {
			let shape = layer.singleSelection as! DKDrawableShape
			
			// ok, got an object that can be turned into a tool, so ask the user to name it.

			if let toolName = askUserForToolName() {
				DKObjectCreationTool.registerDrawingTool(forObject: shape, withName: toolName)
			}
		}
	}
	
	// MARK: -
	
	@IBAction func polarDuplicate(_ sender: Any?) {
		polarDuplicateController?.beginPolarDuplicationDialog(windowForSheet!, polarDelegate: self)
	}
	
	@IBAction func linearDuplicate(_ sender: Any?) {
		linearDuplicateController?.beginLinearDuplicationDialog(windowForSheet!, linearDelegate: self)
	}
	
	@IBAction func openDrawingSizePanel(_ sender: Any?) {
		if drawingSizeController == nil {
			drawingSizeController = GCSDrawingSizeController(windowNibName: NSNib.Name(rawValue: "Drawingsize"))
		}
		
		drawingSizeController?.beginDrawingSizeDialog(windowForSheet!, with: drawing)
	}
	
	@IBAction func exportAction(_ sender: Any?) {
		exportController?.beginExportDialog(withParentWindow: windowForSheet!, delegate: self)
	}
	
	// MARK: -
	@IBAction func test(_ sender: Any?) {
		
	}
	
	// MARK: - As an DKDrawingDocument
	override var drawing: DKDrawing {
		didSet {
			drawing.dynamicQualityModulationEnabled = DrawDemoDocument.defaultQualityModulation
		}
	}
	
	// MARK: - As an NSDocument
	override var windowNibName: NSNib.Name? {
		return NSNib.Name("GCSDrawDemoDocument")
	}
	
	override func windowControllerDidLoadNib(_ aController: NSWindowController) {
		// zoom the window to max size initially
		// call super to ensure correct establishment of model-view-controller within the DK internals
		
		super.windowControllerDidLoadNib(aController)
		aController.window?.zoom(self)
	}
	
	// MARK: - As a PolarDuplication delegate
	var countOfItemsInSelection: Int {
		if let odl = drawing.activeLayer(of: DKObjectDrawingLayer.self) {
			return odl.selectedAvailableObjects.count
		} else {
			return 0
		}
	}
	
	func performExport(type fileType: GCSExportFileTypes, withOptions options: [NSBitmapImageRep.PropertyKey : Any]) {
		guard let url = options[.gcExportedFileURL] as? URL else {
			return
		}
		
		LogEvent(.fileEvent, "exporting file to URL ‘\(url)’")
		
		var saveGrid = false
		let drawGrid = options[.gcIncludeGridInExportedFile] as? Bool ?? false
		var data: Data?
		if drawGrid {
			saveGrid = drawing.gridLayer?.shouldDrawToPrinter ?? false
			drawing.gridLayer?.shouldDrawToPrinter = true
		}
		
		switch fileType {
		case .JPEG:
			data = drawing.jpegData(withProperties: options)
			
		case .TIFF:
			data = drawing.tiffData(withProperties: options)
			
		case .PNG:
			data = drawing.pngData(withProperties: options)
			
		default:
			data = drawing.pdf()
		}
		
		if drawGrid {
			drawing.gridLayer?.shouldDrawToPrinter = saveGrid;
		}
		
		if let data = data, data.count > 0 {
			do {
				try data.write(to: url)
			} catch {
				presentError(error)
			}
		}
	}
	
	/// callback from dialog. Locate the selection and use the object drawing layer method to do the deed. Note - centre is passed
	/// in grid coordinates so needs converting to the drawing, and the angle is in degrees and needs converting to radians.
	func doPolarDuplicateCopies(_ copies: Int, centre cp: NSPoint, incAngle angle: CGFloat, rotateCopies rotCopies: Bool) {
		guard let odl = drawing.activeLayer(of: DKObjectDrawingLayer.self) else {
			return
		}
		let target = odl.selectedAvailableObjects
		guard target.count > 0 else {
			return
		}
		
		// convert the units
		let radians = (angle * .pi) / 180.0
		
		let grid = drawing.gridLayer!
		let drawingPt = grid.point(forGridLocation: cp)
		
		let newCopies = odl.polarDuplicate(target, centre: drawingPt, numberOfCopies: copies, incrementAngle: radians, rotateCopies: rotCopies)
		
		// add newCopies to the layer and select them
		if let newCopies = newCopies, newCopies.count > 0 {
			odl.recordSelectionForUndo()
			odl.addObjects(from: newCopies)
			odl.exchangeSelectionWithObjects(from: newCopies)
			odl.commitSelectionUndo(withActionName: NSLocalizedString("Polar Duplication", comment: "polar dupe undo string"))
		}
	}
	
	func doAutoPolarDuplicate(withCentre cp: NSPoint) {
		guard let odl = drawing.activeLayer(of: DKObjectDrawingLayer.self), let target = odl.singleSelection else {
			return
		}
		
		let grid = drawing.gridLayer
		let drawingPt = grid?.point(forGridLocation: cp) ?? .zero
		let newCopies = odl.autoPolarDuplicate(target, centre: drawingPt)
		
		// add newCopies to the layer and select them
		
		if let newCopies = newCopies, newCopies.count > 0 {
			odl.recordSelectionForUndo()
			odl.addObjects(from: newCopies)
			odl.exchangeSelectionWithObjects(from: newCopies)
			odl.commitSelectionUndo(withActionName: NSLocalizedString("Auto Polar Duplication", comment: "auto dupe undo string"))
		}
	}
	
	// MARK: - As a LinearDuplication delegate
	func doLinearDuplicateCopies(_ copies: Int, offset: NSSize) {
		guard let odl = drawing.activeLayer(of: DKObjectDrawingLayer.self) else {
			return
		}
		let target = odl.selectedAvailableObjects
		guard target.count > 0 else {
			return
		}
		// convert the units

		let grid = drawing.gridLayer!
		let drawingOffset = NSSize(width: grid.quartzDistance(forGridDistance: offset.width), height: grid.quartzDistance(forGridDistance: offset.height))
		
		let newCopies = odl.linearDuplicate(target, offset: drawingOffset, numberOfCopies: copies)

		// add newCopies to the layer and select them
		if let newCopies = newCopies, newCopies.count > 0 {
			odl.recordSelectionForUndo()
			odl.addObjects(from: newCopies)
			odl.exchangeSelectionWithObjects(from: newCopies)
			odl.commitSelectionUndo(withActionName: NSLocalizedString("Linear Duplication", comment: "linear dupe undo string"))
		}
	}

	// MARK: - As part of NSMenuValidation  Protocol
	override func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
		var enable = true
		let action = menuItem.action
		
		if action == #selector(DrawDemoDocument.linearDuplicate(_:)) {
			enable = countOfItemsInSelection > 0
		} else if action == #selector(DrawDemoDocument.polarDuplicate(_:)) || action == #selector(DKDrawingDocument.newLayerWithSelection(_:)) {
			enable = countOfItemsInSelection > 0
		}
		
		return enable
	}
}
