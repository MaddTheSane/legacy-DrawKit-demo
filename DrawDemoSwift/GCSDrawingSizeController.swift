//
//  GCSDrawingSizeController.swift
//  DrawDemoSwift
//
//  Created by C.W. Betts on 12/15/17.
//  Copyright © 2017 DrawKit. All rights reserved.
//

import Cocoa
import DKDrawKit
import DKDrawKit.DKDrawing
import DKDrawKit.DKGridLayer
import DKDrawKit.DKCategoryManager
import DKDrawKit.DKStyleRegistry
import DrawKitSwift

private let units: [(name: DKDrawingUnits, factor: CGFloat)] = [(.pixels, 1), (.picas, 12), (.inches, 72.0), (.millimetres, 2.8346456692913), (.centimetres, 28.346456692913), (.metres, 2834.6456692913), (.kilometres, 28346.456692913)]

final class GCSDrawingSizeController: NSWindowController, GCSBasicDialogDelegate {
	@IBOutlet weak var bottomMarginTextField: NSTextField!
	@IBOutlet weak var gridDivsTextField: NSTextField!
	@IBOutlet weak var gridMajorsTextField: NSTextField!
	@IBOutlet weak var gridPreviewCheckbox: NSButton!
	@IBOutlet weak var gridSpanTextField: NSTextField!
	@IBOutlet weak var gridThemeColourWell: NSColorWell!
	@IBOutlet weak var heightTextField: NSTextField!
	@IBOutlet weak var leftMarginTextField: NSTextField!
	@IBOutlet weak var rightMarginTextField: NSTextField!
	@IBOutlet weak var topMarginTextField: NSTextField!
	@IBOutlet weak var tweakMarginsCheckbox: NSButton!
	@IBOutlet weak var unitsComboBox: NSComboBox!
	@IBOutlet weak var widthTextField: NSTextField!
	@IBOutlet weak var gridControlsBox: NSBox!
	@IBOutlet weak var gridDivsSpinControl: NSStepper!
	@IBOutlet weak var gridMajorsSpinControl: NSStepper!
	@IBOutlet weak var gridAbbrevUnitsText: NSTextField!
	@IBOutlet weak var gridPrintCheckbox: NSButton!
	@IBOutlet weak var gridRulerStepsTextField: NSTextField!
	@IBOutlet weak var gridRulerStepsSpinControl: NSStepper!
	@IBOutlet weak var conversionFactorTextField: NSTextField!
	@IBOutlet weak var conversionFactorSpinControl: NSStepper!
	@IBOutlet weak var conversionFactorLabelText: NSTextField!
	@IBOutlet weak var paperColourWell: NSColorWell!
	
	var drawing: DKDrawing?
	var livePreview = false
	@objc dynamic var unitConversionFactor: CGFloat = 1
	var savedSpan: CGFloat = 1
	var savedCF: CGFloat = 1
	var savedDivs = 1
	var savedMajors = 0
	var savedUnits: DKDrawingUnits?
	var savedGridColour: NSColor?
	var savedPaperColour: NSColor?
	private weak var parent: NSWindow?
	
	@objc(beginDrawingSizeDialog:withDrawing:)
	func beginDrawingSizeDialog(_ parent: NSWindow, with drawing: DKDrawing) {
		self.drawing = drawing
		unitConversionFactor = drawing.unitToPointsConversionFactor
		savedCF = unitConversionFactor
		
		// save off the current grid settings in case we cancel:
		savedPaperColour = drawing.paperColour
		
		if let grid = drawing.gridLayer {
			savedSpan = grid.spanDistance
			savedDivs = Int(grid.divisions)
			savedMajors = Int(grid.majors)
			savedGridColour = grid.spanColour
			savedUnits = drawing.drawingUnits
		}
		
		_=self.window
		unitsComboBox.stringValue = drawing.drawingUnits.rawValue
		conversionFactorLabelText.stringValue = "1 \(drawing.drawingUnits.rawValue) occupies"
		prepareDialog(with: drawing)
		
		self.parent = parent
		parent.beginSheet(self.window!) { (returnCode) in
			self.sheetDidEnd(self.window!, returnCode: returnCode, contextInfo: nil)
			self.parent = nil
		}
	}
	
	@IBAction func cancelAction(_ sender: Any?) {
		window?.orderOut(self)
		parent?.endSheet(window!, returnCode: .cancel)
	}
	
	@IBAction func gridDivsAction(_ sender: AnyObject?) {
		let newDivs: Int = {
			if let newInt = sender?.integerValue {
				return newInt
			}
			return 1
		}()

		
		if livePreview, let drawing = self.drawing, let grid = drawing.gridLayer {
			let span = grid.spanDistance / unitConversionFactor
			let majs = grid.majors
			
			grid.setDistanceForUnitSpan(unitConversionFactor, drawingUnits: drawing.drawingUnits, span: span, divisions: newDivs, majors: majs, rulerSteps: gridRulerStepsTextField.integerValue)
		}
		
		if sender === gridDivsSpinControl {
			gridDivsTextField.integerValue = newDivs
		} else {
			gridDivsSpinControl.integerValue = newDivs
		}
	}
	
