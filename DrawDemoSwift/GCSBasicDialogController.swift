//
//  GCSBasicDialogController.swift
//  DrawDemoSwift
//
//  Created by C.W. Betts on 1/26/18.
//  Copyright © 2018 DrawKit. All rights reserved.
//
//  Released under the Creative Commons license 2006 Apptree.net.
//
//
//  This work is licensed under the Creative Commons Attribution-ShareAlike 2.5 License.
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/2.5/ or send a letter to
//  Creative Commons, 543 Howard Street, 5th Floor, San Francisco, California, 94105, USA.
//

import Cocoa

/// Basic controller handles dialogs with OK, Cancel and one primary item.
class GCSBasicDialogController: NSWindowController {
	@IBOutlet weak var okButton: NSButton!
	@IBOutlet weak var cancelButton: NSButton!
	@IBOutlet weak var primaryItem: NSTextField!
	
	private var mRunningAsSheet = false
	private weak var parentWindow: NSWindow?
	
	func runModal() -> NSApplication.ModalResponse {
		mRunningAsSheet = false
		
		let result = NSApp.runModal(for: window!)
		
		window?.orderOut(self)
		
		return result
	}
	
	func runAsSheet(inParentWindow parent: NSWindow, completionHandler: @escaping (NSApplication.ModalResponse) -> Void) {
		mRunningAsSheet = true
		parentWindow = parent
		
		parent.beginSheet(window!) { (toRet) in
			completionHandler(toRet)
			self.parentWindow = nil
		}
	}

	@available(*, deprecated)
	func runAsSheet(inParentWindow parent: NSWindow, modalDelegate delegate: GCSBasicDialogDelegate) {
		
		runAsSheet(inParentWindow: parent) { (aRet) in
			let unman = Unmanaged.passUnretained(self)
			delegate.sheetDidEnd(self.window!, returnCode: aRet, contextInfo: unman.toOpaque())
		}
	}

	
	@IBAction func ok(_ sender: Any?) {
		if mRunningAsSheet {
			window?.orderOut(self)
			parentWindow?.endSheet(window!, returnCode: .OK)
		} else {
			NSApp.stopModal(withCode: .OK)
		}
	}
	
	@IBAction func cancel(_ sender: Any?) {
		if mRunningAsSheet {
			window?.orderOut(self)
			parentWindow?.endSheet(window!, returnCode: .cancel)
		} else {
			NSApp.stopModal(withCode: .cancel)
		}
	}
	
	@IBAction func primaryItemAction(_ sender: Any?) {
		
	}
}
