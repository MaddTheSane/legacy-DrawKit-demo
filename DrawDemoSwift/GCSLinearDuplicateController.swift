//
//  GCSLinearDuplicateController.swift
//  DrawDemoSwift
//
//  Created by C.W. Betts on 1/26/18.
//  Copyright © 2018 DrawKit. All rights reserved.
//

import Cocoa

protocol GCSLinearDuplicationDelegate: NSObjectProtocol {
	func doLinearDuplicateCopies(_ copies: Int, offset: NSSize)
	var countOfItemsInSelection: Int { get }
}


class GCSLinearDuplicateController: NSWindowController {
	@IBOutlet weak var numberOfCopiesTextField: NSTextField!
	@IBOutlet weak var xOffsetTextField: NSTextField!
	@IBOutlet weak var yOffsetTextField: NSTextField!
	@IBOutlet weak var okButton: NSButton!
	
	private weak var parentWindow: NSWindow?

	@IBAction func numberOfCopiesAction(_ sender: Any?) {
		conditionallyEnableOKButton()
	}
	
	@IBAction func xyOffsetAction(_ sender: Any?) {
		conditionallyEnableOKButton()
	}
	
	@IBAction func okAction(_ sender: Any?) {
		window?.orderOut(self)
		parentWindow?.endSheet(window!, returnCode: .OK)
	}
	
	@IBAction func cancelAction(_ sender: Any?) {
		window?.orderOut(self)
		parentWindow?.endSheet(window!, returnCode: .cancel)
	}

	func beginLinearDuplicationDialog(_ parentWindow: NSWindow, linearDelegate delegate: GCSLinearDuplicationDelegate) {
		self.parentWindow = parentWindow
		
		parentWindow.beginSheet(window!) { (returnCode) in
			if returnCode == .OK {
				// extract parameters and do something with them
				let copies = self.numberOfCopiesTextField.integerValue
				
				let offset = NSSize(width: self.xOffsetTextField.objectValue as? CGFloat ?? 0, height: self.yOffsetTextField.objectValue as? CGFloat ?? 0)
				
				LogEvent(.reactiveEvent, String(format: "dialog data: copies %d; offset {%.2f,%.2f}", copies, offset.width, offset.height))
				
				delegate.doLinearDuplicateCopies(copies, offset: offset)
			}
			self.parentWindow = nil
		}
		
		conditionallyEnableOKButton()
	}

	private func conditionallyEnableOKButton() {
		if numberOfCopiesTextField.stringValue == "" || xOffsetTextField.stringValue == "" || yOffsetTextField.stringValue == "" {
			okButton.isEnabled = false
		} else {
			okButton.isEnabled = true
		}
	}
}