	@IBAction func gridMajorsAction(_ sender: AnyObject?) {
		let newInt: Int = {
			if let sendInt = sender?.integerValue {
				return sendInt
			}
			return 1
		}()
		
		if livePreview, let drawing = self.drawing, let grid = drawing.gridLayer {
			let span = grid.spanDistance / unitConversionFactor
			let divs = grid.divisions
			
			grid.setDistanceForUnitSpan(unitConversionFactor, drawingUnits: drawing.drawingUnits, span: span, divisions: divs, majors: newInt, rulerSteps: gridRulerStepsTextField.integerValue)
		}
		
		if sender === gridMajorsSpinControl {
			gridMajorsTextField.integerValue = newInt
		} else {
			gridMajorsSpinControl.integerValue = newInt
		}
	}
	
	@IBAction func gridSpanAction(_ sender: Any?) {
		if livePreview, let drawing = self.drawing, let grid = drawing.gridLayer {
			let divs = grid.divisions
			let majs = grid.majors
			
			let spanVal: CGFloat = {
				guard let dv = (sender as AnyObject?)?.doubleValue else {
					return 1
				}
				return CGFloat(dv)
			}()
			
			grid.setDistanceForUnitSpan(unitConversionFactor, drawingUnits: drawing.drawingUnits, span: spanVal, divisions: divs, majors: majs, rulerSteps: gridRulerStepsTextField.integerValue)
		}
	}
	
	@IBAction func gridRulerStepsAction(_ sender: AnyObject?) {
		let newSteps: Int = {
			if let newVal = sender?.integerValue {
				return newVal
			}
			return 1
		}()
		
		if livePreview, let grid = drawing?.gridLayer {
			grid.rulerSteps = newSteps
		}
		
		if sender === gridRulerStepsSpinControl {
			gridRulerStepsTextField.integerValue = newSteps
		} else {
			gridRulerStepsSpinControl.integerValue = newSteps
		}
	}
	
	@IBAction func gridThemeColourAction(_ sender: NSColorWell?) {
		if livePreview, let grid = drawing?.gridLayer {
			grid.setGridThemeColour(sender!.color)
		}
	}
	
	@IBAction func gridPrintAction(_ sender: NSButton?) {
		drawing?.gridLayer?.shouldDrawToPrinter = sender?.state == .on
	}
	
	@IBAction func livePreviewAction(_ sender: NSButton?) {
		livePreview = sender?.state == .on
	}
	
	@IBAction func okAction(_ sender: Any?) {
		window?.orderOut(self)
		parent?.endSheet(window!, returnCode: .OK)
	}
	
	@IBAction func unitsComboBoxAction(_ sender: AnyObject?) {
		let strVal = sender?.stringValue ?? ""
		
		let indx = unitsComboBox.indexOfItem(withObjectValue: strVal)
		
		if indx == NSNotFound {
			unitConversionFactor = 1
		} else {
			unitConversionFactor = units[indx].factor
		}
		
		conversionFactorLabelText.stringValue = "1 \(strVal) occupies"
		drawing?.setDrawingUnits(DKDrawingUnits(rawValue: strVal), unitToPointsConversionFactor: unitConversionFactor)
		
		if livePreview {
			drawing?.gridLayer?.synchronizeRulers()
		}
		
		self.prepareDialog(with: drawing!)
	}
	
	@IBAction func conversionFactorAction(_ sender: AnyObject?) {
		let oldUCF = unitConversionFactor
		
		let newConvFact: CGFloat = {
			if let doub = sender?.doubleValue {
				return CGFloat(doub)
			}
			return oldUCF
		}()
		unitConversionFactor = newConvFact
		
		if sender === conversionFactorSpinControl {
			conversionFactorTextField.objectValue = newConvFact
		} else {
			conversionFactorSpinControl.objectValue = newConvFact
		}
		
		if livePreview, let grid = drawing?.gridLayer {
			let divs = grid.divisions
			let majs = grid.majors
			let span = grid.spanDistance / oldUCF
			
			grid.setDistanceForUnitSpan(unitConversionFactor, drawingUnits: drawing!.drawingUnits, span: span, divisions: divs, majors: majs, rulerSteps: gridRulerStepsTextField.integerValue)
		}
	}
	
	@IBAction func paperColourAction(_ sender: NSColorWell?) {
		if livePreview {
			drawing?.paperColour = sender?.color
		}
	}
	
