//
//  GCSPolarDuplicateController.swift
//  DrawDemoSwift
//
//  Created by C.W. Betts on 1/25/18.
//  Copyright © 2018 DrawKit. All rights reserved.
//

import Foundation

protocol GCSPolarDuplicationDelegate: NSObjectProtocol {
	func doPolarDuplicateCopies(_ copies: Int, centre cp: NSPoint, incAngle angle: CGFloat, rotateCopies rotCopies: Bool)
	func doAutoPolarDuplicate(withCentre cp: NSPoint)
	var countOfItemsInSelection: Int { get }
}

class GCSPolarDuplicateController: NSWindowController {
	@IBOutlet weak var angleIncrementTextField: NSTextField!
	@IBOutlet weak var centreXTextField: NSTextField!
	@IBOutlet weak var centreYTextField: NSTextField!
	@IBOutlet weak var copiesTextField: NSTextField!
	@IBOutlet weak var rotateCopiesCheckbox: NSButton!
	@IBOutlet weak var autoFitCircleCheckbox: NSButton!
	@IBOutlet weak var okButton: NSButton!
	@IBOutlet weak var cancelButton: NSButton!
	@IBOutlet weak var manualSettingsBox: NSBox!
	
	private weak var parentWindow: NSWindow?
	
	@IBAction open func angleAction(_ sender: Any?) {
		// empty
	}
	
	@IBAction open func cancelAction(_ sender: Any?) {
		window?.orderOut(self)
		parentWindow?.endSheet(window!, returnCode: .cancel)
	}
	
	@IBAction open func centreAction(_ sender: Any?) {
		// disable the OK button if either of the centre fields are empty
		conditionallyEnableOKButton()
	}
	
	@IBAction open func copiesAction(_ sender: Any?) {
		// empty
	}
	
	@IBAction open func duplicateAction(_ sender: Any?) {
		window?.orderOut(self)
		parentWindow?.endSheet(window!, returnCode: .OK)
	}
	
	@IBAction open func rotateCopiesAction(_ sender: Any?) {
		// empty
	}
	
	@IBAction open func autoFitAction(_ sender: Any?) {
		let enable: Bool = {
			guard let state: NSControl.StateValue = (sender as AnyObject?)?.state else {
				return false
			}
			return state == .on
		}()
		
		//[mManualSettingsBox setEnabled:enable];

		angleIncrementTextField.isEnabled = enable
		copiesTextField.isEnabled = enable
		rotateCopiesCheckbox.state = .on
		rotateCopiesCheckbox.isEnabled = enable
	}

	func beginPolarDuplicationDialog(_ parentWindow: NSWindow, polarDelegate delegate: GCSPolarDuplicationDelegate) {
		self.parentWindow = parentWindow
		
		parentWindow.beginSheet(self.parentWindow!) { (returnCode) in
			if returnCode == .OK {
				// extract parameters and do something with them
				let copies = self.copiesTextField.integerValue
				
				let centre = NSPoint(x: self.centreXTextField.objectValue as? CGFloat ?? 0, y: self.centreYTextField.objectValue as? CGFloat ?? 0)
				
				let incAngle = self.angleIncrementTextField.objectValue as? CGFloat ?? 0
				let rotCopies = self.rotateCopiesCheckbox.state == .on
				
				if self.autoFitCircleCheckbox.state == .on {
					delegate.doAutoPolarDuplicate(withCentre: centre)
				} else {
					LogEvent(.reactiveEvent, String(format: "dialog data: copies %ld; centre {%.2f,%.2f}; incAngle %.3f; rotateCopies %d", copies, centre.x, centre.y, rotCopies ? 1 : 0))
					
					delegate.doPolarDuplicateCopies(copies, centre: centre, incAngle: incAngle, rotateCopies: rotCopies)
				}
			}
			self.parentWindow = nil
		}
		
		let items = delegate.countOfItemsInSelection
		autoFitCircleCheckbox.isEnabled = items == 1
		conditionallyEnableOKButton()
	}
	
	private func conditionallyEnableOKButton() {
		if centreXTextField.stringValue == "" || centreYTextField.stringValue == "" {
			okButton.isEnabled = false
		} else {
			okButton.isEnabled = true
		}
	}
}