	override func windowDidLoad() {
        super.windowDidLoad()
		
		livePreview = true
		setUpComboBox(currentUnit: drawing!.drawingUnits)
		unitsComboBox.stringValue = drawing?.drawingUnits.rawValue ?? ""
		conversionFactorLabelText.stringValue = "1 \(drawing!.drawingUnits.rawValue) occupies"
		//[self prepareDialogWithDrawing:mDrawing];
	}
	
	/// set up the dialog elements with the current drawing settings
	func prepareDialog(with drawing: DKDrawing) {
		let size = drawing.drawingSize
		
		widthTextField.objectValue = size.width / unitConversionFactor
		heightTextField.objectValue = size.height / unitConversionFactor
		
		topMarginTextField.objectValue = drawing.topMargin / unitConversionFactor;
		leftMarginTextField.objectValue = drawing.leftMargin / unitConversionFactor;
		rightMarginTextField.objectValue = drawing.rightMargin / unitConversionFactor;
		bottomMarginTextField.objectValue = drawing.bottomMargin / unitConversionFactor;
		
		conversionFactorTextField.objectValue = unitConversionFactor
		conversionFactorSpinControl.objectValue = unitConversionFactor
		paperColourWell.color = drawing.paperColour ?? .white

		if let grid = drawing.gridLayer {
			gridSpanTextField.objectValue = grid.spanDistance / unitConversionFactor;
			gridDivsTextField.integerValue = Int(grid.divisions);
			gridDivsSpinControl.integerValue = Int(grid.divisions);
			gridMajorsTextField.integerValue = Int(grid.majors);
			gridMajorsSpinControl.integerValue = Int(grid.majors);
			gridThemeColourWell.color = grid.spanColour;
			gridPrintCheckbox.state = grid.shouldDrawToPrinter ? .on : .off
			gridAbbrevUnitsText.stringValue = drawing.abbreviatedDrawingUnits;
			gridRulerStepsTextField.integerValue = Int(grid.rulerSteps);
			gridRulerStepsSpinControl.integerValue = Int(grid.rulerSteps);

			gridPreviewCheckbox.state = livePreview ? .on : .off
		}
	}
	
	/// populate the combobox with default units
	func setUpComboBox(currentUnit: DKDrawingUnits) {
		unitsComboBox.hasVerticalScroller = false
		unitsComboBox.addItems(withObjectValues: units.map({$0.name.rawValue}))
		unitsComboBox.numberOfVisibleItems = units.count
	}
	
	func sheetDidEnd(_ sheet: NSWindow, returnCode: NSApplication.ModalResponse, contextInfo: UnsafeMutableRawPointer?) {
		if returnCode == NSApplication.ModalResponse.OK {
			// apply the settings to the drawing.
			
			let dwgSize = NSSize(width: ((widthTextField.objectValue as? NSNumber as? CGFloat ) ?? 0) * unitConversionFactor, height: ((heightTextField.objectValue as? NSNumber as? CGFloat ) ?? 0) * unitConversionFactor)
			
			let t = ((topMarginTextField.objectValue as? NSNumber as? CGFloat ) ?? 0) * unitConversionFactor
			let l = ((leftMarginTextField.objectValue as? NSNumber as? CGFloat ) ?? 0) * unitConversionFactor
			let b = ((bottomMarginTextField.objectValue as? NSNumber as? CGFloat ) ?? 0) * unitConversionFactor
			let r = ((rightMarginTextField.objectValue as? NSNumber as? CGFloat ) ?? 0) * unitConversionFactor
			drawing?.drawingSize = dwgSize
			drawing?.margins = (l, t, b, r)
			drawing?.setDrawingUnits(DKDrawingUnits(rawValue: unitsComboBox.stringValue), unitToPointsConversionFactor: unitConversionFactor)
			drawing?.paperColour = paperColourWell.color
			
			if let grid = drawing?.gridLayer {
				let span = CGFloat(gridSpanTextField.doubleValue) * unitConversionFactor
				let divs = gridDivsTextField.integerValue
				let majs = gridMajorsTextField.integerValue
				
				grid.setDistanceForUnitSpan(span, drawingUnits: DKDrawingUnits(unitsComboBox.stringValue), span: 1, divisions: divs, majors: majs, rulerSteps: gridRulerStepsTextField.integerValue)
				
				if tweakMarginsCheckbox.state == .on {
					grid.tweakDrawingMargins()
				}
				
				grid.setGridThemeColour(gridThemeColourWell.color)
			}
			
			drawing?.setNeedsDisplay(true)
		} else if returnCode == NSApplication.ModalResponse.cancel {
			// restore saved grid settings
			
			if let grid = drawing?.gridLayer {
				grid.setDistanceForUnitSpan(savedSpan, drawingUnits: savedUnits!, span: 1, divisions: savedDivs, majors: savedMajors, rulerSteps: 2)
				
				grid.setGridThemeColour(savedGridColour!)
			}
			
			drawing?.paperColour = savedPaperColour
		}
	}
}
